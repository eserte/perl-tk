#ifndef _TKIMGPHOTO
#define _TKIMGPHOTO

EXTERN void		Tk_CreatePhotoImageFormat _ANSI_ARGS_((
			    Tk_PhotoImageFormat *formatPtr));
EXTERN Tk_PhotoHandle	Tk_FindPhoto _ANSI_ARGS_((Tcl_Interp *interp, 
			    char *imageName));
EXTERN void		Tk_PhotoPutBlock _ANSI_ARGS_((Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr, int x, int y,
			    int width, int height));
EXTERN void		Tk_PhotoPutZoomedBlock _ANSI_ARGS_((
			    Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr, int x, int y,
			    int width, int height, int zoomX, int zoomY,
			    int subsampleX, int subsampleY));
EXTERN int		Tk_PhotoGetImage _ANSI_ARGS_((Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr));
EXTERN void		Tk_PhotoBlank _ANSI_ARGS_((Tk_PhotoHandle handle));
EXTERN void		Tk_PhotoExpand _ANSI_ARGS_((Tk_PhotoHandle handle,
			    int width, int height ));
EXTERN void		Tk_PhotoGetSize _ANSI_ARGS_((Tk_PhotoHandle handle,
			    int *widthPtr, int *heightPtr));
EXTERN void		Tk_PhotoSetSize _ANSI_ARGS_((Tk_PhotoHandle handle,
			    int width, int height));

EXTERN char *		Tk_PhotoFormatName _ANSI_ARGS_((Tcl_Interp *interp, 
			    Tcl_Obj *formatString));

extern Tk_PhotoImageFormat	tkImgFmtPPM;
extern Tk_PhotoImageFormat	tkImgFmtGIF;

#endif
