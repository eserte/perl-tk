/*
 * tkImgPS.c --
 *
 * A photo image file handler for postscript files.
 *
 */

/* Author : Jan Nijtmans */
/* Date   : 7/24/97        */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "imgInt.h"

/*
 * The format record for the PS file format:
 */

static int ChnMatchPS _ANSI_ARGS_((Tcl_Channel chan, char *fileName,
	char *formatString, int *widthPtr, int *heightPtr));
static int FileMatchPS _ANSI_ARGS_((FILE *f, char *fileName,
	char *formatString, int *widthPtr, int *heightPtr));
static int ObjMatchPS _ANSI_ARGS_((struct Tcl_Obj *dataObj,
	char *formatString, int *widthPtr, int *heightPtr));
static int ChnReadPS _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Channel chan,
	char *fileName, char *formatString, Tk_PhotoHandle imageHandle,
	int destX, int destY, int width, int height, int srcX, int srcY));
static int FileReadPS _ANSI_ARGS_((Tcl_Interp *interp, FILE *f,
	char *fileName, char *formatString, Tk_PhotoHandle imageHandle,
	int destX, int destY, int width, int height, int srcX, int srcY));
static int ObjReadPS _ANSI_ARGS_((Tcl_Interp *interp, struct Tcl_Obj *dataObj,
	char *formatString, Tk_PhotoHandle imageHandle,
	int destX, int destY, int width, int height, int srcX, int srcY));
static int FileWritePS _ANSI_ARGS_((Tcl_Interp *interp, char *filename,
	char *formatString, Tk_PhotoImageBlock *blockPtr));
static int StringWritePS _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_DString *dataPtr, char *formatString,
	Tk_PhotoImageBlock *blockPtr));

Tk_PhotoImageFormat imgFmtPS = {
    "POSTSCRIPT",				/* name */
    (Tk_ImageFileMatchProc *) ChnMatchPS,	/* fileMatchProc */
    (Tk_ImageStringMatchProc *) ObjMatchPS,	/* stringMatchProc */
    (Tk_ImageFileReadProc *) ChnReadPS,		/* fileReadProc */
    (Tk_ImageStringReadProc *) ObjReadPS,	/* stringReadProc */
    FileWritePS,				/* fileWriteProc */
    (Tk_ImageStringWriteProc *) StringWritePS,	/* stringWriteProc */
};

Tk_PhotoImageFormat imgOldFmtPS = {
    "POSTSCRIPT",				/* name */
    (Tk_ImageFileMatchProc *) FileMatchPS,	/* fileMatchProc */
    (Tk_ImageStringMatchProc *) ObjMatchPS,	/* stringMatchProc */
    (Tk_ImageFileReadProc *) FileReadPS,	/* fileReadProc */
    (Tk_ImageStringReadProc *) ObjReadPS,	/* stringReadProc */
    FileWritePS,				/* fileWriteProc */
    (Tk_ImageStringWriteProc *) StringWritePS,	/* stringWriteProc */
};

/*
 * Prototypes for local procedures defined in this file:
 */

static int CommonMatchPS _ANSI_ARGS_((MFile *handle, char *formatString,
	int *widthPtr, int *heightPtr));
static int CommonReadPS _ANSI_ARGS_((Tcl_Interp *interp, MFile *handle,
	char *formatString, Tk_PhotoHandle imageHandle, int destX, int destY,
	int width, int height, int srcX, int srcY));
static int CommonWritePS _ANSI_ARGS_((Tcl_Interp *interp, MFile *handle,
	char *formatString, Tk_PhotoImageBlock *blockPtr));
static int parseFormat _ANSI_ARGS_((char *formatString, int *zoomx,
	int *zoomy));

static int parseFormat(formatString, zoomx, zoomy)
     char *formatString;
     int *zoomx;
     int *zoomy;
{
    int argc, i, length, index = 0;
    char **argv, *p;
    double zx = 1.0, zy = 1.0;

    if ((formatString == NULL) || (*formatString == '\0')) {
	*zoomx = *zoomy = 72;
	return 0;
    }
    if (Tcl_SplitList((Tcl_Interp*) NULL, formatString, &argc, &argv) != TCL_OK) {
	return -1;
    }
    for (i=1;i<argc;i++) {
	if ((argv[i][0] == '-') && ((i+1)<argc)) {
	    length = strlen(argv[i]);
	    if (length < 2) {
		index = -1; break;
	    }
	    if (!strncmp(argv[i],"-index", length)) {
		index = strtoul(argv[++i], &p, 0);
		if (*p) {
		    index = -1; break;
		}
	    } else if (!strncmp(argv[i],"-zoom", length)) {
		zx = strtod(argv[++i], &p);
		if (*p) {
		    index = -1; break;
		}
		if (((i+1)<argc) && (argv[i+1][0]!='-')) {
		    zy = strtod(argv[++i], &p);
		    if (*p) {
			index = -1; break;
		    }
		} else {
		    zy = zx;
		}
	    } else {
		index = -1; break;
	    }
	} else {
	    index = strtoul(argv[i], &p, 0);
	    if (*p) {
		index = -1; break;
	    }
	}
    }
    ckfree((char *) argv);
    if (!index) {
	*zoomx = (int) (72 * zx + 0.5);
	*zoomy = (int) (72 * zy + 0.5);
    }
    return index;
}

static int ChnMatchPS(chan, fileName, formatString, widthPtr, heightPtr)
    Tcl_Channel chan;
    char *fileName;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    MFile handle;

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    return CommonMatchPS(&handle, formatString, widthPtr, heightPtr);
}

static int FileMatchPS(f, fileName, formatString, widthPtr, heightPtr)
    FILE *f;
    char *fileName;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    MFile handle;

    handle.data = (char *) f;
    handle.state = IMG_FILE;

    return CommonMatchPS(&handle, formatString, widthPtr, heightPtr);
}

static int ObjMatchPS(dataObj, formatString, widthPtr, heightPtr)
    struct Tcl_Obj *dataObj;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    MFile handle;

    handle.data = ImgGetStringFromObj(dataObj, &handle.length);
    handle.state = IMG_STRING;

    return CommonMatchPS(&handle, formatString, widthPtr, heightPtr);
}

static int CommonMatchPS(handle, formatString, widthPtr, heightPtr)
    MFile *handle;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    unsigned char buf[41];

    if ((ImgRead(handle, (char *) buf, 11) != 11)
	    || (strncmp("%!PS-Adobe-", (char *) buf, 11) != 0)) {
	return 0;
    }
    while (ImgRead(handle,(char *) buf, 1) == 1) {
	if (buf[0] == '%' &&
		(ImgRead(handle, (char *) buf, 2) == 2) &&
		(!memcmp(buf, "%B", 2) &&
		(ImgRead(handle, (char *) buf, 11) == 11) &&
		(!memcmp(buf, "oundingBox:", 11)) &&
		(ImgRead(handle, (char *) buf, 40) == 40))) {
	    int w, h, zoomx, zoomy;
	    char *p = buf;
	    buf[41] = 0;
	    w = - strtoul(p, &p, 0);
	    h = - strtoul(p, &p, 0);
	    w += strtoul(p, &p, 0);
	    h += strtoul(p, &p, 0);
	    if (parseFormat(formatString, &zoomx, &zoomy) >= 0) {
		w = (w * zoomx + 36) / 72;
		h = (h * zoomy + 36) / 72;
	    }
	    if ((w <= 0) || (h <= 0)) return 0;
	    *widthPtr = w;
	    *heightPtr = h;
	    return 1;
	}
    }
    return 0;
}

static int ChnReadPS(interp, chan, fileName, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    Tcl_Channel chan;
    char *fileName;
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
    MFile handle;

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    return CommonReadPS(interp, &handle, formatString, imageHandle, destX, destY,
	    width, height, srcX, srcY);
}

static int FileReadPS(interp, f, fileName, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    FILE *f;
    char *fileName;
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
    MFile handle;

    handle.data = (char *) f;
    handle.state = IMG_FILE;

    return CommonReadPS(interp, &handle, formatString, imageHandle,
	    destX, destY, width,height,srcX,srcY);
}

static int ObjReadPS(interp, dataObj, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    struct Tcl_Obj *dataObj;
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
    MFile handle;

    handle.data = ImgGetStringFromObj(dataObj, &handle.length);
    handle.state = IMG_STRING;

    return CommonReadPS(interp, &handle, formatString, imageHandle, 
	    destX, destY, width, height, srcX, srcY);
}

typedef struct myblock {
    Tk_PhotoImageBlock ck;
    int dummy; /* extra space for offset[3], in case it is not
		  included already in Tk_PhotoImageBlock */
} myblock;

#define block bl.ck

static int CommonReadPS(interp, handle, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    MFile *handle;
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
#ifndef MAC_TCL
    char *argv[10];
    int len, i, j, fileWidth, fileHeight, maxintensity, index;
    char *p, type;
    unsigned char buffer[1025], *line = NULL, *line3 = NULL;
    Tcl_Channel chan;
    Tcl_DString dstring;
    myblock bl;
    int zoomx, zoomy;

    argv[0] = "gs";
    argv[1] = "-sDEVICE=ppmraw";
    argv[2] = (char *) buffer;
    argv[3] = "-q";
    argv[4] = "-dNOPAUSE";
    argv[5] = "-sOutputFile=-";
    argv[6] = "-";

    index = parseFormat(formatString, &zoomx, &zoomy);
    if (index < 0) {
	Tcl_AppendResult(interp, "invalid format: \"", formatString,
		"\"", (char *) NULL);
	return TCL_ERROR;
    }
    sprintf((char *) buffer, "-r%dx%d", zoomx, zoomy);
    chan = Tcl_OpenCommandChannel(interp, 7, argv,
	    TCL_STDIN|TCL_STDOUT|TCL_STDERR|TCL_ENFORCE_MODE);
    if (!chan) {
	return TCL_ERROR;
    }

    len = ImgRead(handle, buffer, 1024);
    buffer[1024] = 0;
    p = strstr(buffer,"%%BoundingBox:");
    if (p) {
	p += 14;
	srcX += (strtoul(p, &p, 0) * zoomx + 36) / 72;
	strtoul(p, &p, 0);
	strtoul(p, &p, 0);
	srcY -= (strtoul(p, &p, 0) * zoomy + 36) / 72;
    }
    while (len > 0) {
	Tcl_Write(chan, (char *) buffer, 1024);
	len = ImgRead(handle, buffer, 1024);
    }
    Tcl_Write(chan,"\nquit\n", 6);

    Tcl_DStringInit(&dstring);
    len = Tcl_Gets(chan, &dstring);
    p = Tcl_DStringValue(&dstring);
    type = p[1];
    if ((p[0] != 'P') || (type < '4') || (type > '6')) {
	Tcl_AppendResult(interp, "gs error: \"",
		p, "\"",(char *) NULL);
	return TCL_ERROR;
    }
    do {
	Tcl_DStringSetLength(&dstring, 0);
	Tcl_Gets(chan, &dstring);
	p = Tcl_DStringValue(&dstring);
    } while (p[0] == '#');

    fileWidth = strtoul(p, &p, 0);
    srcY += (fileHeight = strtoul(p, &p, 0));

    if ((srcX + width) > fileWidth) {
	width = fileWidth - srcX;
    }
    if ((srcY + height) > fileHeight) {
	height = fileHeight - srcY;
    }
    if ((width <= 0) || (height <= 0)) {
	Tcl_Close(interp, chan);
	Tcl_DStringFree(&dstring);
	return TCL_OK;
    }
    Tk_PhotoExpand(imageHandle, destX + width, destY + height);

    maxintensity = strtoul(p, &p, 0);
    if ((type != '4') && !maxintensity) {
	Tcl_DStringSetLength(&dstring, 0);
	Tcl_Gets(chan, &dstring);
	p = Tcl_DStringValue(&dstring);
	maxintensity = strtoul(p, &p, 0);
    }
    Tcl_DStringFree(&dstring);
    line3 = (unsigned char *) ckalloc(3 * fileWidth);
    block.pixelSize = 1;
    block.pitch = block.width = width;
    block.height = 1;
    block.offset[0] = 0;
    block.offset[1] = 0;
    block.offset[2] = 0;
    switch(type) {
	case '4':
	    i = (fileWidth+7)/8;
	    line = (unsigned char *) ckalloc(i);
	    while (srcY-- > 0) {
		Tcl_Read(chan,(char *) line, i);
	    }
	    block.pixelPtr = line3;
	    while (height--) {
	        Tcl_Read(chan, (char *) line, i);
	        for (j = 0; j < width; j++) {
		    line3[j] = ((line[(j+srcX)/8]>>(7-(j+srcX)%8) & 1)) ? 0 : 255;
	        }
		Tk_PhotoPutBlock(imageHandle, &block, destX, destY++, width, 1);
	    }
	    break;
	case '5':
	    line = (unsigned char *) ckalloc(fileWidth);
	    while (srcY--) {
		Tcl_Read(chan, (char *) line, fileWidth);
	    }
	    block.pixelPtr = line + srcX;
	    while (height--) {
		unsigned char *c = block.pixelPtr;
		Tcl_Read(chan, (char *) line, fileWidth);
		if (maxintensity != 255) {
		    for (j = width; j > 0; j--) {
			*c = (((int)*c) * maxintensity) / 255;
			c++;
		    }
		}
		Tk_PhotoPutBlock(imageHandle, &block, destX, destY++, width, 1);
	    }
	    break;
	case '6':
	    i = 3 * fileWidth;
	    line = NULL;
	    while (srcY--) {
		Tcl_Read(chan, (char *) line3, i);
	    }
	    block.pixelPtr = line3 + (3 * srcX);
	    block.pixelSize = 3;
	    block.offset[1] = 1;
	    block.offset[2] = 2;
	    while (height--) {
		unsigned char *c = block.pixelPtr;
		Tcl_Read(chan, (char *) line3, i);
		if (maxintensity != 255) {
		    for (j = (3 * width - 1); j >= 0; j--) {
			*c = (((int)*c) * maxintensity) / 255;
			c++;
		    }
		}
		Tk_PhotoPutBlock(imageHandle, &block, destX, destY++, width, 1);
	    }
	    break;
    }
    if (line) {
	ckfree((char *) line);
    }
    ckfree((char *) line3);
    Tcl_Close(interp, chan);
    Tcl_ResetResult(interp);
    return TCL_OK;
#else
    Tcl_AppendResult(interp, "Cannot read postscript file: not implemented",
	    (char *) NULL);
    return TCL_ERROR;
#endif
}

static int FileWritePS(interp, filename, formatString, blockPtr)
    Tcl_Interp *interp;
    char *filename;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    FILE *outfile = NULL;
    MFile handle;
    Tcl_DString nameBuffer; 
    char *fullname;
    int result;

    if ((fullname=Tcl_TranslateFileName(interp,filename,&nameBuffer))==NULL) {
	return TCL_ERROR;
    }

    if (!(outfile=fopen(fullname,"w"))) {
	Tcl_AppendResult(interp, filename, ": ", Tcl_PosixError(interp),
		(char *)NULL);
	Tcl_DStringFree(&nameBuffer);
	return TCL_ERROR;
    }

    Tcl_DStringFree(&nameBuffer);

    handle.data = (char *) outfile;
    handle.state = IMG_FILE;
    
    result = CommonWritePS(interp, &handle, formatString, blockPtr);
    fclose(outfile);
    return result;
}

static int StringWritePS(interp, dataPtr, formatString, blockPtr)
    Tcl_Interp *interp;
    Tcl_DString *dataPtr;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    MFile handle;
    int result;

    ImgWriteInit(dataPtr, &handle);
    result = CommonWritePS(interp, &handle, formatString, blockPtr);
    ImgPutc(IMG_DONE, &handle);
    return result;
}

static int CommonWritePS(interp, handle, formatString, blockPtr)
    Tcl_Interp *interp;
    MFile *handle;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    return(TCL_OK);
}
