#ifdef _TKGLUE
VFUNC(int,Call_Tk,V_Call_Tk,_ANSI_ARGS_((Lang_CmdInfo *info,int argc, SV **args)))
VFUNC(void,EnterWidgetMethods,V_EnterWidgetMethods,_ANSI_ARGS_((char *package, ...)))
VFUNC(SV *,FindTkVarName,V_FindTkVarName,_ANSI_ARGS_((char *varName,int flags)))
VFUNC(Tk_Window,GetWindow,V_GetWindow,_ANSI_ARGS_((SV *win)))
VFUNC(HV *,InterpHv,V_InterpHv,_ANSI_ARGS_((Tcl_Interp *interp,int fatal)))
VFUNC(void,Lang_TkCommand,V_Lang_TkCommand,_ANSI_ARGS_((char *name, Tcl_CmdProc *proc)))
VFUNC(SV *,MakeReference,V_MakeReference,_ANSI_ARGS_((SV * sv)))
VFUNC(Tk_Window,TkToMainWindow,V_TkToMainWindow,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(SV *,TkToWidget,V_TkToWidget,_ANSI_ARGS_((Tk_Window tkwin,Tcl_Interp **pinterp)))
VFUNC(SV *,WidgetRef,V_WidgetRef,_ANSI_ARGS_((Tcl_Interp *interp, char *path)))
VFUNC(Lang_CmdInfo *,WindowCommand,V_WindowCommand,_ANSI_ARGS_((SV *win,HV **hptr, int moan)))
VFUNC(void,XStoWidget,V_XStoWidget,_ANSI_ARGS_((CV * cv)))
#endif /* _TKGLUE */
