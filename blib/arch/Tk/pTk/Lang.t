#ifdef _LANG
VVAR(Tcl_CmdProc *,LangOptionCommand,V_LangOptionCommand)
#ifndef LangAllocVec
VFUNC(Arg *,LangAllocVec,V_LangAllocVec,_ANSI_ARGS_((int count)))
#endif

#ifndef LangBadFile
VFUNC(void,LangBadFile,V_LangBadFile,_ANSI_ARGS_((int fd)))
#endif

#ifndef LangCallbackArg
VFUNC(Arg,LangCallbackArg,V_LangCallbackArg,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangCmpArg
VFUNC(int,LangCmpArg,V_LangCmpArg,_ANSI_ARGS_((Arg,Arg)))
#endif

#ifndef LangCmpCallback
VFUNC(int,LangCmpCallback,V_LangCmpCallback,_ANSI_ARGS_((LangCallback *a,Arg b)))
#endif

#ifndef LangCmpOpt
VFUNC(int,LangCmpOpt,V_LangCmpOpt,_ANSI_ARGS_((char *opt,char *arg,size_t length)))
#endif

#ifndef LangCopyArg
VFUNC(Arg,LangCopyArg,V_LangCopyArg,_ANSI_ARGS_((Arg)))
#endif

#ifndef LangCopyCallback
VFUNC(LangCallback *,LangCopyCallback,V_LangCopyCallback,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangDoCallback
VFUNC(int,LangDoCallback,V_LangDoCallback,_ANSI_ARGS_((Tcl_Interp *,LangCallback *,int result,int argc,...)))
#endif

#ifndef LangEval
VFUNC(int,LangEval,V_LangEval,_ANSI_ARGS_((Tcl_Interp *interp, char *cmd, int global)))
#endif

#ifndef LangEventHook
VFUNC(int,LangEventHook,V_LangEventHook,_ANSI_ARGS_((int flags)))
#endif

#ifndef LangExit
VFUNC(void,LangExit,V_LangExit,_ANSI_ARGS_((int)))
#endif

#ifndef LangFreeArg
VFUNC(void,LangFreeArg,V_LangFreeArg,_ANSI_ARGS_((Arg,Tcl_FreeProc *freeProc)))
#endif

#ifndef LangFreeCallback
VFUNC(void,LangFreeCallback,V_LangFreeCallback,_ANSI_ARGS_((LangCallback *)))
#endif

#ifndef LangFreeVar
VFUNC(void,LangFreeVar,V_LangFreeVar,_ANSI_ARGS_((Var)))
#endif

#ifndef LangFreeVec
VFUNC(void,LangFreeVec,V_LangFreeVec,_ANSI_ARGS_((int,Arg *)))
#endif

#ifndef LangLibraryDir
VFUNC(char *,LangLibraryDir,V_LangLibraryDir,_ANSI_ARGS_((void)))
#endif

#ifndef LangMakeCallback
VFUNC(LangCallback *,LangMakeCallback,V_LangMakeCallback,_ANSI_ARGS_((Arg)))
#endif

#ifndef LangMergeString
VFUNC(char *,LangMergeString,V_LangMergeString,_ANSI_ARGS_((int argc, Arg *args)))
#endif

#ifndef LangMethodCall
VFUNC(int,LangMethodCall,V_LangMethodCall,_ANSI_ARGS_((Tcl_Interp *,Arg,char *,int result,int argc,...)))
#endif

#ifndef LangNull
VFUNC(int,LangNull,V_LangNull,_ANSI_ARGS_((Arg)))
#endif

#ifndef LangRestoreResult
VFUNC(void,LangRestoreResult,V_LangRestoreResult,_ANSI_ARGS_((Tcl_Interp **,LangResultSave *)))
#endif

#ifndef LangSaveResult
VFUNC(LangResultSave *,LangSaveResult,V_LangSaveResult,_ANSI_ARGS_((Tcl_Interp **)))
#endif

#ifndef LangSaveVar
VFUNC(int,LangSaveVar,V_LangSaveVar,_ANSI_ARGS_((Tcl_Interp *,Arg,Var *,int type)))
#endif

#ifndef LangSetArg
VFUNC(void,LangSetArg,V_LangSetArg,_ANSI_ARGS_((Arg *,Arg)))
#endif

#ifndef LangSetDefault
VFUNC(void,LangSetDefault,V_LangSetDefault,_ANSI_ARGS_((Arg *,char *)))
#endif

#ifndef LangSetDouble
VFUNC(void,LangSetDouble,V_LangSetDouble,_ANSI_ARGS_((Arg *,double)))
#endif

#ifndef LangSetInt
VFUNC(void,LangSetInt,V_LangSetInt,_ANSI_ARGS_((Arg *,int)))
#endif

#ifndef LangSetString
VFUNC(void,LangSetString,V_LangSetString,_ANSI_ARGS_((Arg *,char *)))
#endif

#ifndef LangString
VFUNC(char *,LangString,V_LangString,_ANSI_ARGS_((Arg)))
#endif

#ifndef LangStringArg
VFUNC(Arg,LangStringArg,V_LangStringArg,_ANSI_ARGS_((char *)))
#endif

#ifndef LangStringMatch
VFUNC(int,LangStringMatch,V_LangStringMatch,_ANSI_ARGS_((char *string, Arg match)))
#endif

#ifndef LangVarArg
VFUNC(Arg,LangVarArg,V_LangVarArg,_ANSI_ARGS_((Var)))
#endif

#ifndef Lang_BuildInImages
VFUNC(void,Lang_BuildInImages,V_Lang_BuildInImages,_ANSI_ARGS_((void)))
#endif

#ifndef Lang_CreateObject
VFUNC(Tcl_Command,Lang_CreateObject,V_Lang_CreateObject,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
#endif

#ifndef Lang_DeleteObject
VFUNC(void,Lang_DeleteObject,V_Lang_DeleteObject,_ANSI_ARGS_((Tcl_Interp *,Tcl_Command)))
#endif

#ifndef Lang_FreeRegExp
VFUNC(void,Lang_FreeRegExp,V_Lang_FreeRegExp,_ANSI_ARGS_((Tcl_RegExp regexp)))
#endif

#ifndef Lang_GetErrorCode
VFUNC(char *,Lang_GetErrorCode,V_Lang_GetErrorCode,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Lang_GetErrorInfo
VFUNC(char *,Lang_GetErrorInfo,V_Lang_GetErrorInfo,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Lang_RegExpCompile
VFUNC(Tcl_RegExp,Lang_RegExpCompile,V_Lang_RegExpCompile,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int fold)))
#endif

#ifndef Lang_RegExpExec
VFUNC(int,Lang_RegExpExec,V_Lang_RegExpExec,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_RegExp regexp, char *string, char *start)))
#endif

#ifndef Lang_SetBinaryResult
VFUNC(void,Lang_SetBinaryResult,V_Lang_SetBinaryResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int len, Tcl_FreeProc *freeProc)))
#endif

#ifndef Lang_SetErrorCode
VFUNC(void,Lang_SetErrorCode,V_Lang_SetErrorCode,_ANSI_ARGS_((Tcl_Interp *interp,char *code)))
#endif

#ifndef Lang_SplitList
VFUNC(int,Lang_SplitList,V_Lang_SplitList,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg list, int *argcPtr, Arg **argsPtr, 
			    LangFreeProc **)))
#endif

#ifndef Lang_SplitString
VFUNC(int,Lang_SplitString,V_Lang_SplitString,_ANSI_ARGS_((Tcl_Interp *interp,
			    const char *list, int *argcPtr, Arg **argsPtr, 
			    LangFreeProc **)))
#endif

#ifndef TclIdlePending
VFUNC(int,TclIdlePending,V_TclIdlePending,_ANSI_ARGS_((void)))
#endif

#ifndef TclServiceIdle
VFUNC(int,TclServiceIdle,V_TclServiceIdle,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_AddErrorInfo
VFUNC(void,Tcl_AddErrorInfo,V_Tcl_AddErrorInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *message)))
#endif

#ifndef Tcl_AfterCmd
VFUNC(int,Tcl_AfterCmd,V_Tcl_AfterCmd,_ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args)))
#endif

#ifndef Tcl_AppendArg
VFUNC(void,Tcl_AppendArg,V_Tcl_AppendArg,_ANSI_ARGS_((Tcl_Interp *interp, Arg)))
#endif

#ifndef Tcl_AppendElement
VFUNC(void,Tcl_AppendElement,V_Tcl_AppendElement,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string)))
#endif

#ifndef Tcl_AppendResult
VFUNC(void,Tcl_AppendResult,V_Tcl_AppendResult,_ANSI_ARGS_(TCL_VARARGS(Tcl_Interp *,interp)))
#endif

#ifndef Tcl_ArgResult
VFUNC(void,Tcl_ArgResult,V_Tcl_ArgResult,_ANSI_ARGS_((Tcl_Interp *interp, Arg)))
#endif

#ifndef Tcl_AsyncCreate
VFUNC(Tcl_AsyncHandler,Tcl_AsyncCreate,V_Tcl_AsyncCreate,_ANSI_ARGS_((Tcl_AsyncProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_AsyncDelete
VFUNC(void,Tcl_AsyncDelete,V_Tcl_AsyncDelete,_ANSI_ARGS_((Tcl_AsyncHandler async)))
#endif

#ifndef Tcl_AsyncInvoke
VFUNC(int,Tcl_AsyncInvoke,V_Tcl_AsyncInvoke,_ANSI_ARGS_((Tcl_Interp *interp,
			    int code)))
#endif

#ifndef Tcl_AsyncMark
VFUNC(void,Tcl_AsyncMark,V_Tcl_AsyncMark,_ANSI_ARGS_((Tcl_AsyncHandler async)))
#endif

#ifndef Tcl_AsyncReady
VFUNC(int,Tcl_AsyncReady,V_Tcl_AsyncReady,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_BackgroundError
VFUNC(void,Tcl_BackgroundError,V_Tcl_BackgroundError,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_CallWhenDeleted
VFUNC(void,Tcl_CallWhenDeleted,V_Tcl_CallWhenDeleted,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_InterpDeleteProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CancelIdleCall
VFUNC(void,Tcl_CancelIdleCall,V_Tcl_CancelIdleCall,_ANSI_ARGS_((Tcl_IdleProc *idleProc,
			    ClientData clientData)))
#endif

#ifndef Tcl_Close
VFUNC(int,Tcl_Close,V_Tcl_Close,_ANSI_ARGS_((Tcl_Interp *interp,
        		    Tcl_Channel chan)))
#endif

#ifndef Tcl_Concat
VFUNC(Arg,Tcl_Concat,V_Tcl_Concat,_ANSI_ARGS_((int argc, Arg *argv)))
#endif

#ifndef Tcl_CreateCommand
VFUNC(Tcl_Command,Tcl_CreateCommand,V_Tcl_CreateCommand,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
#endif

#ifndef Tcl_CreateEventSource
VFUNC(void,Tcl_CreateEventSource,V_Tcl_CreateEventSource,_ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc, Tcl_EventCheckProc
			    *checkProc, ClientData clientData)))
#endif

#ifndef Tcl_CreateExitHandler
VFUNC(void,Tcl_CreateExitHandler,V_Tcl_CreateExitHandler,_ANSI_ARGS_((Tcl_ExitProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateFileHandler
VFUNC(void,Tcl_CreateFileHandler,V_Tcl_CreateFileHandler,_ANSI_ARGS_((
    			    Tcl_File file, int mask, Tcl_FileProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_CreateInterp
VFUNC(Tcl_Interp *,Tcl_CreateInterp,V_Tcl_CreateInterp,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_CreateModalTimeout
VFUNC(void,Tcl_CreateModalTimeout,V_Tcl_CreateModalTimeout,_ANSI_ARGS_((int milliseconds,
			    Tcl_TimerProc *proc, ClientData clientData)))
#endif

#ifndef Tcl_CreateTimerHandler
VFUNC(Tcl_TimerToken,Tcl_CreateTimerHandler,V_Tcl_CreateTimerHandler,_ANSI_ARGS_((int milliseconds,
			    Tcl_TimerProc *proc, ClientData clientData)))
#endif

#ifndef Tcl_DStringAppend
VFUNC(char *,Tcl_DStringAppend,V_Tcl_DStringAppend,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    char *string, int length)))
#endif

#ifndef Tcl_DStringFree
VFUNC(void,Tcl_DStringFree,V_Tcl_DStringFree,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringInit
VFUNC(void,Tcl_DStringInit,V_Tcl_DStringInit,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringResult
VFUNC(void,Tcl_DStringResult,V_Tcl_DStringResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringSetLength
VFUNC(void,Tcl_DStringSetLength,V_Tcl_DStringSetLength,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    int length)))
#endif

#ifndef Tcl_DeleteEventSource
VFUNC(void,Tcl_DeleteEventSource,V_Tcl_DeleteEventSource,_ANSI_ARGS_((
			    Tcl_EventSetupProc *setupProc,
			    Tcl_EventCheckProc *checkProc,
			    ClientData clientData)))
#endif

#ifndef Tcl_DeleteEvents
VFUNC(void,Tcl_DeleteEvents,V_Tcl_DeleteEvents,_ANSI_ARGS_((
			    Tcl_EventDeleteProc *proc,
                            ClientData clientData)))
#endif

#ifndef Tcl_DeleteExitHandler
VFUNC(void,Tcl_DeleteExitHandler,V_Tcl_DeleteExitHandler,_ANSI_ARGS_((Tcl_ExitProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_DeleteFileHandler
VFUNC(void,Tcl_DeleteFileHandler,V_Tcl_DeleteFileHandler,_ANSI_ARGS_((
    			    Tcl_File file)))
#endif

#ifndef Tcl_DeleteHashEntry
VFUNC(void,Tcl_DeleteHashEntry,V_Tcl_DeleteHashEntry,_ANSI_ARGS_((
			    Tcl_HashEntry *entryPtr)))
#endif

#ifndef Tcl_DeleteHashTable
VFUNC(void,Tcl_DeleteHashTable,V_Tcl_DeleteHashTable,_ANSI_ARGS_((
			    Tcl_HashTable *tablePtr)))
#endif

#ifndef Tcl_DeleteInterp
VFUNC(void,Tcl_DeleteInterp,V_Tcl_DeleteInterp,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_DeleteModalTimeout
VFUNC(void,Tcl_DeleteModalTimeout,V_Tcl_DeleteModalTimeout,_ANSI_ARGS_((
			    Tcl_TimerProc *proc, ClientData clientData)))
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

#ifndef Tcl_DoubleResults
VFUNC(void,Tcl_DoubleResults,V_Tcl_DoubleResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
#endif

#ifndef Tcl_EventuallyFree
VFUNC(void,Tcl_EventuallyFree,V_Tcl_EventuallyFree,_ANSI_ARGS_((ClientData clientData,
			    Tcl_FreeProc *freeProc)))
#endif

#ifndef Tcl_Exit
VFUNC(void,Tcl_Exit,V_Tcl_Exit,_ANSI_ARGS_((int status)))
#endif

#ifndef Tcl_FileReady
VFUNC(int,Tcl_FileReady,V_Tcl_FileReady,_ANSI_ARGS_((Tcl_File file,
			    int mask)))
#endif

#ifndef Tcl_FirstHashEntry
VFUNC(Tcl_HashEntry *,Tcl_FirstHashEntry,V_Tcl_FirstHashEntry,_ANSI_ARGS_((
			    Tcl_HashTable *tablePtr,
			    Tcl_HashSearch *searchPtr)))
#endif

#ifndef Tcl_FreeFile
VFUNC(void,Tcl_FreeFile,V_Tcl_FreeFile,_ANSI_ARGS_((
    			    Tcl_File file)))
#endif

#ifndef Tcl_GetAssocData
VFUNC(ClientData,Tcl_GetAssocData,V_Tcl_GetAssocData,_ANSI_ARGS_((Tcl_Interp *interp,
                            char *name, Tcl_InterpDeleteProc **procPtr)))
#endif

#ifndef Tcl_GetBoolean
VFUNC(int,Tcl_GetBoolean,V_Tcl_GetBoolean,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *boolPtr)))
#endif

#ifndef Tcl_GetDouble
VFUNC(int,Tcl_GetDouble,V_Tcl_GetDouble,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, double *doublePtr)))
#endif

#ifndef Tcl_GetFile
VFUNC(Tcl_File,Tcl_GetFile,V_Tcl_GetFile,_ANSI_ARGS_((ClientData fileData,
			    int type)))
#endif

#ifndef Tcl_GetFileInfo
VFUNC(ClientData,Tcl_GetFileInfo,V_Tcl_GetFileInfo,_ANSI_ARGS_((Tcl_File file,
			    int *typePtr)))
#endif

#ifndef Tcl_GetInt
VFUNC(int,Tcl_GetInt,V_Tcl_GetInt,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *intPtr)))
#endif

#ifndef Tcl_GetNotifierData
VFUNC(ClientData,Tcl_GetNotifierData,V_Tcl_GetNotifierData,_ANSI_ARGS_((Tcl_File file,
			    Tcl_FileFreeProc **freeProcPtr)))
#endif

#ifndef Tcl_GetOpenFile
VFUNC(int,Tcl_GetOpenFile,V_Tcl_GetOpenFile,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int write, int checkUsage,
			    ClientData *filePtr)))
#endif

#ifndef Tcl_GetResult
VFUNC(char *,Tcl_GetResult,V_Tcl_GetResult,_ANSI_ARGS_((Tcl_Interp *)))
#endif

#ifndef Tcl_GetVar
VFUNC(Arg,Tcl_GetVar,V_Tcl_GetVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags)))
#endif

#ifndef Tcl_GetVar2
VFUNC(Arg,Tcl_GetVar2,V_Tcl_GetVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags)))
#endif

#ifndef Tcl_HashStats
VFUNC(char *,Tcl_HashStats,V_Tcl_HashStats,_ANSI_ARGS_((Tcl_HashTable *tablePtr)))
#endif

#ifndef Tcl_InitHashTable
VFUNC(void,Tcl_InitHashTable,V_Tcl_InitHashTable,_ANSI_ARGS_((Tcl_HashTable *tablePtr,
			    int keyType)))
#endif

#ifndef Tcl_IntResults
VFUNC(void,Tcl_IntResults,V_Tcl_IntResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
#endif

#ifndef Tcl_JoinPath
VFUNC(char *,Tcl_JoinPath,V_Tcl_JoinPath,_ANSI_ARGS_((int argc, char **argv,
			    Tcl_DString *resultPtr)))
#endif

#ifndef Tcl_LinkVar
VFUNC(int,Tcl_LinkVar,V_Tcl_LinkVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName, char *addr, int type)))
#endif

#ifndef Tcl_Merge
VFUNC(Arg,Tcl_Merge,V_Tcl_Merge,_ANSI_ARGS_((int argc, Arg *argv)))
#endif

#ifndef Tcl_NextHashEntry
VFUNC(Tcl_HashEntry *,Tcl_NextHashEntry,V_Tcl_NextHashEntry,_ANSI_ARGS_((
			    Tcl_HashSearch *searchPtr)))
#endif

#ifndef Tcl_OpenFileChannel
VFUNC(Tcl_Channel,Tcl_OpenFileChannel,V_Tcl_OpenFileChannel,_ANSI_ARGS_((Tcl_Interp *interp,
        		    char *fileName, char *modeString,
                            int permissions)))
#endif

#ifndef Tcl_Panic
VFUNC(void,Tcl_Panic,V_Tcl_Panic,_ANSI_ARGS_((char *,...)))
#endif

#ifndef Tcl_PosixError
VFUNC(char *,Tcl_PosixError,V_Tcl_PosixError,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_Preserve
VFUNC(void,Tcl_Preserve,V_Tcl_Preserve,_ANSI_ARGS_((ClientData data)))
#endif

#ifndef Tcl_QueueEvent
VFUNC(void,Tcl_QueueEvent,V_Tcl_QueueEvent,_ANSI_ARGS_((Tcl_Event *evPtr,
			    Tcl_QueuePosition position)))
#endif

#ifndef Tcl_Read
VFUNC(int,Tcl_Read,V_Tcl_Read,_ANSI_ARGS_((Tcl_Channel chan,
	        	    char *bufPtr, int toRead)))
#endif

#ifndef Tcl_RegExpRange
VFUNC(void,Tcl_RegExpRange,V_Tcl_RegExpRange,_ANSI_ARGS_((Tcl_RegExp regexp,
			    int index, char **startPtr, char **endPtr)))
#endif

#ifndef Tcl_Release
VFUNC(void,Tcl_Release,V_Tcl_Release,_ANSI_ARGS_((ClientData clientData)))
#endif

#ifndef Tcl_ResetResult
VFUNC(void,Tcl_ResetResult,V_Tcl_ResetResult,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_ResultArg
VFUNC(Arg,Tcl_ResultArg,V_Tcl_ResultArg,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_Seek
VFUNC(int,Tcl_Seek,V_Tcl_Seek,_ANSI_ARGS_((Tcl_Channel chan,
        		    int offset, int mode)))
#endif

#ifndef Tcl_SetAssocData
VFUNC(void,Tcl_SetAssocData,V_Tcl_SetAssocData,_ANSI_ARGS_((Tcl_Interp *interp,
                            char *name, Tcl_InterpDeleteProc *proc,
                            ClientData clientData)))
#endif

#ifndef Tcl_SetCommandInfo
VFUNC(int,Tcl_SetCommandInfo,V_Tcl_SetCommandInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdInfo *infoPtr)))
#endif

#ifndef Tcl_SetMaxBlockTime
VFUNC(void,Tcl_SetMaxBlockTime,V_Tcl_SetMaxBlockTime,_ANSI_ARGS_((Tcl_Time *timePtr)))
#endif

#ifndef Tcl_SetNotifierData
VFUNC(void,Tcl_SetNotifierData,V_Tcl_SetNotifierData,_ANSI_ARGS_((Tcl_File file,
			    Tcl_FileFreeProc *freeProcPtr, ClientData data)))
#endif

#ifndef Tcl_SetResult
VFUNC(void,Tcl_SetResult,V_Tcl_SetResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tcl_FreeProc *freeProc)))
#endif

#ifndef Tcl_SetVar
VFUNC(char *,Tcl_SetVar,V_Tcl_SetVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, char *newValue, int flags)))
#endif

#ifndef Tcl_SetVar2
VFUNC(char *,Tcl_SetVar2,V_Tcl_SetVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, char *newValue,
			    int flags)))
#endif

#ifndef Tcl_SetVarArg
VFUNC(char *,Tcl_SetVarArg,V_Tcl_SetVarArg,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, Arg newValue, int flags)))
#endif

#ifndef Tcl_Sleep
VFUNC(void,Tcl_Sleep,V_Tcl_Sleep,_ANSI_ARGS_((int ms)))
#endif

#ifndef Tcl_SprintfResult
VFUNC(void,Tcl_SprintfResult,V_Tcl_SprintfResult,_ANSI_ARGS_((Tcl_Interp *,char *,...)))
#endif

#ifndef Tcl_TraceVar
VFUNC(int,Tcl_TraceVar,V_Tcl_TraceVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_TraceVar2
VFUNC(int,Tcl_TraceVar2,V_Tcl_TraceVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData)))
#endif

#ifndef Tcl_TranslateFileName
VFUNC(char *,Tcl_TranslateFileName,V_Tcl_TranslateFileName,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, Tcl_DString *bufferPtr)))
#endif

#ifndef Tcl_UnlinkVar
VFUNC(void,Tcl_UnlinkVar,V_Tcl_UnlinkVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName)))
#endif

#ifndef Tcl_UntraceVar
VFUNC(void,Tcl_UntraceVar,V_Tcl_UntraceVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_UntraceVar2
VFUNC(void,Tcl_UntraceVar2,V_Tcl_UntraceVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData)))
#endif

#ifndef Tcl_WaitForEvent
VFUNC(int,Tcl_WaitForEvent,V_Tcl_WaitForEvent,_ANSI_ARGS_((Tcl_Time *timePtr)))
#endif

#ifndef Tcl_WatchFile
VFUNC(void,Tcl_WatchFile,V_Tcl_WatchFile,_ANSI_ARGS_((Tcl_File file,
			    int mask)))
#endif

#ifndef Tcl_Write
VFUNC(int,Tcl_Write,V_Tcl_Write,_ANSI_ARGS_((Tcl_Channel chan,
        		    char *s, int slen)))
#endif

#ifndef TclpGetTime
VFUNC(void,TclpGetTime,V_TclpGetTime,_ANSI_ARGS_((Tcl_Time *time)))
#endif

#endif /* _LANG */
