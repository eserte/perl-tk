/*
 *	imgInit.tcl
 */
#define NEED_REAL_STDIO 

#include "imgInt.h"
#include <string.h>

#if 0
#ifdef MAC_TCL
#  include "compat:dlfcn.h"
#else
#  ifdef HAVE_DLFCN_H
#    include <dlfcn.h>
#  else
#    include "compat/dlfcn.h"
#  endif
#endif
#endif

/*
 * In some systems, like SunOS 4.1.3, the RTLD_NOW flag isn't defined
 * and this argument to dlopen must always be 1.
 */

#ifndef RTLD_NOW
#   define RTLD_NOW 1
#endif

#if defined(__WIN32__)
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#   undef WIN32_LEAN_AND_MEAN
#   if defined(_MSC_VER)
#	define EXPORT(a,b) __declspec(dllexport) a b
#   else
#	if defined(__BORLANDC__)
#	    define EXPORT(a,b) a _export b
#	else
#	    define EXPORT(a,b) a b
#	endif
#   endif
#else
#   define EXPORT(a,b) a b
#endif

/*
 * Declarations for functions defined in this file.
 */

EXTERN EXPORT(int,Img_Init) _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN EXPORT(int,Img_SafeInit) _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN EXPORT(int,Img_InitStandAlone) _ANSI_ARGS_((Tcl_Interp *interp));

static int char64 _ANSI_ARGS_((int c));

#ifdef ALLOW_TOB64
static int tob64 _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp,
		int argc, char **argv));
#endif


/*
 *--------------------------------------------------------------
 *
 * Img_Init , Img_SafeInit, Img_InitStandAlone --
 *	Create Img commands.
 *
 * Results:
 *	None
 *
 * Side effects:
 *	None
 *
 *--------------------------------------------------------------
 */

static int initialized = 0;
#if 0

extern Tk_ImageType		imgPixmapImageType;

extern Tk_PhotoImageFormat	imgOldFmtBMP;
extern Tk_PhotoImageFormat	imgOldFmtGIF;
extern Tk_PhotoImageFormat	imgOldFmtJPEG;
extern Tk_PhotoImageFormat	imgOldFmtPNG;
extern Tk_PhotoImageFormat	imgOldFmtPS;
extern Tk_PhotoImageFormat	imgOldFmtRAS;
extern Tk_PhotoImageFormat	imgOldFmtRAW;
extern Tk_PhotoImageFormat	imgOldFmtRGB;
extern Tk_PhotoImageFormat	imgOldFmtTIFF;
extern Tk_PhotoImageFormat	imgOldFmtXBM;
extern Tk_PhotoImageFormat	imgOldFmtXPM;

static Tk_PhotoImageFormat *oldFormats[] = {
	&imgOldFmtTIFF,
/*	&imgOldFmtRAW,*/
/*	&imgOldFmtRAS,*/
/*	&imgOldFmtRGB,*/
	&imgOldFmtPS,
	&imgOldFmtXBM,
	&imgOldFmtXPM,
	&imgOldFmtBMP,
	&imgOldFmtJPEG,
	&imgOldFmtPNG,
	&imgOldFmtGIF,
	(Tk_PhotoImageFormat *) NULL};

extern Tk_PhotoImageFormat	imgFmtBMP;
extern Tk_PhotoImageFormat	imgFmtGIF;
extern Tk_PhotoImageFormat	imgFmtJPEG;
extern Tk_PhotoImageFormat	imgFmtPNG;
extern Tk_PhotoImageFormat	imgFmtPS;
extern Tk_PhotoImageFormat	imgFmtRAS;
extern Tk_PhotoImageFormat	imgFmtRAW;
extern Tk_PhotoImageFormat	imgFmtRGB;
extern Tk_PhotoImageFormat	imgFmtTIFF;
extern Tk_PhotoImageFormat	imgFmtXBM;
extern Tk_PhotoImageFormat	imgFmtXPM;

static Tk_PhotoImageFormat *newFormats[] = {
	&imgFmtTIFF,
/*	&imgFmtRAW,*/
/*	&imgFmtRAS,*/
/*	&imgFmtRGB,*/
	&imgFmtPS,
	&imgFmtXBM,
	&imgFmtXPM,
	&imgFmtBMP,
	&imgFmtJPEG,
	&imgFmtPNG,
	&imgFmtGIF,
	(Tk_PhotoImageFormat *) NULL};


EXPORT(int,Img_Init)(interp)
    Tcl_Interp *interp;
{
    char *patch;
    Tk_PhotoImageFormat **formatPtr = oldFormats;

    if (Tcl_PkgRequire(interp, "Tk", (char *) NULL, 0) == NULL) {
	return TCL_ERROR;
    }
    if (!initialized) {
	initialized = 1;
	patch = Tcl_GetVar(interp,"tcl_patchLevel",TCL_GLOBAL_ONLY);
	if (patch && (patch[0]=='8') && ((patch[2]!='0') || (patch[3]!='a'))) {
	    struct CmdInfo {
		int isNativeObjectProc;
		VOID *dummy[10]; /* worst case space that could be written
				  * by Tcl_GetCommandInfo() */
	    } cmdInfo;
	    if (!Tcl_GetCommandInfo(interp,"image", (Tcl_CmdInfo *) &cmdInfo)) {
		Tcl_AppendResult(interp, "cannot find the \"image\" command",
			(char *) NULL);
		initialized = 0;
		return TCL_ERROR;
	    }
	    if (cmdInfo.isNativeObjectProc == 1) {
		initialized++;
	    }
	    formatPtr = newFormats;
	}
	while(*formatPtr) {
	    Tk_CreatePhotoImageFormat(*formatPtr++);
	}
#ifndef TCL_MAC
	Tk_CreateImageType(&imgPixmapImageType);
#endif
    }
#ifdef ALLOW_TOB64
    Tcl_CreateCommand(interp,"img_to_base64", tob64, (ClientData) NULL, NULL);
#endif
    return Tcl_PkgProvide(interp,"Img","1.1");
}

EXPORT(int,Img_SafeInit)(interp)
    Tcl_Interp *interp;
{
    return Img_Init(interp);
}

EXPORT(int,Img_InitStandAlone)(interp)
    Tcl_Interp *interp;
{
    return Img_Init(interp);
}

#endif


/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoPutBlock --
 *
 *	This procedure is called to put image data into a photo image.
 *	The difference with Tk_PhotoPutBlock is that it handles the
 *	transparency information as well.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image data is stored.  The image may be expanded.
 *	The Tk image code is informed that the image has changed.
 *
 *----------------------------------------------------------------------
 */

int
ImgPhotoPutBlock(handle, blockPtr, x, y, width, height)
    Tk_PhotoHandle handle;	/* Opaque handle for the photo image
				 * to be updated. */
    Tk_PhotoImageBlock *blockPtr;
				/* Pointer to a structure describing the
				 * pixel data to be copied into the image. */
    int x, y;			/* Coordinates of the top-left pixel to
				 * be updated in the image. */
    int width, height;		/* Dimensions of the area of the image
				 * to be updated. */
{
    int alphaOffset;

    alphaOffset = blockPtr->offset[3];
    if ((alphaOffset< 0) || (alphaOffset>= blockPtr->pixelSize)) {
	alphaOffset = blockPtr->offset[0];
	if (alphaOffset < blockPtr->offset[1]) {
	    alphaOffset = blockPtr->offset[1];
	}
	if (alphaOffset < blockPtr->offset[2]) {
	    alphaOffset = blockPtr->offset[2];
	}
	if (++alphaOffset >= blockPtr->pixelSize) {
	    alphaOffset = blockPtr->offset[0];
	}
    } else {
	if ((alphaOffset == blockPtr->offset[1]) ||
		(alphaOffset == blockPtr->offset[2])) {
	    alphaOffset = blockPtr->offset[0];
	}
    }
    if (alphaOffset != blockPtr->offset[0]) {
	int X, Y, end;
	unsigned char *pixelPtr, *imagePtr, *rowPtr;
	rowPtr = imagePtr = blockPtr->pixelPtr;
	for (Y = 0; Y < height; Y++) {
	    X = 0;
	    pixelPtr = rowPtr + alphaOffset;
	    while(X < width) {
		/* search for first non-transparent pixel */
		while ((X < width) && !(*pixelPtr)) {
		    X++; pixelPtr += blockPtr->pixelSize;
		}
		end = X;
		/* search for first transparent pixel */
		while ((end < width) && *pixelPtr) {
		    end++; pixelPtr += blockPtr->pixelSize;
		}
		if (end > X) {
 		    blockPtr->pixelPtr =  rowPtr + blockPtr->pixelSize * X;
		    Tk_PhotoPutBlock(handle, blockPtr, x+X, y+Y, end-X, 1);
		}
		X = end;
	    }
	    rowPtr += blockPtr->pitch;
	}
	blockPtr->pixelPtr = imagePtr;
    } else {
	Tk_PhotoPutBlock(handle,blockPtr,x,y,width,height);
    }
    return TCL_OK;
}


/*
 *----------------------------------------------------------------------
 *
 * ImgLoadLib --
 *
 *	This procedure is called to load a shared library into memory.
 *	If the extension is ".so" (e.g. Solaris, Linux) or ".sl" (HP-UX)
 *	it is possible that the extension is appended or replaced with
 *	a major version number. If the file cannot be found, the version
 *	numbers will be stripped off one by one. e.g.
 *
 *	HP-UX:	libtiff.3.4	Linux,Solaris:	libtiff.so.3.4
 *		libtiff.3			libtiff.so.3
 *		libtiff.sl			libtiff.so
 *
 * Results:
 *	TCL_OK if function succeeds. Otherwise TCL_ERROR while the
 *	interpreter will contain an error-message. The last parameter
 *	"num" contains the minimum number of symbols that is required
 *	by the application to succeed. Only the first <num> symbols
 *	will produce an error if they cannot be found.
 *
 * Side effects:
 *	At least <num> Library functions become available by the
 *	application.
 *
 *----------------------------------------------------------------------
 */

typedef struct Functions {
    VOID *handle;
    int (* first) _ANSI_ARGS_((void));
    int (* next) _ANSI_ARGS_((void));
} Functions;

#define IMG_FAILED ((VOID *) -114)

#if 0
int
ImgLoadLib(interp, libName, handlePtr, symbols, num)
    Tcl_Interp *interp;
    CONST char *libName;
    VOID **handlePtr;
    char **symbols;
    int num;
{
    VOID *handle = (VOID *) NULL;
    Functions *lib = (Functions *) handlePtr;
    char **p = (char **) &(lib->first);
    char **q = symbols;
    char buf[256];
    char *r;
    int length;

    if (lib->handle != NULL) {
	return (lib->handle != IMG_FAILED) ? TCL_OK : TCL_ERROR;
    }

    length = strlen(libName);
    strcpy(buf,libName);
    handle = dlopen(buf, RTLD_NOW);

    while (handle == NULL) {
	if ((r = strrchr(buf,'.')) != NULL) {
	    if ((r[1] < '0') || (r[1] > '9')) {
		if (interp) {
		    Tcl_AppendResult(interp,"cannot open ",libName,
			    ": ", dlerror(), (char *) NULL);
		} else {
		    printf("cannot open %s: %s\n",libName,dlerror());
		}
		lib->handle = IMG_FAILED;
		return TCL_ERROR;
	    }
	    length = r - buf;
	    *r = 0;
	}
	if (strchr(buf,'.') == NULL) {
	    strcpy(buf+length,".sl");
	    length += 3;
	}
	dlerror();
	handle = dlopen(buf, RTLD_NOW);
    }

    buf[0] = '_';
    while (*q) {
	*p = (char *) dlsym(handle,*q);
	if (*p == (char *)NULL) {
	    strcpy(buf+1,*q);
	    *p = (char *) dlsym(handle,buf);
	    if ((num > 0) && (*p == (char *)NULL)) {
		if (interp) {
		    Tcl_AppendResult(interp,"cannot open ",libName,
			    ": symbol \"",*q,"\" not found", (char *) NULL);
		} else {
		    printf("cannot open %s: symbol \"%s\" not found",
			    libName, *q);
		}
		dlclose(handle);
		lib->handle = IMG_FAILED;
		return TCL_ERROR;
	    }
	}
	q++; num--;
	p += (Tk_Offset(Functions, next) - Tk_Offset(Functions, first)) /
		sizeof(char *);
    }
    lib->handle = handle;

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgLoadFailed --
 *
 *	Mark the loaded library as invalid. Remove it from memory
 *	if possible. It will no longer be used in the future.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Next time the same handle is used by ImgLoadLib, it will
 *	fail immediately, without trying to load it.
 *
 *----------------------------------------------------------------------
 */

void
ImgLoadFailed(handlePtr)
    VOID **handlePtr;
{
    if ((*handlePtr != NULL) && (*handlePtr != IMG_FAILED)) {
	/* Oops, still loaded. First remove it from menory */
	dlclose(*handlePtr);
    }
    *handlePtr = IMG_FAILED;
}

#endif

#if TCL_MAJOR_VERSION < 8

/*
 * Procedure types defined by Tcl:
 */

typedef void (Tcl_FreeInternalRepProc) _ANSI_ARGS_((struct Tcl_Obj *objPtr));
typedef void (Tcl_DupInternalRepProc) _ANSI_ARGS_((struct Tcl_Obj *srcPtr, 
        struct Tcl_Obj *dupPtr));
typedef void (Tcl_UpdateStringProc) _ANSI_ARGS_((struct Tcl_Obj *objPtr));
typedef int (Tcl_SetFromAnyProc) _ANSI_ARGS_((Tcl_Interp *interp,
	struct Tcl_Obj *objPtr));

/*
 * The following structure represents a type of object, which is a
 * particular internal representation for an object plus a set of
 * procedures that provide standard operations on objects of that type.
 */

typedef struct Tcl_ObjType {
    char *name;			/* Name of the type, e.g. "int". */
    Tcl_FreeInternalRepProc *freeIntRepProc;
				/* Called to free any storage for the type's
				 * internal rep. NULL if the internal rep
				 * does not need freeing. */
    Tcl_DupInternalRepProc *dupIntRepProc;
    				/* Called to create a new object as a copy
				 * of an existing object. */
    Tcl_UpdateStringProc *updateStringProc;
    				/* Called to update the string rep from the
				 * type's internal representation. */
    Tcl_SetFromAnyProc *setFromAnyProc;
    				/* Called to convert the object's internal
				 * rep to this type. Frees the internal rep
				 * of the old type. Returns TCL_ERROR on
				 * failure. */
} Tcl_ObjType;

/*
 * One of the following structures exists for each object in the Tcl
 * system.  An object stores a value as either a string, some internal
 * representation, or both.
 */

typedef struct Tcl_Obj {
    int refCount;		/* When 0 the object will be freed. */
    char *bytes;		/* This points to the first byte of the
				 * object's string representation. The
				 * array must be followed by a null byte
				 * (i.e., at offset length) but may also
				 * contain embedded null characters. The
				 * array's storage is allocated by
				 * ckalloc. NULL indicates the string
				 * rep is empty or invalid and must be
				 * regenerated from the internal rep.
				 * Clients should use Tcl_GetStringFromObj
				 * to get a pointer to the byte array
				 * as a readonly value.  */
    int length;			/* The number of bytes at *bytes, not
				 * including the terminating null. */
    Tcl_ObjType *typePtr;	/* Denotes the object's type. Always
				 * corresponds to the type of the object's
				 * internal rep. NULL indicates the object
				 * has no internal rep (has no type). */
} Tcl_Obj;
#endif
/*
 *----------------------------------------------------------------------
 *
 * ImgGetStringFromObj --
 *
 *	Returns the string representation's byte array pointer and length
 *	for an object.
 *
 * Results:
 *	Returns a pointer to the string representation of objPtr.  If
 *	lengthPtr isn't NULL, the length of the string representation is
 *	stored at *lengthPtr. The byte array referenced by the returned
 *	pointer must not be modified by the caller. Furthermore, the
 *	caller must copy the bytes if they need to retain them since the
 *	object's string rep can change as a result of other operations.
 *
 * Side effects:
 *	May call the object's updateStringProc to update the string
 *	representation from the internal representation.
 *
 *----------------------------------------------------------------------
 */

char *
ImgGetStringFromObj(objPtr, lengthPtr)
    register Tcl_Obj *objPtr;	/* Object whose string rep byte pointer
				 * should be returned. */
    register int *lengthPtr;	/* If non-NULL, the location where the
				 * string rep's byte array length should be
				 * stored. If NULL, no length is stored. */
{
    if (initialized > 1) {
	if (objPtr->bytes != NULL) {
	    if (lengthPtr != NULL) {
		*lengthPtr = objPtr->length;
	    }
	    return objPtr->bytes;
	}

	if (objPtr->typePtr == NULL) {
	    if (lengthPtr != NULL) {
		*lengthPtr = 0;
	    }
	    return "";
	}

	objPtr->typePtr->updateStringProc(objPtr);
	if (lengthPtr != NULL) {
	    *lengthPtr = objPtr->length;
	}
	return objPtr->bytes;
    } else {
	char *string =  (char *) objPtr;
	if (lengthPtr != NULL) {
	    *lengthPtr = strlen(string);
	}
	return string;
    }
}

/*
 *--------------------------------------------------------------------------
 * char64 --
 *
 *	This procedure converts a base64 ascii character into its binary
 *	equivalent. This code is a slightly modified version of the
 *	char64 proc in N. Borenstein's metamail decoder.
 *
 * Results:
 *	The binary value, or an error code.
 *
 * Side effects:
 *	None.
 *--------------------------------------------------------------------------
 */

static int
char64(c)
    int c;
{
    switch(c) {
	case 'A': return 0;	case 'B': return 1;	case 'C': return 2;
	case 'D': return 3;	case 'E': return 4;	case 'F': return 5;
	case 'G': return 6;	case 'H': return 7;	case 'I': return 8;
	case 'J': return 9;	case 'K': return 10;	case 'L': return 11;
	case 'M': return 12;	case 'N': return 13;	case 'O': return 14;
	case 'P': return 15;	case 'Q': return 16;	case 'R': return 17;
	case 'S': return 18;	case 'T': return 19;	case 'U': return 20;
	case 'V': return 21;	case 'W': return 22;	case 'X': return 23;
	case 'Y': return 24;	case 'Z': return 25;	case 'a': return 26;
	case 'b': return 27;	case 'c': return 28;	case 'd': return 29;
	case 'e': return 30;	case 'f': return 31;	case 'g': return 32;
	case 'h': return 33;	case 'i': return 34;	case 'j': return 35;
	case 'k': return 36;	case 'l': return 37;	case 'm': return 38;
	case 'n': return 39;	case 'o': return 40;	case 'p': return 41;
	case 'q': return 42;	case 'r': return 43;	case 's': return 44;
	case 't': return 45;	case 'u': return 46;	case 'v': return 47;
	case 'w': return 48;	case 'x': return 49;	case 'y': return 50;
	case 'z': return 51;	case '0': return 52;	case '1': return 53;
	case '2': return 54;	case '3': return 55;	case '4': return 56;
	case '5': return 57;	case '6': return 58;	case '7': return 59;
	case '8': return 60;	case '9': return 61;	case '+': return 62;
	case '/': return 63;

	case ' ': case '\t': case '\n': case '\r': case '\f': return IMG_SPACE;
	case '=': return IMG_PAD;
	case '\0': return IMG_DONE;
	default: return IMG_BAD;
    }
}

/*
 *--------------------------------------------------------------------------
 * ImgRead --
 *
 *  This procedure returns a buffer from the stream input. This stream
 *  could be anything from a base-64 encoded string to a Channel.
 *
 * Results:
 *  The number of characters successfully read from the input
 *
 * Side effects:
 *  The MFile state could change.
 *--------------------------------------------------------------------------
 */

int
ImgRead(handle, dst, count)
    MFile *handle;	/* mmdecode "file" handle */
    VOID *dst;		/* where to put the result */
    int count;		/* number of bytes */
{
    register int i, c;
    switch (handle->state) {
      case IMG_STRING:
	if (count > handle->length) {
	    count = handle->length;
	}
	if (count) {
	    memcpy(dst, handle->data, count);
	    handle->length -= count;
	    handle->data += count;
	}
	return count;
      case IMG_FILE:
	return fread(dst, 1, count, (FILE *) handle->data);
      case IMG_CHAN:
	return Tcl_Read((Tcl_Channel) handle->data, dst, count);
    }

    for(i=0; i<count && (c=ImgGetc(handle)) != IMG_DONE; i++) {
	*((char *) dst)++ = c;
    }
    return i;
}
/*
 *--------------------------------------------------------------------------
 *
 * ImgGetc --
 *
 *  This procedure returns the next input byte from a stream. This stream
 *  could be anything from a base-64 encoded string to a Channel.
 *
 * Results:
 *  The next byte (or IMG_DONE) is returned.
 *
 * Side effects:
 *  The MFile state could change.
 *
 *--------------------------------------------------------------------------
 */

int
ImgGetc(handle)
   MFile *handle;			/* Input stream handle */
{
    int c;
    int result = 0;			/* Initialization needed only to prevent
					 * gcc compiler warning */
    if (handle->state == IMG_DONE) {
	return IMG_DONE;
    }

    if (handle->state == IMG_STRING) {
	if (!handle->length--) {
	    handle->state = IMG_DONE;
	    return IMG_DONE;
	}
	return *handle->data++;
    }

    do {
	if (!handle->length--) {
	    handle->state = IMG_DONE;
	    return IMG_DONE;
	}
	c = char64(*handle->data++);
    } while (c == IMG_SPACE);

    if (c > IMG_SPECIAL) {
	handle->state = IMG_DONE;
	return IMG_DONE;
    }

    switch (handle->state++) {
	case 0:
	    handle->c = c<<2;
	    result = ImgGetc(handle);
	    break;
	case 1:
	    result = handle->c | (c>>4);
	    handle->c = (c&0xF)<<4;
	    break;
	case 2:
	    result = handle->c | (c>>2);
	    handle->c = (c&0x3)<<6;
	    break;
	case 3:
	    result = handle->c | c;
	    handle->state = 0;
	    break;
    }
    return result;
}

/*
 *-----------------------------------------------------------------------
 * ImgWrite --
 *
 *  This procedure is invoked to put imaged data into a stream
 *  using ImgPutc.
 *
 * Results:
 *  The return value is the number of characters "written"
 *
 * Side effects:
 *  The base64 handle will change state.
 *
 *-----------------------------------------------------------------------
 */

int
ImgWrite(handle, src, count)
    MFile *handle;	/* mmencode "file" handle */
    CONST char *src;	/* where to get the data */
    int count;		/* number of bytes */
{
    register int i;
    int curcount, bufcount;

    switch (handle->state) {
	case IMG_FILE:
	    return (int) fwrite((char *) src, 1, (size_t) count,
		    (FILE *) handle->data);
	case IMG_CHAN:
	    return Tcl_Write((Tcl_Channel) handle->data, (char *) src, count);
    }
    curcount = handle->data - Tcl_DStringValue(handle->buffer);
    bufcount = curcount + count + count/3 + count/52 + 1024;

    /* make sure that the DString contains enough space */
    if (bufcount >= (handle->buffer->spaceAvl)) {
	Tcl_DStringSetLength(handle->buffer, bufcount + 4096);
	handle->data = Tcl_DStringValue(handle->buffer) + curcount;
    }
    /* write the data */
    for (i=0; (i<count) && (ImgPutc(*src++, handle) != IMG_DONE); i++) {
	/* empty loop body */
    }
    return i;
}
/*
 *-----------------------------------------------------------------------
 *
 * ImgPutc --
 *
 *  This procedure encodes and writes the next byte to a base64
 *  encoded string.
 *
 * Results:
 *  The written byte is returned.
 *
 * Side effects:
 *  the base64 handle will change state.
 *
 *-----------------------------------------------------------------------
 */

static char base64_table[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/'
};

int
ImgPutc(c, handle)
    register int c;		/* character to be written */
    register MFile *handle;	/* handle containing decoder data and state */
{
    /* In fact, here should be checked first if the dynamic
     * string contains enough space for the next character.
     * This would be very expensive to do for each character.
     * Therefore we just allocate 1024 bytes immediately in
     * the beginning and also take a 1024 bytes margin inside
     * every ImgWrite. At least this check is done then only
     * every 256 bytes, which is much faster. Because the GIF
     * header is less than 1024 bytes and pixel data is
     * written in 256 byte portions, this should be safe.
     */

    if (c == IMG_DONE) {
	switch(handle->state) {
	    case 1:
		*handle->data++ = base64_table[(handle->c<<4)&63];
		*handle->data++ = '='; *handle->data++ = '='; break;
	    case 2:
		*handle->data++ = base64_table[(handle->c<<2)&63];
		*handle->data++ = '='; break;
	}
	Tcl_DStringSetLength(handle->buffer,
		(handle->data) - Tcl_DStringValue(handle->buffer));
	return IMG_DONE;
    }

    if (handle->state == IMG_FILE) {
	return fputc(c, (FILE *) handle->data);
    }

    c &= 0xff;
    switch (handle->state++) {
	case 0:
	    *handle->data++ = base64_table[(c>>2)&63]; break;
	case 1:
	    c |= handle->c << 8;
	    *handle->data++ = base64_table[(c>>4)&63]; break;
	case 2:
	    handle->state = 0;
	    c |= handle->c << 8;
	    *handle->data++ = base64_table[(c>>6)&63];
	    *handle->data++ = base64_table[c&63]; break;
    }
    handle->c = c;
    if (handle->length++ > 52) {
	handle->length = 0;
	*handle->data++ = '\n';
    }
    return c & 0xff;
};

/*
 *-------------------------------------------------------------------------
 * ImgWriteInit --
 *  This procedure initializes a base64 decoder handle for writing
 *
 * Results:
 *  none
 *
 * Side effects:
 *  the base64 handle is initialized
 *
 *-------------------------------------------------------------------------
 */

void
ImgWriteInit(buffer, handle)
    Tcl_DString *buffer;
    MFile *handle;		/* mmencode "file" handle */
{
    Tcl_DStringSetLength(buffer, buffer->spaceAvl);
    handle->buffer = buffer;
    handle->data = Tcl_DStringValue(buffer);
    handle->state = 0;
    handle->length = 0;
}

/*
 *-------------------------------------------------------------------------
 * ImgReadInit --
 *  This procedure initializes a base64 decoder handle for reading.
 *
 * Results:
 *  none
 *
 * Side effects:
 *  the base64 handle is initialized
 *
 *-------------------------------------------------------------------------
 */


int
ImgReadInit(dataObj, c, handle)
    struct Tcl_Obj *dataObj;	/* string containing initial mmencoded data */
    int c;
    MFile *handle;		/* mmdecode "file" handle */
{
    handle->data = ImgGetStringFromObj(dataObj, &handle->length);
    if (*handle->data == c) {
	handle->state = IMG_STRING;
	return 1;
    }
    c = base64_table[(c>>2)&63];

    while((handle->length) && (char64(*handle->data) == IMG_SPACE)) {
	handle->data++;
	handle->length--;
    }
    if (c != *handle->data) {
	handle->state = IMG_DONE;
	return 0;
    }
    handle->state = 0;
    return 1;
}

#ifdef ALLOW_TOB64
int tob64(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;
    int argc;
    char **argv;
{
    Tcl_DString dstring;
    MFile handle;
    FILE *fp;
    char *fullName;
    char buffer[1024];
    int len;

    if (argc != 2) {
	Tcl_AppendResult(interp, "wrong num of args: should be \"",
		argv[0]," filename\"", (char *) NULL);
	return TCL_ERROR;
    }

    if ((fullName=Tcl_TranslateFileName(interp, argv[1],&dstring))==NULL) {
	return TCL_ERROR;
    }
    if (!(fp=fopen(fullName,"rb"))) {
	Tcl_AppendResult(interp, argv[1], ": ", Tcl_PosixError(interp),
		(char *)NULL);
	Tcl_DStringFree(&dstring);
	return TCL_ERROR;
    }
    Tcl_DStringFree(&dstring);

    Tcl_DStringInit(&dstring);
    ImgWriteInit(&dstring, &handle);

    while ((len = fread(buffer, 1, 1024, fp)) == 1024) {
	ImgWrite(&handle, buffer, 1024);
    }
    if (len > 0) {
	ImgWrite(&handle, buffer, len);
    }
    fclose(fp);
    ImgPutc(IMG_DONE, &handle);

    Tcl_DStringResult(interp, &dstring);
    return TCL_OK;
}
#endif
