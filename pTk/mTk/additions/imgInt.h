
/* imgInt.h */

#include "Lang.h"
#include "tkInt.h"
#include "tkVMacro.h"

typedef struct {
    Tcl_DString *buffer;/* pointer to dynamical string */
    char *data;		/* mmencoded source string */
    int c;		/* bits left over from previous char */
    int state;		/* decoder state (0-4 or IMG_DONE) */
    int length;		/* length of phisical line already written */
} MFile;

#if TCL_MAJOR_VERSION < 8
struct Tcl_Obj;
#endif

#define IMG_SPECIAL	 (256)
#define IMG_PAD		(IMG_SPECIAL+1)
#define IMG_SPACE	(IMG_SPECIAL+2)
#define IMG_BAD		(IMG_SPECIAL+3)
#define IMG_DONE	(IMG_SPECIAL+4)
#define IMG_STRING	(IMG_SPECIAL+6)
#define IMG_FILE	(IMG_SPECIAL+7)
#define IMG_CHAN	(IMG_SPECIAL+8)

EXTERN int ImgPhotoPutBlock _ANSI_ARGS_((Tk_PhotoHandle handle,
	Tk_PhotoImageBlock *blockPtr, int x, int y, int width, int height));
EXTERN int ImgLoadLib _ANSI_ARGS_((Tcl_Interp *interp, CONST char *libName,
	VOID **handlePtr, char **symbols, int num));
EXTERN void ImgLoadFailed _ANSI_ARGS_((VOID **handlePtr));
#if TCL_MAJOR_VERSION < 8
EXTERN char *ImgGetStringFromObj _ANSI_ARGS_((struct Tcl_Obj *objPtr,
	int *lengthPtr));
#else  
#define ImgGetStringFromObj(obj,lp) Tcl_GetStringFromObj(obj,lp)
#endif 
EXTERN int ImgGetc _ANSI_ARGS_((MFile *handle));
EXTERN int ImgRead _ANSI_ARGS_((MFile *handle, VOID *dst, int count));
EXTERN int ImgPutc _ANSI_ARGS_((int c, MFile *handle));
EXTERN int ImgWrite _ANSI_ARGS_((MFile *handle, CONST char *src, int count));
EXTERN void ImgWriteInit _ANSI_ARGS_((Tcl_DString *buffer, MFile *handle));
EXTERN int ImgReadInit _ANSI_ARGS_((struct Tcl_Obj *objPtr, int c, MFile *handle));
EXTERN int ImgInitTIFFzip _ANSI_ARGS_((VOID *, int));
EXTERN int ImgInitTIFFjpeg _ANSI_ARGS_((VOID *, int));
EXTERN int ImgLoadJpegLibrary _ANSI_ARGS_((void));
