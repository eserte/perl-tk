#ifdef _LANG
VVAR(Tcl_CmdProc *,LangOptionCommand,V_LangOptionCommand)
#ifndef LangBadFile
VFUNC(void,LangBadFile,V_LangBadFile,_ANSI_ARGS_((int fd)))
#endif

#ifndef LangCmpArg
VFUNC(int,LangCmpArg,V_LangCmpArg,_ANSI_ARGS_((Tcl_Obj *,Tcl_Obj *)))
#endif

#ifndef LangCmpOpt
VFUNC(int,LangCmpOpt,V_LangCmpOpt,_ANSI_ARGS_((char *opt,char *arg,size_t length)))
#endif

#ifndef LangCopyArg
VFUNC(Tcl_Obj *,LangCopyArg,V_LangCopyArg,_ANSI_ARGS_((Tcl_Obj *)))
#endif

#ifndef LangDoCallback
VFUNC(int,LangDoCallback,V_LangDoCallback,_ANSI_ARGS_((Tcl_Interp *,LangCallback *,int result,int argc,...)))
#endif

#ifndef LangDumpVec
VFUNC(void,LangDumpVec,V_LangDumpVec,_ANSI_ARGS_((char *tag, int argc, Tcl_Obj **vec)))
#endif

#ifndef LangEval
VFUNC(int,LangEval,V_LangEval,_ANSI_ARGS_((Tcl_Interp *interp, char *cmd, int global)))
#endif

#ifndef LangEventHook
VFUNC(int,LangEventHook,V_LangEventHook,_ANSI_ARGS_((int flags)))
#endif

#ifndef LangFreeArg
VFUNC(void,LangFreeArg,V_LangFreeArg,_ANSI_ARGS_((Tcl_Obj *,Tcl_FreeProc *freeProc)))
#endif

#ifndef LangFreeVar
VFUNC(void,LangFreeVar,V_LangFreeVar,_ANSI_ARGS_((Var)))
#endif

#ifndef LangLibraryDir
VFUNC(char *,LangLibraryDir,V_LangLibraryDir,_ANSI_ARGS_((void)))
#endif

#ifndef LangMergeString
VFUNC(char *,LangMergeString,V_LangMergeString,_ANSI_ARGS_((int argc, Tcl_Obj **args)))
#endif

#ifndef LangMethodCall
VFUNC(int,LangMethodCall,V_LangMethodCall,_ANSI_ARGS_((Tcl_Interp *,Tcl_Obj *,char *,int result,int argc,...)))
#endif

#ifndef LangNull
VFUNC(int,LangNull,V_LangNull,_ANSI_ARGS_((Tcl_Obj *)))
#endif

#ifndef LangObjArg
VFUNC(Tcl_Obj *,LangObjArg,V_LangObjArg,_ANSI_ARGS_((Tcl_Obj *,char *,int)))
#endif

#ifndef LangOldSetArg
VFUNC(void,LangOldSetArg,V_LangOldSetArg,_ANSI_ARGS_((Tcl_Obj **,Tcl_Obj *,char *,int)))
#endif

#ifndef LangRestoreResult
VFUNC(void,LangRestoreResult,V_LangRestoreResult,_ANSI_ARGS_((Tcl_Interp **,LangResultSave *)))
#endif

#ifndef LangSaveResult
VFUNC(LangResultSave *,LangSaveResult,V_LangSaveResult,_ANSI_ARGS_((Tcl_Interp **)))
#endif

#ifndef LangSaveVar
VFUNC(int,LangSaveVar,V_LangSaveVar,_ANSI_ARGS_((Tcl_Interp *,Tcl_Obj *,Var *,int type)))
#endif

#ifndef LangScalarResult
VFUNC(Tcl_Obj *,LangScalarResult,V_LangScalarResult,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef LangSetDefault
VFUNC(void,LangSetDefault,V_LangSetDefault,_ANSI_ARGS_((Tcl_Obj **,char *)))
#endif

#ifndef LangSetDouble
VFUNC(void,LangSetDouble,V_LangSetDouble,_ANSI_ARGS_((Tcl_Obj **,double)))
#endif

#ifndef LangSetInt
VFUNC(void,LangSetInt,V_LangSetInt,_ANSI_ARGS_((Tcl_Obj **,int)))
#endif

#ifndef LangSetObj
VFUNC(void,LangSetObj,V_LangSetObj,_ANSI_ARGS_((Tcl_Obj **,Tcl_Obj *)))
#endif

#ifndef LangSetString
VFUNC(void,LangSetString,V_LangSetString,_ANSI_ARGS_((Tcl_Obj **,char *)))
#endif

#ifndef LangSetVar
VFUNC(void,LangSetVar,V_LangSetVar,_ANSI_ARGS_((Tcl_Obj **,Var)))
#endif

#ifndef LangString
VFUNC(char *,LangString,V_LangString,_ANSI_ARGS_((Tcl_Obj *)))
#endif

#ifndef LangStringMatch
VFUNC(int,LangStringMatch,V_LangStringMatch,_ANSI_ARGS_((char *string, Tcl_Obj *match)))
#endif

#ifndef Lang_BuildInImages
VFUNC(void,Lang_BuildInImages,V_Lang_BuildInImages,_ANSI_ARGS_((void)))
#endif

#ifndef Lang_CallWithArgs
VFUNC(int,Lang_CallWithArgs,V_Lang_CallWithArgs,_ANSI_ARGS_((Tcl_Interp *interp,
					char *sub, int argc, Tcl_Obj **argv)))
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

#ifndef Lang_GetStrInt
VFUNC(int,Lang_GetStrInt,V_Lang_GetStrInt,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int *intPtr)))
#endif

#ifndef Lang_OldArgResult
VFUNC(void,Lang_OldArgResult,V_Lang_OldArgResult,_ANSI_ARGS_((Tcl_Interp *,Tcl_Obj *,char *,int)))
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

#ifndef Tcl_AddErrorInfo
VFUNC(void,Tcl_AddErrorInfo,V_Tcl_AddErrorInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *message)))
#endif

#ifndef Tcl_AllowExceptions
VFUNC(void,Tcl_AllowExceptions,V_Tcl_AllowExceptions,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_AppendArg
VFUNC(void,Tcl_AppendArg,V_Tcl_AppendArg,_ANSI_ARGS_((Tcl_Interp *interp, Tcl_Obj *)))
#endif

#ifndef Tcl_AppendElement
VFUNC(void,Tcl_AppendElement,V_Tcl_AppendElement,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string)))
#endif

#ifndef Tcl_AppendResult
VFUNC(void,Tcl_AppendResult,V_Tcl_AppendResult,_ANSI_ARGS_(TCL_VARARGS(Tcl_Interp *,interp)))
#endif

#ifndef Tcl_AppendStringsToObj
VFUNC(void,Tcl_AppendStringsToObj,V_Tcl_AppendStringsToObj,_ANSI_ARGS_(TCL_VARARGS(Tcl_Obj *,interp)))
#endif

#ifndef Tcl_BackgroundError
VFUNC(void,Tcl_BackgroundError,V_Tcl_BackgroundError,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_CallWhenDeleted
VFUNC(void,Tcl_CallWhenDeleted,V_Tcl_CallWhenDeleted,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_InterpDeleteProc *proc,
			    ClientData clientData)))
#endif

#ifndef Tcl_Close
VFUNC(int,Tcl_Close,V_Tcl_Close,_ANSI_ARGS_((Tcl_Interp *interp,
        		    Tcl_Channel chan)))
#endif

#ifndef Tcl_Concat
VFUNC(Tcl_Obj *,Tcl_Concat,V_Tcl_Concat,_ANSI_ARGS_((int argc, Tcl_Obj **argv)))
#endif

#ifndef Tcl_CreateCommand
VFUNC(Tcl_Command,Tcl_CreateCommand,V_Tcl_CreateCommand,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
#endif

#ifndef Tcl_CreateInterp
VFUNC(Tcl_Interp *,Tcl_CreateInterp,V_Tcl_CreateInterp,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_CreateObjCommand
VFUNC(Tcl_Command,Tcl_CreateObjCommand,V_Tcl_CreateObjCommand,_ANSI_ARGS_((
			    Tcl_Interp *interp, char *cmdName,
			    Tcl_ObjCmdProc *proc, ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
#endif

#ifndef Tcl_DStringAppend
VFUNC(char *,Tcl_DStringAppend,V_Tcl_DStringAppend,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    char *string, int length)))
#endif

#ifndef Tcl_DStringAppendElement
VFUNC(char *,Tcl_DStringAppendElement,V_Tcl_DStringAppendElement,_ANSI_ARGS_((
			    Tcl_DString *dsPtr, char *string)))
#endif

#ifndef Tcl_DStringFree
VFUNC(void,Tcl_DStringFree,V_Tcl_DStringFree,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringGetResult
VFUNC(void,Tcl_DStringGetResult,V_Tcl_DStringGetResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringInit
VFUNC(void,Tcl_DStringInit,V_Tcl_DStringInit,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringLength
VFUNC(int,Tcl_DStringLength,V_Tcl_DStringLength,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringResult
VFUNC(void,Tcl_DStringResult,V_Tcl_DStringResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DStringSetLength
VFUNC(void,Tcl_DStringSetLength,V_Tcl_DStringSetLength,_ANSI_ARGS_((Tcl_DString *dsPtr,
			    int length)))
#endif

#ifndef Tcl_DStringValue
VFUNC(char *,Tcl_DStringValue,V_Tcl_DStringValue,_ANSI_ARGS_((Tcl_DString *dsPtr)))
#endif

#ifndef Tcl_DbCkfree
VFUNC(void,Tcl_DbCkfree,V_Tcl_DbCkfree,_ANSI_ARGS_((char *ptr,
			    char *file, int line)))
#endif

#ifndef Tcl_DbDStringInit
VFUNC(void,Tcl_DbDStringInit,V_Tcl_DbDStringInit,_ANSI_ARGS_((Tcl_DString *dsPtr,char *file,int line)))
#endif

#ifndef Tcl_DecrRefCount
VFUNC(void,Tcl_DecrRefCount,V_Tcl_DecrRefCount,_ANSI_ARGS_((Tcl_Obj *objPtr)))
#endif

#ifndef Tcl_DeleteCommandFromToken
VFUNC(int,Tcl_DeleteCommandFromToken,V_Tcl_DeleteCommandFromToken,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Command command)))
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

#ifndef Tcl_DoubleResults
VFUNC(void,Tcl_DoubleResults,V_Tcl_DoubleResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
#endif

#ifndef Tcl_Eof
VFUNC(int,Tcl_Eof,V_Tcl_Eof,_ANSI_ARGS_((Tcl_Channel chan)))
#endif

#ifndef Tcl_EvalObj
VFUNC(int,Tcl_EvalObj,V_Tcl_EvalObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr)))
#endif

#ifndef Tcl_EventuallyFree
VFUNC(void,Tcl_EventuallyFree,V_Tcl_EventuallyFree,_ANSI_ARGS_((ClientData clientData,
			    Tcl_FreeProc *freeProc)))
#endif

#ifndef Tcl_FirstHashEntry
VFUNC(Tcl_HashEntry *,Tcl_FirstHashEntry,V_Tcl_FirstHashEntry,_ANSI_ARGS_((
			    Tcl_HashTable *tablePtr,
			    Tcl_HashSearch *searchPtr)))
#endif

#ifndef Tcl_GetAssocData
VFUNC(ClientData,Tcl_GetAssocData,V_Tcl_GetAssocData,_ANSI_ARGS_((Tcl_Interp *interp,
                            char *name, Tcl_InterpDeleteProc **procPtr)))
#endif

#ifndef Tcl_GetBoolean
VFUNC(int,Tcl_GetBoolean,V_Tcl_GetBoolean,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *string, int *boolPtr)))
#endif

#ifndef Tcl_GetBooleanFromObj
VFUNC(int,Tcl_GetBooleanFromObj,V_Tcl_GetBooleanFromObj,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Obj *objPtr,
			    int *boolPtr)))
#endif

#ifndef Tcl_GetChannel
VFUNC(Tcl_Channel,Tcl_GetChannel,V_Tcl_GetChannel,_ANSI_ARGS_((Tcl_Interp *interp,
	        	    char *chanName, int *modePtr)))
#endif

#ifndef Tcl_GetDouble
VFUNC(int,Tcl_GetDouble,V_Tcl_GetDouble,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *string, double *doublePtr)))
#endif

#ifndef Tcl_GetDoubleFromObj
VFUNC(int,Tcl_GetDoubleFromObj,V_Tcl_GetDoubleFromObj,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Obj *objPtr,
			    double *doublePtr)))
#endif

#ifndef Tcl_GetIndexFromObj
VFUNC(int,Tcl_GetIndexFromObj,V_Tcl_GetIndexFromObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr, char **tablePtr, char *msg,
			    int flags, int *indexPtr)))
#endif

#ifndef Tcl_GetInt
VFUNC(int,Tcl_GetInt,V_Tcl_GetInt,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *string, int *intPtr)))
#endif

#ifndef Tcl_GetIntFromObj
VFUNC(int,Tcl_GetIntFromObj,V_Tcl_GetIntFromObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr, int *intPtr)))
#endif

#ifndef Tcl_GetLongFromObj
VFUNC(int,Tcl_GetLongFromObj,V_Tcl_GetLongFromObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *objPtr, long *longPtr)))
#endif

#ifndef Tcl_GetObjResult
VFUNC(Tcl_Obj *,Tcl_GetObjResult,V_Tcl_GetObjResult,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_GetOpenFile
VFUNC(int,Tcl_GetOpenFile,V_Tcl_GetOpenFile,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *string, int write, int checkUsage,
			    ClientData *filePtr)))
#endif

#ifndef Tcl_GetResult
VFUNC(char *,Tcl_GetResult,V_Tcl_GetResult,_ANSI_ARGS_((Tcl_Interp *)))
#endif

#ifndef Tcl_GetStringFromObj
VFUNC(char *,Tcl_GetStringFromObj,V_Tcl_GetStringFromObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    int *lengthPtr)))
#endif

#ifndef Tcl_GetVar
VFUNC(Tcl_Obj *,Tcl_GetVar,V_Tcl_GetVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags)))
#endif

#ifndef Tcl_GetVar2
VFUNC(Tcl_Obj *,Tcl_GetVar2,V_Tcl_GetVar2,_ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags)))
#endif

#ifndef Tcl_HideCommand
VFUNC(int,Tcl_HideCommand,V_Tcl_HideCommand,_ANSI_ARGS_((Tcl_Interp *interp,
		            char *cmdName, char *hiddenCmdName)))
#endif

#ifndef Tcl_IncrRefCount
VFUNC(void,Tcl_IncrRefCount,V_Tcl_IncrRefCount,_ANSI_ARGS_((Tcl_Obj *objPtr)))
#endif

#ifndef Tcl_InitHashTable
VFUNC(void,Tcl_InitHashTable,V_Tcl_InitHashTable,_ANSI_ARGS_((Tcl_HashTable *tablePtr,
			    int keyType)))
#endif

#ifndef Tcl_IntResults
VFUNC(void,Tcl_IntResults,V_Tcl_IntResults,_ANSI_ARGS_((Tcl_Interp *interp,int,int,...)))
#endif

#ifndef Tcl_IsSafe
VFUNC(int,Tcl_IsSafe,V_Tcl_IsSafe,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_JoinPath
VFUNC(char *,Tcl_JoinPath,V_Tcl_JoinPath,_ANSI_ARGS_((int argc, char **argv,
			    Tcl_DString *resultPtr)))
#endif

#ifndef Tcl_LinkVar
VFUNC(int,Tcl_LinkVar,V_Tcl_LinkVar,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName, char *addr, int type)))
#endif

#ifndef Tcl_ListObjAppendElement
VFUNC(int,Tcl_ListObjAppendElement,V_Tcl_ListObjAppendElement,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Obj *listPtr,
			    Tcl_Obj *objPtr)))
#endif

#ifndef Tcl_ListObjGetElements
VFUNC(int,Tcl_ListObjGetElements,V_Tcl_ListObjGetElements,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Obj *listPtr,
			    int *objcPtr, Tcl_Obj ***objvPtr)))
#endif

#ifndef Tcl_ListObjIndex
VFUNC(int,Tcl_ListObjIndex,V_Tcl_ListObjIndex,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *listPtr, int index,
			    Tcl_Obj **objPtrPtr)))
#endif

#ifndef Tcl_ListObjLength
VFUNC(int,Tcl_ListObjLength,V_Tcl_ListObjLength,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *listPtr, int *intPtr)))
#endif

#ifndef Tcl_ListObjReplace
VFUNC(int,Tcl_ListObjReplace,V_Tcl_ListObjReplace,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *listPtr, int first, int count,
			    int objc, Tcl_Obj *CONST objv[])))
#endif

#ifndef Tcl_NewBooleanObj
VFUNC(Tcl_Obj *,Tcl_NewBooleanObj,V_Tcl_NewBooleanObj,_ANSI_ARGS_((int boolValue)))
#endif

#ifndef Tcl_NewDoubleObj
VFUNC(Tcl_Obj *,Tcl_NewDoubleObj,V_Tcl_NewDoubleObj,_ANSI_ARGS_((double doubleValue)))
#endif

#ifndef Tcl_NewIntObj
VFUNC(Tcl_Obj *,Tcl_NewIntObj,V_Tcl_NewIntObj,_ANSI_ARGS_((int intValue)))
#endif

#ifndef Tcl_NewListObj
VFUNC(Tcl_Obj *,Tcl_NewListObj,V_Tcl_NewListObj,_ANSI_ARGS_((int objc,
			    Tcl_Obj *CONST objv[])))
#endif

#ifndef Tcl_NewLongObj
VFUNC(Tcl_Obj *,Tcl_NewLongObj,V_Tcl_NewLongObj,_ANSI_ARGS_((long longValue)))
#endif

#ifndef Tcl_NewObj
VFUNC(Tcl_Obj *,Tcl_NewObj,V_Tcl_NewObj,_ANSI_ARGS_((void)))
#endif

#ifndef Tcl_NewStringObj
VFUNC(Tcl_Obj *,Tcl_NewStringObj,V_Tcl_NewStringObj,_ANSI_ARGS_((char *bytes,
			    int length)))
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

#ifndef Tcl_PosixError
VFUNC(char *,Tcl_PosixError,V_Tcl_PosixError,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef Tcl_Preserve
VFUNC(void,Tcl_Preserve,V_Tcl_Preserve,_ANSI_ARGS_((ClientData data)))
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
VFUNC(Tcl_Obj *,Tcl_ResultArg,V_Tcl_ResultArg,_ANSI_ARGS_((Tcl_Interp *interp)))
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

#ifndef Tcl_SetBooleanObj
VFUNC(void,Tcl_SetBooleanObj,V_Tcl_SetBooleanObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    int boolValue)))
#endif

#ifndef Tcl_SetChannelOption
VFUNC(int,Tcl_SetChannelOption,V_Tcl_SetChannelOption,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tcl_Channel chan,
	        	    char *optionName, char *newValue)))
#endif

#ifndef Tcl_SetCommandInfo
VFUNC(int,Tcl_SetCommandInfo,V_Tcl_SetCommandInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdInfo *infoPtr)))
#endif

#ifndef Tcl_SetDoubleObj
VFUNC(void,Tcl_SetDoubleObj,V_Tcl_SetDoubleObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    double doubleValue)))
#endif

#ifndef Tcl_SetIntObj
VFUNC(void,Tcl_SetIntObj,V_Tcl_SetIntObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    int intValue)))
#endif

#ifndef Tcl_SetLongObj
VFUNC(void,Tcl_SetLongObj,V_Tcl_SetLongObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    long longValue)))
#endif

#ifndef Tcl_SetObjResult
VFUNC(void,Tcl_SetObjResult,V_Tcl_SetObjResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *resultObjPtr)))
#endif

#ifndef Tcl_SetResult
VFUNC(void,Tcl_SetResult,V_Tcl_SetResult,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tcl_FreeProc *freeProc)))
#endif

#ifndef Tcl_SetStringObj
VFUNC(void,Tcl_SetStringObj,V_Tcl_SetStringObj,_ANSI_ARGS_((Tcl_Obj *objPtr,
			    char *bytes, int length)))
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
			    Var varName, Tcl_Obj *newValue, int flags)))
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

#ifndef Tcl_Write
VFUNC(int,Tcl_Write,V_Tcl_Write,_ANSI_ARGS_((Tcl_Channel chan,
        		    char *s, int slen)))
#endif

#ifndef Tcl_WrongNumArgs
VFUNC(void,Tcl_WrongNumArgs,V_Tcl_WrongNumArgs,_ANSI_ARGS_((Tcl_Interp *interp,
			    int objc, Tcl_Obj *CONST objv[], char *message)))
#endif

#endif /* _LANG */
