#ifndef _LANG_VM
#define _LANG_VM
#include "Lang_f.h"
#ifndef NO_VTABLES
#define LangOptionCommand (*LangVptr->V_LangOptionCommand)
#ifndef LangBadFile
#  define LangBadFile (*LangVptr->V_LangBadFile)
#endif

#ifndef LangCmpArg
#  define LangCmpArg (*LangVptr->V_LangCmpArg)
#endif

#ifndef LangCmpOpt
#  define LangCmpOpt (*LangVptr->V_LangCmpOpt)
#endif

#ifndef LangCopyArg
#  define LangCopyArg (*LangVptr->V_LangCopyArg)
#endif

#ifndef LangDoCallback
#  define LangDoCallback (*LangVptr->V_LangDoCallback)
#endif

#ifndef LangDumpVec
#  define LangDumpVec (*LangVptr->V_LangDumpVec)
#endif

#ifndef LangEval
#  define LangEval (*LangVptr->V_LangEval)
#endif

#ifndef LangEventHook
#  define LangEventHook (*LangVptr->V_LangEventHook)
#endif

#ifndef LangFreeArg
#  define LangFreeArg (*LangVptr->V_LangFreeArg)
#endif

#ifndef LangFreeVar
#  define LangFreeVar (*LangVptr->V_LangFreeVar)
#endif

#ifndef LangLibraryDir
#  define LangLibraryDir (*LangVptr->V_LangLibraryDir)
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

#ifndef LangObjArg
#  define LangObjArg (*LangVptr->V_LangObjArg)
#endif

#ifndef LangOldSetArg
#  define LangOldSetArg (*LangVptr->V_LangOldSetArg)
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

#ifndef LangScalarResult
#  define LangScalarResult (*LangVptr->V_LangScalarResult)
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

#ifndef LangSetObj
#  define LangSetObj (*LangVptr->V_LangSetObj)
#endif

#ifndef LangSetString
#  define LangSetString (*LangVptr->V_LangSetString)
#endif

#ifndef LangSetVar
#  define LangSetVar (*LangVptr->V_LangSetVar)
#endif

#ifndef LangString
#  define LangString (*LangVptr->V_LangString)
#endif

#ifndef LangStringMatch
#  define LangStringMatch (*LangVptr->V_LangStringMatch)
#endif

#ifndef Lang_BuildInImages
#  define Lang_BuildInImages (*LangVptr->V_Lang_BuildInImages)
#endif

#ifndef Lang_CallWithArgs
#  define Lang_CallWithArgs (*LangVptr->V_Lang_CallWithArgs)
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

#ifndef Lang_GetStrInt
#  define Lang_GetStrInt (*LangVptr->V_Lang_GetStrInt)
#endif

#ifndef Lang_OldArgResult
#  define Lang_OldArgResult (*LangVptr->V_Lang_OldArgResult)
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

#ifndef Tcl_AddErrorInfo
#  define Tcl_AddErrorInfo (*LangVptr->V_Tcl_AddErrorInfo)
#endif

#ifndef Tcl_AllowExceptions
#  define Tcl_AllowExceptions (*LangVptr->V_Tcl_AllowExceptions)
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

#ifndef Tcl_AppendStringsToObj
#  define Tcl_AppendStringsToObj (*LangVptr->V_Tcl_AppendStringsToObj)
#endif

#ifndef Tcl_BackgroundError
#  define Tcl_BackgroundError (*LangVptr->V_Tcl_BackgroundError)
#endif

#ifndef Tcl_CallWhenDeleted
#  define Tcl_CallWhenDeleted (*LangVptr->V_Tcl_CallWhenDeleted)
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

#ifndef Tcl_CreateInterp
#  define Tcl_CreateInterp (*LangVptr->V_Tcl_CreateInterp)
#endif

#ifndef Tcl_CreateObjCommand
#  define Tcl_CreateObjCommand (*LangVptr->V_Tcl_CreateObjCommand)
#endif

#ifndef Tcl_DStringAppend
#  define Tcl_DStringAppend (*LangVptr->V_Tcl_DStringAppend)
#endif

#ifndef Tcl_DStringAppendElement
#  define Tcl_DStringAppendElement (*LangVptr->V_Tcl_DStringAppendElement)
#endif

#ifndef Tcl_DStringFree
#  define Tcl_DStringFree (*LangVptr->V_Tcl_DStringFree)
#endif

#ifndef Tcl_DStringGetResult
#  define Tcl_DStringGetResult (*LangVptr->V_Tcl_DStringGetResult)
#endif

#ifndef Tcl_DStringInit
#  define Tcl_DStringInit (*LangVptr->V_Tcl_DStringInit)
#endif

#ifndef Tcl_DStringLength
#  define Tcl_DStringLength (*LangVptr->V_Tcl_DStringLength)
#endif

#ifndef Tcl_DStringResult
#  define Tcl_DStringResult (*LangVptr->V_Tcl_DStringResult)
#endif

#ifndef Tcl_DStringSetLength
#  define Tcl_DStringSetLength (*LangVptr->V_Tcl_DStringSetLength)
#endif

#ifndef Tcl_DStringValue
#  define Tcl_DStringValue (*LangVptr->V_Tcl_DStringValue)
#endif

#ifndef Tcl_DbCkfree
#  define Tcl_DbCkfree (*LangVptr->V_Tcl_DbCkfree)
#endif

#ifndef Tcl_DbDStringInit
#  define Tcl_DbDStringInit (*LangVptr->V_Tcl_DbDStringInit)
#endif

#ifndef Tcl_DecrRefCount
#  define Tcl_DecrRefCount (*LangVptr->V_Tcl_DecrRefCount)
#endif

#ifndef Tcl_DeleteCommandFromToken
#  define Tcl_DeleteCommandFromToken (*LangVptr->V_Tcl_DeleteCommandFromToken)
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

#ifndef Tcl_DoubleResults
#  define Tcl_DoubleResults (*LangVptr->V_Tcl_DoubleResults)
#endif

#ifndef Tcl_Eof
#  define Tcl_Eof (*LangVptr->V_Tcl_Eof)
#endif

#ifndef Tcl_EvalObj
#  define Tcl_EvalObj (*LangVptr->V_Tcl_EvalObj)
#endif

#ifndef Tcl_EventuallyFree
#  define Tcl_EventuallyFree (*LangVptr->V_Tcl_EventuallyFree)
#endif

#ifndef Tcl_FirstHashEntry
#  define Tcl_FirstHashEntry (*LangVptr->V_Tcl_FirstHashEntry)
#endif

#ifndef Tcl_GetAssocData
#  define Tcl_GetAssocData (*LangVptr->V_Tcl_GetAssocData)
#endif

#ifndef Tcl_GetBoolean
#  define Tcl_GetBoolean (*LangVptr->V_Tcl_GetBoolean)
#endif

#ifndef Tcl_GetBooleanFromObj
#  define Tcl_GetBooleanFromObj (*LangVptr->V_Tcl_GetBooleanFromObj)
#endif

#ifndef Tcl_GetChannel
#  define Tcl_GetChannel (*LangVptr->V_Tcl_GetChannel)
#endif

#ifndef Tcl_GetDouble
#  define Tcl_GetDouble (*LangVptr->V_Tcl_GetDouble)
#endif

#ifndef Tcl_GetDoubleFromObj
#  define Tcl_GetDoubleFromObj (*LangVptr->V_Tcl_GetDoubleFromObj)
#endif

#ifndef Tcl_GetIndexFromObj
#  define Tcl_GetIndexFromObj (*LangVptr->V_Tcl_GetIndexFromObj)
#endif

#ifndef Tcl_GetInt
#  define Tcl_GetInt (*LangVptr->V_Tcl_GetInt)
#endif

#ifndef Tcl_GetIntFromObj
#  define Tcl_GetIntFromObj (*LangVptr->V_Tcl_GetIntFromObj)
#endif

#ifndef Tcl_GetLongFromObj
#  define Tcl_GetLongFromObj (*LangVptr->V_Tcl_GetLongFromObj)
#endif

#ifndef Tcl_GetObjResult
#  define Tcl_GetObjResult (*LangVptr->V_Tcl_GetObjResult)
#endif

#ifndef Tcl_GetOpenFile
#  define Tcl_GetOpenFile (*LangVptr->V_Tcl_GetOpenFile)
#endif

#ifndef Tcl_GetResult
#  define Tcl_GetResult (*LangVptr->V_Tcl_GetResult)
#endif

#ifndef Tcl_GetStringFromObj
#  define Tcl_GetStringFromObj (*LangVptr->V_Tcl_GetStringFromObj)
#endif

#ifndef Tcl_GetVar
#  define Tcl_GetVar (*LangVptr->V_Tcl_GetVar)
#endif

#ifndef Tcl_GetVar2
#  define Tcl_GetVar2 (*LangVptr->V_Tcl_GetVar2)
#endif

#ifndef Tcl_HideCommand
#  define Tcl_HideCommand (*LangVptr->V_Tcl_HideCommand)
#endif

#ifndef Tcl_IncrRefCount
#  define Tcl_IncrRefCount (*LangVptr->V_Tcl_IncrRefCount)
#endif

#ifndef Tcl_InitHashTable
#  define Tcl_InitHashTable (*LangVptr->V_Tcl_InitHashTable)
#endif

#ifndef Tcl_IntResults
#  define Tcl_IntResults (*LangVptr->V_Tcl_IntResults)
#endif

#ifndef Tcl_IsSafe
#  define Tcl_IsSafe (*LangVptr->V_Tcl_IsSafe)
#endif

#ifndef Tcl_JoinPath
#  define Tcl_JoinPath (*LangVptr->V_Tcl_JoinPath)
#endif

#ifndef Tcl_LinkVar
#  define Tcl_LinkVar (*LangVptr->V_Tcl_LinkVar)
#endif

#ifndef Tcl_ListObjAppendElement
#  define Tcl_ListObjAppendElement (*LangVptr->V_Tcl_ListObjAppendElement)
#endif

#ifndef Tcl_ListObjGetElements
#  define Tcl_ListObjGetElements (*LangVptr->V_Tcl_ListObjGetElements)
#endif

#ifndef Tcl_ListObjIndex
#  define Tcl_ListObjIndex (*LangVptr->V_Tcl_ListObjIndex)
#endif

#ifndef Tcl_ListObjLength
#  define Tcl_ListObjLength (*LangVptr->V_Tcl_ListObjLength)
#endif

#ifndef Tcl_ListObjReplace
#  define Tcl_ListObjReplace (*LangVptr->V_Tcl_ListObjReplace)
#endif

#ifndef Tcl_NewBooleanObj
#  define Tcl_NewBooleanObj (*LangVptr->V_Tcl_NewBooleanObj)
#endif

#ifndef Tcl_NewDoubleObj
#  define Tcl_NewDoubleObj (*LangVptr->V_Tcl_NewDoubleObj)
#endif

#ifndef Tcl_NewIntObj
#  define Tcl_NewIntObj (*LangVptr->V_Tcl_NewIntObj)
#endif

#ifndef Tcl_NewListObj
#  define Tcl_NewListObj (*LangVptr->V_Tcl_NewListObj)
#endif

#ifndef Tcl_NewLongObj
#  define Tcl_NewLongObj (*LangVptr->V_Tcl_NewLongObj)
#endif

#ifndef Tcl_NewObj
#  define Tcl_NewObj (*LangVptr->V_Tcl_NewObj)
#endif

#ifndef Tcl_NewStringObj
#  define Tcl_NewStringObj (*LangVptr->V_Tcl_NewStringObj)
#endif

#ifndef Tcl_NextHashEntry
#  define Tcl_NextHashEntry (*LangVptr->V_Tcl_NextHashEntry)
#endif

#ifndef Tcl_OpenFileChannel
#  define Tcl_OpenFileChannel (*LangVptr->V_Tcl_OpenFileChannel)
#endif

#ifndef Tcl_PosixError
#  define Tcl_PosixError (*LangVptr->V_Tcl_PosixError)
#endif

#ifndef Tcl_Preserve
#  define Tcl_Preserve (*LangVptr->V_Tcl_Preserve)
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

#ifndef Tcl_SetBooleanObj
#  define Tcl_SetBooleanObj (*LangVptr->V_Tcl_SetBooleanObj)
#endif

#ifndef Tcl_SetChannelOption
#  define Tcl_SetChannelOption (*LangVptr->V_Tcl_SetChannelOption)
#endif

#ifndef Tcl_SetCommandInfo
#  define Tcl_SetCommandInfo (*LangVptr->V_Tcl_SetCommandInfo)
#endif

#ifndef Tcl_SetDoubleObj
#  define Tcl_SetDoubleObj (*LangVptr->V_Tcl_SetDoubleObj)
#endif

#ifndef Tcl_SetIntObj
#  define Tcl_SetIntObj (*LangVptr->V_Tcl_SetIntObj)
#endif

#ifndef Tcl_SetLongObj
#  define Tcl_SetLongObj (*LangVptr->V_Tcl_SetLongObj)
#endif

#ifndef Tcl_SetObjResult
#  define Tcl_SetObjResult (*LangVptr->V_Tcl_SetObjResult)
#endif

#ifndef Tcl_SetResult
#  define Tcl_SetResult (*LangVptr->V_Tcl_SetResult)
#endif

#ifndef Tcl_SetStringObj
#  define Tcl_SetStringObj (*LangVptr->V_Tcl_SetStringObj)
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

#ifndef Tcl_Write
#  define Tcl_Write (*LangVptr->V_Tcl_Write)
#endif

#ifndef Tcl_WrongNumArgs
#  define Tcl_WrongNumArgs (*LangVptr->V_Tcl_WrongNumArgs)
#endif

#endif /* NO_VTABLES */
#endif /* _LANG_VM */
