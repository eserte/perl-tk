/* 
 * tkFrame.c --
 *
 *	This module implements "frame"  and "toplevel" widgets for
 *	the Tk toolkit.  Frames are windows with a background color
 *	and possibly a 3-D effect, but not much else in the way of
 *	attributes.
 *
 * Copyright (c) 1990-1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

static char sccsid[] = "@(#) tkFrame.c 1.59 95/06/04 14:08:47";

#include "default.h"
#include "tkPort.h"
#include "tkInt.h"

/*
 * A data structure of the following type is kept for each
 * frame that currently exists for this process:
 */

typedef struct {
    Tk_Window tkwin;		/* Window that embodies the frame.  NULL
				 * means that the window has been destroyed
				 * but the data structures haven't yet been
				 * cleaned up. */
    Display *display;		/* Display containing widget.  Used, among
				 * other things, so that resources can be
				 * freed even after tkwin has gone away. */
    Tcl_Interp *interp;		/* Interpreter associated with widget.  Used
				 * to delete widget command. */
    Tcl_Command widgetCmd;	/* Token for frame's widget command. */
    char *className;		/* Class name for widget (from configuration
				 * option).  Malloc-ed. */
    int mask;			/* Either FRAME or TOPLEVEL;  used to select
				 * which configuration options are valid for
				 * widget. */
    char *screenName;		/* Screen on which widget is created.  Non-null
				 * only for top-levels.  Malloc-ed, may be
				 * NULL. */
    char *visualName;		/* Textual description of visual for window,
				 * from -visual option.  Malloc-ed, may be
				 * NULL. */
    char *colormapName;		/* Textual description of colormap for window,
				 * from -colormap option.  Malloc-ed, may be
				 * NULL. */
    Colormap colormap;		/* If not None, identifies a colormap
				 * allocated for this window, which must be
				 * freed when the window is deleted. */
    Tk_3DBorder border;		/* Structure used to draw 3-D border and
				 * background.  NULL means no background
				 * or border. */
    int borderWidth;		/* Width of 3-D border (if any). */
    int relief;			/* 3-d effect: TK_RELIEF_RAISED etc. */
    int highlightWidth;		/* Width in pixels of highlight to draw
				 * around widget when it has the focus.
				 * 0 means don't draw a highlight. */
    XColor *highlightBgColorPtr;
				/* Color for drawing traversal highlight
				 * area when highlight is off. */
    XColor *highlightColorPtr;	/* Color for drawing traversal highlight. */
    int width;			/* Width to request for window.  <= 0 means
				 * don't request any size. */
    int height;			/* Height to request for window.  <= 0 means
				 * don't request any size. */
    Cursor cursor;		/* Current cursor for window, or None. */
    char *takeFocus;		/* Value of -takefocus option;  not used in
				 * the C code, but used by keyboard traversal
				 * scripts.  Malloc'ed, but may be NULL. */
    int flags;			/* Various flags;  see below for
				 * definitions. */
} Frame;

/*
 * Flag bits for frames:
 *
 * REDRAW_PENDING:		Non-zero means a DoWhenIdle handler
 *				has already been queued to redraw
 *				this window.
 * CLEAR_NEEDED;		Need to clear the window when redrawing.
 * GOT_FOCUS:			Non-zero means this widget currently
 *				has the input focus.
 */

#define REDRAW_PENDING		1
#define CLEAR_NEEDED		2
#define GOT_FOCUS		4

/*
 * The following flag bits are used so that there can be separate
 * defaults for some configuration options for frames and toplevels.
 */

#define FRAME		TK_CONFIG_USER_BIT
#define TOPLEVEL	(TK_CONFIG_USER_BIT << 1)
#define BOTH		(FRAME | TOPLEVEL)

static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_BORDER, "-background", "background", "Background",
	DEF_FRAME_BG_COLOR, Tk_Offset(Frame, border),
	BOTH|TK_CONFIG_COLOR_ONLY|TK_CONFIG_NULL_OK},
    {TK_CONFIG_BORDER, "-background", "background", "Background",
	DEF_FRAME_BG_MONO, Tk_Offset(Frame, border),
	BOTH|TK_CONFIG_MONO_ONLY|TK_CONFIG_NULL_OK},
    {TK_CONFIG_SYNONYM, "-bd", "borderWidth",          NULL,
	         NULL, 0, BOTH},
    {TK_CONFIG_SYNONYM, "-bg", "background",          NULL,
	         NULL, 0, BOTH},
    {TK_CONFIG_PIXELS, "-borderwidth", "borderWidth", "BorderWidth",
	DEF_FRAME_BORDER_WIDTH, Tk_Offset(Frame, borderWidth), BOTH},
    {TK_CONFIG_STRING, "-class", "class", "Class",
	DEF_FRAME_CLASS, Tk_Offset(Frame, className), FRAME},
    {TK_CONFIG_STRING, "-class", "class", "Class",
	DEF_TOPLEVEL_CLASS, Tk_Offset(Frame, className), TOPLEVEL},
    {TK_CONFIG_STRING, "-colormap", "colormap", "Colormap",
	DEF_FRAME_COLORMAP, Tk_Offset(Frame, colormapName),
	BOTH|TK_CONFIG_NULL_OK},
    {TK_CONFIG_ACTIVE_CURSOR, "-cursor", "cursor", "Cursor",
	DEF_FRAME_CURSOR, Tk_Offset(Frame, cursor), BOTH|TK_CONFIG_NULL_OK},
    {TK_CONFIG_PIXELS, "-height", "height", "Height",
	DEF_FRAME_HEIGHT, Tk_Offset(Frame, height), BOTH},
    {TK_CONFIG_COLOR, "-highlightbackground", "highlightBackground",
	"HighlightBackground", DEF_FRAME_HIGHLIGHT_BG,
	Tk_Offset(Frame, highlightBgColorPtr), BOTH},
    {TK_CONFIG_COLOR, "-highlightcolor", "highlightColor", "HighlightColor",
	DEF_FRAME_HIGHLIGHT, Tk_Offset(Frame, highlightColorPtr), BOTH},
    {TK_CONFIG_PIXELS, "-highlightthickness", "highlightThickness",
	"HighlightThickness",
	DEF_FRAME_HIGHLIGHT_WIDTH, Tk_Offset(Frame, highlightWidth), BOTH},
    {TK_CONFIG_RELIEF, "-relief", "relief", "Relief",
	DEF_FRAME_RELIEF, Tk_Offset(Frame, relief), BOTH},
    {TK_CONFIG_STRING, "-screen", "screen", "Screen",
	DEF_TOPLEVEL_SCREEN, Tk_Offset(Frame, screenName),
	TOPLEVEL|TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-takefocus", "takeFocus", "TakeFocus",
	DEF_FRAME_TAKE_FOCUS, Tk_Offset(Frame, takeFocus),
	BOTH|TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-visual", "visual", "Visual",
	DEF_FRAME_VISUAL, Tk_Offset(Frame, visualName),
	BOTH|TK_CONFIG_NULL_OK},
    {TK_CONFIG_PIXELS, "-width", "width", "Width",
	DEF_FRAME_WIDTH, Tk_Offset(Frame, width), BOTH},
    {TK_CONFIG_END,          NULL,          NULL,          NULL,
	         NULL, 0, 0}
};

/*
 * Forward declarations for procedures defined later in this file:
 */

static int		ConfigureFrame _ANSI_ARGS_((Tcl_Interp *interp,
			    Frame *framePtr, int argc, Arg *args,
			    int flags));
static void		DestroyFrame _ANSI_ARGS_((ClientData clientData));
static void		DisplayFrame _ANSI_ARGS_((ClientData clientData));
static void		FrameCmdDeletedProc _ANSI_ARGS_((
			    ClientData clientData));
static void		FrameEventProc _ANSI_ARGS_((ClientData clientData,
			    XEvent *eventPtr));
static int		FrameWidgetCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args));
static void		MapFrame _ANSI_ARGS_((ClientData clientData));

/*
 *--------------------------------------------------------------
 *
 * Tk_FrameCmd --
 *
 *	This procedure is invoked to process the "frame" and
 *	"toplevel" Tcl commands.  See the user documentation for
 *	details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

int
Tk_FrameCmd(clientData, interp, argc, args)
    ClientData clientData;	/* Main window associated with
				 * interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tk_Window tkwin = (Tk_Window) clientData;
    Frame *framePtr;
    Tk_Window new = NULL;
    char *className, *screenName, *visualName, *colormapName, *arg;
    int i, c, length, toplevel, depth;
    Colormap colormap;
    Visual *visual;
    Display *display;

    if (argc < 2) {
	Tcl_AppendResult(interp, "wrong # args: should be \"",
		LangString(args[0]), " pathName ?options?\"",          NULL);
	return TCL_ERROR;
    }

    /*
     * Pre-process the argument list.  Scan through it to find any
     * "-class", "-screen", "-visual", and "-newcmap" options.  These
     * arguments need to be processed specially, before the window
     * is configured using the usual Tk mechanisms.
     */

    toplevel = (LangString(args[0])[0] == 't');
    className = colormapName = screenName = visualName = NULL;
    for (i = 2; i < argc; i += 2) {
	arg = LangString(args[i]);
	length = strlen(arg);
	if (length < 2) {
	    continue;
	}
	c = arg[1];
	if ((c == 'c') &&  LangCmpOpt("-class",arg,strlen(arg)) == 0 
		&& (length >= 3)) {
	    className = LangString(args[i+1]);
	} else if ((c == 'c') &&  LangCmpOpt("-colormap",arg,strlen(arg)) == 0 ) {

	    colormapName = LangString(args[i+1]);
	} else if ((c == 's') && toplevel
		&& (LangCmpOpt("-screen", arg, strlen(arg)) == 0)) {
	    screenName = LangString(args[i+1]);
	} else if ((c == 'v') &&  LangCmpOpt("-visual",arg,strlen(arg)) == 0 ) {

	    visualName = LangString(args[i+1]);
	}
    }

    /*
     * Create the window, and deal with the special options -classname,
     * -colormap, -screenname, and -visual.  The order here is tricky,
     * because we want to allow values for these options to come from
     * the database, yet we can't do that until the window is created.
     */

    if (screenName == NULL) {
	screenName = (toplevel) ? "" : NULL;
    }
    new = Tk_CreateWindowFromPath(interp, tkwin, LangString(args[1]), screenName);
    if (new == NULL) {
	goto error;
    }
    if (className == NULL) {
	className = Tk_GetOption(new, "class", "Class");
	if (className == NULL) {
	    className = (toplevel) ? "Toplevel" : "Frame";
	}
    }
    Tk_SetClass(new, className);
    if (visualName == NULL) {
	visualName = Tk_GetOption(new, "visual", "Visual");
    }
    if (colormapName == NULL) {
	colormapName = Tk_GetOption(new, "colormap", "Colormap");
    }
    colormap = None;
    if (visualName != NULL) {
	visual = Tk_GetVisual(interp, new, visualName, &depth,
		(colormapName == NULL) ? &colormap : (Colormap *) NULL);
	if (visual == NULL) {
	    goto error;
	}
	Tk_SetWindowVisual(new, visual, depth, colormap);
    }
    if (colormapName != NULL) {
	colormap = Tk_GetColormap(interp, new, colormapName);
	if (colormap == None) {
	    goto error;
	}
	Tk_SetWindowColormap(new, colormap);
    }

    /*
     * Create the widget record, process configuration options, and
     * create event handlers.  Then fill in a few additional fields
     * in the widget record from the special options.
     */

    display = Tk_Display(new);
    framePtr = (Frame *) TkInitFrame(interp, new, toplevel, argc-2, args+2);
    if (framePtr == NULL) {
	if (colormap != None) {
	    Tk_FreeColormap(display, colormap);
	}
	return TCL_ERROR;
    }
    framePtr->colormap = colormap;
    return TCL_OK;

    error:
    if (new != NULL) {
	Tk_DestroyWindow(new);
    }
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * TkInitFrame --
 *
 *	This procedure initializes a frame or toplevel widget.  It's
 *	separate from Tk_FrameCmd so that it can be used for the
 *	main window, which has already been created elsewhere.
 *
 * Results:
 *	Returns NULL if an error occurred while initializing the
 *	frame.  Otherwise returns a pointer to the frame's widget
 *	record (for use by Tk_FrameCmd, if it was the caller).
 *
 * Side effects:
 *	A widget record gets allocated, handlers get set up, etc..
 *
 *----------------------------------------------------------------------
 */

char *
TkInitFrame(interp, tkwin, toplevel, argc, args)
    Tcl_Interp *interp;			/* Interpreter associated with the
					 * application. */
    Tk_Window tkwin;			/* Window to use for frame or
					 * top-level.   Caller must already
					 * have set window's class. */
    int toplevel;			/* Non-zero means that this is a
					 * top-level window, 0 means it's a
					 * frame. */
    int argc;				/* Number of configuration arguments
					 * (not including class command and
					 * window name). */
    Arg *args;			/* Configuration arguments. */
{
    register Frame *framePtr;

    framePtr = (Frame *) ckalloc(sizeof(Frame));
    framePtr->tkwin = tkwin;
    framePtr->display = Tk_Display(tkwin);
    framePtr->interp = interp;
    framePtr->widgetCmd = Lang_CreateWidget(interp,framePtr->tkwin, FrameWidgetCmd, (ClientData) framePtr, FrameCmdDeletedProc);


    framePtr->className = NULL;
    framePtr->mask = (toplevel) ? TOPLEVEL : FRAME;
    framePtr->screenName = NULL;
    framePtr->visualName = NULL;
    framePtr->colormapName = NULL;
    framePtr->colormap = None;
    framePtr->border = NULL;
    framePtr->borderWidth = 0;
    framePtr->relief = TK_RELIEF_FLAT;
    framePtr->highlightWidth = 0;
    framePtr->highlightBgColorPtr = NULL;
    framePtr->highlightColorPtr = NULL;
    framePtr->width = 0;
    framePtr->height = 0;
    framePtr->cursor = None;
    framePtr->takeFocus = NULL;
    framePtr->flags = 0;
    Tk_CreateEventHandler(framePtr->tkwin,
	    ExposureMask|StructureNotifyMask|FocusChangeMask,
	    FrameEventProc, (ClientData) framePtr);
    if (ConfigureFrame(interp, framePtr, argc, args, 0) != TCL_OK) {
	Tk_DestroyWindow(framePtr->tkwin);
	return NULL;
    }
    if (toplevel) {
	Tk_DoWhenIdle(MapFrame, (ClientData) framePtr);
    }
    Tcl_ArgResult(interp,LangWidgetArg(interp,framePtr->tkwin));
    return (char *) framePtr;
}

/*
 *--------------------------------------------------------------
 *
 * FrameWidgetCmd --
 *
 *	This procedure is invoked to process the Tcl command
 *	that corresponds to a frame widget.  See the user
 *	documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

static int
FrameWidgetCmd(clientData, interp, argc, args)
    ClientData clientData;	/* Information about frame widget. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    register Frame *framePtr = (Frame *) clientData;
    int result = TCL_OK;
    size_t length;
    int c, i;

    if (argc < 2) {
	Tcl_AppendResult(interp, "wrong # args: should be \"",
		LangString(args[0]), " option ?arg arg ...?\"",          NULL);
	return TCL_ERROR;
    }
    Tk_Preserve((ClientData) framePtr);
    c = LangString(args[1])[0];
    length = strlen(LangString(args[1]));
    if ((c == 'c') && (strncmp(LangString(args[1]), "cget", length) == 0)
	    && (length >= 2)) {
	if (argc != 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    LangString(args[0]), " cget option\"",
		             NULL);
	    result = TCL_ERROR;
	    goto done;
	}
	result = Tk_ConfigureValue(interp, framePtr->tkwin, configSpecs,
		(char *) framePtr, LangString(args[2]), framePtr->mask);
    } else if ((c == 'c') && (strncmp(LangString(args[1]), "configure", length) == 0)
	    && (length >= 2)) {
	if (argc == 2) {
	    result = Tk_ConfigureInfo(interp, framePtr->tkwin, configSpecs,
		    (char *) framePtr,          NULL, framePtr->mask);
	} else if (argc == 3) {
	    result = Tk_ConfigureInfo(interp, framePtr->tkwin, configSpecs,
		    (char *) framePtr, LangString(args[2]), framePtr->mask);
	} else {
	    /*
	     * Don't allow the options -class, -newcmap, -screen,
	     * or -visual to be changed.
	     */

	    for (i = 2; i < argc; i++) {
		length = strlen(LangString(args[i]));
		if (length < 2) {
		    continue;
		}
		c = LangString(args[i])[1];
		if (((c == 'c') &&  LangCmpOpt("-class",LangString(args[i]),length) == 0 
			&& (length >= 2))
			|| ((c == 'c') && (framePtr->mask == TOPLEVEL)
			&& (LangCmpOpt("-colormap", LangString(args[i]), length) == 0))
			|| ((c == 's') && (framePtr->mask == TOPLEVEL)
			&& (LangCmpOpt("-screen", LangString(args[i]), length) == 0))
			|| ((c == 'v') && (framePtr->mask == TOPLEVEL)
			&& (LangCmpOpt("-visual", LangString(args[i]), length) == 0))) {
		    Tcl_AppendResult(interp, "can't modify ", LangString(args[i]),
			    " option after widget is created",          NULL);
		    result = TCL_ERROR;
		    goto done;
		}
	    }
	    result = ConfigureFrame(interp, framePtr, argc-2, args+2,
		    TK_CONFIG_ARGV_ONLY);
	}
    } else {
	Tcl_AppendResult(interp, "bad option \"", LangString(args[1]),
		"\":  must be cget or configure",          NULL);
	result = TCL_ERROR;
    }

    done:
    Tk_Release((ClientData) framePtr);
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 * DestroyFrame --
 *
 *	This procedure is invoked by Tk_EventuallyFree or Tk_Release
 *	to clean up the internal structure of a frame at a safe time
 *	(when no-one is using it anymore).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Everything associated with the frame is freed up.
 *
 *----------------------------------------------------------------------
 */

static void
DestroyFrame(clientData)
    ClientData clientData;	/* Info about frame widget. */
{
    register Frame *framePtr = (Frame *) clientData;

    Tk_FreeOptions(configSpecs, (char *) framePtr, framePtr->display,
	    framePtr->mask);
    if (framePtr->colormap != None) {
	Tk_FreeColormap(framePtr->display, framePtr->colormap);
    }
    ckfree((char *) framePtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ConfigureFrame --
 *
 *	This procedure is called to process an args/argc list, plus
 *	the Tk option database, in order to configure (or
 *	reconfigure) a frame widget.
 *
 * Results:
 *	The return value is a standard Tcl result.  If TCL_ERROR is
 *	returned, then Tcl_GetResult(interp) contains an error message.
 *
 * Side effects:
 *	Configuration information, such as text string, colors, font,
 *	etc. get set for framePtr;  old resources get freed, if there
 *	were any.
 *
 *----------------------------------------------------------------------
 */

static int
ConfigureFrame(interp, framePtr, argc, args, flags)
    Tcl_Interp *interp;		/* Used for error reporting. */
    register Frame *framePtr;	/* Information about widget;  may or may
				 * not already have values for some fields. */
    int argc;			/* Number of valid entries in args. */
    Arg *args;		/* Arguments. */
    int flags;			/* Flags to pass to Tk_ConfigureWidget. */
{
    if (Tk_ConfigureWidget(interp, framePtr->tkwin, configSpecs,
	    argc, args, (char *) framePtr, flags | framePtr->mask) != TCL_OK) {
	return TCL_ERROR;
    }

    if (framePtr->border != NULL) {
	Tk_SetBackgroundFromBorder(framePtr->tkwin, framePtr->border);
    }
    if (framePtr->highlightWidth < 0) {
	framePtr->highlightWidth = 0;
    }
    Tk_SetInternalBorder(framePtr->tkwin,
	    framePtr->borderWidth + framePtr->highlightWidth);
    if ((framePtr->width > 0) || (framePtr->height > 0)) {
	Tk_GeometryRequest(framePtr->tkwin, framePtr->width,
		framePtr->height);
    }

    if (Tk_IsMapped(framePtr->tkwin)) {
	if (!(framePtr->flags & REDRAW_PENDING)) {
	    Tk_DoWhenIdle(DisplayFrame, (ClientData) framePtr);
	}
	framePtr->flags |= REDRAW_PENDING|CLEAR_NEEDED;
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * DisplayFrame --
 *
 *	This procedure is invoked to display a frame widget.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Commands are output to X to display the frame in its
 *	current mode.
 *
 *----------------------------------------------------------------------
 */

static void
DisplayFrame(clientData)
    ClientData clientData;	/* Information about widget. */
{
    register Frame *framePtr = (Frame *) clientData;
    register Tk_Window tkwin = framePtr->tkwin;
    GC gc;

    framePtr->flags &= ~REDRAW_PENDING;
    if ((framePtr->tkwin == NULL) || !Tk_IsMapped(tkwin)) {
	return;
    }

    if (framePtr->flags & CLEAR_NEEDED) {
	XClearWindow(framePtr->display, Tk_WindowId(tkwin));
	framePtr->flags &= ~CLEAR_NEEDED;
    }
    if ((framePtr->border != NULL)
	    && (framePtr->relief != TK_RELIEF_FLAT)) {
	Tk_Draw3DRectangle(tkwin, Tk_WindowId(tkwin),
		framePtr->border, framePtr->highlightWidth,
		framePtr->highlightWidth,
		Tk_Width(tkwin) - 2*framePtr->highlightWidth,
		Tk_Height(tkwin) - 2*framePtr->highlightWidth,
		framePtr->borderWidth, framePtr->relief);
    }
    if (framePtr->highlightWidth != 0) {
	if (framePtr->flags & GOT_FOCUS) {
	    gc = Tk_GCForColor(framePtr->highlightColorPtr,
		    Tk_WindowId(tkwin));
	} else {
	    gc = Tk_GCForColor(framePtr->highlightBgColorPtr,
		    Tk_WindowId(tkwin));
	}
	Tk_DrawFocusHighlight(tkwin, gc, framePtr->highlightWidth,
		Tk_WindowId(tkwin));
    }
}

/*
 *--------------------------------------------------------------
 *
 * FrameEventProc --
 *
 *	This procedure is invoked by the Tk dispatcher on
 *	structure changes to a frame.  For frames with 3D
 *	borders, this procedure is also invoked for exposures.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	When the window gets deleted, internal structures get
 *	cleaned up.  When it gets exposed, it is redisplayed.
 *
 *--------------------------------------------------------------
 */

static void
FrameEventProc(clientData, eventPtr)
    ClientData clientData;	/* Information about window. */
    register XEvent *eventPtr;	/* Information about event. */
{
    register Frame *framePtr = (Frame *) clientData;

    if ((eventPtr->type == Expose) && (eventPtr->xexpose.count == 0)) {
	goto redraw;
    } else if (eventPtr->type == ConfigureNotify) {
	/*
	 * If the window changed size then the borders need to be
	 * redrawn.
	 */

	framePtr->flags |= CLEAR_NEEDED;
	goto redraw;
    } else if (eventPtr->type == DestroyNotify) {
	if (framePtr->tkwin != NULL) {
	    framePtr->tkwin = NULL;
	    Lang_DeleteWidget(framePtr->interp,framePtr->widgetCmd);

	}
	if (framePtr->flags & REDRAW_PENDING) {
	    Tk_CancelIdleCall(DisplayFrame, (ClientData) framePtr);
	}
	Tk_CancelIdleCall(MapFrame, (ClientData) framePtr);
	Tk_EventuallyFree((ClientData) framePtr, DestroyFrame);
    } else if (eventPtr->type == FocusIn) {
	if (eventPtr->xfocus.detail != NotifyInferior) {
	    framePtr->flags |= GOT_FOCUS;
	    if (framePtr->highlightWidth > 0) {
		goto redraw;
	    }
	}
    } else if (eventPtr->type == FocusOut) {
	if (eventPtr->xfocus.detail != NotifyInferior) {
	    framePtr->flags &= ~GOT_FOCUS;
	    if (framePtr->highlightWidth > 0) {
		goto redraw;
	    }
	}
    }
    return;

    redraw:
    if ((framePtr->tkwin != NULL) && !(framePtr->flags & REDRAW_PENDING)) {
	Tk_DoWhenIdle(DisplayFrame, (ClientData) framePtr);
	framePtr->flags |= REDRAW_PENDING;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * FrameCmdDeletedProc --
 *
 *	This procedure is invoked when a widget command is deleted.  If
 *	the widget isn't already in the process of being destroyed,
 *	this command destroys it.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The widget is destroyed.
 *
 *----------------------------------------------------------------------
 */

static void
FrameCmdDeletedProc(clientData)
    ClientData clientData;	/* Pointer to widget record for widget. */
{
    Frame *framePtr = (Frame *) clientData;
    Tk_Window tkwin = framePtr->tkwin;

    /*
     * This procedure could be invoked either because the window was
     * destroyed and the command was then deleted (in which case tkwin
     * is NULL) or because the command was deleted, and then this procedure
     * destroys the widget.
     */

    if (tkwin != NULL) {
	framePtr->tkwin = NULL;
	Tk_DestroyWindow(tkwin);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * MapFrame --
 *
 *	This procedure is invoked as a when-idle handler to map a
 *	newly-created top-level frame.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The frame given by the clientData argument is mapped.
 *
 *----------------------------------------------------------------------
 */

static void
MapFrame(clientData)
    ClientData clientData;		/* Pointer to frame structure. */
{
    Frame *framePtr = (Frame *) clientData;

    /*
     * Wait for all other background events to be processed before
     * mapping window.  This ensures that the window's correct geometry
     * will have been determined before it is first mapped, so that the
     * window manager doesn't get a false idea of its desired geometry.
     */

    Tk_Preserve((ClientData) framePtr);
    while (1) {
	if (Tk_DoOneEvent(TK_IDLE_EVENTS) == 0) {
	    break;
	}

	/*
	 * After each event, make sure that the window still exists
	 * and quit if the window has been destroyed.
	 */

	if (framePtr->tkwin == NULL) {
	    Tk_Release((ClientData) framePtr);
	    return;
	}
    }
    Tk_MapWindow(framePtr->tkwin);
    Tk_Release((ClientData) framePtr);
}
