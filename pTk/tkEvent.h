#ifndef _TKEVENT
#define _TKEVENT

EXTERN LangCallback *	LangMakeCallback _ANSI_ARGS_((Arg));
EXTERN Tcl_Obj *	LangCallbackObj _ANSI_ARGS_((LangCallback *));
EXTERN Arg		LangOldCallbackArg _ANSI_ARGS_((LangCallback *,char *,int));

#define LangCallbackArg(x) LangOldCallbackArg(x,__FILE__,__LINE__)

EXTERN void		LangFreeCallback _ANSI_ARGS_((LangCallback *));
EXTERN LangCallback *	LangCopyCallback _ANSI_ARGS_((LangCallback *));
EXTERN int		LangCmpCallback _ANSI_ARGS_((LangCallback *a,Arg b));
EXTERN void		LangPushCallbackArgs _ANSI_ARGS_((LangCallback **svp));
EXTERN int		LangCallCallback _ANSI_ARGS_((LangCallback *cb, int flags));
EXTERN void		LangDebug _ANSI_ARGS_((char *fmt,...));

EXTERN char *		Tcl_Alloc _ANSI_ARGS_((unsigned int size));
EXTERN void		Tcl_Free _ANSI_ARGS_((char *ptr));
EXTERN char *		Tcl_Realloc _ANSI_ARGS_((char *ptr,
			    unsigned int size));
EXTERN char *		Tcl_DbCkalloc _ANSI_ARGS_((unsigned int size,char *file,int line));
EXTERN void		Tcl_DbCkfree _ANSI_ARGS_((char *ptr,char *file ,int line));
EXTERN char *		Tcl_DbCkrealloc _ANSI_ARGS_((char *ptr,
			    unsigned int size,char *file,int line));

EXTERN void		Tcl_Panic _ANSI_ARGS_((char *,...));

EXTERN void		TclpGetTime _ANSI_ARGS_((Tcl_Time *time));

EXTERN void		Tcl_Exit _ANSI_ARGS_((int status));

EXTERN void		Tcl_CreateEventSource _ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc,
			    Tcl_EventCheckProc *checkProc,
			    ClientData clientData));

EXTERN void		Tcl_DeleteEventSource _ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc,
			    Tcl_EventCheckProc *checkProc,
			    ClientData clientData));

EXTERN int		Tcl_DoOneEvent _ANSI_ARGS_((int flags));

EXTERN void		Tcl_QueueEvent _ANSI_ARGS_((Tcl_Event *evPtr,
			    Tcl_QueuePosition position));

EXTERN void		Tcl_QueueProcEvent _ANSI_ARGS_((Tcl_EventProc *proc,
			    Tcl_Event *evPtr,
			    Tcl_QueuePosition position));

EXTERN int		Tcl_ServiceEvent _ANSI_ARGS_((int flags));

EXTERN Tcl_TimerToken	Tcl_CreateTimerHandler _ANSI_ARGS_((int milliseconds,
			    Tcl_TimerProc *proc, ClientData clientData));

EXTERN void		Tcl_DeleteTimerHandler _ANSI_ARGS_((
			    Tcl_TimerToken token));

EXTERN void		Tcl_SetMaxBlockTime _ANSI_ARGS_((Tcl_Time *timePtr));

EXTERN void		Tcl_DoWhenIdle _ANSI_ARGS_((Tcl_IdleProc *proc,
			    ClientData clientData));

EXTERN void		Tcl_CancelIdleCall _ANSI_ARGS_((Tcl_IdleProc *idleProc,
			    ClientData clientData));

EXTERN void		Tcl_CreateExitHandler _ANSI_ARGS_((Tcl_ExitProc *proc,
			    ClientData clientData));

EXTERN void		Tcl_CreateFileHandler _ANSI_ARGS_((
    			    int fd, int mask, Tcl_FileProc *proc,
			    ClientData clientData));
EXTERN void		Tcl_DeleteFileHandler _ANSI_ARGS_((int fd));

EXTERN void		Tcl_Sleep _ANSI_ARGS_((int ms));

EXTERN int		Tcl_GetServiceMode _ANSI_ARGS_((void));

EXTERN int		Tcl_SetServiceMode _ANSI_ARGS_((int mode));

EXTERN int		Tcl_ServiceAll _ANSI_ARGS_((void));

#endif /* _TKEVENT */
