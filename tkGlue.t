#ifdef _TKGLUE
#ifndef Call_Tk
VFUNC(int,Call_Tk,V_Call_Tk,_ANSI_ARGS_((Lang_CmdInfo *info,int argc, SV **args)))
#endif
#ifndef EnterWidgetMethods
VFUNC(void,EnterWidgetMethods,V_EnterWidgetMethods,_ANSI_ARGS_((char *package, ...)))
#endif
#ifndef FindTkVarName
VFUNC(SV *,FindTkVarName,V_FindTkVarName,_ANSI_ARGS_((char *varName,int flags)))
#endif
#ifndef InterpHv
VFUNC(HV *,InterpHv,V_InterpHv,_ANSI_ARGS_((Tcl_Interp *interp,int fatal)))
#endif
#ifndef Lang_TkCommand
VFUNC(void,Lang_TkCommand,V_Lang_TkCommand,_ANSI_ARGS_((char *name, Tcl_CmdProc *proc)))
#endif
#ifndef MakeReference
VFUNC(SV *,MakeReference,V_MakeReference,_ANSI_ARGS_((SV * sv)))
#endif
#ifndef SVtoWindow
VFUNC(Tk_Window,SVtoWindow,V_SVtoWindow,_ANSI_ARGS_((SV *win)))
#endif
#ifndef TkToMainWindow
VFUNC(Tk_Window,TkToMainWindow,V_TkToMainWindow,_ANSI_ARGS_((Tk_Window tkwin)))
#endif
#ifndef TkToWidget
VFUNC(SV *,TkToWidget,V_TkToWidget,_ANSI_ARGS_((Tk_Window tkwin,Tcl_Interp **pinterp)))
#endif
#ifndef WidgetRef
VFUNC(SV *,WidgetRef,V_WidgetRef,_ANSI_ARGS_((Tcl_Interp *interp, char *path)))
#endif
#ifndef WindowCommand
VFUNC(Lang_CmdInfo *,WindowCommand,V_WindowCommand,_ANSI_ARGS_((SV *win,HV **hptr, int moan)))
#endif
#ifndef XStoWidget
VFUNC(void,XStoWidget,V_XStoWidget,_ANSI_ARGS_((CV * cv)))
#endif
#endif /* _TKGLUE */
