/*
 * imgGIF.c --
 *
 * A photo image file handler for GIF files. Reads 87a and 89a GIF files.
 * At present THERE ARE WRITE functions for 87a and 89a GIF.
 *
 * GIF images may be read using the -data option of the photo image by
 * representing the data as BASE64 encoded ascii (SAU 6/96)
 *
 * Derived from the giftoppm code found in the pbmplus package 
 * and tkImgFmtPPM.c in the tk4.0b2 distribution by -
 *
 * Reed Wade (wade@cs.utk.edu), University of Tennessee
 *
 * Copyright (c) 1995-1996 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * This file also contains code from the giftoppm and the ppmtogif programs, 
 * which are copyrighted as follows:
 *
 * +-------------------------------------------------------------------+
 * | Copyright 1990, David Koblas.                                     |
 * |   Permission to use, copy, modify, and distribute this software   |
 * |   and its documentation for any purpose and without fee is hereby |
 * |   granted, provided that the above copyright notice appear in all |
 * |   copies and that both that copyright notice and this permission  |
 * |   notice appear in supporting documentation.  This software is    |
 * |   provided "as is" without express or implied warranty.           |
 * +-------------------------------------------------------------------+
 *
 * It also contains parts of the the LUG package developed by Raul Rivero.
 *
 * The GIF write function uses the Xiaolin Wu quantize function:
 *
 * +-------------------------------------------------------------------+
 * |           C Implementation of Wu's Color Quantizer (v. 2)         |
 * |           (see Graphics Gems vol. II, pp. 126-133)                |
 * |                                                                   |
 * | Author: Xiaolin Wu                                                |
 * |         Dept. of Computer Science                                 |
 * |         Univ. of Western Ontario                                  |
 * |         London, Ontario N6A 5B7                                   |
 * |         wu@csd.uwo.ca                                             |
 * |                                                                   |
 * | Algorithm: Greedy orthogonal bipartition of RGB space for         |
 * |            variance minimization aided by inclusion-exclusion     |
 * |            tricks. For speed no nearest neighbor search is done.  |
 * |            Slightly better performance can be expected by more    |
 * |            sophisticated but more expensive versions.             |
 * |                                                                   |
 * | The author thanks Tom Lane at Tom_Lane@G.GP.CS.CMU.EDU for much   |
 * | of additional documentation and a cure to a previous bug.         |
 * |                                                                   |
 * | Free to distribute, comments and suggestions are appreciated.     |
 * +-------------------------------------------------------------------+
 *
 * SCCS: @(#) imgGIF.c 1.13 97/01/21 19:54:13
 */ 
#include "tk.h"
#include "tkVMacro.h"
#include "imgInt.h"
#include <string.h>
#include <stdlib.h>

/*
 * The format record for the GIF file format:
 */

static int      ChanMatchGIF _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Channel chan, struct Tcl_Obj *fileName,
		    struct Tcl_Obj *format, int *widthPtr, int *heightPtr));
static int	ObjMatchGIF _ANSI_ARGS_((Tcl_Interp *interp, struct Tcl_Obj *data,
		    struct Tcl_Obj *format, int *widthPtr, int *heightPtr));
static int      ChanReadGIF  _ANSI_ARGS_((Tcl_Interp *interp,
		    Tcl_Channel chan, struct Tcl_Obj *fileName, struct Tcl_Obj *format,
		    Tk_PhotoHandle imageHandle, int destX, int destY,
		    int width, int height, int srcX, int srcY));
static int	ObjReadGIF _ANSI_ARGS_((Tcl_Interp *interp,
		    struct Tcl_Obj *data, struct Tcl_Obj *format,
		    Tk_PhotoHandle imageHandle, int destX, int destY,
		    int width, int height, int srcX, int srcY));
static int 	ChanWriteGIF _ANSI_ARGS_(( Tcl_Interp *interp,  
		    char *filename, struct Tcl_Obj *format, 
		    Tk_PhotoImageBlock *blockPtr));
static int	StringWriteGIF _ANSI_ARGS_((Tcl_Interp *interp,
		    Tcl_DString *dataPtr, struct Tcl_Obj *format,
		    Tk_PhotoImageBlock *blockPtr));
static int      CommonReadGIF  _ANSI_ARGS_((Tcl_Interp *interp,
		    MFile *handle, char *fileName, struct Tcl_Obj *format,
		    Tk_PhotoHandle imageHandle, int destX, int destY,
		    int width, int height, int srcX, int srcY));
static int	CommonWriteGIF _ANSI_ARGS_((Tcl_Interp *interp,
		    MFile *handle, struct Tcl_Obj *format,
		    Tk_PhotoImageBlock *blockPtr));

Tk_PhotoImageFormat imgFmtGIF = {
    "GIF",		/* name */
    ChanMatchGIF,	/* fileMatchProc */
    ObjMatchGIF,	/* stringMatchProc */
    ChanReadGIF,	/* fileReadProc */
    ObjReadGIF,		/* stringReadProc */
    ChanWriteGIF,	/* fileWriteProc */
    StringWriteGIF,	/* stringWriteProc */
};

#define INTERLACE		0x40
#define LOCALCOLORMAP		0x80
#define BitSet(byte, bit)	(((byte) & (bit)) == (bit))
#define MAXCOLORMAPSIZE		256
#define CM_RED			0
#define CM_GREEN		1
#define CM_BLUE			2
#define CM_ALPHA		3
#define MAX_LWZ_BITS		12
#define LM_to_uint(a,b)         (((b)<<8)|(a))
#define ReadOK(handle,buffer,len)	(ImgRead(handle, buffer, len) == len)

/*
 * Prototypes for local procedures defined in this file:
 */

static int		DoExtension _ANSI_ARGS_((MFile *handle, int label,
			    int *transparent));
static int		GetCode _ANSI_ARGS_((MFile *handle, int code_size,
			    int flag));
static int		GetDataBlock _ANSI_ARGS_((MFile *handle,
			    unsigned char *buf));
static int		LWZReadByte _ANSI_ARGS_((MFile *handle, int flag,
			    int input_code_size));
static int		ReadColorMap _ANSI_ARGS_((MFile *handle, int number,
			    unsigned char buffer[MAXCOLORMAPSIZE][4]));
static int		ReadGIFHeader _ANSI_ARGS_((MFile *handle,
			    int *widthPtr, int *heightPtr));
static int		ReadImage _ANSI_ARGS_((Tcl_Interp *interp,
			    char *imagePtr, MFile *handle, int len, int rows, 
			    unsigned char cmap[MAXCOLORMAPSIZE][4],
			    int width, int height, int srcX, int srcY,
			    int interlace, int transparent));


/*
 *----------------------------------------------------------------------
 *
 * ChanMatchGIF --
 *
 *  This procedure is invoked by the photo image type to see if
 *  a channel contains image data in GIF format.
 *
 * Results:
 *  The return value is 1 if the first characters in channel chan
 *  look like GIF data, and 0 otherwise.
 *
 * Side effects:
 *  The access position in f may change.
 *
 *----------------------------------------------------------------------
 */

static int
ChanMatchGIF(interp, chan, fileName, format, widthPtr, heightPtr)
    Tcl_Interp *interp;
    Tcl_Channel chan;		/* The image channel, open for reading. */
    struct Tcl_Obj *fileName;	/* The name of the image file. */
    struct Tcl_Obj *format;	/* User-specified format object, or NULL. */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here if the file is a valid
				 * raw GIF file. */
{
    MFile handle;

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    return ReadGIFHeader(&handle, widthPtr, heightPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ChanReadGIF --
 *
 *	This procedure is called by the photo image type to read
 *	GIF format data from a channel and write it into a given
 *	photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	The access position in channel chan is changed, and new data is
 *	added to the image given by imageHandle.
 *
 *----------------------------------------------------------------------
 */

static int
ChanReadGIF(interp, chan, fileName, format, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    Tcl_Channel chan;		/* The image channel, open for reading. */
    struct Tcl_Obj *fileName;	/* The name of the image file. */
    struct Tcl_Obj *format;	/* User-specified format object, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
    MFile handle; 
    int nBytes;

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    return CommonReadGIF(interp, &handle, Tcl_GetStringFromObj(fileName,&nBytes), format,
    	    imageHandle, destX, destY, width, height, srcX, srcY);
}

/*
 *----------------------------------------------------------------------
 *
 * CommonReadGIF --
 *
 *	This procedure is called by the photo image type to read
 *	GIF format data from a file and write it into a given
 *	photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	The access position in file f is changed, and new data is
 *	added to the image given by imageHandle.
 *
 *----------------------------------------------------------------------
 */

typedef struct myblock {
    Tk_PhotoImageBlock ck;
    int dummy; /* extra space for offset[3], if not included already
		  in Tk_PhotoImageBlock */
} myblock;

#define block bl.ck

static int
CommonReadGIF(interp, handle, fileName, format, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    MFile *handle;		/* The image file, open for reading. */
    char *fileName;		/* The name of the image file. */
    struct Tcl_Obj *format;	/* User-specified format object, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
    int fileWidth, fileHeight;
    int nBytes, index = 0, objc = 0;
    Tcl_Obj **objv = NULL;
    char *c = "";
    myblock bl;
    unsigned char buf[100];
    int bitPixel;
    unsigned int colorResolution;
    unsigned int background;
    unsigned int aspectRatio;
    unsigned char colorMap[MAXCOLORMAPSIZE][4];
    int transparent = -1;

    if (ImgListObjGetElements(interp, format, &objc, &objv) != TCL_OK) {
	return TCL_ERROR;
    }
    if (objc > 1) {
	c = Tcl_GetStringFromObj(objv[1], &nBytes);
    }
    if ((objc > 3) || ((objc == 3) && ((c[0] != '-') ||
	    (c[1] != 'i') || strncmp(c, "-index", strlen(c))))) {
	Tcl_AppendResult(interp, "invalid format: \"",
		ImgGetStringFromObj(format, NULL), "\"", (char *) NULL);
	return TCL_ERROR;
    }
    if (objc > 1) {
	if (Tcl_GetIntFromObj(interp, objv[objc-1], &index) != TCL_OK) {
	    return TCL_ERROR;
	}
    }

    if (!ReadGIFHeader(handle, &fileWidth, &fileHeight)) {
	Tcl_AppendResult(interp, "couldn't read GIF header from file \"",
		fileName, "\"", NULL);
	return TCL_ERROR;
    }
    if ((fileWidth <= 0) || (fileHeight <= 0)) {
	Tcl_AppendResult(interp, "GIF image file \"", fileName,
 		"\" has dimension(s) <= 0", (char *) NULL);
	return TCL_ERROR;
    }

    if (ImgRead(handle, buf, 3) != 3) {
	return TCL_OK;
    }

    bitPixel = 2<<(buf[0]&0x07);
    colorResolution = ((((unsigned int) buf[0]&0x70)>>3)+1);
    background = buf[1];
    aspectRatio = buf[2];

    if (BitSet(buf[0], LOCALCOLORMAP)) {    /* Global Colormap */
	if (!ReadColorMap(handle, bitPixel, colorMap)) {
	    Tcl_AppendResult(interp, "error reading color map",
		    (char *) NULL);
	    return TCL_ERROR;
	}
    }

    if ((srcX + width) > fileWidth) {
	width = fileWidth - srcX;
    }
    if ((srcY + height) > fileHeight) {
	height = fileHeight - srcY;
    }
    if ((width <= 0) || (height <= 0)) {
	return TCL_OK;
    }

    Tk_PhotoExpand(imageHandle, destX + width, destY + height);

    block.pixelSize = 4;
    block.offset[0] = 0;
    block.offset[1] = 1;
    block.offset[2] = 2;
    block.offset[3] = 3;
    block.pixelPtr = NULL;

    while (1) {
	if (ImgRead(handle, buf, 1) != 1) {
	    /*
	     * Premature end of image.  We should really notify
	     * the user, but for now just show garbage.
	     */

	    break;
	}

	if (buf[0] == ';') {
	    /*
	     * GIF terminator.
	     */

	    Tcl_AppendResult(interp,"no image data for this index",
		    (char *) NULL);
	    goto error;
	}

	if (buf[0] == '!') {
	    /*
	     * This is a GIF extension.
	     */

	    if (ImgRead(handle, buf, 1) != 1) {
		Tcl_AppendResult(interp,
			"error reading extension function code in GIF image",
			(char *) NULL);
		goto error;
	    }
	    if (DoExtension(handle, buf[0], &transparent) < 0) {
		Tcl_AppendResult(interp, "error reading extension in GIF image",
			(char *) NULL);
		goto error;
	    }
	    continue;
	}

	if (buf[0] != ',') {
	    /*
	     * Not a valid start character; ignore it.
	     */
	    continue;
	}

	if (ImgRead(handle, buf, 9) != 9) {
	    Tcl_AppendResult(interp,
		    "couldn't read left/top/width/height in GIF image",
		    (char *) NULL);
	    goto error;
	}

	fileWidth = LM_to_uint(buf[4],buf[5]);
	fileHeight = LM_to_uint(buf[6],buf[7]);

	bitPixel = 2<<(buf[8]&0x07);

	if (index--) {
	    int x,y;
	    unsigned char c;
	    /* this is not the image we want to read: skip it. */

	    if (BitSet(buf[8], LOCALCOLORMAP)) {
		if (!ReadColorMap(handle, bitPixel, 0)) {
		    Tcl_AppendResult(interp,
			    "error reading color map", (char *) NULL);
		    goto error;
		}
	    }

	    /* read data */
	    if (!ReadOK(handle,&c,1)) {
		goto error;
	    }

	    LWZReadByte(handle, 1, c);

	    for (y=0; y<fileHeight; y++) {
		for (x=0; x<fileWidth; x++) {
		    if (LWZReadByte(handle, 0, c) < 0) {
			printf("read error\n");
			goto error;
		    }
		}
	    }
	    continue;
	}

	if (BitSet(buf[8], LOCALCOLORMAP)) {
	    if (!ReadColorMap(handle, bitPixel, colorMap)) {
		Tcl_AppendResult(interp,
			"error reading color map", (char *) NULL);
		goto error;
	    }
	}

	index = LM_to_uint(buf[0],buf[1]);
	srcX -= index;
	if (srcX<0) {
	    destX -= srcX; width += srcX;
	    srcX = 0;
	}

	if (width > fileWidth) {
	    width = fileWidth;
	}

	index = LM_to_uint(buf[2],buf[3]);
	srcY -= index;
	if (index > srcY) {
	    destY -= srcY; height += srcY;
	    srcY = 0;
	}
	if (height > fileHeight) {
	    height = fileHeight;
	}

	if ((width <= 0) || (height <= 0)) {
	    block.pixelPtr = 0;
	    goto noerror;
	}

	block.width = width;
	block.height = height;
	block.pixelSize = (transparent>=0)?4:3;
	block.pitch = block.pixelSize * width;
	nBytes = block.pitch * height;
	block.pixelPtr = (unsigned char *) ckalloc((unsigned) nBytes);

	if (ReadImage(interp, (char *) block.pixelPtr, handle, width, height,
		colorMap, fileWidth, fileHeight, srcX, srcY,
		BitSet(buf[8], INTERLACE), transparent) != TCL_OK) {
	    goto error;
	}
	break;
    }

    if (transparent == -1) {
	Tk_PhotoPutBlock(imageHandle, &block, destX, destY, width, height);
    } else {
	ImgPhotoPutBlock(imageHandle, &block, destX, destY, width, height);
    }

    noerror:
    if (block.pixelPtr) {
	ckfree((char *) block.pixelPtr);
    }
    return TCL_OK;

    error:
    if (block.pixelPtr) {
	ckfree((char *) block.pixelPtr);
    }
    return TCL_ERROR;

}

/*
 *----------------------------------------------------------------------
 *
 * ObjMatchGIF --
 *
 *  This procedure is invoked by the photo image type to see if
 *  an object contains image data in GIF format.
 *
 * Results:
 *  The return value is 1 if the first characters in the object are
 *  like GIF data, and 0 otherwise.
 *
 * Side effects:
 *  the size of the image is placed in widthPtr and heightPtr.
 *
 *----------------------------------------------------------------------
 */

static int
ObjMatchGIF(interp, data, format, widthPtr, heightPtr)
    Tcl_Interp *interp;
    struct Tcl_Obj *data;	/* the object containing the image data */
    struct Tcl_Obj *format;	/* the image format object */
    int *widthPtr;		/* where to put the image width */
    int *heightPtr;		/* where to put the image height */
{
    MFile handle;

    if (!ImgReadInit(data, 'G', &handle)) {
	return 0;
    }
    return ReadGIFHeader(&handle, widthPtr, heightPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ObjReadGIF --
 *
 *	This procedure is called by the photo image type to read
 *	GIF format data from a base64 encoded string, and give it to
 *	the photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	new data is added to the image given by imageHandle.  This
 *	procedure calls FileReadGif by redefining the operation of
 *	fprintf temporarily.
 *
 *----------------------------------------------------------------------
 */

static int
ObjReadGIF(interp, data, format, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;		/* interpreter for reporting errors in */
    struct Tcl_Obj *data;	/* object containing the image */
    struct Tcl_Obj *format;	/* format object if any */
    Tk_PhotoHandle imageHandle;	/* the image to write this data into */
    int destX, destY;		/* The rectangular region of the  */
    int  width, height;		/*   image to copy */
    int srcX, srcY;
{
    MFile handle;                         
    int code;

    ImgReadInit(data, 'G', &handle);
    return CommonReadGIF(interp, &handle, "inline data", format,
	    imageHandle, destX, destY, width, height, srcX, srcY);
}

/*
 *----------------------------------------------------------------------
 *
 * ReadGIFHeader --
 *
 *	This procedure reads the GIF header from the beginning of a
 *	GIF file and returns the dimensions of the image.
 *
 * Results:
 *	The return value is 1 if file "f" appears to start with
 *	a valid GIF header, 0 otherwise.  If the header is valid,
 *	then *widthPtr and *heightPtr are modified to hold the
 *	dimensions of the image.
 *
 * Side effects:
 *	The access position in f advances.
 *
 *----------------------------------------------------------------------
 */

static int
ReadGIFHeader(handle, widthPtr, heightPtr)
    MFile *handle;		/* Image file to read the header from */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here. */
{
    unsigned char buf[7];

    if ((ImgRead(handle, buf, 6) != 6)
	    || ((strncmp("GIF87a", (char *) buf, 6) != 0)
	    && (strncmp("GIF89a", (char *) buf, 6) != 0))) {
	return 0;
    }

    if (ImgRead(handle, buf, 4) != 4) {
	return 0;
    }

    *widthPtr = LM_to_uint(buf[0],buf[1]);
    *heightPtr = LM_to_uint(buf[2],buf[3]);
    return 1;
}

/*
 *-----------------------------------------------------------------
 * The code below is copied from the giftoppm program and modified
 * just slightly.
 *-----------------------------------------------------------------
 */

static int
ReadColorMap(handle, number, buffer)
    MFile	*handle;
    int		number;
    unsigned char buffer[MAXCOLORMAPSIZE][4];
{
    int     i;
    unsigned char rgb[3];

    for (i = 0; i < number; ++i) {
	if (! ReadOK(handle, rgb, sizeof(rgb)))
			return 0;
	if (buffer) {
		buffer[i][CM_RED] = rgb[0] ;
		buffer[i][CM_GREEN] = rgb[1] ;
		buffer[i][CM_BLUE] = rgb[2] ;
		buffer[i][CM_ALPHA] = 255 ;
	}
    }
    return 1;
}



static int
DoExtension(handle, label, transparent)
    MFile    *handle;
    int label;
    int	*transparent;
{
	static unsigned char buf[256];
	int count = 0;

	switch (label) {
		case 0x01:      /* Plain Text Extension */
			break;

		case 0xff:      /* Application Extension */
			break;

		case 0xfe:      /* Comment Extension */
			do {
				count = GetDataBlock(handle, (unsigned char*) buf);
			} while (count > 0);
			return count;

		case 0xf9:      /* Graphic Control Extension */
			count = GetDataBlock(handle, (unsigned char*) buf);
			if (count < 0) {
				return 1;
			}
			if ((buf[0] & 0x1) != 0) {
				*transparent = buf[3];
			}

			do {
			    count = GetDataBlock(handle, (unsigned char*) buf);
			} while (count > 0);
			return count;
	}

	do {
	    count = GetDataBlock(handle, (unsigned char*) buf);
	} while (count > 0);
	return count;
}

static int ZeroDataBlock = 0;

static int
GetDataBlock(handle, buf)
    MFile        *handle;
    unsigned char   *buf;
{
	unsigned char   count;

	if (! ReadOK(handle,&count,1)) {
		return -1;
	}

	ZeroDataBlock = count == 0;

	if ((count != 0) && (! ReadOK(handle, buf, count))) {
		return -1;
	}

	return count;
}


static int
ReadImage(interp, imagePtr, handle, len, rows, cmap,
	width, height, srcX, srcY, interlace, transparent)
Tcl_Interp *interp;
char 	*imagePtr;
MFile    *handle;
int len, rows;
unsigned char   cmap[MAXCOLORMAPSIZE][4];
int width, height;
int srcX, srcY;
int interlace;
int transparent;
{
	unsigned char   c;
	int     v;
	int     xpos = 0, ypos = 0, pass = 0;
	char	*pixelPtr;


	/*
	 *  Initialize the Compression routines
	 */
	if (! ReadOK(handle,&c,1))  {
	    Tcl_AppendResult(interp, "error reading GIF image: ",
		    Tcl_PosixError(interp), (char *) NULL);
	    return TCL_ERROR;
	}

	if (LWZReadByte(handle, 1, c) < 0) {
	    Tcl_AppendResult(interp, "format error in GIF image", (char*) NULL);
	    return TCL_ERROR;
	}

	if (transparent!=-1) {
	    cmap[transparent][CM_RED] = 0;
	    cmap[transparent][CM_GREEN] = 0;
	    cmap[transparent][CM_BLUE] = 0;
	    cmap[transparent][CM_ALPHA] = 0;
	}

	pixelPtr = imagePtr;
	while ((v = LWZReadByte(handle,0,c)) >= 0 ) {

		if ((xpos>=srcX) && (xpos<srcX+len) &&
			(ypos>=srcY) && (ypos<srcY+rows)) {
		    *pixelPtr++ = cmap[v][CM_RED];
		    *pixelPtr++ = cmap[v][CM_GREEN];
		    *pixelPtr++ = cmap[v][CM_BLUE];
		    if (transparent>=0) {
			*pixelPtr++ = cmap[v][CM_ALPHA];
		    }
		}
		++xpos;
		if (xpos == width) {
			xpos = 0;
			if (interlace) {
				switch (pass) {
					case 0:
					case 1:
						ypos += 8; break;
					case 2:
						ypos += 4; break;
					case 3:
						ypos += 2; break;
				}

				while (ypos >= height) {
					++pass;
					switch (pass) {
						case 1:
							ypos = 4; break;
						case 2:
							ypos = 2; break;
						case 3:
							ypos = 1; break;
						default:
							return TCL_OK;
					}
				}
			} else {
				++ypos;
			}
			pixelPtr = imagePtr + (ypos-srcY) * len * ((transparent>=0)?4:3);
		}
		if (ypos >= height)
			break;
	}
	return TCL_OK;
}

static int
LWZReadByte(handle, flag, input_code_size)
MFile    *handle;
int flag;
int input_code_size;
{
	static int  fresh = 0;
	int     code, incode;
	static int  code_size, set_code_size;
	static int  max_code, max_code_size;
	static int  firstcode, oldcode;
	static int  clear_code, end_code;
	static int  table[2][(1<< MAX_LWZ_BITS)];
	static int  stack[(1<<(MAX_LWZ_BITS))*2], *sp;
	register int    i;


	if (flag) {

		set_code_size = input_code_size;
		code_size = set_code_size+1;
		clear_code = 1 << set_code_size ;
		end_code = clear_code + 1;
		max_code_size = 2*clear_code;
		max_code = clear_code+2;

		GetCode(handle, 0, 1);

		fresh = 1;

		for (i = 0; i < clear_code; ++i) {
			table[0][i] = 0;
			table[1][i] = i;
		}
		for (; i < (1<<MAX_LWZ_BITS); ++i) {
			table[0][i] = table[1][0] = 0;
		}

		sp = stack;

		return 0;

	} else if (fresh) {

		fresh = 0;
		do {
			firstcode = oldcode = GetCode(handle, code_size, 0);
		} while (firstcode == clear_code);
		return firstcode;
	}

	if (sp > stack)
		return *--sp;

	while ((code = GetCode(handle, code_size, 0)) >= 0) {
		if (code == clear_code) {
			for (i = 0; i < clear_code; ++i) {
				table[0][i] = 0;
				table[1][i] = i;
			}

			for (; i < (1<<MAX_LWZ_BITS); ++i) {
				table[0][i] = table[1][i] = 0;
			}

			code_size = set_code_size+1;
			max_code_size = 2*clear_code;
			max_code = clear_code+2;
			sp = stack;
			firstcode = oldcode = GetCode(handle, code_size, 0);
			return firstcode;

	} else if (code == end_code) {
		int     count;
		unsigned char   buf[260];

		if (ZeroDataBlock)
			return -2;

		while ((count = GetDataBlock(handle, buf)) > 0)
			;

		if (count != 0)
			return -2;
	}

	incode = code;

	if (code >= max_code) {
		*sp++ = firstcode;
		code = oldcode;
	}

	while (code >= clear_code) {
		*sp++ = table[1][code];
		if (code == table[0][code]) {
			return -2;

			/*
			 * Used to be this instead, Steve Ball suggested
			 * the change to just return.

			printf("circular table entry BIG ERROR\n");
			*/
		}
		code = table[0][code];
	}

	*sp++ = firstcode = table[1][code];

	if ((code = max_code) <(1<<MAX_LWZ_BITS)) {

		table[0][code] = oldcode;
		table[1][code] = firstcode;
		++max_code;
		if ((max_code>=max_code_size) && (max_code_size < (1<<MAX_LWZ_BITS))) {
			max_code_size *= 2;
			++code_size;
		}
	}

	oldcode = incode;

	if (sp > stack)
		return *--sp;
	}
	return code;
}


static int
GetCode(handle, code_size, flag)
MFile    *handle;
int code_size;
int flag;
{
	static unsigned char    buf[280];
	static int      curbit, lastbit, done, last_byte;
	int         i, j, ret;
	unsigned char       count;

	if (flag) {
		curbit = 0;
		lastbit = 0;
		done = 0;
		return 0;
	}


	if ( (curbit+code_size) >= lastbit) {
		if (done) {
			/* ran off the end of my bits */
			return -1;
		}
		buf[0] = buf[last_byte-2];
		buf[1] = buf[last_byte-1];

		if ((count = GetDataBlock(handle, &buf[2])) == 0)
			done = 1;

		last_byte = 2 + count;
		curbit = (curbit - lastbit) + 16;
		lastbit = (2+count)*8 ;
	}

	ret = 0;
	for (i = curbit, j = 0; j < code_size; ++i, ++j)
		ret |= ((buf[ i / 8 ] & (1 << (i % 8))) != 0) << j;


	curbit += code_size;

	return ret;
}

/*
 * This software is copyrighted as noted below.  It may be freely copied,
 * modified, and redistributed, provided that the copyright notice is
 * preserved on all copies.
 *
 * There is no warranty or other guarantee of fitness for this software,
 * it is provided solely "as is".  Bug reports or fixes may be sent
 * to the author, who may or may not act on them as he desires.
 *
 * You may not include this software in a program or other software product
 * without supplying the source, or without informing the end-user that the
 * source is available for no extra charge.
 *
 * If you modify this software, you should include a notice giving the
 * name of the person performing the modification, the date of modification,
 * and the reason for such modification.
 */






/*
 * ChanWriteGIF - writes a image in GIF format.
 *-------------------------------------------------------------------------
 * Author:          		Lolo
 *                              Engeneering Projects Area 
 *	            		Department of Mining 
 *                  		University of Oviedo
 * e-mail			zz11425958@zeus.etsimo.uniovi.es
 *                  		lolo@pcsig22.etsimo.uniovi.es
 * Date:            		Fri September 20 1996
 *----------------------------------------------------------------------
 * FileWriteGIF-
 *
 *    This procedure is called by the photo image type to write
 *    GIF format data from a photo image into a given file 
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 *----------------------------------------------------------------------
 */

 /*
  *  Types, defines and variables needed to write and compress a GIF.
  */

typedef int (* ifunptr) _ANSI_ARGS_((void));	

#define LSB(a)                  ((unsigned char) (((short)(a)) & 0x00FF))
#define MSB(a)                  ((unsigned char) (((short)(a)) >> 8))

#define GIFBITS 12
#define HSIZE  5003            /* 80% occupancy */

static int ssize;
static int csize;
static int rsize;
static unsigned char *pixelo;
static int pixelSize;
static int pixelPitch;
static int greenOffset;
static int blueOffset;
static int alphaOffset;
static int num;
static unsigned char mapa[MAXCOLORMAPSIZE][3];

/*
 *	Definition of new functions to write GIFs
 */

static int color _ANSI_ARGS_((int red,int green, int blue));
static void compress _ANSI_ARGS_((int init_bits, MFile *handle,
		ifunptr readValue));
static int nuevo _ANSI_ARGS_((int red, int green ,int blue,
		unsigned char mapa[MAXCOLORMAPSIZE][3]));
static int savemap _ANSI_ARGS_((Tk_PhotoImageBlock *blockPtr,
		unsigned char mapa[MAXCOLORMAPSIZE][3]));
static int ReadValue _ANSI_ARGS_((void));
static int no_bits _ANSI_ARGS_((int colors));

static int
ChanWriteGIF (interp, filename, format, blockPtr)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    char	*filename;
    struct Tcl_Obj *format;
    Tk_PhotoImageBlock *blockPtr;
{
    Tcl_Channel chan = NULL;
    MFile handle;
    int result;

    chan = Tcl_OpenFileChannel(interp, filename, "w", 0644);
    if (!chan) {
	return TCL_ERROR;
    }
    if (Tcl_SetChannelOption(interp, chan, "-translation", "binary") != TCL_OK) {
	return TCL_ERROR;
    }

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    result = CommonWriteGIF(interp, &handle, format, blockPtr);
    if (Tcl_Close(interp, chan) == TCL_ERROR) {
	return TCL_ERROR;
    }
    return result;
}

static int
StringWriteGIF(interp, dataPtr, format, blockPtr)
    Tcl_Interp *interp;
    Tcl_DString *dataPtr;
    struct Tcl_Obj *format;
    Tk_PhotoImageBlock *blockPtr;
{
    int result;
    MFile handle;

    Tcl_DStringSetLength(dataPtr, 1024);
    ImgWriteInit(dataPtr, &handle);

    result = CommonWriteGIF(interp, &handle, format, blockPtr);
    ImgPutc(IMG_DONE, &handle);

    return(result);
}

static int
CommonWriteGIF(interp, handle, format, blockPtr)
    Tcl_Interp *interp;
    MFile *handle;
    struct Tcl_Obj *format;
    Tk_PhotoImageBlock *blockPtr;
{
    int  resolution;
    long  numcolormap;

    long  width,height,x;
    unsigned char c;
    unsigned int top,left;
    int num;

    top = 0;
    left = 0;

    pixelSize=blockPtr->pixelSize;
    greenOffset=blockPtr->offset[1]-blockPtr->offset[0];
    blueOffset=blockPtr->offset[2]-blockPtr->offset[0];
    alphaOffset = blockPtr->offset[0];
    if (alphaOffset < blockPtr->offset[2]) {
	alphaOffset = blockPtr->offset[2];
    }
    if (++alphaOffset < pixelSize) {
	alphaOffset -= blockPtr->offset[0];
    } else {
	alphaOffset = 0;
    }

    ImgWrite(handle, (CONST char *) (alphaOffset ? "GIF89a":"GIF87a"), 6);

    for (x=0;x<MAXCOLORMAPSIZE;x++) {
	mapa[x][CM_RED] = 255;
	mapa[x][CM_GREEN] = 255;
	mapa[x][CM_BLUE] = 255;
    }


    width=blockPtr->width;
    height=blockPtr->height;
    pixelo=blockPtr->pixelPtr + blockPtr->offset[0];
    pixelPitch=blockPtr->pitch;
    if ((num=savemap(blockPtr,mapa))<0) {
	Tcl_AppendResult(interp, "too many colors", (char *) NULL);
	return TCL_ERROR;
    }
    if (num<3) num=3;
    c=LSB(width);
    ImgPutc(c,handle);
    c=MSB(width);
    ImgPutc(c,handle);
    c=LSB(height);
    ImgPutc(c,handle);
    c=MSB(height);
    ImgPutc(c,handle);

    c= (1 << 7) | (no_bits(num) << 4) | (no_bits(num));
    ImgPutc(c,handle);
    resolution = no_bits(num)+1;

    numcolormap=1 << resolution;

    /*  background color */

    ImgPutc(0,handle);

    /*  zero for future expansion  */

    ImgPutc(0,handle);

    for (x=0; x<numcolormap ;x++) {
	ImgPutc(mapa[x][CM_RED],handle);
	ImgPutc(mapa[x][CM_GREEN],handle);
	ImgPutc(mapa[x][CM_BLUE],handle);
    }

    /*
     * Write out extension for transparent colour index, if necessary.
     */

    if (alphaOffset) {
	ImgWrite(handle, "!\371\4\1\0\0\0", 8);
    }

    ImgPutc(',',handle);
    c=LSB(top);
    ImgPutc(c,handle);
    c=MSB(top);
    ImgPutc(c,handle);
    c=LSB(left);
    ImgPutc(c,handle);
    c=MSB(left);
    ImgPutc(c,handle);

    c=LSB(width);
    ImgPutc(c,handle);
    c=MSB(width);
    ImgPutc(c,handle);

    c=LSB(height);
    ImgPutc(c,handle);
    c=MSB(height);
    ImgPutc(c,handle);

    c=0;
    ImgPutc(c,handle);
    c=resolution;
    ImgPutc(c,handle);

    ssize = rsize = blockPtr->width;
    csize = blockPtr->height;
    compress(resolution+1, handle, ReadValue);
 
    ImgPutc(0,handle);
    ImgPutc(';',handle);

    return TCL_OK;	
}

static int
color(red, green, blue)
    int red;
    int green;
    int blue;
{
    int x;
    for (x=(alphaOffset != 0);x<=MAXCOLORMAPSIZE;x++) {
	if ((mapa[x][CM_RED]==red) && (mapa[x][CM_GREEN]==green) &&
		(mapa[x][CM_BLUE]==blue)) {
	    return x;
	}
    }
    return -1;
}


static int
nuevo(red, green, blue, mapa)
    int red,green,blue;
    unsigned char mapa[MAXCOLORMAPSIZE][3];
{
    int x;
    for (x=(alphaOffset != 0);x<num;x++) {
	if ((mapa[x][CM_RED]==red) && (mapa[x][CM_GREEN]==green) &&
		(mapa[x][CM_BLUE]==blue)) {
	    return 0;
	}
    }
    return 1;
}

static int
savemap(blockPtr,mapa)
    Tk_PhotoImageBlock *blockPtr;
    unsigned char mapa[MAXCOLORMAPSIZE][3];
{
    unsigned char  *colores;
    int x,y;
    unsigned char  red,green,blue;

    if (alphaOffset) {
	num = 1;
	mapa[0][CM_RED] = 0xd9;
	mapa[0][CM_GREEN] = 0xd9;
	mapa[0][CM_BLUE] = 0xd9;
    } else {
	num = 0;
    }

    for(y=0;y<blockPtr->height;y++) {
	colores=blockPtr->pixelPtr + blockPtr->offset[0]
		+ y * blockPtr->pitch;
	for(x=0;x<blockPtr->width;x++) {
	    if (!alphaOffset || (colores[alphaOffset] != 0)) {
		red = colores[0];
		green = colores[greenOffset];
		blue = colores[blueOffset];
		if (nuevo(red,green,blue,mapa)) {
		    if (num>255) 
			return -1;

		    mapa[num][CM_RED]=red;
		    mapa[num][CM_GREEN]=green;
		    mapa[num][CM_BLUE]=blue;
		    num++;
		}
	    }
	    colores += pixelSize;
	}
    }
    return num;
}

static int
ReadValue()
{
    unsigned int col;

    if (csize == 0) {
	return EOF;
    }
    if (alphaOffset && (pixelo[alphaOffset]==0)) {
	col = 0;
    } else {
	col = color(pixelo[0],pixelo[greenOffset],pixelo[blueOffset]);
    }
    pixelo += pixelSize;
    if (--ssize <= 0) {
	ssize = rsize;
	csize--;
	pixelo += pixelPitch - (rsize * pixelSize);
    }

    return col;
}

/*
 * Return the number of bits ( -1 ) to represent a given
 * number of colors ( ex: 256 colors => 7 ).
 */
static int
no_bits( colors )
int colors;
{
    register int bits = 0;

    colors--;
    while ( colors >> bits ) {
	bits++;
    }

    return (bits-1);
}



#ifdef IMG_USE_LZW

/*
 *
 * GIF Image compression - modified 'compress'
 *
 * Based on: compress.c - File compression ala IEEE Computer, June 1984.
 *
 * By Authors:  Spencer W. Thomas       (decvax!harpo!utah-cs!utah-gr!thomas)
 *              Jim McKie               (decvax!mcvax!jim)
 *              Steve Davies            (decvax!vax135!petsd!peora!srd)
 *              Ken Turkowski           (decvax!decwrl!turtlevax!ken)
 *              James A. Woods          (decvax!ihnp4!ames!jaw)
 *              Joe Orost               (decvax!vax135!petsd!joe)
 *
 */
#include <ctype.h>

static void output _ANSI_ARGS_((long code));
static void cl_block _ANSI_ARGS_((void));
static void cl_hash _ANSI_ARGS_((int hsize));
static void char_init _ANSI_ARGS_((void));
static void char_out _ANSI_ARGS_((int c));
static void flush_char _ANSI_ARGS_((void));

static int n_bits;		/* number of bits/code */
static int maxbits = GIFBITS;	/* user settable max # bits/code */
static long maxcode;		/* maximum code, given n_bits */
static long maxmaxcode = (long)1 << GIFBITS;
				/* should NEVER generate this code */
#define MAXCODE(n_bits)		(((long) 1 << (n_bits)) - 1)

static int		htab[HSIZE];
static unsigned int	codetab[HSIZE];
#define HashTabOf(i)	htab[i]
#define CodeTabOf(i)	codetab[i]

static long hsize = HSIZE;	/* for dynamic table sizing */

/*
 * To save much memory, we overlay the table used by compress() with those
 * used by decompress().  The tab_prefix table is the same size and type
 * as the codetab.  The tab_suffix table needs 2**GIFBITS characters.  We
 * get this from the beginning of htab.  The output stack uses the rest
 * of htab, and contains characters.  There is plenty of room for any
 * possible stack (stack used to be 8000 characters).
 */

static int free_ent = 0;  /* first unused entry */

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */
static int clear_flg = 0;

static int offset;
static unsigned int in_count = 1;            /* length of input */
static unsigned int out_count = 0;           /* # of codes output (for debugging) */

/*
 * compress stdin to stdout
 *
 * Algorithm:  use open addressing double hashing (no chaining) on the
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, whereby the code table is cleared when the compression
 * ratio decreases, but after the table fills.  The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.  Late addition:  construct the table according to
 * file size for noticeable speed improvement on small files.  Please direct
 * questions about this implementation to ames!jaw.
 */

static int g_init_bits;
static MFile *g_outfile;

static int ClearCode;
static int EOFCode;

static void compress( init_bits, handle, readValue )
    int init_bits;
    MFile *handle;
    ifunptr readValue;
{
    register long fcode;
    register long i = 0;
    register int c;
    register long ent;
    register long disp;
    register long hsize_reg;
    register int hshift;

    /*
     * Set up the globals:  g_init_bits - initial number of bits
     *                      g_outfile   - pointer to output file
     */
    g_init_bits = init_bits;
    g_outfile = handle;

    /*
     * Set up the necessary values
     */
    offset = 0;
    out_count = 0;
    clear_flg = 0;
    in_count = 1;
    maxcode = MAXCODE(n_bits = g_init_bits);

    ClearCode = (1 << (init_bits - 1));
    EOFCode = ClearCode + 1;
    free_ent = ClearCode + 2;

    char_init();

    ent = readValue();

    hshift = 0;
    for ( fcode = (long) hsize;  fcode < 65536L; fcode *= 2L )
        hshift++;
    hshift = 8 - hshift;                /* set hash code range bound */

    hsize_reg = hsize;
    cl_hash( (int) hsize_reg);            /* clear hash table */

    output( (long)ClearCode );

#ifdef SIGNED_COMPARE_SLOW
    while ( (c = readValue() ) != (unsigned) EOF ) {
#else
    while ( (c = readValue()) != EOF ) {
#endif

        in_count++;

        fcode = (long) (((long) c << maxbits) + ent);
        i = (((long)c << hshift) ^ ent);    /* xor hashing */

        if ( HashTabOf (i) == fcode ) {
            ent = CodeTabOf (i);
            continue;
        } else if ( (long) HashTabOf (i) < 0 )      /* empty slot */
            goto nomatch;
        disp = hsize_reg - i;           /* secondary hash (after G. Knott) */
        if ( i == 0 )
            disp = 1;
probe:
        if ( (i -= disp) < 0 )
            i += hsize_reg;

        if ( HashTabOf(i) == fcode ) {
            ent = CodeTabOf (i);
            continue;
        }
        if ( (long) HashTabOf(i) > 0 )
            goto probe;
nomatch:
        output ( (long) ent );
        out_count++;
        ent = c;
#ifdef SIGNED_COMPARE_SLOW
        if ( (unsigned) free_ent < (unsigned) maxmaxcode) {
#else
        if ( free_ent < maxmaxcode ) {
#endif
            CodeTabOf (i) = free_ent++; /* code -> hashtable */
            HashTabOf (i) = fcode;
        } else
                cl_block();
    }
    /*
     * Put out the final code.
     */
    output( (long)ent );
    out_count++;
    output( (long) EOFCode );

    return;
}

/*****************************************************************
 * TAG( output )
 *
 * Output the given code.
 * Inputs:
 *      code:   A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *              that n_bits =< (long) wordsize - 1.
 * Outputs:
 *      Outputs code to the file.
 * Assumptions:
 *      Chars are 8 bits long.
 * Algorithm:
 *      Maintain a GIFBITS character long buffer (so that 8 codes will
 * fit in it exactly).  Use the VAX insv instruction to insert each
 * code in turn.  When the buffer fills up empty it and start over.
 */

static unsigned long cur_accum = 0;
static int  cur_bits = 0;

static
unsigned long masks[] = { 0x0000, 0x0001, 0x0003, 0x0007, 0x000F,
                                  0x001F, 0x003F, 0x007F, 0x00FF,
                                  0x01FF, 0x03FF, 0x07FF, 0x0FFF,
                                  0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF };

static void
output(code)
    long  code;
{
    cur_accum &= masks[cur_bits];

    if (cur_bits > 0) {
	cur_accum |= ((long) code << cur_bits);
    } else {
	cur_accum = code;
    }

    cur_bits += n_bits;

    while (cur_bits >= 8 ) {
	char_out((unsigned int)(cur_accum & 0xff));
	cur_accum >>= 8;
	cur_bits -= 8;
    }

    /*
     * If the next entry is going to be too big for the code size,
     * then increase it, if possible.
     */

    if ((free_ent > maxcode)|| clear_flg ) {
	if (clear_flg) {
	    maxcode = MAXCODE(n_bits = g_init_bits);
	    clear_flg = 0;
	} else {
	    n_bits++;
	    if (n_bits == maxbits) {
		maxcode = maxmaxcode;
	    } else {
		maxcode = MAXCODE(n_bits);
	    }
	}
    }

    if (code == EOFCode) {
	/*
	 * At EOF, write the rest of the buffer.
	 */
        while (cur_bits > 0) {
	    char_out((unsigned int)(cur_accum & 0xff));
	    cur_accum >>= 8;
	    cur_bits -= 8;
	}
	flush_char();
    }
}

/*
 * Clear out the hash table
 */
static void
cl_block()             /* table clear for block compress */
{

        cl_hash ( (int) hsize );
        free_ent = ClearCode + 2;
        clear_flg = 1;

        output((long) ClearCode);
}

static void
cl_hash(hsize)          /* reset code table */
    int hsize;
{
    register int *htab_p = htab+hsize;
    register long i;
    register long m1 = -1;

    i = hsize - 16;
    do {                            /* might use Sys V memset(3) here */
	*(htab_p-16) = m1;
	*(htab_p-15) = m1;
	*(htab_p-14) = m1;
	*(htab_p-13) = m1;
	*(htab_p-12) = m1;
	*(htab_p-11) = m1;
	*(htab_p-10) = m1;
	*(htab_p-9) = m1;
	*(htab_p-8) = m1;
	*(htab_p-7) = m1;
	*(htab_p-6) = m1;
	*(htab_p-5) = m1;
	*(htab_p-4) = m1;
	*(htab_p-3) = m1;
	*(htab_p-2) = m1;
	*(htab_p-1) = m1;
	htab_p -= 16;
    } while ((i -= 16) >= 0);

    for (i += 16; i > 0; i--) {
	*--htab_p = m1;
    }
}


/******************************************************************************
 *
 * GIF Specific routines
 *
 ******************************************************************************/

/*
 * Number of characters so far in this 'packet'
 */
static int a_count;

/*
 * Set up the 'byte output' routine
 */
static void
char_init()
{
    a_count = 0;
    cur_accum = 0;
    cur_bits = 0;
}

/*
 * Define the storage for the packet accumulator
 */
static unsigned char accum[256];

/*
 * Add a character to the end of the current packet, and if it is 254
 * characters, flush the packet to disk.
 */
static void
char_out( c )
    int c;
{
    accum[a_count++] = c;
    if (a_count >= 254) {
	flush_char();
    }
}

/*
 * Flush the packet to disk, and reset the accumulator
 */
static void
flush_char()
{
    unsigned char c;
    if (a_count > 0) {
	c = a_count;
	ImgWrite(g_outfile, (CONST char *) &c, 1);
	ImgWrite(g_outfile, (CONST char *) accum, a_count);
	a_count = 0;
    }
}

/* The End */
#else
/*-----------------------------------------------------------------------
 *
 * miGIF Compression - mouse and ivo's GIF-compatible compression
 *
 *          -run length encoding compression routines-
 *
 * Copyright (C) 1998 Hutchison Avenue Software Corporation
 *               http://www.hasc.com
 *               info@hasc.com
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  This software is provided "AS IS." The Hutchison Avenue 
 * Software Corporation disclaims all warranties, either express or implied, 
 * including but not limited to implied warranties of merchantability and 
 * fitness for a particular purpose, with respect to this code and accompanying
 * documentation. 
 * 
 * The miGIF compression routines do not, strictly speaking, generate files 
 * conforming to the GIF spec, since the image data is not LZW-compressed 
 * (this is the point: in order to avoid transgression of the Unisys patent 
 * on the LZW algorithm.)  However, miGIF generates data streams that any 
 * reasonably sane LZW decompresser will decompress to what we want.
 *
 * miGIF compression uses run length encoding. It compresses horizontal runs 
 * of pixels of the same color. This type of compression gives good results
 * on images with many runs, for example images with lines, text and solid 
 * shapes on a solid-colored background. It gives little or no compression 
 * on images with few runs, for example digital or scanned photos.
 *
 *                               der Mouse
 *                      mouse@rodents.montreal.qc.ca
 *            7D C8 61 52 5D E7 2D 39  4E F1 31 3E E8 B3 27 4B
 *
 *                             ivo@hasc.com
 *
 * The Graphics Interchange Format(c) is the Copyright property of
 * CompuServe Incorporated.  GIF(sm) is a Service Mark property of
 * CompuServe Incorporated.
 *
 */

static int rl_pixel;
static int rl_basecode;
static int rl_count;
static int rl_table_pixel;
static int rl_table_max;
static int just_cleared;
static int out_bits;
static int out_bits_init;
static int out_count;
static int out_bump;
static int out_bump_init;
static int out_clear;
static int out_clear_init;
static int max_ocodes;
static int code_clear;
static int code_eof;
static unsigned int obuf;
static int obits;
static MFile *ofile;
static unsigned char oblock[256];
static int oblen;

/* Used only when debugging GIF compression code */
/* #define DEBUGGING_ENVARS */

#ifdef DEBUGGING_ENVARS

static int verbose_set = 0;
static int verbose;
#define VERBOSE (verbose_set?verbose:set_verbose())

static int set_verbose(void)
{
 verbose = !!getenv("GIF_VERBOSE");
 verbose_set = 1;
 return(verbose);
}

#else

#define VERBOSE 0

#endif


static const char *
binformat(v, nbits)
    unsigned int v;
    int nbits;
{
 static char bufs[8][64];
 static int bhand = 0;
 unsigned int bit;
 int bno;
 char *bp;

 bhand --;
 if (bhand < 0) bhand = (sizeof(bufs)/sizeof(bufs[0]))-1;
 bp = &bufs[bhand][0];
 for (bno=nbits-1,bit=1U<<bno;bno>=0;bno--,bit>>=1)
  { *bp++ = (v & bit) ? '1' : '0';
    if (((bno&3) == 0) && (bno != 0)) *bp++ = '.';
  }
 *bp = '\0';
 return(&bufs[bhand][0]);
}

static void write_block()
{
 int i;
 unsigned char c;

 if (VERBOSE)
  { printf("write_block %d:",oblen);
    for (i=0;i<oblen;i++) printf(" %02x",oblock[i]);
    printf("\n");
  }
 c = oblen;
 ImgWrite(ofile, (CONST char *) &c, 1);
 ImgWrite(ofile, &oblock[0], oblen);
 oblen = 0;
}

static void
block_out(c)
    unsigned char c;
{
 if (VERBOSE) printf("block_out %s\n",binformat(c,8));
 oblock[oblen++] = c;
 if (oblen >= 255) write_block();
}

static void block_flush()
{
 if (VERBOSE) printf("block_flush\n");
 if (oblen > 0) write_block();
}

static void output(val)
    int val;
{
 if (VERBOSE) printf("output %s [%s %d %d]\n",binformat(val,out_bits),binformat(obuf,obits),obits,out_bits);
 obuf |= val << obits;
 obits += out_bits;
 while (obits >= 8)
  { block_out(obuf&0xff);
    obuf >>= 8;
    obits -= 8;
  }
 if (VERBOSE) printf("output leaving [%s %d]\n",binformat(obuf,obits),obits);
}

static void output_flush()
{
 if (VERBOSE) printf("output_flush\n");
 if (obits > 0) block_out(obuf);
 block_flush();
}

static void did_clear()
{
 if (VERBOSE) printf("did_clear\n");
 out_bits = out_bits_init;
 out_bump = out_bump_init;
 out_clear = out_clear_init;
 out_count = 0;
 rl_table_max = 0;
 just_cleared = 1;
}

static void
output_plain(c)
    int c;
{
 if (VERBOSE) printf("output_plain %s\n",binformat(c,out_bits));
 just_cleared = 0;
 output(c);
 out_count ++;
 if (out_count >= out_bump)
  { out_bits ++;
    out_bump += 1 << (out_bits - 1);
  }
 if (out_count >= out_clear)
  { output(code_clear);
    did_clear();
  }
}

static unsigned int isqrt(x)
    unsigned int x;
{
 unsigned int r;
 unsigned int v;

 if (x < 2) return(x);
 for (v=x,r=1;v;v>>=2,r<<=1) ;
 while (1)
  { v = ((x / r) + r) / 2;
    if ((v == r) || (v == r+1)) return(r);
    r = v;
  }
}

static unsigned int
compute_triangle_count(count, nrepcodes)
    unsigned int count;
    unsigned int nrepcodes;
{
 unsigned int perrep;
 unsigned int cost;

 cost = 0;
 perrep = (nrepcodes * (nrepcodes+1)) / 2;
 while (count >= perrep)
  { cost += nrepcodes;
    count -= perrep;
  }
 if (count > 0)
  { unsigned int n;
    n = isqrt(count);
    while ((n*(n+1)) >= 2*count) n --;
    while ((n*(n+1)) < 2*count) n ++;
    cost += n;
  }
 return(cost);
}

static void max_out_clear()
{
 out_clear = max_ocodes;
}

static void reset_out_clear()
{
 out_clear = out_clear_init;
 if (out_count >= out_clear)
  { output(code_clear);
    did_clear();
  }
}

static void
rl_flush_fromclear(count)
    int count;
{
 int n;

 if (VERBOSE) printf("rl_flush_fromclear %d\n",count);
 max_out_clear();
 rl_table_pixel = rl_pixel;
 n = 1;
 while (count > 0)
  { if (n == 1)
     { rl_table_max = 1;
       output_plain(rl_pixel);
       count --;
     }
    else if (count >= n)
     { rl_table_max = n;
       output_plain(rl_basecode+n-2);
       count -= n;
     }
    else if (count == 1)
     { rl_table_max ++;
       output_plain(rl_pixel);
       count = 0;
     }
    else
     { rl_table_max ++;
       output_plain(rl_basecode+count-2);
       count = 0;
     }
    if (out_count == 0) n = 1; else n ++;
  }
 reset_out_clear();
 if (VERBOSE) printf("rl_flush_fromclear leaving table_max=%d\n",rl_table_max);
}

static void rl_flush_clearorrep(count)
    int count;
{
 int withclr;

 if (VERBOSE) printf("rl_flush_clearorrep %d\n",count);
 withclr = 1 + compute_triangle_count(count,max_ocodes);
 if (withclr < count)
  { output(code_clear);
    did_clear();
    rl_flush_fromclear(count);
  }
 else
  { for (;count>0;count--) output_plain(rl_pixel);
  }
}

static void rl_flush_withtable(count)
    int count;
{
 int repmax;
 int repleft;
 int leftover;

 if (VERBOSE) printf("rl_flush_withtable %d\n",count);
 repmax = count / rl_table_max;
 leftover = count % rl_table_max;
 repleft = (leftover ? 1 : 0);
 if (out_count+repmax+repleft > max_ocodes)
  { repmax = max_ocodes - out_count;
    leftover = count - (repmax * rl_table_max);
    repleft = 1 + compute_triangle_count(leftover,max_ocodes);
  }
 if (VERBOSE) printf("rl_flush_withtable repmax=%d leftover=%d repleft=%d\n",repmax,leftover,repleft);
 if (1+compute_triangle_count(count,max_ocodes) < repmax+repleft)
  { output(code_clear);
    did_clear();
    rl_flush_fromclear(count);
    return;
  }
 max_out_clear();
 for (;repmax>0;repmax--) output_plain(rl_basecode+rl_table_max-2);
 if (leftover)
  { if (just_cleared)
     { rl_flush_fromclear(leftover);
     }
    else if (leftover == 1)
     { output_plain(rl_pixel);
     }
    else
     { output_plain(rl_basecode+leftover-2);
     }
  }
 reset_out_clear();
}

static void rl_flush()
{
 if (VERBOSE) printf("rl_flush [ %d %d\n",rl_count,rl_pixel);
 if (rl_count == 1)
  { output_plain(rl_pixel);
    rl_count = 0;
    if (VERBOSE) printf("rl_flush ]\n");
    return;
  }
 if (just_cleared)
  { rl_flush_fromclear(rl_count);
  }
 else if ((rl_table_max < 2) || (rl_table_pixel != rl_pixel))
  { rl_flush_clearorrep(rl_count);
  }
 else
  { rl_flush_withtable(rl_count);
  }
 if (VERBOSE) printf("rl_flush ]\n");
 rl_count = 0;
}


static void compress( init_bits, handle, readValue )
    int init_bits;
    MFile *handle;
    ifunptr readValue;
{
 int c;

 ofile = handle;
 obuf = 0;
 obits = 0;
 oblen = 0;
 code_clear = 1 << (init_bits - 1);
 code_eof = code_clear + 1;
 rl_basecode = code_eof + 1;
 out_bump_init = (1 << (init_bits - 1)) - 1;
 /* for images with a lot of runs, making out_clear_init larger will
    give better compression. */ 
 out_clear_init = (init_bits <= 3) ? 9 : (out_bump_init-1);
#ifdef DEBUGGING_ENVARS
  { const char *ocienv;
    ocienv = getenv("GIF_OUT_CLEAR_INIT");
    if (ocienv)
     { out_clear_init = atoi(ocienv);
       if (VERBOSE) printf("[overriding out_clear_init to %d]\n",out_clear_init);
     }
  }
#endif
 out_bits_init = init_bits;
 max_ocodes = (1 << GIFBITS) - ((1 << (out_bits_init - 1)) + 3);
 did_clear();
 output(code_clear);
 rl_count = 0;
 while (1)
  { c = readValue();
    if ((rl_count > 0) && (c != rl_pixel)) rl_flush();
    if (c == EOF) break;
    if (rl_pixel == c)
     { rl_count ++;
     }
    else
     { rl_pixel = c;
       rl_count = 1;
     }
  }
 output(code_eof);
 output_flush();
}

/*-----------------------------------------------------------------------
 *
 * End of miGIF section  - See copyright notice at start of section.
 *
 *-----------------------------------------------------------------------*/


#endif
