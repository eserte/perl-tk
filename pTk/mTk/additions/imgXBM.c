/*
 * imgXBM.c --
 *
 *	A photo image file handler for XBM files.
 *
 * Written by:
 *	Jan Nijtmans
 *	CMG (Computer Management Group) Arnhem B.V.
 *	email: nijtmans@worldaccess.nl (private)
 *	       Jan.Nijtmans@cmg.nl (work)
 *	url:   http://www.worldaccess.nl/~nijtmans/
 *
 */
#define NEED_REAL_STDIO 
#include "imgInt.h"

/* constants used only in this file */

#define MAX_BUFFER 4096

/*
 * The following data structure is used to describe the state of
 * parsing a bitmap file or string.  It is used for communication
 * between TkGetBitmapData and NextBitmapWord.
 */

#define MAX_WORD_LENGTH 100
typedef struct ParseInfo {
    char *string;		/* Next character of string data for bitmap,
				 * or NULL if bitmap is being read from
				 * file. */
    int stringlength;           /* length of the string */
    Tcl_Channel chan;           /* Channel containing bitmap data, or NULL
    				 * if no channel. */
    FILE *file;			/* File containing bitmap data, or NULL
				 * if no file. */
    char word[MAX_WORD_LENGTH+1];
				/* Current word of bitmap data, NULL
				 * terminated. */
    int wordLength;		/* Number of non-NULL bytes in word. */
} ParseInfo;

/*
 * The format record for the XBM file format:
 */

static int		ChnMatchXBM _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Channel chan,
			    Arg fileName, Arg formatString, int *widthPtr,
			    int *heightPtr));
static int		FileMatchXBM _ANSI_ARGS_((Tcl_Interp *interp, FILE *f, 
			    Arg fileName, Arg formatString, int *widthPtr,
			    int *heightPtr));
static int      	ObjMatchXBM _ANSI_ARGS_((Tcl_Interp *interp, struct Tcl_Obj *dataObj,
		            Arg formatString, int *widthPtr, int *heightPtr));
static int		ChnReadXBM  _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Channel chan, Arg fileName,
			    Arg formatString, Tk_PhotoHandle imageHandle,
			    int destX, int destY, int width, int height,
			    int srcX, int srcY));
static int		FileReadXBM  _ANSI_ARGS_((Tcl_Interp *interp,
			    FILE *f, Arg fileName, Arg formatString,
			    Tk_PhotoHandle imageHandle, int destX, int destY,
			    int width, int height, int srcX, int srcY));
static int	        ObjReadXBM _ANSI_ARGS_((Tcl_Interp *interp,
			    struct Tcl_Obj *dataObj, Arg formatString,
              		    Tk_PhotoHandle imageHandle, int destX, int destY,
		            int width, int height, int srcX, int srcY));
static int	        StringWriteXBM _ANSI_ARGS_((Tcl_Interp *interp,
               		    Tcl_DString *dataPtr, Arg formatString,
		            Tk_PhotoImageBlock *blockPtr));
static int              FileWriteXBM _ANSI_ARGS_((Tcl_Interp *interp,
                            char *fileName, Arg formatString,
                            Tk_PhotoImageBlock *blockPtr));

static int		CommonReadXBM _ANSI_ARGS_((Tcl_Interp *interp,
			    ParseInfo *parseInfo,
			    Arg formatString, Tk_PhotoHandle imageHandle,
			    int destX, int destY, int width, int height,
			    int srcX, int srcY));
static int		CommonWriteXBM _ANSI_ARGS_((Tcl_Interp *interp,
			    char *fileName, Tcl_DString *dataPtr,
			    Arg formatString, Tk_PhotoImageBlock *blockPtr));

Tk_PhotoImageFormat imgFmtXBM = {
    "XBM",					/* name */
    ChnMatchXBM,	/* fileMatchProc */
    ObjMatchXBM,	/* stringMatchProc */
    ChnReadXBM,		/* fileReadProc */
    ObjReadXBM,		/* stringReadProc */
    FileWriteXBM,	/* fileWriteProc */
    StringWriteXBM	/* stringWriteProc */
};

/*
 * Prototypes for local procedures defined in this file:
 */

static int	ReadXBMFileHeader _ANSI_ARGS_((ParseInfo *parseInfo,
			int *widthPtr, int *heightPtr));
static int	NextBitmapWord _ANSI_ARGS_((ParseInfo *parseInfoPtr));

/*
 *----------------------------------------------------------------------
 *
 * ObjMatchXBM --
 *
 *	This procedure is invoked by the photo image type to see if
 *	a datastring contains image data in XBM format.
 *
 * Results:
 *	The return value is >0 if the first characters in data look
 *	like XBM data, and 0 otherwise.
 *
 * Side effects:
 *	none
 *
 *----------------------------------------------------------------------
 */
static int
ObjMatchXBM(interp, dataObj, formatString, widthPtr, heightPtr)
    Tcl_Interp *interp;
    struct Tcl_Obj *dataObj;	/* The data supplied by the image */
    Arg formatString;		/* User-specified format string, or NULL. */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here if the file is a valid
				 * raw XBM file. */
{
    ParseInfo parseInfo;

    parseInfo.string = ImgGetStringFromObj(dataObj, &parseInfo.stringlength);
    return ReadXBMFileHeader(&parseInfo, widthPtr, heightPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * ChnMatchXBM --
 *
 *	This procedure is invoked by the photo image type to see if
 *	a channel contains image data in XBM format.
 *
 * Results:
 *	The return value is >0 if the first characters in channel "chan"
 *	look like XBM data, and 0 otherwise.
 *
 * Side effects:
 *	The access position in chan may change.
 *
 *----------------------------------------------------------------------
 */

static int
ChnMatchXBM(interp, chan, fileName, formatString, widthPtr, heightPtr)
    Tcl_Interp *interp;
    Tcl_Channel chan;		/* The image channel, open for reading. */
    Arg fileName;		/* The name of the image file. */
    Arg formatString;		/* User-specified format string, or NULL. */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here if the file is a valid
				 * raw XBM file. */
{
    ParseInfo parseInfo;

    parseInfo.string = NULL;
    parseInfo.chan = chan;

    return ReadXBMFileHeader(&parseInfo, widthPtr, heightPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * FileMatchXBM --
 *
 *	This procedure is invoked by the photo image type to see if
 *	a file contains image data in XBM format.
 *
 * Results:
 *	The return value is >0 if the first characters in file "f" look
 *	like XBM data, and 0 otherwise.
 *
 * Side effects:
 *	The access position in f may change.
 *
 *----------------------------------------------------------------------
 */

static int
FileMatchXBM(interp, f, fileName, formatString, widthPtr, heightPtr)
    Tcl_Interp *interp;
    FILE *f;			/* The image file, open for reading. */
    Arg fileName;		/* The name of the image file. */
    Arg formatString;		/* User-specified format string, or NULL. */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here if the file is a valid
				 * raw XBM file. */
{
    ParseInfo parseInfo;

    parseInfo.string = NULL;
    parseInfo.chan = NULL;
    parseInfo.file = f;

    return ReadXBMFileHeader(&parseInfo, widthPtr, heightPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * CommonReadXBM --
 *
 *	This procedure is called by the photo image type to read
 *	XBM format data from a file or string and write it into a
 *	given photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	The access position in file f is changed (if read from file)
 *	and new data is added to the image given by imageHandle.
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
CommonReadXBM(interp, parseInfo, formatString, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    ParseInfo *parseInfo;
    Arg formatString;		/* User-specified format string, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
    myblock bl;
    int fileWidth, fileHeight;
    int numBytes, row, col, value, i;
    unsigned char *data, *pixelPtr;
    char *end;

    ReadXBMFileHeader(parseInfo, &fileWidth, &fileHeight);

    if ((srcX + width) > fileWidth) {
	width = fileWidth - srcX;
    }
    if ((srcY + height) > fileHeight) {
	height = fileHeight - srcY;
    }
    if ((width <= 0) || (height <= 0)
	|| (srcX >= fileWidth) || (srcY >= fileHeight)) {
	return TCL_OK;
    }

    Tk_PhotoExpand(imageHandle, destX + width, destY + height);

    numBytes = ((fileWidth+7)/8)*32;
    block.width = fileWidth;
    block.height = 1;
    block.pixelSize = 4;
    block.offset[0] = 0;
    block.offset[1] = 1;
    block.offset[2] = 2;
    block.offset[3] = 3;

    data = (unsigned char *) ckalloc((unsigned) numBytes);
    block.pixelPtr = data + srcX*4;
    for (row = 0; row < srcY + height; row++) {
	pixelPtr = data;
        for (col = 0; col<(numBytes/32); col++) {
	    if (NextBitmapWord(parseInfo) != TCL_OK) {
		ckfree((char *) data);
		return TCL_ERROR;
	    }
	    value = (int) strtol(parseInfo->word, &end, 0);
	    if (end == parseInfo->word) {
	    	ckfree((char *) data);
	    	return TCL_ERROR;
	    }
	    for (i=0; i<8; i++) {
	        *pixelPtr++ = 0;
	        *pixelPtr++ = 0;
	        *pixelPtr++ = 0;
	        *pixelPtr++ = (value & 0x1)? 255:0;
	  	value >>= 1;
	    }
	}
	if (row >= srcY) {
	    ImgPhotoPutBlock(imageHandle, &block, destX, destY++, width, 1);
	}
    }
    ckfree((char *) data);
    return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * ChnReadXBM --
 *
 *	This procedure is called by the photo image type to read
 *	XBM format data from a channel and write it into a given
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
ChnReadXBM(interp, chan, fileName, formatString, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    Tcl_Channel chan;		/* The image channel, open for reading. */
    Arg fileName;		/* The name of the image file. */
    Arg formatString;		/* User-specified format string, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
  ParseInfo parseInfo;

  parseInfo.string = NULL;
  parseInfo.chan = chan;

  return CommonReadXBM(interp, &parseInfo, formatString, imageHandle,
		 destX, destY, width, height, srcX, srcY);
}


/*
 *----------------------------------------------------------------------
 *
 * FileReadXBM --
 *
 *	This procedure is called by the photo image type to read
 *	XBM format data from a file and write it into a given
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

static int
FileReadXBM(interp, f, fileName, formatString, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    FILE *f;			/* The image file, open for reading. */
    Arg fileName;		/* The name of the image file. */
    Arg formatString;		/* User-specified format string, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
  ParseInfo parseInfo;

  parseInfo.string = NULL;
  parseInfo.chan = NULL;
  parseInfo.file = f;

  return CommonReadXBM(interp, &parseInfo, formatString, imageHandle,
		 destX, destY, width, height, srcX, srcY);
}


/*
 *----------------------------------------------------------------------
 *
 * ObjReadXBM --
 *
 *	This procedure is called by the photo image type to read
 *	XBM format data from a string and write it into a given
 *	photo image.
 *
 * Results:
 *	A standard TCL completion code.  If TCL_ERROR is returned
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	New data is added to the image given by imageHandle.
 *
 *----------------------------------------------------------------------
 */

static int
ObjReadXBM(interp, dataObj, formatString, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    struct Tcl_Obj *dataObj;
    Arg formatString;		/* User-specified format string, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{
  ParseInfo parseInfo;

  parseInfo.string = ImgGetStringFromObj(dataObj, &parseInfo.stringlength);

  return CommonReadXBM(interp, &parseInfo, formatString, imageHandle,
		 destX, destY, width, height, srcX, srcY);
}

/*
 *----------------------------------------------------------------------
 *
 * ReadXBMFileHeader --
 *
 *	This procedure reads the XBM header from the beginning of a
 *	XBM file and returns information from the header.
 *
 * Results:
 *	The return value is 1 if file "f" appears to start with a valid
 *      XBM header, and 0 otherwise.  If the header is valid,
 *	then *widthPtr and *heightPtr are modified to hold the
 *	dimensions of the image and *numColors holds the number of
 *	colors and byteSize the number of bytes used for 1 pixel.
 *
 * Side effects:
 *	The access position in f advances.
 *
 *----------------------------------------------------------------------
 */

#define UCHAR(c) ((unsigned char) (c))

/*
 *----------------------------------------------------------------------
 *
 * NextBitmapWord --
 *
 *	This procedure retrieves the next word of information (stuff
 *	between commas or white space) from a bitmap description.
 *
 * Results:
 *	Returns TCL_OK if all went well.  In this case the next word,
 *	and its length, will be availble in *parseInfoPtr.  If the end
 *	of the bitmap description was reached then TCL_ERROR is returned.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
NextBitmapWord(parseInfoPtr)
    ParseInfo *parseInfoPtr;		/* Describes what we're reading
					 * and where we are in it. */
{
    char *src, *dst;
    int c;

    parseInfoPtr->wordLength = 0;
    dst = parseInfoPtr->word;
    if (parseInfoPtr->string != NULL) {
	int len = parseInfoPtr->stringlength;
	for (src = parseInfoPtr->string; isspace(UCHAR(*src)) || (*src == ',');
		src++,len--) {
	    if ((*src == 0) || len <= 0) {
		return TCL_ERROR;
	    }
	}
	for ( ; !isspace(UCHAR(*src)) && (*src != ',') && (*src != 0) && (len > 0);
		src++,len--) {
	    *dst++ = *src;
	    parseInfoPtr->wordLength++;
	    if (parseInfoPtr->wordLength > MAX_WORD_LENGTH) {
		return TCL_ERROR;
	    }
	}
	parseInfoPtr->string = src;
	parseInfoPtr->stringlength = len;
    } else if (parseInfoPtr->chan != NULL) {
        char buf;
        int num;
	for (num=Tcl_Read(parseInfoPtr->chan,&buf,1); isspace(UCHAR(buf)) || (buf == ',');
		num=Tcl_Read(parseInfoPtr->chan,&buf,1)) {
	    if (buf == EOF) {
		return TCL_ERROR;
	    }
	}
	for ( ; !isspace(UCHAR(buf)) && (buf != ',') && (num != 0);
		num=Tcl_Read(parseInfoPtr->chan,&buf,1)) {
	    *dst = buf;
	    dst++;
	    parseInfoPtr->wordLength++;
	    if (parseInfoPtr->wordLength > MAX_WORD_LENGTH) {
		return TCL_ERROR;
	    }
	}
    } else {
	for (c = fgetc(parseInfoPtr->file); isspace(UCHAR(c)) || (c == ',');
		c = fgetc(parseInfoPtr->file)) {
	    if (c == EOF) {
		return TCL_ERROR;
	    }
	}
	for ( ; !isspace(UCHAR(c)) && (c != ',') && (c != EOF);
		c = fgetc(parseInfoPtr->file)) {
	    *dst = c;
	    dst++;
	    parseInfoPtr->wordLength++;
	    if (parseInfoPtr->wordLength > MAX_WORD_LENGTH) {
		return TCL_ERROR;
	    }
	}
    }
    if (parseInfoPtr->wordLength == 0) {
	return TCL_ERROR;
    }
    parseInfoPtr->word[parseInfoPtr->wordLength] = 0;
    return TCL_OK;
}

static int
ReadXBMFileHeader(pi, widthPtr, heightPtr)
    ParseInfo *pi;
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here. */
{
    int width, height, hotX, hotY;
    char *end;

    /*
     * Parse the lines that define the dimensions of the bitmap,
     * plus the first line that defines the bitmap data (it declares
     * the name of a data variable but doesn't include any actual
     * data).  These lines look something like the following:
     *
     *		#define foo_width 16
     *		#define foo_height 16
     *		#define foo_x_hot 3
     *		#define foo_y_hot 3
     *		static char foo_bits[] = {
     *
     * The x_hot and y_hot lines may or may not be present.  It's
     * important to check for "char" in the last line, in order to
     * reject old X10-style bitmaps that used shorts.
     */

    width = 0;
    height = 0;
    hotX = -1;
    hotY = -1;
    while (1) {
	if (NextBitmapWord(pi) != TCL_OK) {
	    return 0;
	}
	if ((pi->wordLength >= 6) && (pi->word[pi->wordLength-6] == '_')
		&& (strcmp(pi->word+pi->wordLength-6, "_width") == 0)) {
	    if (NextBitmapWord(pi) != TCL_OK) {
		return 0;
	    }
	    width = strtol(pi->word, &end, 0);
	    if ((end == pi->word) || (*end != 0)) {
		return 0;
	    }
	} else if ((pi->wordLength >= 7) && (pi->word[pi->wordLength-7] == '_')
		&& (strcmp(pi->word+pi->wordLength-7, "_height") == 0)) {
	    if (NextBitmapWord(pi) != TCL_OK) {
		return 0;
	    }
	    height = strtol(pi->word, &end, 0);
	    if ((end == pi->word) || (*end != 0)) {
		return 0;
	    }
	} else if ((pi->wordLength >= 6) && (pi->word[pi->wordLength-6] == '_')
		&& (strcmp(pi->word+pi->wordLength-6, "_x_hot") == 0)) {
	    if (NextBitmapWord(pi) != TCL_OK) {
		return 0;
	    }
	    hotX = strtol(pi->word, &end, 0);
	    if ((end == pi->word) || (*end != 0)) {
		return 0;
	    }
	} else if ((pi->wordLength >= 6) && (pi->word[pi->wordLength-6] == '_')
		&& (strcmp(pi->word+pi->wordLength-6, "_y_hot") == 0)) {
	    if (NextBitmapWord(pi) != TCL_OK) {
		return 0;
	    }
	    hotY = strtol(pi->word, &end, 0);
	    if ((end == pi->word) || (*end != 0)) {
		return 0;
	    }
	} else if ((pi->word[0] == 'c') && (strcmp(pi->word, "char") == 0)) {
	    while (1) {
		if (NextBitmapWord(pi) != TCL_OK) {
		    return 0;
		}
		if ((pi->word[0] == '{') && (pi->word[1] == 0)) {
		    goto getData;
		}
	    }
	} else if ((pi->word[0] == '{') && (pi->word[1] == 0)) {

	    return 0;
	}
    }

getData:
    *widthPtr = width;
    *heightPtr = height;
    return 1;
}


/*
 *----------------------------------------------------------------------
 *
 * FileWriteXBM
 *
 *	Writes a XBM image to a file. Just calls CommonWriteXBM
 *      with appropriate arguments.
 *
 * Results:
 *	Returns the return value of CommonWriteXBM
 *
 * Side effects:
 *	A file is (hopefully) created on success.
 *
 *----------------------------------------------------------------------
 */
static int
FileWriteXBM(interp, fileName, formatString, blockPtr)
    Tcl_Interp *interp;
    char *fileName;
    Arg formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    return CommonWriteXBM(interp, fileName, (Tcl_DString *)NULL, formatString, blockPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * StringWriteXBM
 *
 *	Writes a XBM image to a string. Just calls CommonWriteXBM
 *      with appropriate arguments.
 *
 * Results:
 *	Returns the return value of CommonWriteXBM
 *
 * Side effects:
 *	The Tcl_DString dataPtr is modified on success.
 *
 *----------------------------------------------------------------------
 */
static int	        
StringWriteXBM(interp, dataPtr, formatString, blockPtr) 
    Tcl_Interp *interp;
    Tcl_DString *dataPtr;
    Arg formatString;
    Tk_PhotoImageBlock *blockPtr;
{
  return CommonWriteXBM(interp, (char *) NULL, dataPtr, formatString, blockPtr);
}


/*
 * Yes, I know these macros are dangerous. But it should work fine
 */
#define WRITE(buf) { if (f) fputs(buf, f); else Tcl_DStringAppend(dataPtr, buf, -1);}

/*
 *----------------------------------------------------------------------
 *
 * CommonWriteXBM
 *
 *	This procedure writes a XBM image to the file filename 
 *      (if filename != NULL) or to dataPtr.
 *
 * Results:
 *	Returns TCL_OK on success, or TCL_ERROR on error.
 *
 * Side effects:
 *	varies (see StringWriteXBM and FileWriteXBM)
 *
 *----------------------------------------------------------------------
 */
static int
CommonWriteXBM(interp, fileName, dataPtr, formatString, blockPtr)
    Tcl_Interp *interp;
    char *fileName;
    Tcl_DString *dataPtr;
    Arg formatString;    
    Tk_PhotoImageBlock *blockPtr;
{
    FILE *f = (FILE *) NULL;
    char buffer[256];
    static CONST char format[] =
"#define %s_width %d\n\
#define %s_height %d\n\
static char %s_bits[] = {\n";

    /* open the output file (if needed) */
    if (fileName) {
      f = fopen(fileName, "w");
      if (f == (FILE *)NULL) {
	Tcl_AppendResult(interp, ": cannot open file for writing",
		(char *)NULL);
	return TCL_ERROR;
      }
    }

    /* compute image name */
    if (f) {
	char *p;
	p = strrchr(fileName, '/');
	if (p) {
	    fileName = p;
	}
	p = strrchr(fileName, '\\');
	if (p) {
	    fileName = p;
	}
	p = strrchr(fileName, ':');
	if (p) {
	    fileName = p;
	}
	p = strchr(fileName, '.');
	if (p) {
	    *p = 0;
	}
    } else {
        fileName = "unknown";
    }
    
    sprintf(buffer, format, fileName, blockPtr->width, fileName,
	    blockPtr->height, fileName);
    WRITE(buffer);

    /* write the file (not implemented yet) */

    WRITE("/* sorry, not implemented yet */\n")
    
    /* finally: the closing bracket */
    WRITE("};");

    /* close the file */
    if (f) {
	fclose(f);
    }
    return TCL_OK;
}
