/*
 * imgTIFF.c --
 *
 * A photo image file handler for TIFF files.
 *
 * Uses the libtiff.so library, which is dynamically
 * loaded only when used.
 *
 */

/* Author : Jan Nijtmans */
/* Date   : 7/16/97      */

#include "imgInt.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#if defined(__STDC__) || defined(HAS_STDARG)
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#ifdef __WIN32__
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#define WIN32_LEAN_AND_MEAN
#endif

#ifdef MAC_TCL
#include "libtiff:tiffio.h"
#else
#ifdef HAVE_TIFF_H
#   include <tiffio.h>
#else
#   include "libtiff/tiffio.h"
#endif
#endif

#ifdef __WIN32__
#define TIFF_LIB_NAME "tiff.dll"
#endif

#ifndef TIFF_LIB_NAME
#define TIFF_LIB_NAME "libtiff.so"
#endif

/*
 * Prototypes for local procedures defined in this file:
 */

static int ChnMatchTIFF _ANSI_ARGS_((Tcl_Channel chan, char *fileName,
	char *formatString, int *widthPtr, int *heightPtr));
static int FileMatchTIFF _ANSI_ARGS_((FILE *f, char *fileName,
	char *formatString, int *widthPtr, int *heightPtr));
static int ObjMatchTIFF _ANSI_ARGS_((struct Tcl_Obj *dataObj,
	char *formatString, int *widthPtr, int *heightPtr));
static int ChnReadTIFF _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Channel chan,
	char *fileName, char *formatString, Tk_PhotoHandle imageHandle,
	int destX, int destY, int width, int height, int srcX, int srcY));
static int FileReadTIFF _ANSI_ARGS_((Tcl_Interp *interp, FILE *f,
	char *fileName, char *formatString, Tk_PhotoHandle imageHandle,
	int destX, int destY, int width, int height, int srcX, int srcY));
static int ObjReadTIFF _ANSI_ARGS_((Tcl_Interp *interp,
	struct Tcl_Obj *dataObj, char *formatString,
	Tk_PhotoHandle imageHandle, int destX, int destY,
	int width, int height, int srcX, int srcY));
static int FileWriteTIFF _ANSI_ARGS_((Tcl_Interp *interp, char *filename,
	char *formatString, Tk_PhotoImageBlock *blockPtr));
static int StringWriteTIFF _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_DString *dataPtr, char *formatString,
	Tk_PhotoImageBlock *blockPtr));

Tk_PhotoImageFormat imgFmtTIFF = {
    "TIFF",					/* name */
    (Tk_ImageFileMatchProc *) ChnMatchTIFF,	/* fileMatchProc */
    (Tk_ImageStringMatchProc *) ObjMatchTIFF,	/* stringMatchProc */
    (Tk_ImageFileReadProc *) ChnReadTIFF,	/* fileReadProc */
    (Tk_ImageStringReadProc *) ObjReadTIFF,	/* stringReadProc */
    FileWriteTIFF,				/* fileWriteProc */
    (Tk_ImageStringWriteProc *) StringWriteTIFF,/* stringWriteProc */
};

Tk_PhotoImageFormat imgOldFmtTIFF = {
    "TIFF",					/* name */
    (Tk_ImageFileMatchProc *) FileMatchTIFF,	/* fileMatchProc */
    (Tk_ImageStringMatchProc *) ObjMatchTIFF,	/* stringMatchProc */
    (Tk_ImageFileReadProc *) FileReadTIFF,	/* fileReadProc */
    (Tk_ImageStringReadProc *) ObjReadTIFF,	/* stringReadProc */
    FileWriteTIFF,				/* fileWriteProc */
    (Tk_ImageStringWriteProc *) StringWriteTIFF,/* stringWriteProc */
};

/*
 * We use Tk_ParseArgv to parse any options supplied in the format string.
 */

static char *compression;	/* static variables hold parse results */
				/* ... icky, and not reentrant ... */

static Tk_ArgvInfo writeOptTable[] = {
    {"-compression", TK_ARGV_STRING, "none", (char *) &compression,
	"Select compression method"},
    {NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,
	(char *) NULL}
};

static struct TiffFunctions {
    VOID *handle;
    void (* Close) _ANSI_ARGS_((TIFF *));
    int (* GetField) _ANSI_ARGS_(TCL_VARARGS(TIFF *, tif));
    int (* GetFieldDefaulted) _ANSI_ARGS_(TCL_VARARGS(TIFF *,tif));
    TIFF* (* Open) _ANSI_ARGS_((CONST char*, CONST char*));
    int (* ReadEncodedStrip) _ANSI_ARGS_((TIFF*, tstrip_t, tdata_t, tsize_t));
    int (* ReadRGBAImage) _ANSI_ARGS_((TIFF *, uint32, uint32, uint32*, int));
    int (* ReadTile) _ANSI_ARGS_((TIFF *, uint32, uint32, uint32*, int));
    int (* SetField) _ANSI_ARGS_(TCL_VARARGS(TIFF *, tif));
    tsize_t (* TileSize) _ANSI_ARGS_((TIFF*));
    int (* WriteEncodedStrip) _ANSI_ARGS_((TIFF*, tstrip_t, tdata_t, tsize_t));
    void (* free) _ANSI_ARGS_((tdata_t));
    tdata_t (* malloc) _ANSI_ARGS_((tsize_t));
    tdata_t (* memcpy) _ANSI_ARGS_((tdata_t, tdata_t, tsize_t));
    tdata_t (* realloc) _ANSI_ARGS_((tdata_t, tsize_t));
    TIFFErrorHandler (* SetErrorHandler) _ANSI_ARGS_((TIFFErrorHandler));
    TIFFErrorHandler (* SetWarningHandler) _ANSI_ARGS_((TIFFErrorHandler));
    TIFF* (* ClientOpen) _ANSI_ARGS_((CONST char*, CONST char*, VOID *,
	    TIFFReadWriteProc, TIFFReadWriteProc, TIFFSeekProc,
	    TIFFCloseProc, TIFFSizeProc, TIFFMapFileProc, TIFFUnmapFileProc));
    TIFFCodec* (*RegisterCODEC) _ANSI_ARGS_((uint16, CONST char*, VOID *));
    void (* Error) _ANSI_ARGS_(TCL_VARARGS(CONST char *, arg1));
    int (* PredictorInit) _ANSI_ARGS_((TIFF *));
    void (* MergeFieldInfo) _ANSI_ARGS_((TIFF *, CONST VOID *, int));
    int (* FlushData1) _ANSI_ARGS_((TIFF *));
    void (* NoPostDecode) _ANSI_ARGS_((TIFF *, VOID*, tsize_t));
    tsize_t (* TileRowSize) _ANSI_ARGS_((TIFF *));
    tsize_t (* ScanlineSize) _ANSI_ARGS_((TIFF *));
    void (* setByteArray) _ANSI_ARGS_((VOID **, VOID*, long));
    int (* VSetField) _ANSI_ARGS_((TIFF *, ttag_t, va_list));
} tiff = {0};

static char *symbols[] = {
    "TIFFClose",
    "TIFFGetField",
    "TIFFGetFieldDefaulted",
    "TIFFOpen",
    "TIFFReadEncodedStrip",
    "TIFFReadRGBAImage",
    "TIFFReadTile",
    "TIFFSetField",
    "TIFFTileSize",
    "TIFFWriteEncodedStrip",
    /* The following symbols are not crucial. If they cannot be
	found, just don't use them. The ClientOpen function is
	more difficult to emulate, but even that is possible. */
    "_TIFFfree",
    "_TIFFmalloc",
    "_TIFFmemcpy",
    "_TIFFrealloc",
    "TIFFSetErrorHandler",
    "TIFFSetWarningHandler",
    "TIFFClientOpen",
    "TIFFRegisterCODEC",
    "TIFFError",
    "TIFFPredictorInit",
    "_TIFFMergeFieldInfo",
    "TIFFFlushData1",
    "_TIFFNoPostDecode",
    "TIFFTileRowSize",
    "TIFFScanlineSize",
    "_TIFFsetByteArray",
    "TIFFVSetField",
    (char *) NULL
};

/*
 * Prototypes for local procedures defined in this file:
 */

static int getint _ANSI_ARGS_((unsigned char *buf, TIFFDataType format,
	int order));
static int CommonMatchTIFF _ANSI_ARGS_((MFile *handle, int *widhtPtr,
	int *heightPtr));
static int CommonReadTIFF _ANSI_ARGS_((Tcl_Interp *interp, TIFF *tif,
	char *formatString, Tk_PhotoHandle imageHandle, int destX, int destY,
	int width, int height, int srcX, int srcY));
static int CommonWriteTIFF _ANSI_ARGS_((Tcl_Interp *interp, TIFF *tif,
	char *formatString, Tk_PhotoImageBlock *blockPtr));
static int load_tiff_library _ANSI_ARGS_((Tcl_Interp *interp));
static void  _TIFFerr    _ANSI_ARGS_((CONST char *, CONST char *, va_list));
static void  _TIFFwarn   _ANSI_ARGS_((CONST char *, CONST char *, va_list));
static int tiff_vsprintf _ANSI_ARGS_((char *dest,
	CONST char *format, va_list args));
void ImgTIFFfree _ANSI_ARGS_((tdata_t data));
tdata_t ImgTIFFmalloc _ANSI_ARGS_((tsize_t size));
tdata_t ImgTIFFrealloc _ANSI_ARGS_((tdata_t data, tsize_t size));
tdata_t ImgTIFFmemcpy _ANSI_ARGS_((tdata_t, tdata_t, tsize_t));
void ImgTIFFError _ANSI_ARGS_(TCL_VARARGS(CONST char *, module));
int ImgTIFFPredictorInit _ANSI_ARGS_((TIFF *tif));
void ImgTIFFMergeFieldInfo _ANSI_ARGS_((TIFF* tif, CONST VOID *voidp, int i));
int ImgTIFFFlushData1 _ANSI_ARGS_((TIFF *tif));
void ImgTIFFNoPostDecode _ANSI_ARGS_((TIFF *, VOID *, tsize_t));
tsize_t ImgTIFFTileRowSize _ANSI_ARGS_((TIFF *));
tsize_t ImgTIFFScanlineSize _ANSI_ARGS_((TIFF *));
void ImgTIFFsetByteArray _ANSI_ARGS_((VOID **, VOID*, long));
int ImgTIFFSetField _ANSI_ARGS_(TCL_VARARGS(TIFF *, tif));
tsize_t ImgTIFFTileSize _ANSI_ARGS_((TIFF*));

/*
 * External hooks to functions, so they can be called from
 * imgTIFFzip.c and imgTIFFjpeg.c as well.
 */

void ImgTIFFfree (data)
    tdata_t data;
{
    if (tiff.free) {
	tiff.free(data);
    } else {
	ckfree((char *) data);
    }
}

tdata_t ImgTIFFmalloc(size)
    tsize_t size;
{
    if (tiff.malloc) {
	return tiff.malloc(size);
    } else {
	return ckalloc(size);
    }
}

tdata_t ImgTIFFrealloc(data, size)
    tdata_t data;
    tsize_t size;
{
    if (tiff.realloc) {
	return tiff.realloc(data, size);
    } else {
	return Tcl_Realloc(data, size);
    }
}

tdata_t
ImgTIFFmemcpy(a,b,c)
     tdata_t a;
     tdata_t b;
     tsize_t c;
{
    return tiff.memcpy(a,b,c);
}

void
ImgTIFFError TCL_VARARGS_DEF(CONST char *, arg1)
{
    va_list ap;
    CONST char* module;
    CONST char* fmt;

    module = TCL_VARARGS_START(CONST char *, arg1, ap);
    fmt =  va_arg(ap, CONST char *);
    _TIFFerr(module, fmt, ap);
    va_end(ap);
}

int
ImgTIFFPredictorInit(tif)
    TIFF *tif;
{
    return tiff.PredictorInit(tif);
}

void
ImgTIFFMergeFieldInfo(tif, voidp, i)
    TIFF* tif;
    CONST VOID *voidp;
    int i;
{
    tiff.MergeFieldInfo(tif, voidp, i);
}

int
ImgTIFFFlushData1(tif)
    TIFF *tif;
{
    return tiff.FlushData1(tif);
}

void
ImgTIFFNoPostDecode(tif,a,b)
    TIFF * tif;
    VOID *a;
    tsize_t b;
{
    tiff.NoPostDecode(tif, a, b);
}

tsize_t
ImgTIFFTileRowSize(tif)
    TIFF * tif;
{
    return tiff.TileRowSize(tif);
}

tsize_t
ImgTIFFScanlineSize(tif)
    TIFF *tif;
{
    return tiff.ScanlineSize(tif);
}

void
ImgTIFFsetByteArray(a,b,c)
    VOID **a;
    VOID *b;
    long c;
{
    tiff.setByteArray(a,b,c);
}

int
ImgTIFFSetField TCL_VARARGS_DEF(TIFF*, arg1)
{
    va_list ap;
    TIFF* tif;
    ttag_t tag;
    int result;

    tif = TCL_VARARGS_START(TIFF*, arg1, ap);
    tag =  va_arg(ap, ttag_t);
    result = tiff.VSetField(tif, tag, ap);
    va_end(ap);
    return result;
}

tsize_t
ImgTIFFTileSize(tif)
    TIFF* tif;
{
    return tiff.TileSize(tif);
}

/*
 * The functions for the TIFF input handler
 */

static int mapDummy _ANSI_ARGS_((thandle_t, tdata_t *, toff_t *));
static void unMapDummy _ANSI_ARGS_((thandle_t, tdata_t, toff_t));
static int closeDummy _ANSI_ARGS_((thandle_t));
static tsize_t writeDummy _ANSI_ARGS_((thandle_t, tdata_t, tsize_t));

static tsize_t readFile _ANSI_ARGS_((thandle_t, tdata_t, tsize_t));
static tsize_t seekFile _ANSI_ARGS_((thandle_t, toff_t, int));
static toff_t  sizeFile _ANSI_ARGS_((thandle_t));

static tsize_t readChan _ANSI_ARGS_((thandle_t, tdata_t, tsize_t));
static tsize_t seekChan _ANSI_ARGS_((thandle_t, toff_t, int));
static toff_t  sizeChan _ANSI_ARGS_((thandle_t));

static tsize_t readString _ANSI_ARGS_((thandle_t, tdata_t, tsize_t));
static tsize_t writeString _ANSI_ARGS_((thandle_t, tdata_t, tsize_t));
static tsize_t seekString _ANSI_ARGS_((thandle_t, toff_t, int));
static toff_t  sizeString _ANSI_ARGS_((thandle_t));

static char *errorMessage = NULL;

static int getint(buf, format, order)
    unsigned char *buf;
    TIFFDataType format;
    int order;
{
    int result;

    switch (format) {
	case TIFF_BYTE:
	    result = buf[0]; break;
	case TIFF_SHORT:
	    result = (buf[order]<<8) + buf[1-order]; break;
	case TIFF_LONG:
	    if (order) {
		result = (buf[3]<<24) + (buf[2]<<16) + (buf[1]<<8) + buf[0];
	    } else {
		result = (buf[0]<<24) + (buf[1]<<16) + (buf[2]<<8) + buf[3];
	    }; break;
	default:
	    result = -1;
    }
    return result;
}

static int
load_tiff_library(interp)
    Tcl_Interp *interp;
{
    static int initialized = 0;
    if (errorMessage) {
	ckfree(errorMessage);
	errorMessage = NULL;
    }
    if (ImgLoadLib(interp, TIFF_LIB_NAME, &tiff.handle, symbols, 10)
	    != TCL_OK) {
	return TCL_ERROR;
    }
    if (tiff.SetErrorHandler != NULL) {
	tiff.SetErrorHandler(_TIFFerr);
    }
    if (tiff.SetWarningHandler != NULL) {
	tiff.SetWarningHandler(_TIFFwarn);
    }
    if (!initialized) {
	initialized = 1;
	if (tiff.RegisterCODEC && tiff.Error && tiff.PredictorInit &&
		tiff.MergeFieldInfo && tiff.FlushData1 && tiff.NoPostDecode &&
		tiff.TileRowSize && tiff.ScanlineSize && tiff.setByteArray &&
		tiff.VSetField) {
	    tiff.RegisterCODEC(COMPRESSION_DEFLATE, "Deflate", ImgInitTIFFzip);
	    tiff.RegisterCODEC(COMPRESSION_JPEG, "JPEG", ImgInitTIFFjpeg);
	}
    }
    return TCL_OK;
}

static void _TIFFerr(module, fmt, ap)
     CONST char *module;
     CONST char *fmt;
     va_list     ap;
{
  char buf[2048];
  char *cp = buf;

  if (module != NULL) {
    sprintf(cp, "%s: ", module);
    cp += strlen(module) + 2;
  }

  tiff_vsprintf(cp, fmt, ap);
  if (errorMessage) {
    ckfree(errorMessage);
  }
  errorMessage = (char *) ckalloc(strlen(buf)+1);
  strcpy(errorMessage, buf);
}

/* warnings are not processed in Tcl */
static void _TIFFwarn(module, fmt, ap)
     CONST char *module;
     CONST char *fmt;
     va_list     ap;
{
}

static int
mapDummy(fd, base, size)
    thandle_t fd;
    tdata_t *base;
    toff_t *size;
{
    return (toff_t) 0;
}

static void
unMapDummy(fd, base, size)
    thandle_t fd;
    tdata_t base;
    toff_t size;
{
}

static int
closeDummy(fd)
    thandle_t fd;
{
    return 0;
}

static tsize_t
writeDummy(fd, data, size)
    thandle_t fd;
    tdata_t data;
    tsize_t size;
{
   return size;
}

static tsize_t
readFile(fd, data, size)
    thandle_t fd;
    tdata_t data;
    tsize_t size;
{
    return (tsize_t) fread((char *) data, 1, (size_t) size, (FILE *) fd);
}

static tsize_t
seekFile(fd, off, whence)
    thandle_t fd;
    toff_t off;
    int whence;
{
    if (fseek((FILE *) fd, (long) off, whence)) {
	return -1;
    } else {
	return (tsize_t) ftell((FILE *) fd);
    }
}

static toff_t
sizeFile(fd)
    thandle_t fd;
{
    int fsize;
    return (fsize = seekFile(fd, 0, SEEK_END)) < 0 ? 0 : (toff_t) fsize;
}

static tsize_t
readChan(fd, data, size)
    thandle_t fd;
    tdata_t data;
    tsize_t size;
{
    return (tsize_t) Tcl_Read((Tcl_Channel) fd, (char *) data, (int) size) ;
}

static tsize_t
seekChan(fd, off, whence)
    thandle_t fd;
    toff_t off;
    int whence;
{
    return (tsize_t) Tcl_Seek((Tcl_Channel) fd, (int) off, whence);
}

static toff_t
sizeChan(fd)
    thandle_t fd;
{
    int fsize;
    return (fsize = Tcl_Seek((Tcl_Channel) fd, 0, SEEK_END)) < 0 ? 0 : (toff_t) fsize;
}

/*
 * In the following functions "handle" is used differently for speed reasons:
 *
 *	handle.buffer   (writing only) dstring used for writing.
 *	handle.data	pointer to first character
 *	handle.lenght	size of data
 *	handle.state	"file" position pointer.
 *
 * After a read, only the position pointer is adapted, not the other fields.
 */

static tsize_t
readString(fd, data, size)
    thandle_t fd;
    tdata_t data;
    tsize_t size;
{
    register MFile *handle = (MFile *) fd;

    if ((size + handle->state) > handle->length) {
	size = handle->length - handle->state;
    }
    if (size) {
	memcpy((char *) data, handle->data + handle->state, (size_t) size);
	handle->state += size;
    }
    return size;
}

static tsize_t
writeString(fd, data, size)
    thandle_t fd;
    tdata_t data;
    tsize_t size;
{
    register MFile *handle = (MFile *) fd;

    if (handle->state + size > handle->length) {
	handle->length = handle->state + size;
	Tcl_DStringSetLength(handle->buffer, handle->length);
	handle->data = Tcl_DStringValue(handle->buffer);
    }
    memcpy(handle->data + handle->state, (char *) data, (size_t) size);
    handle->state += size;
    return size;
}

static tsize_t
seekString(fd, off, whence)
    thandle_t fd;
    toff_t off;
    int whence;
{
    register MFile *handle = (MFile *) fd;

    switch (whence) {
	case SEEK_SET:
	    handle->state = (int) off;
	    break;
	case SEEK_CUR:
	    handle->state += (int) off;
	    break;
	case SEEK_END:
	    handle->state = handle->length + (int) off;
	    break;
    }
    if (handle->state < 0) {
	handle->state = 0;
	return -1;
    }
    return (toff_t) handle->state;
}

static toff_t
sizeString(fd)
    thandle_t fd;
{
    return ((MFile *) fd)->length;
}


/*
 *----------------------------------------------------------------------
 *
 * ObjMatchTIFF --
 *
 *  This procedure is invoked by the photo image type to see if
 *  a string contains image data in TIFF format.
 *
 * Results:
 *  The return value is 1 if the first characters in the string
 *  is like TIFF data, and 0 otherwise.
 *
 * Side effects:
 *  the size of the image is placed in widthPre and heightPtr.
 *
 *----------------------------------------------------------------------
 */

static int
ObjMatchTIFF(dataObj, formatString, widthPtr, heightPtr)
    struct Tcl_Obj *dataObj;	/* the object containing the image data */
    char *formatString;		/* the image format string */
    int *widthPtr;		/* where to put the string width */
    int *heightPtr;		/* where to put the string height */
{
    MFile handle;

    if (!ImgReadInit(dataObj, 'I', &handle) &&
	    !ImgReadInit(dataObj, 'M', &handle)) {
	return 0;
    }

    return CommonMatchTIFF(&handle, widthPtr, heightPtr);
}

static int ChnMatchTIFF(chan, fileName, formatString, widthPtr, heightPtr)
    Tcl_Channel chan;
    char *fileName;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    MFile handle;

    handle.data = (char *) chan;
    handle.state = IMG_CHAN;

    return CommonMatchTIFF(&handle, widthPtr, heightPtr);
}

static int FileMatchTIFF(f, fileName, formatString, widthPtr, heightPtr)
    FILE *f;
    char *fileName;
    char *formatString;
    int *widthPtr, *heightPtr;
{
    MFile handle;

    handle.data = (char *) f;
    handle.state = IMG_FILE;

    return CommonMatchTIFF(&handle, widthPtr, heightPtr);
}

static int CommonMatchTIFF(handle, widthPtr, heightPtr)
    MFile *handle;
    int *widthPtr, *heightPtr;
{
    unsigned char buf[4096];
    int i, j, order, w = 0, h = 0;

    i = ImgRead(handle, (char *) buf, 8);
    order = (buf[0] == 'I');
    if ((i != 8) || (buf[0] != buf[1])
	    || ((buf[0] != 'I') && (buf[0] != 'M'))
	    || (getint(buf+2,TIFF_SHORT,order) != 42)) {
	return 0;
    }
    i = getint(buf+4,TIFF_LONG,order);

    while (i > 4104) {
	i -= 4096;
	ImgRead(handle, (char *) buf, 4096);
    }
    ImgRead(handle, (char *) buf, i-8);
    ImgRead(handle, (char *) buf, 2);
    i = getint(buf,TIFF_SHORT,order);
    while (i--) {
	ImgRead(handle, (char *) buf, 12);
	if (buf[order]!=1) continue;
	j = getint(buf+2,TIFF_SHORT,order);
	j = getint(buf+8, (TIFFDataType) j, order);
	if (buf[1-order]==0) {
	    w = j;
	    if (h>0) break;
	} else if (buf[1-order]==1) {
	    h = j;
	    if (w>0) break;
	}
    }

    if ((w <= 0) || (h <= 0)) {
	return 0;
    }
    *widthPtr = w;
    *heightPtr = h;
    return 1;
}

static int ObjReadTIFF(interp, dataObj, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    struct Tcl_Obj *dataObj;		/* object containing the image */
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
    TIFF *tif;
    char tempFileName[256];
    int count, result;
    MFile handle;
    char buffer[1024];
    FILE *outfile;
    char *data = NULL;

    if (load_tiff_library(interp) != TCL_OK) {
	return TCL_ERROR;
    }

    if (!ImgReadInit(dataObj, 'M', &handle) &&
	    !ImgReadInit(dataObj, 'I', &handle)) {
	return TCL_ERROR;
    }

    if (tiff.ClientOpen) {
	tempFileName[0] = 0;
	if (handle.state != IMG_STRING) {
	    data = ckalloc((handle.length*3)/4);
	    handle.length = ImgRead(&handle, data, handle.length);
	    handle.data = data;
	}
	handle.state = 0;
	tif = tiff.ClientOpen("inline data", "rb", (thandle_t) &handle,
		readString, writeString, seekString, closeDummy,
		sizeString, mapDummy, unMapDummy);
    } else {
	tmpnam(tempFileName);
	outfile = fopen(tempFileName,"wb");

	count = ImgRead(&handle, buffer, 1024);
	while (count == 1024) {
	    fwrite(buffer, 1, count, outfile);
	    count = ImgRead(&handle, buffer, 1024);
	}
	if (count>0){
	    fwrite(buffer, 1, count, outfile);
	}
	fclose(outfile);

	tif = tiff.Open(tempFileName, "rb");
    }

    if (tif != NULL) {
	result = CommonReadTIFF(interp, tif, formatString, imageHandle,
		destX, destY, width, height, srcX, srcY);
    } else {
	result = TCL_ERROR;
    }
    if (tempFileName[0]) {
	unlink(tempFileName);
    }
    if (result == TCL_ERROR) {
	Tcl_AppendResult(interp, errorMessage, (char *) NULL);
	ckfree(errorMessage);
	errorMessage = NULL;
    }
    if (data) {
	ckfree(data);
    }
    return result;
}

static int ChnReadTIFF(interp, chan, fileName, formatString, imageHandle,
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
    TIFF *tif;
    char tempFileName[256];
    int count, result;
    char buffer[1024];
    FILE *outfile;

    if (load_tiff_library(interp) != TCL_OK) {
	return TCL_ERROR;
    }

    if (tiff.ClientOpen) {
	tempFileName[0] = 0;
	tif = tiff.ClientOpen(fileName, "rb", (thandle_t) chan,
		readChan, writeDummy, seekChan, closeDummy,
		sizeChan, mapDummy, unMapDummy);
    } else {
	tmpnam(tempFileName);
	outfile = fopen(tempFileName,"wb");

	count = Tcl_Read(chan, buffer, 1024);
	while (count == 1024) {
	    fwrite(buffer, 1, count, outfile);
	    count = Tcl_Read(chan, buffer, 1024);
	}
	if (count>0){
	    fwrite(buffer, 1, count, outfile);
	}
	fclose(outfile);

	tif = tiff.Open(tempFileName, "rb");
    }
    if (tif) {
	result = CommonReadTIFF(interp, tif, formatString, imageHandle,
		destX, destY, width, height, srcX, srcY);
    } else {
	result = TCL_ERROR;
    }
    if (tempFileName[0]) {
	unlink(tempFileName);
    }
    if (result == TCL_ERROR) {
	Tcl_AppendResult(interp, errorMessage, (char *) NULL);
	ckfree(errorMessage);
	errorMessage = 0;
    }
    return result;
}

static int FileReadTIFF(interp, f, fileName, formatString, imageHandle,
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
    TIFF *tif;
    char tempFileName[256];
    int count, result;
    char buffer[1024];
    FILE *outfile;

    if (load_tiff_library(interp) != TCL_OK) {
	return TCL_ERROR;
    }

    if (tiff.ClientOpen) {
	tempFileName[0] = 0;
	tif = tiff.ClientOpen(fileName, "rb", (thandle_t) f,
		readFile, writeDummy, seekFile, closeDummy,
		sizeFile, mapDummy, unMapDummy);
    } else {
	tmpnam(tempFileName);
	outfile = fopen(tempFileName,"wb");

	count = fread(buffer, 1, 1024, f);
	while (count == 1024) {
	    fwrite(buffer, 1, count, outfile);
	    count = fread(buffer, 1, 1024, f);
	}
	if (count>0){
	    fwrite(buffer, 1, count, outfile);
	}
	fclose(outfile);
	tif = tiff.Open(tempFileName, "rb");
    }
    if (tif) {
	result = CommonReadTIFF(interp, tif, formatString, imageHandle,
		destX, destY, width, height, srcX, srcY);
    } else {
	result = TCL_ERROR;
    }
    if (tempFileName[0]) {
	unlink(tempFileName);
    }
    if (result == TCL_ERROR) {
	Tcl_AppendResult(interp, errorMessage, (char *) NULL);
	ckfree(errorMessage);
	errorMessage = NULL;
    }
    return result;
}

typedef struct myblock {
    Tk_PhotoImageBlock ck;
    int dummy; /* extra space for offset[3], if not included already
		  in Tk_PhotoImageBlock */
} myblock;

#define block bl.ck

static int CommonReadTIFF(interp, tif, formatString, imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;
    TIFF *tif;
    char *formatString;
    Tk_PhotoHandle imageHandle;
    int destX, destY;
    int width, height;
    int srcX, srcY;
{
    myblock bl;
    unsigned char *pixelPtr = block.pixelPtr;
    uint32 w, h;
    size_t npixels;
    uint32 *raster;

#ifdef WORDS_BIGENDIAN
    block.offset[0] = 3;
    block.offset[1] = 2;
    block.offset[2] = 1;
    block.offset[3] = 0;
#else
    block.offset[0] = 0;
    block.offset[1] = 1;
    block.offset[2] = 2;
    block.offset[3] = 3;
#endif
    block.pixelSize = sizeof (uint32);

    tiff.GetField(tif, TIFFTAG_IMAGEWIDTH, &w);
    tiff.GetField(tif, TIFFTAG_IMAGELENGTH, &h);
    npixels = w * h;
    if (tiff.malloc == NULL) {
	raster = (uint32 *) ckalloc(npixels * sizeof (uint32));
    } else {
	raster = (uint32 *) tiff.malloc(npixels * sizeof (uint32));
    }
    block.width = w;
    block.height = h;
    block.pitch = - (block.pixelSize * (int) w);
    block.pixelPtr = ((unsigned char *) raster) - (h-1) * block.pitch;
    if (raster == NULL) {
	printf("cannot malloc\n");
	return TCL_ERROR;
    }

    if (!tiff.ReadRGBAImage(tif, w, h, raster, 0) || errorMessage) {
	if (tiff.free == NULL) {
	    ckfree((char *)raster);
	} else {
	    tiff.free((char *)raster);
	}
	if (errorMessage) {
	    Tcl_AppendResult(interp, errorMessage, (char *) NULL);
	    ckfree(errorMessage);
	    errorMessage = NULL;
	}
	return TCL_ERROR;
    }

    pixelPtr = block.pixelPtr += srcY * block.pitch
	    + srcX * block.pixelSize;
    block.offset[3] = block.offset[0]; /* don't use transparency */
    ImgPhotoPutBlock(imageHandle, &block, destX,
			destY, width, height);

    if (tiff.free == NULL) {
	ckfree((char *)raster);
    } else {
	tiff.free((char *)raster);
    }
    tiff.Close(tif);
    return TCL_OK;
}

static int StringWriteTIFF(interp, dataPtr, formatString, blockPtr)
    Tcl_Interp *interp;
    Tcl_DString *dataPtr;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    TIFF *tif;
    int result;
    MFile handle;
    FILE *f = NULL;
    char tempFileName[256];
    Tcl_DString dstring;

    if (load_tiff_library(interp) != TCL_OK) {
	return TCL_ERROR;
    }

    if (tiff.ClientOpen) {
	tempFileName[0] = 0;
	Tcl_DStringInit(&dstring);
	ImgWriteInit(&dstring, &handle);
	tif = tiff.ClientOpen("inline data", "wb", (thandle_t) &handle,
		readString, writeString, seekString, closeDummy,
		sizeString, mapDummy, unMapDummy);
    } else {
	tmpnam(tempFileName);
	tif = tiff.Open(tempFileName,"wb");
    }

    result = CommonWriteTIFF(interp, tif, formatString, blockPtr);
    tiff.Close(tif);

    if (result != TCL_OK) {
	if (tempFileName[0]) {
	    unlink(tempFileName);
	}
	Tcl_AppendResult(interp, errorMessage, (char *) NULL);
	ckfree(errorMessage);
	errorMessage = NULL;
	return TCL_ERROR;
    }

    if (tempFileName[0]) {
	char buffer[1024];
	f = fopen(tempFileName,"rb");
	if (f == NULL) {
	    Tcl_AppendResult(interp, "cannot open temporary file", (char *) NULL);
	    return TCL_ERROR;
	}
	ImgWriteInit(dataPtr, &handle);

	result = fread(buffer, 1, 1024, f);
	while (!feof(f)) {
	    ImgWrite(&handle, buffer, result);
	    result = fread(buffer, 1, 1024, f);
	}
	ImgWrite(&handle, buffer, result);
	fclose(f);
	unlink(tempFileName);
    } else {
	int length = handle.length;
	ImgWriteInit(dataPtr, &handle);
	ImgWrite(&handle, Tcl_DStringValue(&dstring), length);
	Tcl_DStringFree(&dstring);
    }
    ImgPutc(IMG_DONE, &handle);
    return TCL_OK;
}

static int FileWriteTIFF(interp, filename, formatString, blockPtr)
    Tcl_Interp *interp;
    char *filename;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    TIFF *tif;
    int result;
    Tcl_DString nameBuffer; 
    char *fullname;

    if ((fullname=Tcl_TranslateFileName(interp,filename,&nameBuffer))==NULL) {
	return TCL_ERROR;
    }

    if (!(tif = tiff.Open(fullname,"wb"))) {
	Tcl_AppendResult(interp, filename, ": ", Tcl_PosixError(interp),
		(char *)NULL);
	Tcl_DStringFree(&nameBuffer);
	return TCL_ERROR;
    }

    Tcl_DStringFree(&nameBuffer);

    if (load_tiff_library(interp) != TCL_OK) {
	return TCL_ERROR;
    }
    result = CommonWriteTIFF(interp, tif, formatString, blockPtr);
    tiff.Close(tif);
    return result;
}

static int CommonWriteTIFF(interp, tif, formatString, blockPtr)
    Tcl_Interp *interp;
    TIFF *tif;
    char *formatString;
    Tk_PhotoImageBlock *blockPtr;
{
    int numsamples, comp;
    unsigned char *data = NULL;

    comp = COMPRESSION_NONE;
    if (formatString != NULL) {
      int argc, length, c;
      char **argv;
      if (Tcl_SplitList(interp, formatString, &argc, &argv) != TCL_OK)
	return TCL_ERROR;
      compression = "none";
      if (Tk_ParseArgv(interp, (Tk_Window) NULL, &argc, argv,
	      writeOptTable, TK_ARGV_NO_LEFTOVERS|TK_ARGV_NO_DEFAULTS)
	      != TCL_OK) {
	ckfree((char *) argv);
	return TCL_ERROR;
      }
      c = compression[0]; length = strlen(compression);
      if ((c == 'n') && (!strncmp(compression,"none",length))) {
	comp = COMPRESSION_NONE;
      } else if ((c == 'l') && (!strncmp(compression,"lzw",length))) {
	comp = COMPRESSION_LZW;
      } else if ((c == 'j') && (!strncmp(compression,"jpeg",length))) {
	comp = COMPRESSION_JPEG;
      } else if ((c == 'p') && (!strncmp(compression,"packbits",length))) {
	comp = COMPRESSION_PACKBITS;
      } else if ((c == 'd') && (!strncmp(compression,"deflate",length))) {
	comp = COMPRESSION_DEFLATE;
      } else {
	Tcl_AppendResult(interp, "invalid compression mode \"",
		compression,"\": should be deflate, jpeg, lzw, ",
		"packbits or none", (char *) NULL);
	ckfree((char *) argv);
	return TCL_ERROR;
      }
      ckfree((char *) argv);
    }
    tiff.SetField(tif, TIFFTAG_IMAGEWIDTH, blockPtr->width);
    tiff.SetField(tif, TIFFTAG_IMAGELENGTH, blockPtr->height);
    tiff.SetField(tif, TIFFTAG_COMPRESSION, comp);

    tiff.SetField(tif, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    tiff.SetField(tif, TIFFTAG_SAMPLESPERPIXEL, 1);
    tiff.SetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    tiff.SetField(tif, TIFFTAG_ROWSPERSTRIP, blockPtr->height);

    tiff.SetField(tif, TIFFTAG_RESOLUTIONUNIT, (int)2);
    tiff.SetField(tif, TIFFTAG_XRESOLUTION, (float)1200.0);
    tiff.SetField(tif, TIFFTAG_YRESOLUTION, (float)1200.0);

    tiff.SetField(tif, TIFFTAG_BITSPERSAMPLE,   8);
    if ((blockPtr->offset[0] == blockPtr->offset[1])
	    && (blockPtr->offset[0] == blockPtr->offset[2])) {
	numsamples = 1;
	tiff.SetField(tif, TIFFTAG_SAMPLESPERPIXEL, 1);
	tiff.SetField(tif, TIFFTAG_PHOTOMETRIC,    PHOTOMETRIC_MINISBLACK);
    } else {
	numsamples = 3;
	tiff.SetField(tif, TIFFTAG_SAMPLESPERPIXEL, 3);
	tiff.SetField(tif, TIFFTAG_PHOTOMETRIC,     PHOTOMETRIC_RGB);
    }

    if ((blockPtr->pitch == numsamples * blockPtr->width)
	    && (blockPtr->pixelSize == numsamples)) {
	data = blockPtr->pixelPtr;
    } else {
	unsigned char *srcPtr, *dstPtr, *rowPtr;
	int greenOffset, blueOffset, alphaOffset, x, y;
	dstPtr = data = (unsigned char *) ckalloc(numsamples *
		blockPtr->width * blockPtr->height);
	rowPtr = blockPtr->pixelPtr + blockPtr->offset[0];
	greenOffset = blockPtr->offset[1] - blockPtr->offset[0];
	blueOffset = blockPtr->offset[2] - blockPtr->offset[0];
	alphaOffset =  blockPtr->offset[0];
	if (alphaOffset < blockPtr->offset[2]) {
	    alphaOffset = blockPtr->offset[2];
	}
	if (++alphaOffset < blockPtr->pixelSize) {
	    alphaOffset -= blockPtr->offset[0];
	} else {
	    alphaOffset = 0;
	}
	if (blueOffset || greenOffset) {
	    for (y = blockPtr->height; y > 0; y--) {
		srcPtr = rowPtr;
		for (x = blockPtr->width; x>0; x--) {
		    if (alphaOffset && !srcPtr[alphaOffset]) {
			*dstPtr++ = 0xd9;
			*dstPtr++ = 0xd9;
			*dstPtr++ = 0xd9;
		    } else {
			*dstPtr++ = srcPtr[0];
			*dstPtr++ = srcPtr[greenOffset];
			*dstPtr++ = srcPtr[blueOffset];
		    }
		    srcPtr += blockPtr->pixelSize;
		}
		rowPtr += blockPtr->pitch;
	    }
	} else {
	    for (y = blockPtr->height; y > 0; y--) {
		srcPtr = rowPtr;
		for (x = blockPtr->width; x>0; x--) {
		    *dstPtr++ = srcPtr[0];
		    srcPtr += blockPtr->pixelSize;
		}
		rowPtr += blockPtr->pitch;
	    }
	}
    }

    tiff.WriteEncodedStrip(tif, 0, data,
	    numsamples * blockPtr->width * blockPtr->height);
    if (data != blockPtr->pixelPtr) {
	ckfree((char *) data);
    }

    return TCL_OK;
}


/* Portable vsprintf  by Robert A. Larson <blarson@skat.usc.edu> */

/* Copyright 1989 Robert A. Larson.
 * Distribution in any form is allowed as long as the author
 * retains credit, changes are noted by their author and the
 * copyright message remains intact.  This program comes as-is
 * with no warentee of fitness for any purpouse.
 *
 * Thanks to Doug Gwen, Chris Torek, and others who helped clarify
 * the ansi printf specs.
 *
 * Please send any bug fixes and improvments to blarson@skat.usc.edu .
 * The use of goto is NOT a bug.
 */

/* Feb	7, 1989		blarson		First usenet release */

/* This code implements the vsprintf function, without relying on
 * the existance of _doprint or other system specific code.
 *
 * Define NOVOID if void * is not a supported type.
 *
 * Two compile options are available for efficency:
 *	INTSPRINTF	should be defined if sprintf is int and returns
 *			the number of chacters formated.
 *	LONGINT		should be defined if sizeof(long) == sizeof(int)
 *
 *	They only make the code smaller and faster, they need not be
 *	defined.
 *
 * UNSIGNEDSPECIAL should be defined if unsigned is treated differently
 * than int in argument passing.  If this is definded, and LONGINT is not,
 * the compiler must support the type unsingned long.
 *
 * Most quirks and bugs of the available sprintf fuction are duplicated,
 * however * in the width and precision fields will work correctly
 * even if sprintf does not support this, as will the n format.
 *
 * Bad format strings, or those with very long width and precision
 * fields (including expanded * fields) will cause undesired results.
 */

#ifdef OSK		/* os9/68k can take advantage of both */
#define LONGINT
#define INTSPRINTF
#endif

/* This must be a typedef not a #define! */
typedef VOID *pointer;


#ifdef	INTSPRINTF
#define Sprintf(string,format,arg)	(sprintf((string),(format),(arg)))
#else
#define Sprintf(string,format,arg)	(\
	sprintf((string),(format),(arg)),\
	strlen(string)\
)
#endif

typedef int *intp;

static int tiff_vsprintf(dest, format, args)
    char *dest;
    CONST char *format;
    va_list args;
{
    register char *dp = dest;
    register char c;
    register char *tp;
    char tempfmt[64];
#ifndef LONGINT
    int longflag;
#endif

    tempfmt[0] = '%';
    while( (c = *format++) != 0) {
	if(c=='%') {
	    tp = &tempfmt[1];
#ifndef LONGINT
	    longflag = 0;
#endif
continue_format:
	    switch(c = *format++) {
		case 's':
		    *tp++ = c;
		    *tp = '\0';
		    dp += Sprintf(dp, tempfmt, va_arg(args, char *));
		    break;
		case 'u':
		case 'x':
		case 'o':
		case 'X':
#ifdef UNSIGNEDSPECIAL
		    *tp++ = c;
		    *tp = '\0';
#ifndef LONGINT
		    if(longflag)
			dp += Sprintf(dp, tempfmt, va_arg(args, unsigned long));
		    else
#endif
			dp += Sprintf(dp, tempfmt, va_arg(args, unsigned));
		    break;
#endif
		case 'd':
		case 'c':
		case 'i':
		    *tp++ = c;
		    *tp = '\0';
#ifndef LONGINT
		    if(longflag)
			dp += Sprintf(dp, tempfmt, va_arg(args, long));
		    else
#endif
			dp += Sprintf(dp, tempfmt, va_arg(args, int));
		    break;
		case 'f':
		case 'e':
		case 'E':
		case 'g':
		case 'G':
		    *tp++ = c;
		    *tp = '\0';
		    dp += Sprintf(dp, tempfmt, va_arg(args, double));
		    break;
		case 'p':
		    *tp++ = c;
		    *tp = '\0';
		    dp += Sprintf(dp, tempfmt, va_arg(args, pointer));
		    break;
		case '-':
		case '+':
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		case '.':
		case ' ':
		case '#':
		case 'h':
		    *tp++ = c;
		    goto continue_format;
		case 'l':
#ifndef LONGINT
		    longflag = 1;
		    *tp++ = c;
#endif
		    goto continue_format;
		case '*':
		    tp += Sprintf(tp, "%d", va_arg(args, int));
		    goto continue_format;
		case 'n':
		    *va_arg(args, intp) = dp - dest;
		    break;
		case '%':
		default:
		    *dp++ = c;
		    break;
	    }
	} else *dp++ = c;
    }
    *dp = '\0';
    return dp - dest;
}
