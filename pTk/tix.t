#ifdef _TIX
VVAR(Tcl_HashTable,specTable,V_specTable)
VFUNC(int,Tix_AppInit,V_Tix_AppInit,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(int,Tix_CallMethod,V_Tix_CallMethod,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *widRec, char *method,
			    int argc, Arg *args)))
VFUNC(int,Tix_ChangeOneOption,V_Tix_ChangeOneOption,_ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord *cPtr,
			    char * widRec, TixConfigSpec *spec, char * value,
			    int isDefault, int isInit)))
VFUNC(void,Tix_CreateCommands,V_Tix_CreateCommands,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tix_TclCmd *commands,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
VFUNC(int,Tix_ExistMethod,V_Tix_ExistMethod,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *method)))
VFUNC(void,Tix_Exit,V_Tix_Exit,_ANSI_ARGS_((Tcl_Interp * interp, int code)))
VFUNC(TixConfigSpec *,Tix_FindConfigSpecByName,V_Tix_FindConfigSpecByName,_ANSI_ARGS_((
			    Tcl_Interp * interp,
			    TixClassRecord * cPtr, char * name)))
VFUNC(char  *,Tix_FindMethod,V_Tix_FindMethod,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *method)))
VFUNC(char *,Tix_FindPublicMethod,V_Tix_FindPublicMethod,_ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord * cPtr, 
			    char * method)))
VFUNC(TixClassRecord *,Tix_GetClassByName,V_Tix_GetClassByName,_ANSI_ARGS_((
			    Tcl_Interp * interp, char * classRec)))
VFUNC(char  *,Tix_GetConfigSpecFullName,V_Tix_GetConfigSpecFullName,_ANSI_ARGS_((char *clasRec,
			    char *flag)))
VFUNC(char  *,Tix_GetContext,V_Tix_GetContext,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec)))
VFUNC(char  *,Tix_GetMethodFullName,V_Tix_GetMethodFullName,_ANSI_ARGS_((char *context,
			    char *method)))
VFUNC(void,Tix_GetPublicMethods,V_Tix_GetPublicMethods,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec, int *numMethods,
			    char *** validMethods)))
VFUNC(void,Tix_GetScrollFractions,V_Tix_GetScrollFractions,_ANSI_ARGS_((int total,
			    int window, int first,
			    double * first_ret, double * last_ret)))
VFUNC(int,Tix_GetWidgetOption,V_Tix_GetWidgetOption,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin,
			    char *argvName, char *dbName, char *dbClass,
			    char *defValue, int argc, Arg *args,
			    int type, char *ptr)))
VFUNC(int,Tix_HandleSubCmds,V_Tix_HandleSubCmds,_ANSI_ARGS_((
			    Tix_CmdInfo * cmdInfo,
			    Tix_SubCmdInfo * subCmdInfo,
			    ClientData clientData, Tcl_Interp *interp,
			    int argc, Arg *args)))
VFUNC(int,Tix_Init,V_Tix_Init,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tix_LinkListAppend,V_Tix_LinkListAppend,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr, int flags)))
VFUNC(void,Tix_LinkListDelete,V_Tix_LinkListDelete,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
VFUNC(int,Tix_LinkListDeleteRange,V_Tix_LinkListDeleteRange,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * fromPtr,
			    char * toPtr, Tix_ListIterator * liPtr)))
VFUNC(int,Tix_LinkListFind,V_Tix_LinkListFind,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr, Tix_LinkList * lPtr,
			    char * itemPtr, Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListInit,V_Tix_LinkListInit,_ANSI_ARGS_((Tix_LinkList * lPtr)))
VFUNC(void,Tix_LinkListInsert,V_Tix_LinkListInsert,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr,
			    Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListIteratorInit,V_Tix_LinkListIteratorInit,_ANSI_ARGS_((Tix_ListIterator *liPtr)))
VFUNC(void,Tix_LinkListNext,V_Tix_LinkListNext,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListStart,V_Tix_LinkListStart,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
VFUNC(int,Tix_LoadTclLibrary,V_Tix_LoadTclLibrary,_ANSI_ARGS_((
			    Tcl_Interp *interp, char *envName,
			    char *tclName, char *initFile,
			    char *defDir, char * appName)))
VFUNC(void,Tix_MainLoop,V_Tix_MainLoop,_ANSI_ARGS_((Tcl_Interp * interp)))
VFUNC(void,Tix_OpenStdin,V_Tix_OpenStdin,_ANSI_ARGS_(()))
VFUNC(void,Tix_RestoreContext,V_Tix_RestoreContext,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec, char *oldContext)))
VFUNC(char  *,Tix_SaveContext,V_Tix_SaveContext,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec)))
VFUNC(void,Tix_SetArgv,V_Tix_SetArgv,_ANSI_ARGS_((Tcl_Interp *interp, 
			    int argc, Arg *args)))
VFUNC(int,Tix_SuperClass,V_Tix_SuperClass,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *widClass, char ** superClass_ret)))
VFUNC(int,Tix_SysInit,V_Tix_SysInit,_ANSI_ARGS_((Tcl_Interp *interp,
			    int *argcPtr, Arg *args)))
VFUNC(int,Tix_UnknownPublicMethodError,V_Tix_UnknownPublicMethodError,_ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord * cPtr,
			    char * widRec, char * method)))
VFUNC(int,Tix_ValueMissingError,V_Tix_ValueMissingError,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *spec)))
VFUNC(Tcl_Interp *,Tix_WishInit,V_Tix_WishInit,_ANSI_ARGS_((int *argcPtr, Arg *args,
			    char * rcFileName, int readStdin)))
VFUNC(void,Tk_Draw3DArc,V_Tk_Draw3DArc,_ANSI_ARGS_((Display *display,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int angle1,
			    int angle2, int borderWidth, int relief)))
#endif /* _TIX */
