/*
 * tixInit.c --
 *
 *	Initialze the internals of Tix.
 */
#include "tkPort.h"
#include "tkInt.h"
#include <tixInt.h>
#include "patchlevel.h"

extern TIX_DECLARE_CMD(Tix_CallMethodCmd);
extern TIX_DECLARE_CMD(Tix_ChainMethodCmd);
extern TIX_DECLARE_CMD(Tix_ClassCmd);
extern TIX_DECLARE_CMD(Tix_DoWhenIdleCmd);
extern TIX_DECLARE_CMD(Tix_DoWhenMappedCmd);
extern TIX_DECLARE_CMD(Tix_FileCmd);
extern TIX_DECLARE_CMD(Tix_FlushXCmd);
extern TIX_DECLARE_CMD(Tix_FormCmd);
extern TIX_DECLARE_CMD(Tix_HListCmd);
extern TIX_DECLARE_CMD(Tix_ItemStyleCmd);
extern TIX_DECLARE_CMD(Tix_GeometryRequestCmd);
extern TIX_DECLARE_CMD(Tix_Get3DBorderCmd);
extern TIX_DECLARE_CMD(Tix_GetBooleanCmd);
extern TIX_DECLARE_CMD(Tix_GetIntCmd);
extern TIX_DECLARE_CMD(Tix_GetMethodCmd);
extern TIX_DECLARE_CMD(Tix_HandleOptionsCmd);
extern TIX_DECLARE_CMD(Tix_InputOnlyCmd);
extern TIX_DECLARE_CMD(Tix_ManageGeometryCmd);
extern TIX_DECLARE_CMD(Tix_MapWindowCmd);
extern TIX_DECLARE_CMD(Tix_MoveResizeWindowCmd);
extern TIX_DECLARE_CMD(Tix_NoteBookFrameCmd);
extern TIX_DECLARE_CMD(Tix_RaiseWindowCmd);
extern TIX_DECLARE_CMD(Tix_ShellInputCmd);
extern TIX_DECLARE_CMD(Tix_TListCmd);
extern TIX_DECLARE_CMD(Tix_TmpLineCmd);
extern TIX_DECLARE_CMD(Tix_UnmapWindowCmd);

#ifdef TIX_USE_PATCHES
extern TIX_DECLARE_CMD(Tix_MwmCmd);
#endif


static Tix_TclCmd commands[] = {
    /*
     * Commands that are part of the intrinsics:
     */
    {"tixCallMethod",           Tix_CallMethodCmd},
    {"tixChainMethod",          Tix_ChainMethodCmd},
    {"tixClass",                Tix_ClassCmd},
    {"tixDisplayStyle",         Tix_ItemStyleCmd},
    {"tixDoWhenIdle",           Tix_DoWhenIdleCmd},
    {"tixDoWhenMapped",         Tix_DoWhenMappedCmd},
    {"tixFile",                 Tix_FileCmd},
    {"tixFlushX",           	Tix_FlushXCmd},
    {"tixForm",                 Tix_FormCmd},
    {"tixHList",                Tix_HListCmd},
    {"tixItemStyle",            Tix_ItemStyleCmd},	/* Old name */
    {"tixGeometryRequest",      Tix_GeometryRequestCmd},
    {"tixGet3DBorder",		Tix_Get3DBorderCmd},
    {"tixGetBoolean",		Tix_GetBooleanCmd},
    {"tixGetInt",		Tix_GetIntCmd},
    {"tixGetMethod",            Tix_GetMethodCmd},
    {"tixHandleOptions",        Tix_HandleOptionsCmd},
    {"tixInputOnly",		Tix_InputOnlyCmd},
    {"tixManageGeometry",       Tix_ManageGeometryCmd},
    {"tixMapWindow",            Tix_MapWindowCmd},
    {"tixMoveResizeWindow",     Tix_MoveResizeWindowCmd},
    {"tixNoteBookFrame",        Tix_NoteBookFrameCmd},
    {"tixRaiseWindow",          Tix_RaiseWindowCmd},
    {"tixShellInput",           Tix_ShellInputCmd},
#if 0
    {"tixTList",                Tix_TListCmd},
#endif
    {"tixTmpLine",              Tix_TmpLineCmd},
    {"tixUnmapWindow",          Tix_UnmapWindowCmd},
    {"tixWidgetClass",          Tix_ClassCmd},
    {"tixWidgetDoWhenIdle",     Tix_DoWhenIdleCmd},

    /*
     * Extended TK Widgets
     */
#ifdef TIX_USE_PATCHES
    {"tixMwm",     		Tix_MwmCmd},
#if 0
    /* Removed tkWm.c from the patches */
    {"wm",			Tk_WmCmd},
#endif
#endif

    {(char *) NULL,		(int (*)()) NULL}
};

typedef struct {
    int		isBeta;
    char      * binding;
    int		isDebug;
    char      * fontSet;
    char      * tixlibrary;
    char      * scheme;
} OptionStruct;

static OptionStruct tixOption;

static Tk_ArgvInfo argTable[] = {
    {"-beta", TK_ARGV_CONSTANT, (char *) 1, (char*) &tixOption.isBeta,
       "Specifies whether to use the BETA widgets"},
    {"-binding", TK_ARGV_STRING, (char *) NULL, (char *) &tixOption.binding,
       "Event binding to use for application"},
    {"-debug", TK_ARGV_CONSTANT, (char *) 1, (char*) &tixOption.isDebug,
       "Specifies whether to run Tix in DEBUG mode"},
    {"-fontset", TK_ARGV_STRING, (char *) NULL, (char *) &tixOption.fontSet,
       "Font-set to use for application"},
    {"-tixlibrary", TK_ARGV_STRING, (char *)NULL, (char*)&tixOption.tixlibrary,
       "Alternate directory of the Tix library"},
    {"-scheme", TK_ARGV_STRING, (char *) NULL, (char *) &tixOption.scheme,
       "Color scheme to use for application"},
    {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,
	(char *) NULL}
};

#define DEF_TIX_TOOLKIT_OPTION_BETA	"1"
#define DEF_TIX_TOOLKIT_OPTION_BINDING	"Motif"
#define DEF_TIX_TOOLKIT_OPTION_DEBUG	"1"
#define DEF_TIX_TOOLKIT_OPTION_FONTSET	"14Point"
#define DEF_TIX_TOOLKIT_OPTION_LIBRARY	""
#define DEF_TIX_TOOLKIT_OPTION_SCHEME	"TixGray"

static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_BOOLEAN, "-beta", "tixBeta", "TixBeta",
       DEF_TIX_TOOLKIT_OPTION_BETA, Tk_Offset(OptionStruct, isBeta), 0},
    {TK_CONFIG_STRING, "-binding", "binding", "TixBinding",
       DEF_TIX_TOOLKIT_OPTION_BINDING, Tk_Offset(OptionStruct, binding),
       0},
    {TK_CONFIG_BOOLEAN, "-debug", "tixDebug", "TixDebug",
       DEF_TIX_TOOLKIT_OPTION_DEBUG, Tk_Offset(OptionStruct, isDebug), 0},
    {TK_CONFIG_STRING, "-fontset", "tixFontSet", "TixFontSet",
       DEF_TIX_TOOLKIT_OPTION_FONTSET, Tk_Offset(OptionStruct, fontSet),
       0},
    {TK_CONFIG_STRING, "-scheme", "tixScheme", "TixScheme",
       DEF_TIX_TOOLKIT_OPTION_SCHEME, Tk_Offset(OptionStruct, scheme),
       0},
    {TK_CONFIG_STRING, "-tixlibrary", "tixLibrary", "TixLibrary",
       DEF_TIX_TOOLKIT_OPTION_LIBRARY, Tk_Offset(OptionStruct, tixlibrary),
       0},
    {TK_CONFIG_END, (char *) NULL, (char *) NULL, (char *) NULL,
       (char *) NULL, 0, 0}
};

#ifndef TIX_LIBRARY
#define TIX_LIBRARY "/usr/local/lib/tix"
#endif

extern Tix_DItemInfo tix_ImageTextType;
extern Tix_DItemInfo tix_TextItemType;
extern Tix_DItemInfo tix_WindowItemType;

static int
ParseArgv(interp, argcPtr, argv)
    Tcl_Interp * interp;
    int * argcPtr;
    char ** argv;
{
    char buff[10];
    int flag;

#if 0
    int oldArgc;
    if (argcPtr) {
	oldArgc = *argcPtr;
    }
#endif

    tixOption.isBeta = 0;
    tixOption.binding = NULL;
    tixOption.isDebug = 0;
    tixOption.fontSet = NULL;
    tixOption.tixlibrary = NULL;
    tixOption.scheme = NULL;

    /*
     * The toolkit options may be set in the resources of the main window
     */
    if (Tk_ConfigureWidget(interp, Tk_MainWindow(interp), configSpecs,
	    0, 0, (char *) &tixOption, 0) != TCL_OK) {
	return TCL_ERROR;
    }

#if 0
    /*
     * Parse command-line arguments.
     */
    if (argcPtr && argv) {
	if (Tk_ParseArgv(interp, (Tk_Window) NULL, argcPtr, argv, argTable, 0)
	        != TCL_OK) {
	    fprintf(stderr, "%s\n", interp->result);
	    exit(1);
	}
    }

    if (argcPtr && (oldArgc != *argcPtr)) {
	/*
	 * argc was changes, let's modify the TCL variable "argv"
	 */
	Tix_SetArgv(interp, *argcPtr, argv);
    }
#endif

    /*
     * Now lets set the Tix toolkit variables so that the Toolkit can
     * initialize according to user options.
     */
    flag = TCL_GLOBAL_ONLY;
    sprintf(buff, "%d", tixOption.isBeta);
    Tcl_SetVar2(interp, "tix_priv", "-beta", buff, flag);
    sprintf(buff, "%d", tixOption.isDebug);
    Tcl_SetVar2(interp, "tix_priv", "-debug", buff, flag);

    if (strlen(tixOption.tixlibrary) == 0) {
	/* Set up the TCL variable "tix_library" according to the environment
	 * variable.
	 */
	 tixOption.tixlibrary= getenv("TIX_LIBRARY");
	 if (tixOption.tixlibrary == NULL) {
	     tixOption.tixlibrary = TIX_LIBRARY;
	 }
     }

    Tcl_SetVar2(interp, "tix_priv", "-binding", tixOption.binding,    flag);
    Tcl_SetVar2(interp, "tix_priv", "-fontset", tixOption.fontSet,    flag);
    Tcl_SetVar2(interp, "tix_priv", "-scheme",  tixOption.scheme,     flag);
    Tcl_SetVar2(interp, "tix_priv", "-libdir",  tixOption.tixlibrary, flag);

    return TCL_OK;
}

/* Initialize the Tix toolkit
 *
 * Will change the argc and argv of the caller function.
 */
int Tix_Init_Internal(interp, argcPtr, argv, doSource)
    Tcl_Interp * interp;
    int * argcPtr;
    char ** argv;
    int doSource;
{
    Tk_Window topLevel;
    char * appName;

#ifdef USE_XPM_READER
    extern Tk_ImageType tixPixmapImageType;
#endif
    extern Tk_ImageType tixCompoundImageType;

    topLevel = Tk_MainWindow(interp);

    /* Set the "tix_version" variable */
    Tcl_SetVar(interp, "tix_version",    TIX_VERSION,    TCL_GLOBAL_ONLY);
    Tcl_SetVar(interp, "tix_patchLevel", TIX_PATCHLEVEL, TCL_GLOBAL_ONLY);

    /* Initialize the Tix commands */
    Tix_CreateCommands(interp, commands, (ClientData) topLevel,
	(void (*)()) NULL);

#ifdef USE_XPM_READER
    /* Initialize the image readers */
    Tk_CreateImageType(&tixPixmapImageType);
#endif
    Tk_CreateImageType(&tixCompoundImageType);

    /* Initialize the display item types */
    Tix_AddDItemType(&tix_ImageTextType);
    Tix_AddDItemType(&tix_TextItemType);
    Tix_AddDItemType(&tix_WindowItemType);

    /* Parse the command line arguments for fontSets, schemes, etc */
    if (ParseArgv(interp, argcPtr, argv) == TCL_ERROR) {
	return TCL_ERROR;
    }

    if ((appName = Tcl_GetVar(interp, "argv0", TCL_GLOBAL_ONLY))== NULL) {
	appName = "tixwish";
    }

    if (doSource) {
	/* Load the Tix library */
	if (Tix_LoadTclLibrary(interp, "TIX_LIBRARY", "tix_library", 
	    "Init.tcl",	TIX_LIBRARY, appName) != TCL_OK) {
	    return TCL_ERROR;
	} else {
	    return TCL_OK;
	}
    } else {
	Tcl_SetVar(interp, "tix_library", "nowhere", TCL_GLOBAL_ONLY);
	return TCL_OK;
    }
}

#if 0
int
HackXX(clientData, mask, flags)
    ClientData clientData;	/* Pointer to Xlib Display structure
				 * for display. */
    int mask;			/* OR-ed combination of the bits TK_READABLE,
				 * TK_WRITABLE, and TK_EXCEPTION, indicating
				 * current state of file. */
    int flags;			/* Flag bits passed to Tk_DoOneEvent;
				 * contains bits such as TK_DONT_WAIT,
				 * TK_X_EVENTS, Tk_FILE_EVENTS, etc. */
{

    fprintf(stderr, "hello\n");
    return 0;
}

void Hack(interp)
    Tcl_Interp * interp;
{
    Tk_Window tkwin = Tk_MainWindow(interp);
    Display * display = Tk_Display(tkwin);

    Tk_CreateFileHandler2(ConnectionNumber(display), HackXX,
	(ClientData)display);
}

#endif

/* Tix_Init --
 *
 * 	This is the function to call in your Tcl_AppInit() function
 */
int Tix_Init(interp)
    Tcl_Interp * interp;
{
#if 0
    Hack(interp);
#endif
    return Tix_Init_Internal(interp, (int*)NULL, (char**)NULL, 1);
}

/* Tix_EtInit --
 *
 * 	This takes special care when you initialize the Tix
 *	library from an ET application.
 */
int Tix_EtInit(interp)
    Tcl_Interp * interp;
{
    return Tix_Init_Internal(interp, (int*)NULL, (char**)NULL, 0);
}


/*----------------------------------------------------------------------
 * ToDo : should move to a tixCompat.c file
 *
 * Some compatibility junk
 *
 *----------------------------------------------------------------------
 */
#ifdef NO_STRDUP

/* strdup not a POSIX call */

char * tixStrDup(char * s)
{
    size_t len = strlen(s)+1;
    char * new_string;

    new_string = (char*)ckalloc(len);
    strcpy(new_string, s);

    return new_string;
}

#endif /* NO_STRDUP */
