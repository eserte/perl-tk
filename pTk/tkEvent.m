#ifndef _TKEVENT_VM
#define _TKEVENT_VM
#include "tkEvent_f.h"
#ifndef NO_VTABLES
#ifndef LangCallCallback
#  define LangCallCallback (*TkeventVptr->V_LangCallCallback)
#endif

#ifndef LangCallbackObj
#  define LangCallbackObj (*TkeventVptr->V_LangCallbackObj)
#endif

#ifndef LangCmpCallback
#  define LangCmpCallback (*TkeventVptr->V_LangCmpCallback)
#endif

#ifndef LangCopyCallback
#  define LangCopyCallback (*TkeventVptr->V_LangCopyCallback)
#endif

#ifndef LangDebug
#  define LangDebug (*TkeventVptr->V_LangDebug)
#endif

#ifndef LangFreeCallback
#  define LangFreeCallback (*TkeventVptr->V_LangFreeCallback)
#endif

#ifndef LangMakeCallback
#  define LangMakeCallback (*TkeventVptr->V_LangMakeCallback)
#endif

#ifndef LangOldCallbackArg
#  define LangOldCallbackArg (*TkeventVptr->V_LangOldCallbackArg)
#endif

#ifndef LangPushCallbackArgs
#  define LangPushCallbackArgs (*TkeventVptr->V_LangPushCallbackArgs)
#endif

#ifndef Tcl_Alloc
#  define Tcl_Alloc (*TkeventVptr->V_Tcl_Alloc)
#endif

#ifndef Tcl_CancelIdleCall
#  define Tcl_CancelIdleCall (*TkeventVptr->V_Tcl_CancelIdleCall)
#endif

#ifndef Tcl_CreateEventSource
#  define Tcl_CreateEventSource (*TkeventVptr->V_Tcl_CreateEventSource)
#endif

#ifndef Tcl_CreateExitHandler
#  define Tcl_CreateExitHandler (*TkeventVptr->V_Tcl_CreateExitHandler)
#endif

#ifndef Tcl_CreateFileHandler
#  define Tcl_CreateFileHandler (*TkeventVptr->V_Tcl_CreateFileHandler)
#endif

#ifndef Tcl_CreateTimerHandler
#  define Tcl_CreateTimerHandler (*TkeventVptr->V_Tcl_CreateTimerHandler)
#endif

#ifndef Tcl_DbCkalloc
#  define Tcl_DbCkalloc (*TkeventVptr->V_Tcl_DbCkalloc)
#endif

#ifndef Tcl_DbCkfree
#  define Tcl_DbCkfree (*TkeventVptr->V_Tcl_DbCkfree)
#endif

#ifndef Tcl_DbCkrealloc
#  define Tcl_DbCkrealloc (*TkeventVptr->V_Tcl_DbCkrealloc)
#endif

#ifndef Tcl_DeleteEventSource
#  define Tcl_DeleteEventSource (*TkeventVptr->V_Tcl_DeleteEventSource)
#endif

#ifndef Tcl_DeleteFileHandler
#  define Tcl_DeleteFileHandler (*TkeventVptr->V_Tcl_DeleteFileHandler)
#endif

#ifndef Tcl_DeleteTimerHandler
#  define Tcl_DeleteTimerHandler (*TkeventVptr->V_Tcl_DeleteTimerHandler)
#endif

#ifndef Tcl_DoOneEvent
#  define Tcl_DoOneEvent (*TkeventVptr->V_Tcl_DoOneEvent)
#endif

#ifndef Tcl_DoWhenIdle
#  define Tcl_DoWhenIdle (*TkeventVptr->V_Tcl_DoWhenIdle)
#endif

#ifndef Tcl_Exit
#  define Tcl_Exit (*TkeventVptr->V_Tcl_Exit)
#endif

#ifndef Tcl_Free
#  define Tcl_Free (*TkeventVptr->V_Tcl_Free)
#endif

#ifndef Tcl_GetServiceMode
#  define Tcl_GetServiceMode (*TkeventVptr->V_Tcl_GetServiceMode)
#endif

#ifndef Tcl_Panic
#  define Tcl_Panic (*TkeventVptr->V_Tcl_Panic)
#endif

#ifndef Tcl_QueueEvent
#  define Tcl_QueueEvent (*TkeventVptr->V_Tcl_QueueEvent)
#endif

#ifndef Tcl_QueueProcEvent
#  define Tcl_QueueProcEvent (*TkeventVptr->V_Tcl_QueueProcEvent)
#endif

#ifndef Tcl_Realloc
#  define Tcl_Realloc (*TkeventVptr->V_Tcl_Realloc)
#endif

#ifndef Tcl_ServiceAll
#  define Tcl_ServiceAll (*TkeventVptr->V_Tcl_ServiceAll)
#endif

#ifndef Tcl_ServiceEvent
#  define Tcl_ServiceEvent (*TkeventVptr->V_Tcl_ServiceEvent)
#endif

#ifndef Tcl_SetMaxBlockTime
#  define Tcl_SetMaxBlockTime (*TkeventVptr->V_Tcl_SetMaxBlockTime)
#endif

#ifndef Tcl_SetServiceMode
#  define Tcl_SetServiceMode (*TkeventVptr->V_Tcl_SetServiceMode)
#endif

#ifndef Tcl_Sleep
#  define Tcl_Sleep (*TkeventVptr->V_Tcl_Sleep)
#endif

#ifndef TclpGetTime
#  define TclpGetTime (*TkeventVptr->V_TclpGetTime)
#endif

#endif /* NO_VTABLES */
#endif /* _TKEVENT_VM */
