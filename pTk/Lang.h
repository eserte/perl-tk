/*
 * tcl.h --
 *
 *	This header file describes the externally-visible facilities
 *	of the Tcl interpreter.
 *
 * Copyright (c) 1987-1993 The Regents of the University of California.
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that the
 * above copyright notice and the following two paragraphs appear in
 * all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * $Header: /home/auspex6/CVSROOT/tcl/tcl.h,v 1.1.1.2 1993/11/29 12:35:01 a904209 Exp $ SPRITE (Berkeley)
 */

#ifndef _LANG
#define _LANG

#ifndef _TKPORT
#include "tkPort.h"
#endif

#ifndef BUFSIZ
#include <stdio.h>
#endif

#ifndef _XLIB_H
#include <X11/Xlib.h>
#endif

#define TCL_VERSION "7.3"
#define TCL_MAJOR_VERSION 7
#define TCL_MINOR_VERSION 3

/*
 * Data structures defined opaquely in this module.  The definitions
 * below just provide dummy types.  A few fields are made visible in
 * Tcl_Interp structures, namely those for returning string values.
 * Note:  any change to the Tcl_Interp definition below must be mirrored
 * in the "real" definition in tclInt.h.
 */

#ifndef Tcl_RegExp
typedef struct Tcl_RegExp_ *Tcl_RegExp;
#endif

#ifndef LangCallback
typedef struct LangCallback *LangCallback;
#endif

#ifndef Tcl_Command
typedef struct Tcl_Command *Tcl_Command;
#endif

#ifndef Tcl_Interp
typedef struct Tcl_Interp
#ifdef IMPURE
{
    char *result;		/* Points to result string returned by last
				 * command. */
    void (*freeProc) _ANSI_ARGS_((char *blockPtr));
				/* Zero means result is statically allocated.
				 * If non-zero, gives address of procedure
				 * to invoke to free the result.  Must be
				 * freed by Tcl_Eval before executing next
				 * command. */
    int errorLine;		/* When TCL_ERROR is returned, this gives
				 * the line number within the command where
				 * the error occurred (1 means first line). */
} 
#endif
Tcl_Interp;
#endif

typedef int *Tcl_Trace;
typedef struct Tcl_AsyncHandler_ *Tcl_AsyncHandler;

/*
 * When a TCL command returns, the string pointer Tcl_GetResult(interp) points to
 * a string containing return information from the command.  In addition,
 * the command procedure returns an integer value, which is one of the
 * following:
 *
 * TCL_OK		Command completed normally;  Tcl_GetResult(interp) contains
 *			the command's result.
 * TCL_ERROR		The command couldn't be completed successfully;
 *			Tcl_GetResult(interp) describes what went wrong.
 * TCL_RETURN		The command requests that the current procedure
 *			return;  Tcl_GetResult(interp) contains the procedure's
 *			return value.
 * TCL_BREAK		The command requests that the innermost loop
 *			be exited;  Tcl_GetResult(interp) is meaningless.
 * TCL_CONTINUE		Go on to the next iteration of the current loop;
 *			Tcl_GetResult(interp) is meaningless.
 */

#define TCL_OK		0
#define TCL_ERROR	1
#define TCL_RETURN	2
#define TCL_BREAK	3
#define TCL_CONTINUE	4

#define TCL_RESULT_SIZE 200

/*
 * Argument descriptors for math function callbacks in expressions:
 */

typedef enum {TCL_INT, TCL_DOUBLE, TCL_EITHER} Tcl_ValueType;
typedef struct Tcl_Value {
    Tcl_ValueType type;		/* Indicates intValue or doubleValue is
				 * valid, or both. */
    int intValue;		/* Integer value. */
    double doubleValue;		/* Double-precision floating value. */
} Tcl_Value;

/*
 * Procedure types defined by Tcl:
 */

#ifndef Arg
typedef struct Arg *Arg;
#endif
#ifndef Var
typedef struct Var *Var;
#endif

#ifndef LangResultSave 
typedef struct LangResultSave LangResultSave;
#endif

typedef int (Tcl_AsyncProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int code));
typedef void (Tcl_CmdDeleteProc) _ANSI_ARGS_((ClientData clientData));
typedef int (Tcl_CmdProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, Arg *args));
typedef void (Tcl_CmdTraceProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int level, char *command, Tcl_CmdProc *proc,
	ClientData cmdClientData, int argc, Arg *args));
typedef void (Tcl_FreeProc) _ANSI_ARGS_((char *blockPtr));
typedef void (LangFreeProc) _ANSI_ARGS_((int count,Arg *blockPtr));
typedef void (Tcl_InterpDeleteProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp));
typedef int (Tcl_MathProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, Tcl_Value *args, Tcl_Value *resultPtr));
typedef char *(Tcl_VarTraceProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, Var part1, char *part2, int flags));
typedef void Lang_FileCloseProc _ANSI_ARGS_((FILE *f));

/*
 * The structure returned by Tcl_GetCmdInfo and passed into
 * Tcl_SetCmdInfo:
 */

typedef struct Tcl_CmdInfo {
    Tcl_CmdProc *proc;			/* Procedure that implements command. */
    ClientData clientData;		/* ClientData passed to proc. */
    Tcl_CmdDeleteProc *deleteProc;	/* Procedure to call when command
					 * is deleted. */
    ClientData deleteData;		/* Value to pass to deleteProc (usually
					 * the same as clientData). */
} Tcl_CmdInfo;

/*
 * The structure defined below is used to hold dynamic strings.  The only
 * field that clients should use is the string field, and they should
 * never modify it.
 */

#define TCL_DSTRING_STATIC_SIZE 200
typedef struct Tcl_DString {
    char *string;		/* Points to beginning of string:  either
				 * staticSpace below or a malloc'ed array. */
    int length;			/* Number of non-NULL characters in the
				 * string. */
    int spaceAvl;		/* Total number of bytes available for the
				 * string and its terminating NULL char. */
    char staticSpace[TCL_DSTRING_STATIC_SIZE];
				/* Space to use in common case where string
				 * is small. */
} Tcl_DString;

#define Tcl_DStringLength(dsPtr) ((dsPtr)->length)
#define Tcl_DStringValue(dsPtr) ((dsPtr)->string)

/*
 * Definitions for the maximum number of digits of precision that may
 * be specified in the "tcl_precision" variable, and the number of
 * characters of buffer space required by Tcl_PrintDouble.
 */

#define TCL_MAX_PREC 17
#define TCL_DOUBLE_SPACE (TCL_MAX_PREC+10)

/*
 * Flag values passed to Tcl_Eval (see the man page for details;  also
 * see tclInt.h for additional flags that are only used internally by
 * Tcl):
 */

#define TCL_BRACKET_TERM	1

/*
 * Flag that may be passed to Tcl_ConvertElement to force it not to
 * output braces (careful!  if you change this flag be sure to change
 * the definitions at the front of tclUtil.c).
 */

#define TCL_DONT_USE_BRACES	1

/*
 * Flag value passed to Tcl_RecordAndEval to request no evaluation
 * (record only).
 */

#define TCL_NO_EVAL		-1

/*
 * Special freeProc values that may be passed to Tcl_SetResult (see
 * the man page for details):
 */

#define TCL_VOLATILE	((Tcl_FreeProc *) -1)
#define TCL_STATIC	((Tcl_FreeProc *) 0)
#define TCL_DYNAMIC	((Tcl_FreeProc *) free)

/*
 * Flag values passed to variable-related procedures.
 */

#define TCL_GLOBAL_ONLY		1
#define TCL_APPEND_VALUE	2
#define TCL_LIST_ELEMENT	4
#define TCL_TRACE_READS		0x10
#define TCL_TRACE_WRITES	0x20
#define TCL_TRACE_UNSETS	0x40
#define TCL_TRACE_DESTROYED	0x80
#define TCL_INTERP_DESTROYED	0x100
#define TCL_LEAVE_ERR_MSG	0x200

/*
 * Types for linked variables:
 */

#define TCL_LINK_INT		1
#define TCL_LINK_DOUBLE		2
#define TCL_LINK_BOOLEAN	3
#define TCL_LINK_STRING		4
#define TCL_LINK_READ_ONLY	0x80

/*
 * Permission flags for files:
 */

#define TCL_FILE_READABLE	1
#define TCL_FILE_WRITABLE	2

/*
 * The following declarations either map ckalloc and ckfree to
 * malloc and free, or they map them to procedures with all sorts
 * of debugging hooks defined in tclCkalloc.c.
 */

#  define ckalloc(x) malloc(x)
#  define ckfree(x)  free(x)
#  define ckrealloc(x,y) realloc(x,y)
#  define Tcl_DumpActiveMemory(x)
#  define Tcl_ValidateAllMemory(x,y)

/*
 * Macro to free up result of interpreter.
 */

#define Tcl_FreeResult(interp)					\
    if ((interp)->freeProc != 0) {				\
	if ((interp)->freeProc == (Tcl_FreeProc *) free) {	\
	    ckfree((interp)->result);				\
	} else {						\
	    (*(interp)->freeProc)((interp)->result);		\
	}							\
	(interp)->freeProc = 0;					\
    }

/*
 * Forward declaration of Tcl_HashTable.  Needed by some C++ compilers
 * to prevent errors when the forward reference to Tcl_HashTable is
 * encountered in the Tcl_HashEntry structure.
 */

#ifdef __cplusplus
struct Tcl_HashTable;
#endif

/*
 * Structure definition for an entry in a hash table.  No-one outside
 * Tcl should access any of these fields directly;  use the macros
 * defined below.
 */

typedef struct Tcl_HashEntry {
    struct Tcl_HashEntry *nextPtr;	/* Pointer to next entry in this
					 * hash bucket, or NULL for end of
					 * chain. */
    struct Tcl_HashTable *tablePtr;	/* Pointer to table containing entry. */
    struct Tcl_HashEntry **bucketPtr;	/* Pointer to bucket that points to
					 * first entry in this entry's chain:
					 * used for deleting the entry. */
    ClientData clientData;		/* Application stores something here
					 * with Tcl_SetHashValue. */
    union {				/* Key has one of these forms: */
	char *oneWordValue;		/* One-word value for key. */
	int words[1];			/* Multiple integer words for key.
					 * The actual size will be as large
					 * as necessary for this table's
					 * keys. */
	char string[4];			/* String for key.  The actual size
					 * will be as large as needed to hold
					 * the key. */
    } key;				/* MUST BE LAST FIELD IN RECORD!! */
} Tcl_HashEntry;

/*
 * Structure definition for a hash table.  Must be in tcl.h so clients
 * can allocate space for these structures, but clients should never
 * access any fields in this structure.
 */

#define TCL_SMALL_HASH_TABLE 4
typedef struct Tcl_HashTable {
    Tcl_HashEntry **buckets;		/* Pointer to bucket array.  Each
					 * element points to first entry in
					 * bucket's hash chain, or NULL. */
    Tcl_HashEntry *staticBuckets[TCL_SMALL_HASH_TABLE];
					/* Bucket array used for small tables
					 * (to avoid mallocs and frees). */
    int numBuckets;			/* Total number of buckets allocated
					 * at **bucketPtr. */
    int numEntries;			/* Total number of entries present
					 * in table. */
    int rebuildSize;			/* Enlarge table when numEntries gets
					 * to be this large. */
    int downShift;			/* Shift count used in hashing
					 * function.  Designed to use high-
					 * order bits of randomized keys. */
    int mask;				/* Mask value used in hashing
					 * function. */
    int keyType;			/* Type of keys used in this table. 
					 * It's either TCL_STRING_KEYS,
					 * TCL_ONE_WORD_KEYS, or an integer
					 * giving the number of ints in a
					 */
    Tcl_HashEntry *(*findProc) _ANSI_ARGS_((struct Tcl_HashTable *tablePtr,
	    char *key));
    Tcl_HashEntry *(*createProc) _ANSI_ARGS_((struct Tcl_HashTable *tablePtr,
	    char *key, int *newPtr));
} Tcl_HashTable;

/*
 * Structure definition for information used to keep track of searches
 * through hash tables:
 */

typedef struct Tcl_HashSearch {
    Tcl_HashTable *tablePtr;		/* Table being searched. */
    int nextIndex;			/* Index of next bucket to be
					 * enumerated after present one. */
    Tcl_HashEntry *nextEntryPtr;	/* Next entry to be enumerated in the
					 * the current bucket. */
} Tcl_HashSearch;

/*
 * Acceptable key types for hash tables:
 */

#define TCL_STRING_KEYS		0
#define TCL_ONE_WORD_KEYS	1

/*
 * Macros for clients to use to access fields of hash entries:
 */

#define Tcl_GetHashValue(h) ((h)->clientData)
#define Tcl_SetHashValue(h, value) ((h)->clientData = (ClientData) (value))
#define Tcl_GetHashKey(tablePtr, h) \
    ((char *) (((tablePtr)->keyType == TCL_ONE_WORD_KEYS) ? (h)->key.oneWordValue \
						: (h)->key.string))

/*
 * Macros to use for clients to use to invoke find and create procedures
 * for hash tables:
 */

#define Tcl_FindHashEntry(tablePtr, key) \
	(*((tablePtr)->findProc))(tablePtr, key)
#define Tcl_CreateHashEntry(tablePtr, key, newPtr) \
	(*((tablePtr)->createProc))(tablePtr, key, newPtr)

/*
 * Exported Tcl variables:
 */

/*
 * Exported Tcl procedures:
 */

EXTERN void		Tcl_AppendElement _ANSI_ARGS_((Tcl_Interp *interp,
			    char *string));
EXTERN void		Tcl_AppendArg _ANSI_ARGS_((Tcl_Interp *interp, Arg));
EXTERN void		Tcl_AddErrorInfo _ANSI_ARGS_((Tcl_Interp *interp,
			    char *message));
EXTERN void		Tcl_CallWhenDeleted _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_InterpDeleteProc *proc,
			    ClientData clientData));
EXTERN Arg		Tcl_Concat _ANSI_ARGS_((int argc, Arg *argv));
EXTERN Tcl_Command	Tcl_CreateCommand _ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc));
EXTERN Tcl_Interp *	Tcl_CreateInterp _ANSI_ARGS_((void));
EXTERN void		Tcl_DeleteHashEntry _ANSI_ARGS_((
			    Tcl_HashEntry *entryPtr));
EXTERN void		Tcl_DeleteHashTable _ANSI_ARGS_((
			    Tcl_HashTable *tablePtr));
EXTERN char *		Tcl_DStringAppend _ANSI_ARGS_((Tcl_DString *dsPtr,
			    char *string, int length));
EXTERN void		Tcl_DStringFree _ANSI_ARGS_((Tcl_DString *dsPtr));
EXTERN void		Tcl_DStringInit _ANSI_ARGS_((Tcl_DString *dsPtr));
EXTERN void		Tcl_DStringResult _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr));
EXTERN void		Tcl_DeleteInterp _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN Tcl_HashEntry *	Tcl_FirstHashEntry _ANSI_ARGS_((
			    Tcl_HashTable *tablePtr,
			    Tcl_HashSearch *searchPtr));
EXTERN int		Tcl_GetBoolean _ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *boolPtr));
EXTERN int		Tcl_GetDouble _ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, double *doublePtr));
EXTERN int		Tcl_GetInt _ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *intPtr));
EXTERN int		Tcl_GetOpenFile _ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int doWrite, int checkUsage,
			    FILE **filePtr));
EXTERN Arg 		Tcl_GetVar _ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags));
EXTERN Arg		Tcl_GetVar2 _ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags));

EXTERN char *		Tcl_HashStats _ANSI_ARGS_((Tcl_HashTable *tablePtr));
EXTERN void		Tcl_InitHashTable _ANSI_ARGS_((Tcl_HashTable *tablePtr,
			    int keyType));
EXTERN int		Tcl_LinkVar _ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName, char *addr, int type));
EXTERN Arg		Tcl_Merge _ANSI_ARGS_((int argc, Arg *args));
EXTERN char *		LangMergeString _ANSI_ARGS_((int argc, Arg *args));
EXTERN Tcl_HashEntry *	Tcl_NextHashEntry _ANSI_ARGS_((
			    Tcl_HashSearch *searchPtr));
EXTERN char *		Tcl_PosixError _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN void		Tcl_ResetResult _ANSI_ARGS_((Tcl_Interp *interp));
#define Tcl_Return Tcl_SetResult
EXTERN void		Tcl_SetResult _ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tcl_FreeProc *freeProc));
EXTERN void		Tcl_IntResults _ANSI_ARGS_((Tcl_Interp *interp,int,int,...));
EXTERN void		Tcl_DoubleResults _ANSI_ARGS_((Tcl_Interp *interp,int,int,...));
EXTERN void		Tcl_ArgResult _ANSI_ARGS_((Tcl_Interp *interp, Arg));
EXTERN char *		Tcl_SetVar _ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, char *newValue, int flags));
EXTERN char *		Tcl_SetVarArg _ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, Arg newValue, int flags));
EXTERN char *		Tcl_SetVar2 _ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, char *newValue,
			    int flags));
EXTERN int		Lang_SplitList _ANSI_ARGS_((Tcl_Interp *interp,
			    Arg list, int *argcPtr, Arg **argsPtr, LangFreeProc **));
EXTERN char *		Tcl_TildeSubst _ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, Tcl_DString *bufferPtr));
EXTERN int		Tcl_TraceVar _ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData));
EXTERN int		Tcl_TraceVar2 _ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData));
EXTERN void		Tcl_UnlinkVar _ANSI_ARGS_((Tcl_Interp *interp,
			    char *varName));
EXTERN void		Tcl_UntraceVar _ANSI_ARGS_((Tcl_Interp *interp,
			    Var varName, int flags, Tcl_VarTraceProc *proc,
			    ClientData clientData));
EXTERN void		Tcl_UntraceVar2 _ANSI_ARGS_((Tcl_Interp *interp,
			    Var part1, char *part2, int flags,
			    Tcl_VarTraceProc *proc, ClientData clientData));

EXTERN void		Tcl_AppendResult _ANSI_ARGS_((Tcl_Interp *interp,...));

#define Tcl_GlobalEval(interp,cmd) LangEval(interp,cmd,1)
EXTERN int LangEval _ANSI_ARGS_((Tcl_Interp *interp, char *cmd, int global));

EXTERN char *LangString _ANSI_ARGS_((Arg));
EXTERN void LangSetString _ANSI_ARGS_((Arg *,char *));
EXTERN void LangSetDefault _ANSI_ARGS_((Arg *,char *));
EXTERN void LangSetInt _ANSI_ARGS_((Arg *,int));
EXTERN void LangSetDouble _ANSI_ARGS_((Arg *,double));
EXTERN void LangSetArg _ANSI_ARGS_((Arg *,Arg));
EXTERN Arg  LangStringArg _ANSI_ARGS_((char *));
EXTERN int  LangCmpArg  _ANSI_ARGS_((Arg,Arg));
EXTERN int  LangCmpOpt  _ANSI_ARGS_((char *opt,char *arg,size_t length));

/* FIXME:
   Tk will set freeProc as for Tcl e.g. NULL for statics & UIDs
   and to "free" for Tcl_Merge etc.
   Non Tk users *may* be able to use it as a guide,
   but it is more likely that they will have to use 
   their own ref counts.
   Perhaps Tcl_Merge should set freeProc and/or Tcl's 
   LangSetString() deliberately malloc() a copy of the string so we don't need
   the freeProc 
*/
EXTERN void LangFreeArg _ANSI_ARGS_((Arg,Tcl_FreeProc *freeProc));
EXTERN Arg  LangCopyArg _ANSI_ARGS_((Arg));

EXTERN void LangRestoreResult _ANSI_ARGS_((Tcl_Interp **,LangResultSave *));
EXTERN LangResultSave *LangSaveResult _ANSI_ARGS_((Tcl_Interp **));

EXTERN Arg *LangAllocVec _ANSI_ARGS_((int count));
EXTERN void LangFreeVec _ANSI_ARGS_((int,Arg *));

EXTERN void Tcl_SprintfResult _ANSI_ARGS_((Tcl_Interp *,char *,...));
EXTERN char *Tcl_GetResult _ANSI_ARGS_((Tcl_Interp *));
EXTERN void Tcl_Panic _ANSI_ARGS_((char *,...));
#define panic Tcl_Panic

EXTERN LangCallback *LangMakeCallback _ANSI_ARGS_((Arg));
EXTERN Arg LangCallbackArg _ANSI_ARGS_((LangCallback *));
EXTERN void LangFreeCallback _ANSI_ARGS_((LangCallback *));
EXTERN int LangDoCallback _ANSI_ARGS_((Tcl_Interp *,LangCallback *,int result,int argc,...));
EXTERN int LangMethodCall _ANSI_ARGS_((Tcl_Interp *,Arg,char *,int result,int argc,...));

EXTERN int  LangNull _ANSI_ARGS_((Arg));

/* Used to default Menu variable to the label 
   TCL just strdup's the string so it can be ckfree'ed
*/

EXTERN int  LangStringMatch _ANSI_ARGS_((char *string, Arg match));

EXTERN void LangExit _ANSI_ARGS_((int));

EXTERN void		Tcl_DStringGetResult _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_DString *dsPtr));
EXTERN void		Tcl_DStringSetLength _ANSI_ARGS_((Tcl_DString *dsPtr,
			    int length));

EXTERN Tcl_RegExp	Lang_RegExpCompile _ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int fold));
EXTERN int		Lang_RegExpExec _ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_RegExp regexp, char *string, char *start));
EXTERN void		Tcl_RegExpRange _ANSI_ARGS_((Tcl_RegExp regexp,
			    int index, char **startPtr, char **endPtr));

EXTERN void Lang_SetErrorCode _ANSI_ARGS_((Tcl_Interp *interp,char *code));
EXTERN char *Lang_GetErrorCode _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN char *Lang_GetErrorInfo _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN void LangCloseHandler _ANSI_ARGS_((Tcl_Interp *interp,Arg arg,FILE *f,Lang_FileCloseProc *proc));

EXTERN int LangSaveVar _ANSI_ARGS_((Tcl_Interp *,Arg,Var *,int type));
EXTERN void LangFreeVar _ANSI_ARGS_((Var));
EXTERN Arg LangVarArg _ANSI_ARGS_((Var));
EXTERN Arg Tcl_ResultArg _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN int LangCmpCallback _ANSI_ARGS_((LangCallback *a,Arg b));

EXTERN LangCallback *LangCopyCallback _ANSI_ARGS_((LangCallback *));
EXTERN int LangEventCallback _ANSI_ARGS_((Tcl_Interp *,LangCallback *,XEvent *,KeySym));

EXTERN int LangEventHook _ANSI_ARGS_((int flags));
EXTERN void LangBadFile  _ANSI_ARGS_((int fd));
EXTERN void Lang_BuildInImages _ANSI_ARGS_((void));
EXTERN void Lang_FreeRegExp _ANSI_ARGS_((Tcl_RegExp regexp));
EXTERN int TkReadDataPending _ANSI_ARGS_((FILE *f));
EXTERN int	TclOpen _ANSI_ARGS_((char *path, int oflag, int mode));
EXTERN int	TclRead _ANSI_ARGS_((int fd, VOID *buf, size_t numBytes));
EXTERN int	TclWrite _ANSI_ARGS_((int fd, VOID *buf, size_t numBytes));

EXTERN void Lang_DeleteObject _ANSI_ARGS_((Tcl_Interp *,Tcl_Command));
EXTERN Tcl_Command	Lang_CreateObject _ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc));

EXTERN char *LangLibraryDir _ANSI_ARGS_((void));
#define TK_LIBRARY LangLibraryDir()

#endif /* _LANG */
