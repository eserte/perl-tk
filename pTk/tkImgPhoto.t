#ifdef _TKIMGPHOTO
VVAR(Tk_PhotoImageFormat,tkImgFmtGIF,V_tkImgFmtGIF)
VVAR(Tk_PhotoImageFormat,tkImgFmtPPM,V_tkImgFmtPPM)
VFUNC(void,Tk_CreatePhotoImageFormat,V_Tk_CreatePhotoImageFormat,_ANSI_ARGS_((
			    Tk_PhotoImageFormat *formatPtr)))
VFUNC(Tk_PhotoHandle,Tk_FindPhoto,V_Tk_FindPhoto,_ANSI_ARGS_((char *imageName)))
VFUNC(void,Tk_PhotoBlank,V_Tk_PhotoBlank,_ANSI_ARGS_((Tk_PhotoHandle handle)))
VFUNC(void,Tk_PhotoExpand,V_Tk_PhotoExpand,_ANSI_ARGS_((Tk_PhotoHandle handle,
			    int width, int height )))
VFUNC(int,Tk_PhotoGetImage,V_Tk_PhotoGetImage,_ANSI_ARGS_((Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr)))
VFUNC(void,Tk_PhotoGetSize,V_Tk_PhotoGetSize,_ANSI_ARGS_((Tk_PhotoHandle handle,
			    int *widthPtr, int *heightPtr)))
VFUNC(void,Tk_PhotoPutBlock,V_Tk_PhotoPutBlock,_ANSI_ARGS_((Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr, int x, int y,
			    int width, int height)))
VFUNC(void,Tk_PhotoPutZoomedBlock,V_Tk_PhotoPutZoomedBlock,_ANSI_ARGS_((
			    Tk_PhotoHandle handle,
			    Tk_PhotoImageBlock *blockPtr, int x, int y,
			    int width, int height, int zoomX, int zoomY,
			    int subsampleX, int subsampleY)))
VFUNC(void,Tk_PhotoSetSize,V_Tk_PhotoSetSize,_ANSI_ARGS_((Tk_PhotoHandle handle,
			    int width, int height)))
#endif /* _TKIMGPHOTO */
