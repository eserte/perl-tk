#ifndef _LANG_VM
#define _LANG_VM
#include "Lang_f.h"
#ifndef NO_VTABLES
#define LangOptionCommand (*LangVptr->V_LangOptionCommand)
#ifndef LangAllocVec
#  define LangAllocVec (*LangVptr->V_LangAllocVec)
#endif

#ifndef LangBadFile
#  define LangBadFile (*LangVptr->V_LangBadFile)
#endif

#ifndef LangCallbackArg
#  define LangCallbackArg (*LangVptr->V_LangCallbackArg)
#endif

#ifndef LangCmpArg
#  define LangCmpArg (*LangVptr->V_LangCmpArg)
#endif

#ifndef LangCmpCallback
#  define LangCmpCallback (*LangVptr->V_LangCmpCallback)
#endif

#ifndef LangCmpOpt
#  define LangCmpOpt (*LangVptr->V_LangCmpOpt)
#endif

#ifndef LangCopyArg
#  define LangCopyArg (*LangVptr->V_LangCopyArg)
#endif

#ifndef LangCopyCallback
#  define LangCopyCallback (*LangVptr->V_LangCopyCallback)
#endif

#ifndef LangDoCallback
#  define LangDoCallback (*LangVptr->V_LangDoCallback)
#endif

#ifndef LangEval
#  define LangEval (*LangVptr->V_LangEval)
#endif

#ifndef LangEventHook
#  define LangEventHook (*LangVptr->V_LangEventHook)
#endif

#ifndef LangExit
#  define LangExit (*LangVptr->V_LangExit)
#endif

#ifndef LangFreeArg
#  define LangFreeArg (*LangVptr->V_LangFreeArg)
#endif

#ifndef LangFreeCallback
#  define LangFreeCallback (*LangVptr->V_LangFreeCallback)
#endif

#ifndef LangFreeVar
#  define LangFreeVar (*LangVptr->V_LangFreeVar)
#endif

#ifndef LangFreeVec
#  define LangFreeVec (*LangVptr->V_LangFreeVec)
#endif

#ifndef LangLibraryDir
#  define LangLibraryDir (*LangVptr->V_LangLibraryDir)
#endif

#ifndef LangMakeCallback
#  define LangMakeCallback (*LangVptr->V_LangMakeCallback)
#endif

#ifndef LangMergeString
#  define LangMergeString (*LangVptr->V_LangMergeString)
#endif

#ifndef LangMethodCall
#  define LangMethodCall (*LangVptr->V_LangMethodCall)
#endif

#ifndef LangNull
#  define LangNull (*LangVptr->V_LangNull)
#endif

#ifndef LangRestoreResult
#  define LangRestoreResult (*LangVptr->V_LangRestoreResult)
#endif

#ifndef LangSaveResult
#  define LangSaveResult (*LangVptr->V_LangSaveResult)
#endif

#ifndef LangSaveVar
#  define LangSaveVar (*LangVptr->V_LangSaveVar)
#endif

#ifndef LangSetArg
#  define LangSetArg (*LangVptr->V_LangSetArg)
#endif

#ifndef LangSetDefault
#  define LangSetDefault (*LangVptr->V_LangSetDefault)
#endif

#ifndef LangSetDouble
#  define LangSetDouble (*LangVptr->V_LangSetDouble)
#endif

#ifndef LangSetInt
#  define LangSetInt (*LangVptr->V_LangSetInt)
#endif

#ifndef LangSetString
#  define LangSetString (*LangVptr->V_LangSetString)
#endif

#ifndef LangString
#  define LangString (*LangVptr->V_LangString)
#endif

#ifndef LangStringArg
#  define LangStringArg (*LangVptr->V_LangStringArg)
#endif

#ifndef LangStringMatch
#  define LangStringMatch (*LangVptr->V_LangStringMatch)
#endif

#ifndef LangVarArg
#  define LangVarArg (*LangVptr->V_LangVarArg)
#endif

#ifndef Lang_BuildInImages
#  define Lang_BuildInImages (*LangVptr->V_Lang_BuildInImages)
#endif

#ifndef Lang_CreateObject
#  define Lang_CreateObject (*LangVptr->V_Lang_CreateObject)
#endif

#ifndef Lang_DeleteObject
#  define Lang_DeleteObject (*LangVptr->V_Lang_DeleteObject)
#endif

#ifndef Lang_FreeRegExp
#  define Lang_FreeRegExp (*LangVptr->V_Lang_FreeRegExp)
#endif

#ifndef Lang_GetErrorCode
#  define Lang_GetErrorCode (*LangVptr->V_Lang_GetErrorCode)
#endif

#ifndef Lang_GetErrorInfo
#  define Lang_GetErrorInfo (*LangVptr->V_Lang_GetErrorInfo)
#endif

#ifndef Lang_RegExpCompile
#  define Lang_RegExpCompile (*LangVptr->V_Lang_RegExpCompile)
#endif

#ifndef Lang_RegExpExec
#  define Lang_RegExpExec (*LangVptr->V_Lang_RegExpExec)
#endif

#ifndef Lang_SetBinaryResult
#  define Lang_SetBinaryResult (*LangVptr->V_Lang_SetBinaryResult)
#endif

#ifndef Lang_SetErrorCode
#  define Lang_SetErrorCode (*LangVptr->V_Lang_SetErrorCode)
#endif

#ifndef Lang_SplitList
#  define Lang_SplitList (*LangVptr->V_Lang_SplitList)
#endif

#ifndef Lang_SplitString
#  define Lang_SplitString (*LangVptr->V_Lang_SplitString)
#endif

#ifndef TclIdlePending
#  define TclIdlePending (*LangVptr->V_TclIdlePending)
#endif

#ifndef TclServiceIdle
#  define TclServiceIdle (*LangVptr->V_TclServiceIdle)
#endif

#ifndef Tcl_AddErrorInfo
#  define Tcl_AddErrorInfo (*LangVptr->V_Tcl_AddErrorInfo)
#endif

#ifndef Tcl_AfterCmd
#  define Tcl_AfterCmd (*LangVptr->V_Tcl_AfterCmd)
#endif

#ifndef Tcl_AppendArg
#  define Tcl_AppendArg (*LangVptr->V_Tcl_AppendArg)
#endif

#ifndef Tcl_AppendElement
#  define Tcl_AppendElement (*LangVptr->V_Tcl_AppendElement)
#endif

#ifndef Tcl_AppendResult
#  define Tcl_AppendResult (*LangVptr->V_Tcl_AppendResult)
#endif

#ifndef Tcl_ArgResult
#  define Tcl_ArgResult (*LangVptr->V_Tcl_ArgResult)
#endif

#ifndef Tcl_AsyncCreate
#  define Tcl_AsyncCreate (*LangVptr->V_Tcl_AsyncCreate)
#endif

#ifndef Tcl_AsyncDelete
#  define Tcl_AsyncDelete (*LangVptr->V_Tcl_AsyncDelete)
#endif

#ifndef Tcl_AsyncInvoke
#  define Tcl_AsyncInvoke (*LangVptr->V_Tcl_AsyncInvoke)
#endif

#ifndef Tcl_AsyncMark
#  define Tcl_AsyncMark (*LangVptr->V_Tcl_AsyncMark)
#endif

#ifndef Tcl_AsyncReady
#  define Tcl_AsyncReady (*LangVptr->V_Tcl_AsyncReady)
#endif

#ifndef Tcl_BackgroundError
#  define Tcl_BackgroundError (*LangVptr->V_Tcl_BackgroundError)
#endif

#ifndef Tcl_CallWhenDeleted
#  define Tcl_CallWhenDeleted (*LangVptr->V_Tcl_CallWhenDeleted)
#endif

#ifndef Tcl_CancelIdleCall
#  define Tcl_CancelIdleCall (*LangVptr->V_Tcl_CancelIdleCall)
#endif

#ifndef Tcl_Close
#  define Tcl_Close (*LangVptr->V_Tcl_Close)
#endif

#ifndef Tcl_Concat
#  define Tcl_Concat (*LangVptr->V_Tcl_Concat)
#endif

#ifndef Tcl_CreateCommand
#  define Tcl_CreateCommand (*LangVptr->V_Tcl_CreateCommand)
#endif

#ifndef Tcl_CreateEventSource
#  define Tcl_CreateEventSource (*LangVptr->V_Tcl_CreateEventSource)
#endif

#ifndef Tcl_CreateExitHandler
#  define Tcl_CreateExitHandler (*LangVptr->V_Tcl_CreateExitHandler)
#endif

#ifndef Tcl_CreateFileHandler
#  define Tcl_CreateFileHandler (*LangVptr->V_Tcl_CreateFileHandler)
#endif

#ifndef Tcl_CreateInterp
#  define Tcl_CreateInterp (*LangVptr->V_Tcl_CreateInterp)
#endif

#ifndef Tcl_CreateModalTimeout
#  define Tcl_CreateModalTimeout (*LangVptr->V_Tcl_CreateModalTimeout)
#endif

#ifndef Tcl_CreateTimerHandler
#  define Tcl_CreateTimerHandler (*LangVptr->V_Tcl_CreateTimerHandler)
#endif

#ifndef Tcl_DStringAppend
#  define Tcl_DStringAppend (*LangVptr->V_Tcl_DStringAppend)
#endif

#ifndef Tcl_DStringFree
#  define Tcl_DStringFree (*LangVptr->V_Tcl_DStringFree)
#endif

#ifndef Tcl_DStringInit
#  define Tcl_DStringInit (*LangVptr->V_Tcl_DStringInit)
#endif

#ifndef Tcl_DStringResult
#  define Tcl_DStringResult (*LangVptr->V_Tcl_DStringResult)
#endif

#ifndef Tcl_DStringSetLength
#  define Tcl_DStringSetLength (*LangVptr->V_Tcl_DStringSetLength)
#endif

#ifndef Tcl_DeleteEventSource
#  define Tcl_DeleteEventSource (*LangVptr->V_Tcl_DeleteEventSource)
#endif

#ifndef Tcl_DeleteEvents
#  define Tcl_DeleteEvents (*LangVptr->V_Tcl_DeleteEvents)
#endif

#ifndef Tcl_DeleteExitHandler
#  define Tcl_DeleteExitHandler (*LangVptr->V_Tcl_DeleteExitHandler)
#endif

#ifndef Tcl_DeleteFileHandler
#  define Tcl_DeleteFileHandler (*LangVptr->V_Tcl_DeleteFileHandler)
#endif

#ifndef Tcl_DeleteHashEntry
#  define Tcl_DeleteHashEntry (*LangVptr->V_Tcl_DeleteHashEntry)
#endif

#ifndef Tcl_DeleteHashTable
#  define Tcl_DeleteHashTable (*LangVptr->V_Tcl_DeleteHashTable)
#endif

#ifndef Tcl_DeleteInterp
#  define Tcl_DeleteInterp (*LangVptr->V_Tcl_DeleteInterp)
#endif

#ifndef Tcl_DeleteModalTimeout
#  define Tcl_DeleteModalTimeout (*LangVptr->V_Tcl_DeleteModalTimeout)
#endif

#ifndef Tcl_DeleteTimerHandler
#  define Tcl_DeleteTimerHandler (*LangVptr->V_Tcl_DeleteTimerHandler)
#endif

#ifndef Tcl_DoOneEvent
#  define Tcl_DoOneEvent (*LangVptr->V_Tcl_DoOneEvent)
#endif

#ifndef Tcl_DoWhenIdle
#  define Tcl_DoWhenIdle (*LangVptr->V_Tcl_DoWhenIdle)
#endif

#ifndef Tcl_DoubleResults
#  define Tcl_DoubleResults (*LangVptr->V_Tcl_DoubleResults)
#endif

#ifndef Tcl_EventuallyFree
#  define Tcl_EventuallyFree (*LangVptr->V_Tcl_EventuallyFree)
#endif

#ifndef Tcl_Exit
#  define Tcl_Exit (*LangVptr->V_Tcl_Exit)
#endif

#ifndef Tcl_FileReady
#  define Tcl_FileReady (*LangVptr->V_Tcl_FileReady)
#endif

#ifndef Tcl_FirstHashEntry
#  define Tcl_FirstHashEntry (*LangVptr->V_Tcl_FirstHashEntry)
#endif

#ifndef Tcl_FreeFile
#  define Tcl_FreeFile (*LangVptr->V_Tcl_FreeFile)
#endif

#ifndef Tcl_GetAssocData
#  define Tcl_GetAssocData (*LangVptr->V_Tcl_GetAssocData)
#endif

#ifndef Tcl_GetBoolean
#  define Tcl_GetBoolean (*LangVptr->V_Tcl_GetBoolean)
#endif

#ifndef Tcl_GetDouble
#  define Tcl_GetDouble (*LangVptr->V_Tcl_GetDouble)
#endif

#ifndef Tcl_GetFile
#  define Tcl_GetFile (*LangVptr->V_Tcl_GetFile)
#endif

#ifndef Tcl_GetFileInfo
#  define Tcl_GetFileInfo (*LangVptr->V_Tcl_GetFileInfo)
#endif

#ifndef Tcl_GetInt
#  define Tcl_GetInt (*LangVptr->V_Tcl_GetInt)
#endif

#ifndef Tcl_GetNotifierData
#  define Tcl_GetNotifierData (*LangVptr->V_Tcl_GetNotifierData)
#endif

#ifndef Tcl_GetOpenFile
#  define Tcl_GetOpenFile (*LangVptr->V_Tcl_GetOpenFile)
#endif

#ifndef Tcl_GetResult
#  define Tcl_GetResult (*LangVptr->V_Tcl_GetResult)
#endif

#ifndef Tcl_GetVar
#  define Tcl_GetVar (*LangVptr->V_Tcl_GetVar)
#endif

#ifndef Tcl_GetVar2
#  define Tcl_GetVar2 (*LangVptr->V_Tcl_GetVar2)
#endif

#ifndef Tcl_HashStats
#  define Tcl_HashStats (*LangVptr->V_Tcl_HashStats)
#endif

#ifndef Tcl_InitHashTable
#  define Tcl_InitHashTable (*LangVptr->V_Tcl_InitHashTable)
#endif

#ifndef Tcl_IntResults
#  define Tcl_IntResults (*LangVptr->V_Tcl_IntResults)
#endif

#ifndef Tcl_JoinPath
#  define Tcl_JoinPath (*LangVptr->V_Tcl_JoinPath)
#endif

#ifndef Tcl_LinkVar
#  define Tcl_LinkVar (*LangVptr->V_Tcl_LinkVar)
#endif

#ifndef Tcl_Merge
#  define Tcl_Merge (*LangVptr->V_Tcl_Merge)
#endif

#ifndef Tcl_NextHashEntry
#  define Tcl_NextHashEntry (*LangVptr->V_Tcl_NextHashEntry)
#endif

#ifndef Tcl_OpenFileChannel
#  define Tcl_OpenFileChannel (*LangVptr->V_Tcl_OpenFileChannel)
#endif

#ifndef Tcl_Panic
#  define Tcl_Panic (*LangVptr->V_Tcl_Panic)
#endif

#ifndef Tcl_PosixError
#  define Tcl_PosixError (*LangVptr->V_Tcl_PosixError)
#endif

#ifndef Tcl_Preserve
#  define Tcl_Preserve (*LangVptr->V_Tcl_Preserve)
#endif

#ifndef Tcl_QueueEvent
#  define Tcl_QueueEvent (*LangVptr->V_Tcl_QueueEvent)
#endif

#ifndef Tcl_Read
#  define Tcl_Read (*LangVptr->V_Tcl_Read)
#endif

#ifndef Tcl_RegExpRange
#  define Tcl_RegExpRange (*LangVptr->V_Tcl_RegExpRange)
#endif

#ifndef Tcl_Release
#  define Tcl_Release (*LangVptr->V_Tcl_Release)
#endif

#ifndef Tcl_ResetResult
#  define Tcl_ResetResult (*LangVptr->V_Tcl_ResetResult)
#endif

#ifndef Tcl_ResultArg
#  define Tcl_ResultArg (*LangVptr->V_Tcl_ResultArg)
#endif

#ifndef Tcl_Seek
#  define Tcl_Seek (*LangVptr->V_Tcl_Seek)
#endif

#ifndef Tcl_SetAssocData
#  define Tcl_SetAssocData (*LangVptr->V_Tcl_SetAssocData)
#endif

#ifndef Tcl_SetCommandInfo
#  define Tcl_SetCommandInfo (*LangVptr->V_Tcl_SetCommandInfo)
#endif

#ifndef Tcl_SetMaxBlockTime
#  define Tcl_SetMaxBlockTime (*LangVptr->V_Tcl_SetMaxBlockTime)
#endif

#ifndef Tcl_SetNotifierData
#  define Tcl_SetNotifierData (*LangVptr->V_Tcl_SetNotifierData)
#endif

#ifndef Tcl_SetResult
#  define Tcl_SetResult (*LangVptr->V_Tcl_SetResult)
#endif

#ifndef Tcl_SetVar
#  define Tcl_SetVar (*LangVptr->V_Tcl_SetVar)
#endif

#ifndef Tcl_SetVar2
#  define Tcl_SetVar2 (*LangVptr->V_Tcl_SetVar2)
#endif

#ifndef Tcl_SetVarArg
#  define Tcl_SetVarArg (*LangVptr->V_Tcl_SetVarArg)
#endif

#ifndef Tcl_Sleep
#  define Tcl_Sleep (*LangVptr->V_Tcl_Sleep)
#endif

#ifndef Tcl_SprintfResult
#  define Tcl_SprintfResult (*LangVptr->V_Tcl_SprintfResult)
#endif

#ifndef Tcl_TraceVar
#  define Tcl_TraceVar (*LangVptr->V_Tcl_TraceVar)
#endif

#ifndef Tcl_TraceVar2
#  define Tcl_TraceVar2 (*LangVptr->V_Tcl_TraceVar2)
#endif

#ifndef Tcl_TranslateFileName
#  define Tcl_TranslateFileName (*LangVptr->V_Tcl_TranslateFileName)
#endif

#ifndef Tcl_UnlinkVar
#  define Tcl_UnlinkVar (*LangVptr->V_Tcl_UnlinkVar)
#endif

#ifndef Tcl_UntraceVar
#  define Tcl_UntraceVar (*LangVptr->V_Tcl_UntraceVar)
#endif

#ifndef Tcl_UntraceVar2
#  define Tcl_UntraceVar2 (*LangVptr->V_Tcl_UntraceVar2)
#endif

#ifndef Tcl_WaitForEvent
#  define Tcl_WaitForEvent (*LangVptr->V_Tcl_WaitForEvent)
#endif

#ifndef Tcl_WatchFile
#  define Tcl_WatchFile (*LangVptr->V_Tcl_WatchFile)
#endif

#ifndef Tcl_Write
#  define Tcl_Write (*LangVptr->V_Tcl_Write)
#endif

#ifndef TclpGetTime
#  define TclpGetTime (*LangVptr->V_TclpGetTime)
#endif

#endif /* NO_VTABLES */
#endif /* _LANG_VM */
