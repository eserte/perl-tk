#include <tkPort.h>
#include <tkInt.h>
#include <tix.h>
#include <math.h>

/*
 * Maximum intensity for a color:
 */

#define MAX_INTENSITY 65535


/*
 * Global vars
 */
static Tcl_HashTable idleTable;		/* hash table for TixDoWhenIdle */
static Tcl_HashTable mapEventTable;	/* hash table for TixDoWhenMapped */

static int IsOption(option, optArgc, optArgv)
    char *option;		/* Number of arguments. */ 
    int optArgc;		/* Number of arguments. */
    char **optArgv;		/* Argument strings. */
{
    int i;

    for (i=0; i<optArgc; i++) {
	if (strcmp(option, optArgv[i]) == 0) {
	    return 1;
	}
    }
    return 0;
}


/*
 * Tix_HandleOptionsCmd
 *
 * 
 * argv[1] = recordName
 * argv[2] = validOptions
 * argv[3] = argList
 *           if (argv[3][0] == "-nounknown") then 
 * 		don't complain about unknown options
 *
 */
TIX_DEFINE_CMD(Tix_HandleOptionsCmd)
{
    int		listArgc;
    int		optArgc;
    char     ** listArgv = 0;
    char     ** optArgv  = 0;
    int		i, code = TCL_OK;
    int		noUnknown = 0;

    if (argc >= 2 && (strcmp(argv[1], "-nounknown") == 0)) {
	noUnknown = 1;
	argv[1] = argv[0];
	argc --;
	argv ++;
    }

    if (argc!=4) {
	return Tix_ArgcError(interp, argc, argv, 2, "w validOptions argList");
    }

    if (Tcl_SplitList(interp, argv[2], &optArgc,  &optArgv ) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }
    if (Tcl_SplitList(interp, argv[3], &listArgc, &listArgv) != TCL_OK) {
	code = TCL_ERROR;	
	goto done;
    }

    if ((listArgc %2) == 1) {
	if (noUnknown || IsOption(listArgv[listArgc-1], optArgc, optArgv)) {
	    Tcl_AppendResult(interp, "value for \"", listArgv[listArgc-1],
		"\" missing", (char*)NULL);
	} else {
	    Tcl_AppendResult(interp, "unknown option \"", listArgv[listArgc-1],
		"\"", (char*)NULL);
	}
	code = TCL_ERROR;
	goto done;
    }
    for (i=0; i<listArgc; i+=2) {
	if (IsOption(listArgv[i], optArgc, optArgv)) {
	    Tcl_SetVar2(interp, argv[1], listArgv[i], listArgv[i+1], 0);
	}
	else if (!noUnknown) {
	    Tcl_AppendResult(interp, "unknown option \"", listArgv[i],
		"\"; must be one of \"", argv[2], "\".", NULL);
	    code = TCL_ERROR;
	    goto done;
	}
    }

  done:

    if (listArgv) {
	ckfree((char *) listArgv);
    }
    if (optArgv) {
	ckfree((char *) optArgv);
    }

    return code;
}

/*----------------------------------------------------------------------
 * Tix_TmpLineCmd
 *
 * 	Draw a temporary line on the root window
 *
 * argv[1..] = x1 y1 x2 y2
 */
TIX_DEFINE_CMD(Tix_TmpLineCmd)
{
    static GC gc = None;
    static Window root;
    static Tk_Window topLevel;

    if (argc != 5) {
	return Tix_ArgcError(interp, argc, argv, 0, "tixTmpLine x1 y1 x2 y2");
    }

    if (gc == None) {		/* uninitialized */
	XGCValues values;
	unsigned long valuemask = GCForeground | GCBackground 
	  | GCSubwindowMode | GCFunction | GCLineStyle;

	if (!(topLevel = Tk_MainWindow(interp))) {
	    return TCL_ERROR;
	}
	root = XRootWindow(Tk_Display(topLevel), Tk_ScreenNumber(topLevel));

	values.line_style     = LineDoubleDash;
#if 0
	values.background     = BlackPixelOfScreen(Tk_Screen(topLevel));
	values.foreground     = WhitePixelOfScreen(Tk_Screen(topLevel));
#else
	values.background     = 0x0a;
	values.foreground     = 0x05;
#endif
	values.subwindow_mode = IncludeInferiors;
	values.function       = GXxor;

	gc = XCreateGC(Tk_Display(topLevel), root, valuemask, &values);
    }		     

    XDrawLine(Tk_Display(topLevel), root, gc,
	atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4]));

    return TCL_OK;
}

static XColor * ScaleColor(tkwin, color, scale)
    Tk_Window tkwin;
    XColor * color;
    float scale;
{
    XColor test;

    test.red   = (int)((float)(color->red)   * scale);
    test.green = (int)((float)(color->green) * scale);
    test.blue  = (int)((float)(color->blue)  * scale);
    if (test.red > MAX_INTENSITY) {
	test.red = MAX_INTENSITY;
    }
    if (test.green > MAX_INTENSITY) {
	test.green = MAX_INTENSITY;
    }
    if (test.blue > MAX_INTENSITY) {
	test.blue = MAX_INTENSITY;
    }

    return Tk_GetColorByValue(tkwin, &test);
}

static char * NameOfColor(colorPtr)
   XColor * colorPtr;
{
    static char string[20];
    char *ptr;

    sprintf(string, "#%4x%4x%4x", colorPtr->red, colorPtr->green,
	colorPtr->blue);

    for (ptr = string; *ptr; ptr++) {
	if (*ptr == ' ') {
	    *ptr = '0';
	}
    }
    return string;
}

/*----------------------------------------------------------------------
 * Tix_Get3DBorderCmd
 *
 * 	Returns the upper and lower border shades of a color. Returns then
 *	in a list of two X color names.
 *
 *	The color is not very useful if the display is a mono display: it will
 *	just return black and white. So a clever program may want to check
 *	the [tk colormodel] and if it is mono, then dither using a bitmap.
 *
 */
TIX_DEFINE_CMD(Tix_Get3DBorderCmd)
{
    XColor * color, * light, * dark;
    Tk_Window tkwin;
    Tk_Uid colorUID;

    if (argc != 2) {
	return Tix_ArgcError(interp, argc, argv, 0, "colorName");
    }

    tkwin = Tk_MainWindow(interp);

    colorUID = Tk_GetUid(argv[1]);
    color = Tk_GetColor(interp, tkwin, colorUID);
    if (color == NULL) {
	return TCL_ERROR;
    }

    if ((light = ScaleColor(tkwin, color, 1.4)) == NULL) {
	return TCL_ERROR;
    }
    if ((dark  = ScaleColor(tkwin, color, 0.6)) == NULL) {
	return TCL_ERROR;
    }

    Tcl_ResetResult(interp);
    Tcl_AppendElement(interp, NameOfColor(light));
    Tcl_AppendElement(interp, NameOfColor(dark));

    Tk_FreeColor(color);
    Tk_FreeColor(light);
    Tk_FreeColor(dark);

    return TCL_OK;
}

/*----------------------------------------------------------------------
 * Tix_GetBooleanCmd
 *
 * 	Return "1" if is a true boolean number. "0" otherwise
 *
 * argv[1]  = string to test
 */
TIX_DEFINE_CMD(Tix_GetBooleanCmd)
{
    int value;
    int nocomplain = 0;
    char *string;
    static char *results[2] = {"0", "1"};

    if (argc == 3) {
	if (strcmp(argv[1], "-nocomplain") != 0) {
	    goto error;
	}
	nocomplain = 1;
	string = argv[2];
    }
    else if (argc != 2) {
	goto error;
    }
    else {
	string = argv[1];
    }

    if (Tcl_GetBoolean(interp, string, &value) != TCL_OK) {
	if (nocomplain) {
	    value = 0;
	}
	else {
	    return TCL_ERROR;
	}
    }

    Tcl_SetResult(interp, results[value], TCL_STATIC);
    return TCL_OK;

  error:
    return Tix_ArgcError(interp, argc, argv, 1, "?-nocomplain? string");
}

/*----------------------------------------------------------------------
 * Tix_GetIntCmd
 *
 * 	Return "1" if is a true boolean number. "0" otherwise
 *
 * argv[1]  = string to test
 */
TIX_DEFINE_CMD(Tix_GetIntCmd)
{
    int    i;
    int    opTrunc = 0;
    int    opNocomplain = 0;
    int    i_value;
    double f_value;
    char * string = 0;
    char   buff[20];

    for (i=1; i<argc; i++) {
	if (strcmp(argv[i], "-nocomplain") == 0) {
	    opNocomplain = 1;
	}
	else if (strcmp(argv[i], "-trunc") == 0) {
	    opTrunc = 1;
	}
	else {
	    string = argv[i];
	    break;
	}
    }
    if (i != argc-1) {
	return Tix_ArgcError(interp, argc, argv, 1, 
	    "?-nocomplain? ?-trunc? string");
    }

    if (Tcl_GetInt(interp, string, &i_value) == TCL_OK) {
	;
    }
    else if (Tcl_GetDouble(interp, string, &f_value) == TCL_OK) {
#if 0
	/* Some machines don't have the "trunc" function */
	if (opTrunc) {
	    i_value = (int) trunc(f_value);
	}
	else {
	    i_value = (int) f_value;
	}
#else
	i_value = (int) f_value;
#endif
    }
    else if (opNocomplain) {
	i_value = 0;
    }
    else {
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", string, 
	    "\" is not a valid numerical value", NULL);
	return TCL_ERROR;
    }
    
    sprintf(buff, "%d", i_value);
    Tcl_SetResult(interp, buff, TCL_VOLATILE);
    return TCL_OK;
}


/*----------------------------------------------------------------------
 *
 *			"DO WHEN IDLE" UTILITY
 *
 * The difference between "tixDoWhenIdle" and "after" is: the "after"
 * handler is called after all other TK Idel Event Handler are called.
 * Sometimes this will cause some toplevel windows to be mapped
 * before the Idle Event Handler is executed.
 *
 * This behavior of "after" is not suitable for implementing geometry
 * managers. Therefore I wrote "tixDoWhenIdle" which is an exact TCL
 * interface for Tk_DoWhenIdle()
 *----------------------------------------------------------------------
 */

typedef struct {
    Tcl_Interp * interp;
    char       * command;
    char       * widget;
} IdleStruct;

static void IdleHandler(clientData)
    ClientData clientData;	/* TCL command to evaluate */
{
    Tcl_HashEntry     * hashPtr;
    IdleStruct	      * iPtr;
    TkWindow	      * winPtr;
    int			doit;

    iPtr = (IdleStruct *) clientData;

    /* Clean up the hash table. Note that we have to do this BEFORE
     * calling the TCL command. Otherwise if the TCL command tries
     * to register itself again it will fail in Tix_DoWhenIdleCmd()
     * because the command is still in the hashtable
     */
    hashPtr = Tcl_FindHashEntry(&idleTable, iPtr->command);
    if (hashPtr) {
	Tcl_DeleteHashEntry(hashPtr);
    }

    /* If this idle handler is created by "tixWidgetDoWhenIdle"
     * execute it only if the widget exists
     */
    doit = 1;
    if (iPtr->widget != NULL) {
	winPtr = (TkWindow*)Tk_NameToWindow(iPtr->interp, iPtr->widget,
	    Tk_MainWindow(iPtr->interp));
	if (!winPtr || (winPtr->flags &TK_ALREADY_DEAD)) {
	    doit = 0;
	}
	ckfree(iPtr->widget);
    }

    if (doit) {
	if (Tcl_Eval(iPtr->interp, iPtr->command) != TCL_OK) {
	    Tcl_AddErrorInfo(iPtr->interp,
		"\n    (idle event handler executed by tixDoWhenIdle)");
	    Tk_BackgroundError(iPtr->interp);
	}
    }

    /* deallocate the TCL command string */
    ckfree((char*)iPtr->command);
    ckfree((char*)iPtr);
}

/* Tix_DoWhenIdle
 *
 * argv[1..] = command argvs
 *
 */
TIX_DEFINE_CMD(Tix_DoWhenIdleCmd)
{
    int			isNew;
    char       	      * command;
    static int 	        inited = 0;
    IdleStruct	      * iPtr;
    int			isWidget;

    if (strncmp(argv[0], "tixWidgetDoWhenIdle", strlen(argv[0]))== 0) {
	isWidget = 1;
	if (argc<3) {
	    return Tix_ArgcError(interp, argc, argv, 1,
		"command window ?arg arg ...?");
	}
    } else {
	isWidget = 0;
	if (argc<2) {
	    return Tix_ArgcError(interp, argc, argv, 1,
		"command ?arg arg ...?");
	}
    }

    if (!inited) {
	Tcl_InitHashTable(&idleTable, TCL_STRING_KEYS);
	inited = 1;
    }

    command = Tcl_Merge(argc-1, argv+1);

    Tcl_CreateHashEntry(&idleTable, command, &isNew);

    if (!isNew) {
	ckfree(command);
    } else {
	iPtr = (IdleStruct *) ckalloc(sizeof(IdleStruct));
	iPtr->interp  = interp;
	iPtr->command = command;

	/* tixWidgetDoWhenIdle reqires that the second argument must
	 * be the name of a mega widget
	 */
	if (isWidget) {
	    iPtr->widget = (char*)strdup(argv[2]);
	} else {
	    iPtr->widget = NULL;
	}

	Tk_DoWhenIdle(IdleHandler, (ClientData) iPtr);
    }

    return TCL_OK;
}


/*----------------------------------------------------------------------
 *
 *			"DO WHEN MAPPED" UTILITY
 *
 *----------------------------------------------------------------------
 */

typedef struct _MapCmdLink {
    char * command;
    struct _MapCmdLink * next;
} MapCmdLink;

typedef struct {
    Tcl_Interp * interp;
    Tk_Window	 tkwin;
    MapCmdLink * cmds;
} MapEventStruct;

static void MapEventProc(clientData, eventPtr)
    ClientData clientData;	/* TCL command to evaluate */
    XEvent *eventPtr;		/* Information about event. */
{
    Tcl_HashEntry     * hashPtr;
    MapEventStruct    * mPtr;
    MapCmdLink	      * cmd;

    if (eventPtr->type != MapNotify) {
	return;
    }

    mPtr = (MapEventStruct *) clientData;

    Tk_DeleteEventHandler(mPtr->tkwin, StructureNotifyMask,
	MapEventProc, (ClientData)mPtr);

    /* Clean up the hash table.
     */
    if (hashPtr = Tcl_FindHashEntry(&mapEventTable, (char*)mPtr->tkwin)) {
	Tcl_DeleteHashEntry(hashPtr);
    }

    for (cmd = mPtr->cmds; cmd; ) {
	MapCmdLink * old;

	/* Execute the event handler */
	if (Tcl_Eval(mPtr->interp, cmd->command) != TCL_OK) {
	    Tcl_AddErrorInfo(mPtr->interp,
		"\n    (event handler executed by tixDoWhenMapped)");
	    Tk_BackgroundError(mPtr->interp);
	}

	/* Delete the link */
	old = cmd;
	cmd = cmd->next;

	ckfree(old->command);
	ckfree((char*)old);
    }

    /* deallocate the mapEventStruct */
    ckfree((char*)mPtr);
}

/* Tix_DoWhenMapped
 *
 * argv[1..] = command argvs
 *
 */
TIX_DEFINE_CMD(Tix_DoWhenMappedCmd)
{
    Tcl_HashEntry     * hashPtr;
    int			isNew;
    MapEventStruct    * mPtr;
    MapCmdLink	      * cmd;
    Tk_Window		tkwin;
    static int 	        inited = 0;

    if (argc!=3) {
	return Tix_ArgcError(interp, argc, argv, 1, " pathname command");
    }

    if (!(tkwin = Tk_NameToWindow(interp, argv[1], Tk_MainWindow(interp)))) {
	return TCL_ERROR;
    }

    if (!inited) {
	Tcl_InitHashTable(&mapEventTable, sizeof(Tk_Window)/sizeof(int));
	inited = 1;
    }

    hashPtr = Tcl_CreateHashEntry(&mapEventTable, (char*)tkwin, &isNew);

    if (!isNew) {
	mPtr = (MapEventStruct*) Tcl_GetHashValue(hashPtr);
    } else {
	mPtr = (MapEventStruct*) ckalloc(sizeof(MapEventStruct));
	mPtr->interp = interp;
	mPtr->tkwin  = tkwin;
	mPtr->cmds   = 0;

	Tcl_SetHashValue(hashPtr, (char*)mPtr);

	Tk_CreateEventHandler(tkwin, StructureNotifyMask,
	    MapEventProc, (ClientData)mPtr);
    }

    /*
     * Add this into a link list
     */
    cmd = (MapCmdLink*) ckalloc(sizeof(MapCmdLink));
    cmd->command = (char*)strdup(argv[2]);

    cmd->next = mPtr->cmds;
    mPtr->cmds = cmd;

    return TCL_OK;
}

/* Tix_FileCmd
 *
 *
 *
 */
TIX_DEFINE_CMD(Tix_FileCmd)
{
    char *expandedFileName;
    Tcl_DString buffer;
    size_t len;

    if (argc!=3) {
	return Tix_ArgcError(interp, argc, argv, 1, "option filename");
    }
    len = strlen(argv[1]);
    if (argv[1][0]=='t' && strncmp(argv[1], "tildesubst", len)==0) {

	expandedFileName = Tcl_TildeSubst(interp, argv[2], &buffer);
	Tcl_ResetResult(interp);
	if (expandedFileName == NULL) {
	    Tcl_AppendResult(interp, argv[2], NULL);
	} else {
	    Tcl_AppendResult(interp, expandedFileName, NULL);
	}
	Tcl_DStringFree(&buffer);

	return TCL_OK;
    }
    else if (argv[1][0]=='t' && strncmp(argv[1], "trimslash", len)==0) {
	/* Compress the extra "/"
	 *
	 */
	char *src, *dst;
	int isSlash = 0;

	for (src=dst=argv[2]; *src; src++) {
	    if (*src == '/') {
		if (!isSlash) {
		    *dst++ = *src;
		    isSlash = 1;
		}
	    } else {
		*dst++ = *src;
		isSlash = 0;
	    }
	}
	* dst = '\0';

	/* Trim the tariling "/", but only if this filename is not "/" */
	-- dst;
	if (*dst == '/') {
	    if (dst != argv[2]) {
		* dst = '\0';
	    }
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, argv[2], NULL);
	return TCL_OK;
    }

    Tcl_AppendResult(interp, "unknown option \"", argv[1], 
	"\", must be tildesubst or trimslash", NULL);
    return TCL_ERROR;
}
