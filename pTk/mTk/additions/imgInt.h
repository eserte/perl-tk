/* imgInt.h */

#ifndef _IMGINT
#define _IMGINT

#include "tkInt.h"

#ifndef RESOURCE_INCLUDED

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#include "img.h"

typedef struct {
    Tcl_DString *buffer;/* pointer to dynamical string */
    char *data;		/* mmencoded source string */
    int c;		/* bits left over from previous char */
    int state;		/* decoder state (0-4 or IMG_DONE) */
    int length;		/* length of phisical line already written */
} MFile;

#define IMG_SPECIAL	 (1<<8)
#define IMG_PAD		(IMG_SPECIAL+1)
#define IMG_SPACE	(IMG_SPECIAL+2)
#define IMG_BAD		(IMG_SPECIAL+3)
#define IMG_DONE	(IMG_SPECIAL+4)
#define IMG_CHAN        (IMG_SPECIAL+5)
#define IMG_STRING	(IMG_SPECIAL+6)

#define IMG_TCL		(1<<9)
#define IMG_OBJS	(1<<10)
#define IMG_PERL	(1<<11)

EXTERN int ImgPhotoPutBlock _ANSI_ARGS_((Tk_PhotoHandle handle,
	Tk_PhotoImageBlock *blockPtr, int x, int y, int width, int height));

EXTERN int ImgLoadLib _ANSI_ARGS_((Tcl_Interp *interp, CONST char *libName,
	VOID **handlePtr, char **symbols, int num));
EXTERN void ImgLoadFailed _ANSI_ARGS_((VOID **handlePtr));

EXTERN int ImgObjInit _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN char *ImgGetStringFromObj _ANSI_ARGS_((Tcl_Obj *objPtr,
	int *lengthPtr));
EXTERN char *ImgGetByteArrayFromObj _ANSI_ARGS_((Tcl_Obj *objPtr,
	int *lengthPtr));
EXTERN int ImgListObjGetElements _ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *objPtr, int *argc, Tcl_Obj ***argv));

EXTERN int ImgGetc _ANSI_ARGS_((MFile *handle));
EXTERN int ImgRead _ANSI_ARGS_((MFile *handle, char *dst, int count));
EXTERN int ImgPutc _ANSI_ARGS_((int c, MFile *handle));
EXTERN int ImgWrite _ANSI_ARGS_((MFile *handle, CONST char *src, int count));
EXTERN int ImgSeek _ANSI_ARGS_((MFile *handle, int off, int whence));
EXTERN void ImgWriteInit _ANSI_ARGS_((Tcl_DString *buffer, MFile *handle));
EXTERN int ImgReadInit _ANSI_ARGS_((Tcl_Obj *data, int c, MFile *handle));

EXTERN int ImgInitTIFFzip _ANSI_ARGS_((VOID *, int));
EXTERN int ImgInitTIFFjpeg _ANSI_ARGS_((VOID *, int));
EXTERN int ImgInitTIFFpixar _ANSI_ARGS_((VOID *, int));
EXTERN int ImgLoadJpegLibrary _ANSI_ARGS_((void));

#endif /* RESOURCE_INCLUDED */

#endif /* _IMGINT */

