#ifdef _TKOPTION
#ifndef TkOptionClassChanged
VFUNC(void,TkOptionClassChanged,V_TkOptionClassChanged,_ANSI_ARGS_((struct TkWindow *winPtr)))
#endif

#ifndef TkOptionDeadWindow
VFUNC(void,TkOptionDeadWindow,V_TkOptionDeadWindow,_ANSI_ARGS_((struct TkWindow *winPtr)))
#endif

#ifndef Tk_AddOption
VFUNC(void,Tk_AddOption,V_Tk_AddOption,_ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *value, int priority)))
#endif

#ifndef Tk_GetOption
VFUNC(Tk_Uid,Tk_GetOption,V_Tk_GetOption,_ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *className)))
#endif

#ifndef Tk_OptionCmd
VFUNC(int,Tk_OptionCmd,V_Tk_OptionCmd,_ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args)))
#endif

#endif /* _TKOPTION */
