#ifdef _LANG
VFUNC(Arg *,LangAllocVec,V_LangAllocVec,_ANSI_ARGS_((int count)))
VFUNC(void,LangBadFile,V_LangBadFile,_ANSI_ARGS_((int fd)))
VFUNC(Arg,LangCallbackArg,V_LangCallbackArg,_ANSI_ARGS_((LangCallback *)))
VFUNC(void,LangCloseHandler,V_LangCloseHandler,_ANSI_ARGS_((Tcl_Interp *interp,Arg arg,FILE *f,Lang_FileCloseProc *proc)))
VFUNC(int,LangCmpArg,V_LangCmpArg,_ANSI_ARGS_((Arg,Arg)))
VFUNC(int,LangCmpCallback,V_LangCmpCallback,_ANSI_ARGS_((LangCallback *a,Arg b)))
VFUNC(int,LangCmpOpt,V_LangCmpOpt,_ANSI_ARGS_((char *opt,char *arg,size_t length)))
VFUNC(Arg,LangCopyArg,V_LangCopyArg,_ANSI_ARGS_((Arg)))
VFUNC(LangCallback *,LangCopyCallback,V_LangCopyCallback,_ANSI_ARGS_((LangCallback *)))
VFUNC(int,LangDoCallback,V_LangDoCallback,_ANSI_ARGS_((Tcl_Interp *,LangCallback *,int result,int argc,...)))
VFUNC(int,LangEval,V_LangEval,_ANSI_ARGS_((Tcl_Interp *interp, char *cmd, int global)))
VFUNC(int,LangEventCallback,V_LangEventCallback,_ANSI_ARGS_((Tcl_Interp *,LangCallback *,XEvent *,KeySym)))
VFUNC(int,LangEventHook,V_LangEventHook,_ANSI_ARGS_((int flags)))
VFUNC(void,LangExit,V_LangExit,_ANSI_ARGS_((int)))
VFUNC(void,LangFreeArg,V_LangFreeArg,_ANSI_ARGS_((Arg,Tcl_FreeProc *freeProc)))
VFUNC(void,LangFreeCallback,V_LangFreeCallback,_ANSI_ARGS_((LangCallback *)))
VFUNC(void,LangFreeVar,V_LangFreeVar,_ANSI_ARGS_((Var)))
VFUNC(void,LangFreeVec,V_LangFreeVec,_ANSI_ARGS_((int,Arg *)))
VFUNC(char *,LangLibraryDir,V_LangLibraryDir,_ANSI_ARGS_((void)))
VFUNC(LangCallback *,LangMakeCallback,V_LangMakeCallback,_ANSI_ARGS_((Arg)))
VFUNC(char *,LangMergeString,V_LangMergeString,_ANSI_ARGS_((int argc, Arg *args)))
VFUNC(int,LangMethodCall,V_LangMethodCall,_ANSI_ARGS_((Tcl_Interp *,Arg,char *,int result,int argc,...)))
VFUNC(int,LangNull,V_LangNull,_ANSI_ARGS_((Arg)))
VFUNC(void,LangRestoreResult,V_LangRestoreResult,_ANSI_ARGS_((Tcl_Interp **,LangResultSave *)))
VFUNC(LangResultSave *,LangSaveResult,V_LangSaveResult,_ANSI_ARGS_((Tcl_Interp **)))
VFUNC(int,LangSaveVar,V_LangSaveVar,_ANSI_ARGS_((Tcl_Interp *,Arg,Var *,int type)))
VFUNC(void,LangSetArg,V_LangSetArg,_ANSI_ARGS_((Arg *,Arg)))
VFUNC(void,LangSetDefault,V_LangSetDefault,_ANSI_ARGS_((Arg *,char *)))
VFUNC(void,LangSetDouble,V_LangSetDouble,_ANSI_ARGS_((Arg *,double)))
VFUNC(void,LangSetInt,V_LangSetInt,_ANSI_ARGS_((Arg *,int)))
VFUNC(void,LangSetString,V_LangSetString,_ANSI_ARGS_((Arg *,char *)))
VFUNC(char *,LangString,V_LangString,_ANSI_ARGS_((Arg)))
VFUNC(Arg,LangStringArg,V_LangStringArg,_ANSI_ARGS_((char *)))
VFUNC(int,LangStringMatch,V_LangStringMatch,_ANSI_ARGS_((char *string, Arg match)))
VFUNC(Arg,LangVarArg,V_LangVarArg,_ANSI_ARGS_((Var)))
VFUNC(void,Lang_BuildInImages,V_Lang_BuildInImages,_ANSI_ARGS_((void)))
VFUNC(Tcl_Command,Lang_CreateObject,V_Lang_CreateObject,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
VFUNC(void,Lang_DeleteObject,V_Lang_DeleteObject,_ANSI_ARGS_((Tcl_Interp *,Tcl_Command)))
VFUNC(void,Lang_FreeRegExp,V_Lang_FreeRegExp,_ANSI_ARGS_((Tcl_RegExp regexp)))
VFUNC(char *,Lang_GetErrorCode,V_Lang_GetErrorCode,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(char *,Lang_GetErrorInfo,V_Lang_GetErrorInfo,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(Tcl_RegExp,Lang_RegExpCompile,V_Lang_RegExpCompile,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int fold)))
VFUNC(int,Lang_RegExpExec,V_Lang_RegExpExec,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_RegExp regexp, char *string, char *start)))
VFUNC(void,Lang_SetErrorCode,V_Lang_SetErrorCode,_ANSI_ARGS_((Tcl_Interp *interp,char *code)))
VFUNC(int,Lang_SplitList,V_Lang_SplitList,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg list, int *argcPtr, Arg **argsPtr, LangFreeProc **)))
VFUNC(int,TclOpen,V_TclOpen,_ANSI_ARGS_((char *path, int oflag, int mode)))
VFUNC(int,TclRead,V_TclRead,_ANSI_ARGS_((int fd, VOID *buf, size_t numBytes)))
VFUNC(int,TclWrite,V_TclWrite,_ANSI_ARGS_((int fd, VOID *buf, size_t numBytes)))
VFUNC(void,Tcl_AddErrorInfo,V_Tcl_AddErrorInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *message)))
VFUNC(void,Tcl_AppendArg,V_Tcl_AppendArg,_ANSI_ARGS_((Tcl_Interp *interp, Arg)))
VFUNC(void,Tcl_AppendElement,V_Tcl_AppendElement,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string)))
VFUNC(void,Tcl_AppendResult,V_Tcl_AppendResult,_ANSI_ARGS_((Tcl_Interp *interp,...)))
VFUNC(void,Tcl_ArgResult,V_Tcl_ArgResult,_ANSI_ARGS_((Tcl_Interp *interp, Arg)))
VFUNC(void,Tcl_CallWhenDeleted,V_Tcl_CallWhenDeleted,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_InterpDeleteProc *proc,
			    ClientData clientData)))
VFUNC(Arg,Tcl_Concat,V_Tcl_Concat,_ANSI_ARGS_((int argc, Arg *argv)))
VFUNC(Tcl_Command,Tcl_CreateCommand,V_Tcl_CreateCommand,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
VFUNC(Tcl_Interp *,Tcl_CreateInterp,V_Tcl_CreateInterp,_ANSI_ARGS_((void)))
VFUNC(char *,Tcl_DStringAppend,V_Tcl_DStringAppend,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    char *string, int length)))
VFUNC(void,Tcl_DStringFree,V_Tcl_DStringFree,_ANSI_ARGS_((Tcl_DString *dsPtr)))
VFUNC(void,Tcl_DStringGetResult,V_Tcl_DStringGetResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr)))
VFUNC(void,Tcl_DStringInit,V_Tcl_DStringInit,_ANSI_ARGS_((Tcl_DString *dsPtr)))
VFUNC(void,Tcl_DStringResult,V_Tcl_DStringResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr)))
VFUNC(void,Tcl_DStringSetLength,V_Tcl_DStringSetLength,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    int length)))
VFUNC(void,Tcl_DeleteHashEntry,V_Tcl_DeleteHashEntry,_ANSI_ARGS_((
			    Tcl_HashEntry *entryPtr)))
VFUNC(void,Tcl_DeleteHashTable,V_Tcl_DeleteHashTable,_ANSI_ARGS_((
			    Tcl_HashTable *tablePtr)))
VFUNC(void,Tcl_DeleteInterp,V_Tcl_DeleteInterp,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tcl_DoubleResults,V_Tcl_DoubleResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
VFUNC(Tcl_HashEntry *,Tcl_FirstHashEntry,V_Tcl_FirstHashEntry,_ANSI_ARGS_((
			    Tcl_HashTable *tablePtr,
			    Tcl_HashSearch *searchPtr)))
VFUNC(int,Tcl_GetBoolean,V_Tcl_GetBoolean,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *boolPtr)))
VFUNC(int,Tcl_GetDouble,V_Tcl_GetDouble,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, double *doublePtr)))
VFUNC(int,Tcl_GetInt,V_Tcl_GetInt,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *intPtr)))
VFUNC(int,Tcl_GetOpenFile,V_Tcl_GetOpenFile,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int doWrite, int checkUsage,
			    FILE **filePtr)))
VFUNC(char *,Tcl_GetResult,V_Tcl_GetResult,_ANSI_ARGS_((Tcl_Interp *)))
VFUNC(Arg,Tcl_GetVar,V_Tcl_GetVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags)))
VFUNC(Arg,Tcl_GetVar2,V_Tcl_GetVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags)))
VFUNC(char *,Tcl_HashStats,V_Tcl_HashStats,_ANSI_ARGS_((Tcl_HashTable *tablePtr)))
VFUNC(void,Tcl_InitHashTable,V_Tcl_InitHashTable,_ANSI_ARGS_((Tcl_HashTable *tablePtr,
			    int keyType)))
VFUNC(void,Tcl_IntResults,V_Tcl_IntResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
VFUNC(int,Tcl_LinkVar,V_Tcl_LinkVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName, char *addr, int type)))
VFUNC(Arg,Tcl_Merge,V_Tcl_Merge,_ANSI_ARGS_((int argc, Arg *args)))
VFUNC(Tcl_HashEntry *,Tcl_NextHashEntry,V_Tcl_NextHashEntry,_ANSI_ARGS_((
			    Tcl_HashSearch *searchPtr)))
VFUNC(void,Tcl_Panic,V_Tcl_Panic,_ANSI_ARGS_((char *,...)))
VFUNC(char *,Tcl_PosixError,V_Tcl_PosixError,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tcl_RegExpRange,V_Tcl_RegExpRange,_ANSI_ARGS_((Tcl_RegExp regexp,
			    int index, char **startPtr, char **endPtr)))
VFUNC(void,Tcl_ResetResult,V_Tcl_ResetResult,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(Arg,Tcl_ResultArg,V_Tcl_ResultArg,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tcl_SetResult,V_Tcl_SetResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tcl_FreeProc *freeProc)))
VFUNC(char *,Tcl_SetVar,V_Tcl_SetVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, char *newValue, int flags)))
VFUNC(char *,Tcl_SetVar2,V_Tcl_SetVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, char *newValue,
			    int flags)))
VFUNC(char *,Tcl_SetVarArg,V_Tcl_SetVarArg,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, Arg newValue, int flags)))
VFUNC(void,Tcl_SprintfResult,V_Tcl_SprintfResult,_ANSI_ARGS_((Tcl_Interp *,char *,...)))
VFUNC(char *,Tcl_TildeSubst,V_Tcl_TildeSubst,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, Tcl_DString *bufferPtr)))
VFUNC(int,Tcl_TraceVar,V_Tcl_TraceVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData)))
VFUNC(int,Tcl_TraceVar2,V_Tcl_TraceVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData)))
VFUNC(void,Tcl_UnlinkVar,V_Tcl_UnlinkVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName)))
VFUNC(void,Tcl_UntraceVar,V_Tcl_UntraceVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData)))
VFUNC(void,Tcl_UntraceVar2,V_Tcl_UntraceVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData)))
VFUNC(int,TkReadDataPending,V_TkReadDataPending,_ANSI_ARGS_((FILE *f)))
#endif /* _LANG */
