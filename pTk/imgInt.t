#ifdef _IMGINT
#ifndef ImgFixChanMatchProc
VFUNC(void,ImgFixChanMatchProc,V_ImgFixChanMatchProc,_ANSI_ARGS_((Tcl_Interp **interp, Tcl_Channel *chan,
	Tcl_Obj **file, Tcl_Obj **format, int **width, int **height)))
#endif

#ifndef ImgFixObjMatchProc
VFUNC(void,ImgFixObjMatchProc,V_ImgFixObjMatchProc,_ANSI_ARGS_((Tcl_Interp **interp, Tcl_Obj **data,
	Tcl_Obj **format, int **width, int **height)))
#endif

#ifndef ImgFixStringWriteProc
VFUNC(void,ImgFixStringWriteProc,V_ImgFixStringWriteProc,_ANSI_ARGS_((Tcl_DString *data, Tcl_Interp **interp,
	Tcl_DString **dataPtr, Tcl_Obj **format, Tk_PhotoImageBlock **blockPtr)))
#endif

#ifndef ImgGetByteArrayFromObj
VFUNC(char *,ImgGetByteArrayFromObj,V_ImgGetByteArrayFromObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
	int *lengthPtr)))
#endif

#ifndef ImgGetc
VFUNC(int,ImgGetc,V_ImgGetc,_ANSI_ARGS_((MFile *handle)))
#endif

#ifndef ImgListObjGetElements
VFUNC(int,ImgListObjGetElements,V_ImgListObjGetElements,_ANSI_ARGS_((Tcl_Interp *interp,
	Tcl_Obj *objPtr, int *argc, Tcl_Obj ***objv)))
#endif

#ifndef ImgObjInit
VFUNC(int,ImgObjInit,V_ImgObjInit,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef ImgOpenFileChannel
VFUNC(Tcl_Channel,ImgOpenFileChannel,V_ImgOpenFileChannel,_ANSI_ARGS_((Tcl_Interp *interp,
	CONST char *fileName, int permissions)))
#endif

#ifndef ImgPhotoPutBlock
VFUNC(int,ImgPhotoPutBlock,V_ImgPhotoPutBlock,_ANSI_ARGS_((Tk_PhotoHandle handle,
	Tk_PhotoImageBlock *blockPtr, int x, int y, int width, int height)))
#endif

#ifndef ImgPutc
VFUNC(int,ImgPutc,V_ImgPutc,_ANSI_ARGS_((int c, MFile *handle)))
#endif

#ifndef ImgRead
VFUNC(int,ImgRead,V_ImgRead,_ANSI_ARGS_((MFile *handle, char *dst, int count)))
#endif

#ifndef ImgReadInit
VFUNC(int,ImgReadInit,V_ImgReadInit,_ANSI_ARGS_((Tcl_Obj *data, int c, MFile *handle)))
#endif

#ifndef ImgWrite
VFUNC(int,ImgWrite,V_ImgWrite,_ANSI_ARGS_((MFile *handle, CONST char *src, int count)))
#endif

#ifndef ImgWriteInit
VFUNC(void,ImgWriteInit,V_ImgWriteInit,_ANSI_ARGS_((Tcl_DString *buffer, MFile *handle)))
#endif

#endif /* _IMGINT */
