EXTERN void		Xrm_AddOption _ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *value, int priority));
EXTERN Tk_Uid		Xrm_GetOption _ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *className));
EXTERN int		Xrm_OptionCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args));
EXTERN void		XrmOptionClassChanged _ANSI_ARGS_((TkWindow *winPtr));
EXTERN void		XrmOptionDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
EXTERN void		Xrm_import _ANSI_ARGS_((char *class));

