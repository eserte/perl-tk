#ifdef _TKEVENT
#ifndef LangCallCallback
VFUNC(int,LangCallCallback,V_LangCallCallback,_ANSI_ARGS_((LangCallback *cb, int flags)))
#endif

#ifndef LangCallbackObj
VFUNC(Tcl_Obj *,LangCallbackObj,V_LangCallbackObj,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangCmpCallback
VFUNC(int,LangCmpCallback,V_LangCmpCallback,_ANSI_ARGS_((LangCallback *a,Arg b)))
#endif

#ifndef LangCopyCallback
VFUNC(LangCallback *,LangCopyCallback,V_LangCopyCallback,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangDebug
VFUNC(void,LangDebug,V_LangDebug,_ANSI_ARGS_((char *fmt,...)))
#endif

#ifndef LangFreeCallback
VFUNC(void,LangFreeCallback,V_LangFreeCallback,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangMakeCallback
VFUNC(LangCallback *,LangMakeCallback,V_LangMakeCallback,_ANSI_ARGS_((Arg)))
#endif

#ifndef LangOldCallbackArg
VFUNC(Arg,LangOldCallbackArg,V_LangOldCallbackArg,_ANSI_ARGS_((LangCallback *,char *,int)))
#endif

#ifndef LangPushCallbackArgs
VFUNC(void,LangPushCallbackArgs,V_LangPushCallbackArgs,_ANSI_ARGS_((LangCallback **svp)))
#endif

#ifndef Tcl_Alloc
VFUNC(char *,Tcl_Alloc,V_Tcl_Alloc,_ANSI_ARGS_((unsigned int size)))
#endif

#ifndef Tcl_CancelIdleCall
VFUNC(void,Tcl_CancelIdleCall,V_Tcl_CancelIdleCall,_ANSI_ARGS_((Tcl_IdleProc *idleProc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateEventSource
VFUNC(void,Tcl_CreateEventSource,V_Tcl_CreateEventSource,_ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc,
			    Tcl_EventCheckProc *checkProc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateExitHandler
VFUNC(void,Tcl_CreateExitHandler,V_Tcl_CreateExitHandler,_ANSI_ARGS_((Tcl_ExitProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateFileHandler
VFUNC(void,Tcl_CreateFileHandler,V_Tcl_CreateFileHandler,_ANSI_ARGS_((
    			    int fd, int mask, Tcl_FileProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateTimerHandler
VFUNC(Tcl_TimerToken,Tcl_CreateTimerHandler,V_Tcl_CreateTimerHandler,_ANSI_ARGS_((int milliseconds,
			    Tcl_TimerProc *proc, ClientData clientData)))
#endif

#ifndef Tcl_DbCkalloc
VFUNC(char *,Tcl_DbCkalloc,V_Tcl_DbCkalloc,_ANSI_ARGS_((unsigned int size,char *file,int line)))
#endif

#ifndef Tcl_DbCkfree
VFUNC(void,Tcl_DbCkfree,V_Tcl_DbCkfree,_ANSI_ARGS_((char *ptr,char *file ,int line)))
#endif

#ifndef Tcl_DbCkrealloc
VFUNC(char *,Tcl_DbCkrealloc,V_Tcl_DbCkrealloc,_ANSI_ARGS_((char *ptr,
			    unsigned int size,char *file,int line)))
#endif

#ifndef Tcl_DeleteEventSource
VFUNC(void,Tcl_DeleteEventSource,V_Tcl_DeleteEventSource,_ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc,
			    Tcl_EventCheckProc *checkProc,
			    ClientData clientData)))
#endif

#ifndef Tcl_DeleteFileHandler
VFUNC(void,Tcl_DeleteFileHandler,V_Tcl_DeleteFileHandler,_ANSI_ARGS_((int fd)))
#endif

#ifndef Tcl_DeleteTimerHandler
VFUNC(void,Tcl_DeleteTimerHandler,V_Tcl_DeleteTimerHandler,_ANSI_ARGS_((
			    Tcl_TimerToken token)))
#endif

#ifndef Tcl_DoOneEvent
VFUNC(int,Tcl_DoOneEvent,V_Tcl_DoOneEvent,_ANSI_ARGS_((int flags)))
#endif

#ifndef Tcl_DoWhenIdle
VFUNC(void,Tcl_DoWhenIdle,V_Tcl_DoWhenIdle,_ANSI_ARGS_((Tcl_IdleProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_Exit
VFUNC(void,Tcl_Exit,V_Tcl_Exit,_ANSI_ARGS_((int status)))
#endif

#ifndef Tcl_Free
VFUNC(void,Tcl_Free,V_Tcl_Free,_ANSI_ARGS_((char *ptr)))
#endif

#ifndef Tcl_GetServiceMode
VFUNC(int,Tcl_GetServiceMode,V_Tcl_GetServiceMode,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_Panic
VFUNC(void,Tcl_Panic,V_Tcl_Panic,_ANSI_ARGS_((char *,...)))
#endif

#ifndef Tcl_QueueEvent
VFUNC(void,Tcl_QueueEvent,V_Tcl_QueueEvent,_ANSI_ARGS_((Tcl_Event *evPtr,
			    Tcl_QueuePosition position)))
#endif

#ifndef Tcl_QueueProcEvent
VFUNC(void,Tcl_QueueProcEvent,V_Tcl_QueueProcEvent,_ANSI_ARGS_((Tcl_EventProc *proc,
			    Tcl_Event *evPtr,
			    Tcl_QueuePosition position)))
#endif

#ifndef Tcl_Realloc
VFUNC(char *,Tcl_Realloc,V_Tcl_Realloc,_ANSI_ARGS_((char *ptr,
			    unsigned int size)))
#endif

#ifndef Tcl_ServiceAll
VFUNC(int,Tcl_ServiceAll,V_Tcl_ServiceAll,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_ServiceEvent
VFUNC(int,Tcl_ServiceEvent,V_Tcl_ServiceEvent,_ANSI_ARGS_((int flags)))
#endif

#ifndef Tcl_SetMaxBlockTime
VFUNC(void,Tcl_SetMaxBlockTime,V_Tcl_SetMaxBlockTime,_ANSI_ARGS_((Tcl_Time *timePtr)))
#endif

#ifndef Tcl_SetServiceMode
VFUNC(int,Tcl_SetServiceMode,V_Tcl_SetServiceMode,_ANSI_ARGS_((int mode)))
#endif

#ifndef Tcl_Sleep
VFUNC(void,Tcl_Sleep,V_Tcl_Sleep,_ANSI_ARGS_((int ms)))
#endif

#ifndef TclpGetTime
VFUNC(void,TclpGetTime,V_TclpGetTime,_ANSI_ARGS_((Tcl_Time *time)))
#endif

#endif /* _TKEVENT */
