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

#ifndef Lang_TkSubCommand
VFUNC(void,Lang_TkSubCommand,V_Lang_TkSubCommand,_ANSI_ARGS_((char *name, Tcl_CmdProc *proc)))
#endif

#ifndef MakeReference
VFUNC(SV *,MakeReference,V_MakeReference,_ANSI_ARGS_((SV * sv)))
#endif

#ifndef SVtoFont
VFUNC(Tk_Font,SVtoFont,V_SVtoFont,_ANSI_ARGS_((SV *win)))
#endif

#ifndef SVtoHWND
VFUNC(HWND,SVtoHWND,V_SVtoHWND,_ANSI_ARGS_((SV *win)))
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

#ifndef XSTkCommand
VFUNC(int,XSTkCommand,V_XSTkCommand,_ANSI_ARGS_((CV *cv, Tcl_CmdProc *proc, int items, SV **args)))
#endif

#ifndef install_vtab
VFUNC(void,install_vtab,V_install_vtab,_ANSI_ARGS_((char *name, void *table, size_t size)))
#endif

#endif /* _TKGLUE */
