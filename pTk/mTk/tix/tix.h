/*
 * tix.h
 *
 *	This is the standard header file for all tix C code. It defines
 * many macros and utility functions to make it easier to write TCL commands
 * and TK widgets in C. No more needs to write 2000 line functions!
 *
 *
 */

#ifndef _TIX
#include "tkVMacro.h"
#define  _TIX


#define TIX_STDIN_ALWAYS	0
#define TIX_STDIN_OPTIONAL	1
#define TIX_STDIN_NONE		2

typedef struct {
    char *name;			/* Name of command. */
    int (*cmdProc) _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp,
				int argc, char **argv));
				/* Command procedure. */
} Tix_TclCmd;


/*----------------------------------------------------------------------
 *
 *
 * 			SUB-COMMAND HANDLING
 *
 *
 *----------------------------------------------------------------------
 */
typedef int (*Tix_SubCmdProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char ** argv));
typedef int (*Tix_CheckArgvProc) _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char ** argv));

typedef struct _Tix_CmdInfo {
    int		numSubCmds;
    int		minargc;
    int		maxargc;
    char      * info;
} Tix_CmdInfo;


typedef struct _Tix_SubCmdInfo {
    int			namelen;
    char      	      * name;
    int			minargc;
    int			maxargc;
    Tix_SubCmdProc 	proc;
    char      	      * info;
    Tix_CheckArgvProc   checkArgvProc;
} Tix_SubCmdInfo;

/*
 * Tix_ArraySize --
 *
 *	Find out the number of elements inside a C array. The argument "x"
 * must be a valid C array. Pointers don't work.
 */
#define Tix_ArraySize(x) (sizeof(x) / sizeof(x[0]))

/*
 * This is used for Tix_CmdInfo.maxargc and Tix_SubCmdInfo.maxargc,
 * indicating that this command takes a variable number of arguments.
 */
#define TIX_VAR_ARGS	       -1

/* TIX_DEFAULT_LEN --
 *
 * Use this for Tix_SubCmdInfo.namelen and Tix_ExecSubCmds() will try to
 * determine the length of the subcommand name for you.
 */
#define TIX_DEFAULT_LEN	       -1

/* TIX_DEFAULT_SUB_CMD --
 *
 * Use this for Tix_SubCmdInfo.name. This will match any subcommand name,
 * including the empty string, when Tix_ExecSubCmds() finds a subcommand
 * to execute.
 */
#define TIX_DEFAULT_SUBCMD	0

/* TIX_DECLARE_CMD --
 *
 * This is just a handy macro to declare a C function to use as a
 * command function.
 */
#define TIX_DECLARE_CMD(func) \
    int func _ANSI_ARGS_((ClientData clientData,\
	Tcl_Interp *interp, int argc, char ** argv))

/* TIX_DECLARE_SUBCMD --
 *
 * This is just a handy macro to declare a C function to use as a
 * sub command function.
 */
#define TIX_DECLARE_SUBCMD(func) \
    int func _ANSI_ARGS_((ClientData clientData,\
	Tcl_Interp *interp, int argc, char ** argv))

/* TIX_DEFINE_CMD --
 *
 * This is just a handy macro to define a C function to use as a
 * command function.
 */
#define TIX_DEFINE_CMD(func) \
int func(clientData, interp, argc, argv) \
    ClientData clientData;	/* Main window associated with 	\
				 * interpreter. */		\
    Tcl_Interp *interp;		/* Current interpreter. */	\
    int argc;			/* Number of arguments. */	\
    char **argv;		/* Argument strings. */

/*----------------------------------------------------------------------
 *
 *
 * 		    MEGA-WIDGET CONFIG HANDLING
 *
 *
 *----------------------------------------------------------------------
 */
typedef struct _TixConfigSpec  	  	TixConfigSpec;
typedef struct _TixConfigAlias		TixConfigAlias;
typedef struct _TixClassRecord		TixClassRecord;

struct _TixConfigSpec {
    unsigned int isAlias	: 1;
    unsigned int readOnly	: 1;
    unsigned int isStatic	: 1;
    unsigned int forceCall	: 1;

    char * argvName;
    char * defValue;

    char * dbName;		/* The additional parts of a */
    char * dbClass;		/* TixWidgetConfigSpec structure */

    char *verifyCmd;

    TixConfigSpec * realPtr;	/* valid only if this option is an alias */
};

struct _TixClassRecord {
    TixClassRecord    * superClass;

    unsigned int	isWidget;
    char	      * className;	/* Instiantiation command */
    char	      * ClassName;	/* used in TK option database */

    int			nSpecs;
    TixConfigSpec    ** specs;
    int			nMethods;
    char	     ** methods;
    char	     ** defaults;
    Tk_Window		mainWindow;
};

/*----------------------------------------------------------------------
 *
 *
 * 		    LIST HADLING
 *
 *
 *----------------------------------------------------------------------
 */
typedef struct Tix_ListInfo {
    int nextOffset;		/* offset of the "next" pointer in a list
				 * item */
    int prevOffset;		/* offset of the "next" pointer in a list
				 * item */
} Tix_ListInfo;


/* Singly-linked list */
typedef struct Tix_LinkList {
    int numItems;		/* number of items in this list */
    char * head;		/* (general pointer) head of the list */
    char * tail;		/* (general pointer) tail of the list */
} Tix_LinkList;

typedef struct Tix_ListIterator {
    char * last;
    char * curr;
    unsigned int started : 1;   /* True if the search operation has
				 * already started for this list */
    unsigned int deleted : 1;	/* True if a delete operation has been
				 * performed on the current item (in this
				 * case the curr pointer has already been
				 * adjusted
				 */
} Tix_ListIterator;

#define Tix_IsLinkListEmpty(list)  ((list.numItems) == 0)
#define TIX_UNIQUE 1
#define TIX_UNDEFINED -1

EXTERN TIX_DECLARE_CMD(Tix_InputOnlyCmd);
EXTERN TIX_DECLARE_CMD(Tix_MwmCmd);
EXTERN TIX_DECLARE_CMD(Tix_NoteBookFrameCmd);

EXTERN void 		Tix_LinkListInit _ANSI_ARGS_((Tix_LinkList * lPtr));
EXTERN void		Tix_LinkListAppend _ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr, int flags));
EXTERN void		Tix_LinkListStart _ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr));
EXTERN void		Tix_LinkListNext _ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr));
EXTERN void		Tix_LinkListDelete _ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr));
EXTERN int		Tix_LinkListDeleteRange _ANSI_ARGS_((
			    Tix_ListInfo * infoPtr, Tix_LinkList * lPtr,
			    char * fromPtr, char * toPtr,
			    Tix_ListIterator * liPtr));
EXTERN int		Tix_LinkListFind _ANSI_ARGS_((
			    Tix_ListInfo * infoPtr, Tix_LinkList * lPtr,
			    char * itemPtr, Tix_ListIterator * liPtr));
EXTERN int		Tix_LinkListDeleteRange _ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * fromPtr,
			    char * toPtr, Tix_ListIterator * liPtr));
EXTERN void		Tix_LinkListInsert _ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr,
			    Tix_ListIterator * liPtr));
EXTERN void		Tix_LinkListIteratorInit _ANSI_ARGS_((Tix_ListIterator *liPtr));

#define Tix_LinkListDone(liPtr) ((liPtr)->curr == NULL)

/*----------------------------------------------------------------------
 *
 *
 *
 *  			CUSTOM CONFIG OPTIONS
 *
 *
 *----------------------------------------------------------------------
 */
#define TIX_RELIEF_RAISED	1
#define TIX_RELIEF_FLAT		2
#define TIX_RELIEF_SUNKEN	4
#define TIX_RELIEF_GROOVE	8
#define TIX_RELIEF_RIDGE	16
#define TIX_RELIEF_SOLID	32

typedef int Tix_Relief;

EXTERN Tk_CustomOption tixConfigItemType;
EXTERN Tk_CustomOption tixConfigItemStyle;
EXTERN Tk_CustomOption tixConfigRelief;


/************************/
/*     tixInit.c	*/
/************************/

EXTERN int		Tix_AppInit _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN int 		Tix_CallMethod _ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *widRec, char *method,
			    int argc, char **argv));
EXTERN int		Tix_ChangeOneOption _ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord *cPtr,
			    char * widRec, TixConfigSpec *spec, char * value,
			    int isDefault, int isInit));
EXTERN void		Tix_CreateCommands _ANSI_ARGS_((
			    Tcl_Interp *interp, Tix_TclCmd *commands,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc));
EXTERN void 		Tk_Draw3DArc _ANSI_ARGS_((Display *display,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int angle1,
			    int angle2, int borderWidth, int relief));
EXTERN int 		Tix_ExistMethod _ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *method));
EXTERN void		Tix_Exit _ANSI_ARGS_((Tcl_Interp * interp, int code));
EXTERN TixConfigSpec * 	Tix_FindConfigSpecByName _ANSI_ARGS_((
			    Tcl_Interp * interp,
			    TixClassRecord * cPtr, char * name));
EXTERN char  * 		Tix_FindMethod _ANSI_ARGS_((Tcl_Interp *interp,
			    char *context, char *method));
EXTERN char * 		Tix_FindPublicMethod _ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord * cPtr, 
			    char * method));
EXTERN TixClassRecord *	Tix_GetClassByName _ANSI_ARGS_((
			    Tcl_Interp * interp, char * classRec));
EXTERN char  * 		Tix_GetConfigSpecFullName _ANSI_ARGS_((char *clasRec,
			    char *flag));
EXTERN char  * 		Tix_GetContext _ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec));
EXTERN char  * 		Tix_GetMethodFullName _ANSI_ARGS_((char *context,
			    char *method));
EXTERN void 		Tix_GetPublicMethods _ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec, int *numMethods,
			    char *** validMethods));
EXTERN void		Tix_GetScrollFractions _ANSI_ARGS_((int total,
			    int window, int first,
			    double * first_ret, double * last_ret));
EXTERN int		Tix_GetWidgetOption _ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin,
			    char *argvName, char *dbName, char *dbClass,
			    char *defValue, int argc, char **argv,
			    int type, char *ptr));
EXTERN int		Tix_HandleSubCmds _ANSI_ARGS_((
			    Tix_CmdInfo * cmdInfo,
			    Tix_SubCmdInfo * subCmdInfo,
			    ClientData clientData, Tcl_Interp *interp,
			    int argc, char **argv));
EXTERN int 		Tix_Init _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN int		Tix_LoadTclLibrary _ANSI_ARGS_((
			    Tcl_Interp *interp, char *envName,
			    char *tclName, char *initFile,
			    char *defDir, char * appName));
EXTERN void 		Tix_MainLoop _ANSI_ARGS_((Tcl_Interp * interp));

EXTERN void 		Tix_OpenStdin _ANSI_ARGS_(());

EXTERN void		Tix_RestoreContext _ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec, char *oldContext));
EXTERN char  * 		Tix_SaveContext _ANSI_ARGS_((Tcl_Interp *interp,
			    char *widRec));
EXTERN void 		Tix_SetArgv _ANSI_ARGS_((Tcl_Interp *interp, 
			    int argc, char **argv));
EXTERN int 		Tix_SuperClass _ANSI_ARGS_((Tcl_Interp *interp,
			    char *widClass, char ** superClass_ret));
EXTERN int		Tix_SysInit _ANSI_ARGS_((Tcl_Interp *interp,
			    int *argcPtr, char **argv));
EXTERN int		Tix_UnknownPublicMethodError _ANSI_ARGS_((
			    Tcl_Interp *interp, TixClassRecord * cPtr,
			    char * widRec, char * method));
EXTERN int		Tix_ValueMissingError _ANSI_ARGS_((Tcl_Interp *interp,
			    char *spec));
EXTERN Tcl_Interp *	Tix_WishInit _ANSI_ARGS_((int *argcPtr, char **argv,
			    char * rcFileName, int readStdin));

#define SET_RECORD(interp, record, var, value) \
	Tcl_SetVar2(interp, record, var, value, TCL_GLOBAL_ONLY)

#define GET_RECORD(interp, record, var) \
	Tcl_GetVar2(interp, record, var, TCL_GLOBAL_ONLY)

/*----------------------------------------------------------------------
 * Internal !!
 *---------------------------------------------------------------------- 
 */
EXTERN Tcl_HashTable specTable;

#define FLAG_READONLY	0
#define FLAG_STATIC	1
#define FLAG_FORCECALL	2

/*----------------------------------------------------------------------
 * Compatibility section
 *----------------------------------------------------------------------	*/


#endif /* _TIX */
