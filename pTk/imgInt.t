#ifdef _IMGINT
#ifndef ImgGetc
VFUNC(int,ImgGetc,V_ImgGetc,_ANSI_ARGS_((MFile *handle)))
#endif

#ifndef ImgPhotoPutBlock
VFUNC(int,ImgPhotoPutBlock,V_ImgPhotoPutBlock,_ANSI_ARGS_((Tk_PhotoHandle handle,
	Tk_PhotoImageBlock *blockPtr, int x, int y, int width, int height)))
#endif

#ifndef ImgPutc
VFUNC(int,ImgPutc,V_ImgPutc,_ANSI_ARGS_((int c, MFile *handle)))
#endif

#ifndef ImgRead
VFUNC(int,ImgRead,V_ImgRead,_ANSI_ARGS_((MFile *handle, VOID *dst, int count)))
#endif

#ifndef ImgReadInit
VFUNC(int,ImgReadInit,V_ImgReadInit,_ANSI_ARGS_((Tcl_Obj *objPtr, int c, MFile *handle)))
#endif

#ifndef ImgWrite
VFUNC(int,ImgWrite,V_ImgWrite,_ANSI_ARGS_((MFile *handle, CONST char *src, int count)))
#endif

#ifndef ImgWriteInit
VFUNC(void,ImgWriteInit,V_ImgWriteInit,_ANSI_ARGS_((Tcl_DString *buffer, MFile *handle)))
#endif

#endif /* _IMGINT */
