/* 
 * tixHList.c --
 *
 *	This module implements "HList" widgets. [Some explanation here]
 *
 */

#include "tkPort.h"
#include "tkInt.h"

#include "tixInt.h"
#include <tixHList.h>
#include <tixDefault.h>

/*
 * Information used for args parsing.
 */
static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_COLOR, "-background", "background", "Background",
       DEF_HLIST_BG_COLOR, Tk_Offset(WidgetRecord, normalBg),
       TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_COLOR, "-background", "background", "Background",
       DEF_HLIST_BG_MONO, Tk_Offset(WidgetRecord, normalBg),
       TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_SYNONYM, "-bd", "borderWidth",          NULL,
                NULL, 0, 0},

    {TK_CONFIG_SYNONYM, "-bg", "background",          NULL,
                NULL, 0, 0},

    {TK_CONFIG_PIXELS, "-borderwidth", "borderWidth", "BorderWidth",
       DEF_HLIST_BORDER_WIDTH, Tk_Offset(WidgetRecord, borderWidth), 0},

    {TK_CONFIG_CALLBACK, "-browsecmd", "browseCmd", "BrowseCmd",
	DEF_HLIST_BROWSE_COMMAND, Tk_Offset(WidgetRecord, browseCmd),
	TK_CONFIG_NULL_OK},

    {TK_CONFIG_INT, "-columns", "columns", "Columns",
       DEF_HLIST_COLUMNS, Tk_Offset(WidgetRecord, numColumns),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_CALLBACK, "-command", "command", "Command",
       DEF_HLIST_COMMAND, Tk_Offset(WidgetRecord, command),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_ACTIVE_CURSOR, "-cursor", "cursor", "Cursor",
       DEF_HLIST_CURSOR, Tk_Offset(WidgetRecord, cursor),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_CALLBACK, "-dragcmd", "dragCmd", "DragCmd",
	DEF_HLIST_DRAG_COMMAND, Tk_Offset(WidgetRecord, dragCmd),
	TK_CONFIG_NULL_OK},
 
    {TK_CONFIG_BOOLEAN, "-drawbranch", "drawBranch", "DrawBranch",
       DEF_HLIST_DRAW_BRANCH, Tk_Offset(WidgetRecord, drawBranch), 0},

    {TK_CONFIG_CALLBACK, "-dropcmd", "dropCmd", "DropCmd",
	DEF_HLIST_DROP_COMMAND, Tk_Offset(WidgetRecord, dropCmd),
	TK_CONFIG_NULL_OK},

    {TK_CONFIG_SYNONYM, "-fg", "foreground",          NULL,
                NULL, 0, 0},

    {TK_CONFIG_FONT, "-font", "font", "Font",
       DEF_HLIST_FONT, Tk_Offset(WidgetRecord, fontPtr), 0},

    {TK_CONFIG_COLOR, "-foreground", "foreground", "Foreground",
       DEF_HLIST_FG_COLOR, Tk_Offset(WidgetRecord, normalFg),
       TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_COLOR, "-foreground", "foreground", "Foreground",
       DEF_HLIST_FG_MONO, Tk_Offset(WidgetRecord, normalFg),
       TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_PIXELS, "-gap", "gap", "Gap",
       DEF_HLIST_GAP, Tk_Offset(WidgetRecord, gap), 0},

    {TK_CONFIG_INT, "-height", "height", "Height",
       DEF_HLIST_HEIGHT, Tk_Offset(WidgetRecord, height), 0},

    {TK_CONFIG_BORDER, "-highlightbackground", "highlightBackground",
       "HighlightBackground",
       DEF_HLIST_BG_COLOR, Tk_Offset(WidgetRecord, border),
       TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_BORDER, "-highlightbackground", "highlightBackground",
       "HighlightBackground",
       DEF_HLIST_BG_MONO, Tk_Offset(WidgetRecord, border),
       TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_COLOR, "-highlightcolor", "highlightColor", "HighlightColor",
       DEF_HLIST_HIGHLIGHT_COLOR, Tk_Offset(WidgetRecord, highlightColorPtr),
       TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_COLOR, "-highlightcolor", "highlightColor", "HighlightColor",
       DEF_HLIST_HIGHLIGHT_MONO, Tk_Offset(WidgetRecord, highlightColorPtr),
       TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_PIXELS, "-highlightthickness", "highlightThickness",
	"HighlightThickness",
	DEF_HLIST_HIGHLIGHT_WIDTH, Tk_Offset(WidgetRecord, highlightWidth), 0},

    {TK_CONFIG_PIXELS, "-indent", "indent", "Indent",
       DEF_HLIST_INDENT, Tk_Offset(WidgetRecord, indent), 0},

    {TK_CONFIG_CUSTOM, "-itemtype", "itemType", "ItemType",
       DEF_HLIST_ITEM_TYPE, Tk_Offset(WidgetRecord, diTypePtr),
       0, &tixConfigItemType},

     {TK_CONFIG_PIXELS, "-padx", "padX", "Pad",
	DEF_HLIST_PADX, Tk_Offset(WidgetRecord, padX), 0},

    {TK_CONFIG_PIXELS, "-pady", "padY", "Pad",
	DEF_HLIST_PADY, Tk_Offset(WidgetRecord, padY), 0},

    {TK_CONFIG_RELIEF, "-relief", "relief", "Relief",
       DEF_HLIST_RELIEF, Tk_Offset(WidgetRecord, relief), 0},

    {TK_CONFIG_BORDER, "-selectbackground", "selectBackground", "Foreground",
	DEF_HLIST_SELECT_BG_COLOR, Tk_Offset(WidgetRecord, selectBorder),
	TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_BORDER, "-selectbackground", "selectBackground", "Foreground",
	DEF_HLIST_SELECT_BG_MONO, Tk_Offset(WidgetRecord, selectBorder),
	TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_PIXELS, "-selectborderwidth", "selectBorderWidth","BorderWidth",
       DEF_HLIST_SELECT_BORDERWIDTH,Tk_Offset(WidgetRecord, selBorderWidth),0},

    {TK_CONFIG_COLOR, "-selectforeground", "selectForeground", "Background",
       DEF_HLIST_SELECT_FG_COLOR, Tk_Offset(WidgetRecord, selectFg),
       TK_CONFIG_COLOR_ONLY},

    {TK_CONFIG_COLOR, "-selectforeground", "selectForeground", "Background",
       DEF_HLIST_SELECT_FG_MONO, Tk_Offset(WidgetRecord, selectFg),
       TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_UID, "-selectmode", "selectMode", "SelectMode",
	DEF_HLIST_SELECT_MODE, Tk_Offset(WidgetRecord, selectMode), 0},

    {TK_CONFIG_STRING, "-separator", "separator", "Separator",
       DEF_HLIST_SEPARATOR, Tk_Offset(WidgetRecord, separator), 0},

    {TK_CONFIG_CALLBACK, "-sizecmd", "sizeCmd", "SizeCmd",
       DEF_HLIST_SIZE_COMMAND, Tk_Offset(WidgetRecord, sizeCmd),
       TK_CONFIG_NULL_OK},
 
    {TK_CONFIG_STRING, "-takefocus", "takeFocus", "TakeFocus",
	DEF_HLIST_TAKE_FOCUS, Tk_Offset(WidgetRecord, takeFocus),
	TK_CONFIG_NULL_OK},

    {TK_CONFIG_BOOLEAN, "-wideselection", "wideSelection", "WideSelection",
       DEF_HLIST_WIDE_SELECT, Tk_Offset(WidgetRecord, wideSelect), 0},

    {TK_CONFIG_INT, "-width", "width", "Width",
	DEF_HLIST_WIDTH, Tk_Offset(WidgetRecord, width), 0},

    {TK_CONFIG_CALLBACK, "-xscrollcommand", "xScrollCommand", "ScrollCommand",
	DEF_HLIST_X_SCROLL_COMMAND, Tk_Offset(WidgetRecord, xScrollCmd),
	TK_CONFIG_NULL_OK},

    {TK_CONFIG_CALLBACK, "-yscrollcommand", "yScrollCommand", "ScrollCommand",
	DEF_HLIST_Y_SCROLL_COMMAND, Tk_Offset(WidgetRecord, yScrollCmd),
	TK_CONFIG_NULL_OK},

    {TK_CONFIG_END,          NULL,          NULL,          NULL,
	         NULL, 0, 0}
};

static Tk_ConfigSpec entryConfigSpecs[] = {
    {TK_CONFIG_STRING, "-data",          NULL,          NULL,
       DEF_HLISTENTRY_DATA, Tk_Offset(HListElement, data), TK_CONFIG_NULL_OK},

    {TK_CONFIG_UID, "-state",          NULL,          NULL,
       DEF_HLISTENTRY_STATE, Tk_Offset(HListElement, state), 0},

    {TK_CONFIG_END,          NULL,          NULL,          NULL,
                NULL, 0, 0}
};

/*
 * Forward declarations for procedures defined later in this file:
 */
	/* These are standard procedures for TK widgets
	 * implemeted in C
	 */

static void		WidgetCmdDeletedProc _ANSI_ARGS_((
			    ClientData clientData));
static int		WidgetConfigure _ANSI_ARGS_((Tcl_Interp *interp,
			    WidgetPtr wPtr, int argc, Arg *args,
			    int flags));
static void		WidgetDestroy _ANSI_ARGS_((ClientData clientData));
static void		WidgetEventProc _ANSI_ARGS_((ClientData clientData,
			    XEvent *eventPtr));
static int		WidgetCommand _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *, int argc, Arg *args));
static void		WidgetDisplay _ANSI_ARGS_((ClientData clientData));
static void		WidgetComputeGeometry _ANSI_ARGS_((
			    ClientData clientData));

	/* Extra procedures for this widget
	 */
static HListElement * 	AllocElement _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * parent, char * pathName, 
			    char * name, char * ditemType));
static void 		AppendList _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement *parent, HListElement *chPtr, int at,
			    HListElement *afterPtr,
			    HListElement *beforePtr));
static void		CancelRedrawWhenIdle _ANSI_ARGS_((
			    WidgetPtr wPtr));
static void		CancelResizeWhenIdle _ANSI_ARGS_((
			    WidgetPtr wPtr));
static void 		CheckScrollBar _ANSI_ARGS_((WidgetPtr wPtr,
			    int which));
static void 		ComputeBranchPosition _ANSI_ARGS_((
			    WidgetPtr wPtr, HListElement *chPtr));
static void 		ComputeElementGeometry _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement *chPtr, int indent));
static void 		ComputeOneElementGeometry _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement *chPtr, int indent));
static int		ConfigElement _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement *chPtr, int argc, Arg *args, 
			    int flags, int forced));
static int 		CurSelection _ANSI_ARGS_((Tcl_Interp * interp,
			    WidgetPtr wPtr, HListElement * chPtr));
static void		DeleteNode _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void		DeleteOffsprings _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void		DeleteSiblings _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void 		DrawElements _ANSI_ARGS_((WidgetPtr wPtr,
			    Pixmap pixmap, GC gc, HListElement * chPtr,
			    int x, int y, int xOffset));
static void 		DrawOneElement _ANSI_ARGS_((WidgetPtr wPtr, 
			    Pixmap pixmap, GC gc, HListElement * chPtr,
			    int x, int y, int xOffset));
static HListElement * 	FindElementAtPosition _ANSI_ARGS_((WidgetPtr wPtr,
			    int y));
static HListElement * 	FindNextEntry  _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static HListElement * 	FindPrevEntry  _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void	 	FreeElement _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static int	 	ElementTopPixel _ANSI_ARGS_((
			    WidgetPtr wPtr, HListElement *chPtr));
static int	 	ElementLeftPixel _ANSI_ARGS_((
			    WidgetPtr wPtr, HListElement *chPtr));
static HListElement * 	NewElement _ANSI_ARGS_((Tcl_Interp *interp,
			    WidgetPtr wPtr, int argc, Arg *args,
			    char * pathName, char * defParentName,
			    int * newArgc));
static void		RedrawWhenIdle _ANSI_ARGS_((WidgetPtr wPtr));
void			Tix_HLResizeWhenIdle _ANSI_ARGS_((WidgetPtr wPtr));
static int		XScrollByPages _ANSI_ARGS_((WidgetPtr wPtr,
			    int count));
static int		XScrollByUnits _ANSI_ARGS_((WidgetPtr wPtr,
			    int count));
static int		YScrollByPages _ANSI_ARGS_((WidgetPtr wPtr,
			    int count));
static int		YScrollByUnits _ANSI_ARGS_((WidgetPtr wPtr,
			    int count));
static int		SelectionModifyRange _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * from, HListElement * to,
			    int select));
static void		SelectionAdd _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void		HL_SelectionClear _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void		HL_SelectionClearAll _ANSI_ARGS_((WidgetPtr wPtr,
			    HListElement * chPtr));
static void 		HL_SelectionClearNotifyAncestors _ANSI_ARGS_((
			    WidgetPtr wPtr, HListElement * chPtr));
static void 		SelectionNotifyAncestors _ANSI_ARGS_((
			    WidgetPtr wPtr, HListElement * chPtr));
static void		UpdateOneScrollBar _ANSI_ARGS_((WidgetPtr wPtr,
			    LangCallback *command, int total, int window, int first));
static void		UpdateScrollBars _ANSI_ARGS_((WidgetPtr wPtr,
			    int sizeChanged));
static void		DItemSizeChanged _ANSI_ARGS_((
			    Tix_DItem *iPtr));


static TIX_DECLARE_SUBCMD(Tix_HLAdd);
static TIX_DECLARE_SUBCMD(Tix_HLAddChild);
static TIX_DECLARE_SUBCMD(Tix_HLCGet);
static TIX_DECLARE_SUBCMD(Tix_HLConfig);
static TIX_DECLARE_SUBCMD(Tix_HLDelete);
static TIX_DECLARE_SUBCMD(Tix_HLEntryCget);
static TIX_DECLARE_SUBCMD(Tix_HLEntryConfig);
static TIX_DECLARE_SUBCMD(Tix_HLGeometryInfo);
static TIX_DECLARE_SUBCMD(Tix_HLHide);
static TIX_DECLARE_SUBCMD(Tix_HLInfo);
static TIX_DECLARE_SUBCMD(Tix_HLNearest);
static TIX_DECLARE_SUBCMD(Tix_HLSee);
static TIX_DECLARE_SUBCMD(Tix_HLSelection);
static TIX_DECLARE_SUBCMD(Tix_HLSetSite);
static TIX_DECLARE_SUBCMD(Tix_HLShow);
static TIX_DECLARE_SUBCMD(Tix_HLXView);
static TIX_DECLARE_SUBCMD(Tix_HLYView);

/* in tixHLCol.c */
extern TIX_DECLARE_SUBCMD(Tix_HLColumn);
extern TIX_DECLARE_SUBCMD(Tix_HLItem);


/*
 *--------------------------------------------------------------
 *
 * Tix_HListCmd --
 *
 *	This procedure is invoked to process the "HList" Tcl
 *	command.  It creates a new "HList" widget.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	A new widget is created and configured.
 *
 *--------------------------------------------------------------
 */
int
Tix_HListCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tk_Window main = (Tk_Window) clientData;
    WidgetPtr wPtr;
    Tk_Window tkwin;

    if (argc < 2) {
	Tcl_AppendResult(interp, "wrong # args:  should be \"",
		LangString(args[0]), " pathName ?options?\"",          NULL);
	return TCL_ERROR;
    }

    tkwin = Tk_CreateWindowFromPath(interp, main, LangString(args[1]),          NULL);
    if (tkwin == NULL) {
	return TCL_ERROR;
    }

    Tk_SetClass(tkwin, "TixHList");

    /*
     * Allocate and initialize the widget record.
     */
    wPtr = (WidgetPtr) ckalloc(sizeof(WidgetRecord));

    /* Init the hash table first (needed before calling AllocElement) */
    Tcl_InitHashTable(&wPtr->childTable, TCL_STRING_KEYS);

    wPtr->dispData.tkwin 	= tkwin;
    wPtr->dispData.display 	= Tk_Display(tkwin);
    wPtr->dispData.interp 	= interp;
    wPtr->dispData.sizeChangedProc = DItemSizeChanged;
    wPtr->fontPtr		= NULL;
    wPtr->normalBg 		= NULL;
    wPtr->normalFg		= NULL;
    wPtr->border 		= NULL;
    wPtr->borderWidth 		= 0;
    wPtr->selectBorder 		= NULL;
    wPtr->selBorderWidth 	= 0;
    wPtr->selectFg		= NULL;
    wPtr->backgroundGC		= None;
    wPtr->normalGC		= None;
    wPtr->selectGC		= None;
    wPtr->anchorGC		= None;
    wPtr->dropSiteGC		= None;
    wPtr->highlightWidth	= 0;
    wPtr->highlightColorPtr	= NULL;
    wPtr->highlightGC		= None;
    wPtr->relief 		= TK_RELIEF_FLAT;
    wPtr->cursor 		= None;
    wPtr->indent 		= 0;
    wPtr->resizing 		= 0;
    wPtr->redrawing 		= 0;
    wPtr->hasFocus 		= 0;
    wPtr->topPixel 		= 0;
    wPtr->leftPixel 		= 0;
    wPtr->separator 		= NULL;
    wPtr->selectMode		= NULL;
    wPtr->anchor 		= NULL;
    wPtr->dragSite 		= NULL;
    wPtr->dropSite 		= NULL;
    wPtr->command 		= NULL;
    wPtr->browseCmd		= NULL;
    wPtr->sizeCmd		= NULL;
    wPtr->dragCmd		= NULL;
    wPtr->dropCmd		= NULL;
    wPtr->takeFocus		= NULL;
    wPtr->xScrollCmd		= NULL;
    wPtr->yScrollCmd		= NULL;
    wPtr->scrollUnit[0]		= 1;
    wPtr->scrollUnit[1]		= 1;
    wPtr->serial		= 0;
    wPtr->numColumns		= 1;
    wPtr->initialized		= 0;
    wPtr->allDirty		= 0;
    wPtr->drawBranch		= 1;
    wPtr->wideSelect		= 0;
    wPtr->diTypePtr		= NULL;
    wPtr->reqSize		= NULL;
    wPtr->actualSize		= NULL;
    wPtr->root 			= NULL;
    wPtr->totalSize[0]		= 1;
    wPtr->totalSize[1]		= 1;

    Tix_LinkListInit(&wPtr->mappedWindows);

    Tk_CreateEventHandler(wPtr->dispData.tkwin,
	ExposureMask|StructureNotifyMask|FocusChangeMask,
	WidgetEventProc, (ClientData) wPtr);
    wPtr->widgetCmd = Lang_CreateWidget(interp,wPtr->dispData.tkwin, WidgetCommand, (ClientData) wPtr, WidgetCmdDeletedProc);


    if (WidgetConfigure(interp, wPtr, argc-2, args+2, 0) != TCL_OK) {
	Tk_DestroyWindow(wPtr->dispData.tkwin);
	return TCL_ERROR;
    }

    /* Must call this **after** wPtr->numColumns is set */
    wPtr->reqSize    = Tix_HLAllocColumn(wPtr);
    wPtr->actualSize = Tix_HLAllocColumn(wPtr);
    wPtr->root       = AllocElement(wPtr, 0, 0, 0, 0);

    wPtr->initialized = 1;

    Tcl_ArgResult(interp,LangWidgetArg(interp,wPtr->dispData.tkwin));
    return TCL_OK;
}

/*
 *--------------------------------------------------------------
 *
 * WidgetCommand --
 *
 *	This procedure is invoked to process the Tcl command
 *	that corresponds to a widget managed by this module.
 *	See the user documentation for details on what it does.
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
WidgetCommand(clientData, interp, argc, args)
    ClientData clientData;		/* Information about the widget. */
    Tcl_Interp *interp;			/* Current interpreter. */
    int argc;				/* Number of arguments. */
    Arg *args;			/* Argument strings. */
{
    int code;

    static Tix_SubCmdInfo subCmdInfo[] = {
	{TIX_DEFAULT_LEN, "add", 1, TIX_VAR_ARGS, Tix_HLAdd,
	   "entryPath"},
	{TIX_DEFAULT_LEN, "addchild", 1, TIX_VAR_ARGS, Tix_HLAddChild,
	   "parentEntryPath"},
	{TIX_DEFAULT_LEN, "anchor", 1, 2, Tix_HLSetSite,
	   "option ?entryPath?"},
	{TIX_DEFAULT_LEN, "cget", 1, 1, Tix_HLCGet,
	   "option"},
	{TIX_DEFAULT_LEN, "column", 0, TIX_VAR_ARGS, Tix_HLColumn,
	   "?option? ?args ...?"},
	{TIX_DEFAULT_LEN, "configure", 0, TIX_VAR_ARGS, Tix_HLConfig,
	   "?option? ?value? ?option value ... ?"},
	{TIX_DEFAULT_LEN, "delete", 1, 2, Tix_HLDelete,
	   "option ?entryPath?"},
	{TIX_DEFAULT_LEN, "dragsite", 1, 2, Tix_HLSetSite,
	   "option ?entryPath?"},
	{TIX_DEFAULT_LEN, "dropsite", 1, 2, Tix_HLSetSite,
	   "option ?entryPath?"},
	{TIX_DEFAULT_LEN, "entrycget", 2, 2, Tix_HLEntryCget,
	   "entryPath option"},
	{TIX_DEFAULT_LEN, "entryconfigure", 1, TIX_VAR_ARGS, Tix_HLEntryConfig,
	   "entryPath ?option? ?value? ?option value ... ?"},
	{TIX_DEFAULT_LEN, "geometryinfo", 0, 2, Tix_HLGeometryInfo,
	   "?width height?"},
	{TIX_DEFAULT_LEN, "hide", 2, 2, Tix_HLHide,
	   "option entryPath"},
	{TIX_DEFAULT_LEN, "item", 0, TIX_VAR_ARGS, Tix_HLItem,
	   "?option? ?args ...?"},
	{TIX_DEFAULT_LEN, "info", 1, TIX_VAR_ARGS, Tix_HLInfo,
	   "option ?args ...?"},
	{TIX_DEFAULT_LEN, "nearest", 1, 1, Tix_HLNearest,
	   "y"},
	{TIX_DEFAULT_LEN, "see", 1, 1, Tix_HLSee,
	   "entryPath"},
	{TIX_DEFAULT_LEN, "selection", 1, 3, Tix_HLSelection,
	   "option arg ?arg ...?"},
	{TIX_DEFAULT_LEN, "show", 2, 2, Tix_HLShow,
	   "option entryPath"},
	{TIX_DEFAULT_LEN, "xview", 0, 3, Tix_HLXView,
	   "args"},
	{TIX_DEFAULT_LEN, "yview", 0, 3, Tix_HLYView,
	   "args"},
    };

    static Tix_CmdInfo cmdInfo = {
	Tix_ArraySize(subCmdInfo), 1, TIX_VAR_ARGS, "?option? arg ?arg ...?",
    };

    Tk_Preserve(clientData);
    code = Tix_HandleSubCmds(&cmdInfo, subCmdInfo, clientData,
	interp, argc, args);
    Tk_Release(clientData);

    return code;
}

/*----------------------------------------------------------------------
 * "add" sub command -- 
 *
 *	Add a new item into the list
 *----------------------------------------------------------------------
 */
static int
Tix_HLAdd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    char * pathName = LangString(args[0]);

    argc --;
    args ++;

    if ((chPtr = NewElement(interp, wPtr, argc, args, pathName,
	 NULL, &argc)) == NULL) {
	return TCL_ERROR;
    }

    if (argc > 0) {
	if (ConfigElement(wPtr, chPtr, argc, args, 0, 1) != TCL_OK) {
	    DeleteNode(wPtr, chPtr);
	    return TCL_ERROR;
	}
    } else {
	if (Tix_DItemConfigure(chPtr->col[0].iPtr, 0, 0, 0) != TCL_OK) {
	    DeleteNode(wPtr, chPtr);
	    return TCL_ERROR;
	}
    }

    Tcl_AppendResult(interp, chPtr->pathName, NULL);	
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "addchild" sub command --
 *
 *	Replacement for "add" sub command: it is more flexible and
 *	you can have default names for entries.
 *
 *	Add a new item into the list
 *----------------------------------------------------------------------
 */
static int
Tix_HLAddChild(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    char * parentName;

    parentName = LangString(args[0]);
    if (LangString(args[0]) && strcmp(LangString(args[0]), "") == 0) {
	parentName = NULL;
    }

    argc --;
    args ++;
    if ((chPtr = NewElement(interp, wPtr, argc, args, NULL,
	 parentName, &argc)) == NULL) {
	return TCL_ERROR;
    }

    if (argc > 0) {
	if (ConfigElement(wPtr, chPtr, argc, args, 0, 1) != TCL_OK) {
	    DeleteNode(wPtr, chPtr);
	    return TCL_ERROR;
	}
    } else {
	if (Tix_DItemConfigure(chPtr->col[0].iPtr, 0, 0, 0) != TCL_OK) {
	    DeleteNode(wPtr, chPtr);
	    return TCL_ERROR;
	}
    }

    Tcl_AppendResult(interp, chPtr->pathName, NULL);	
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "anchor", "dragsite" and "dropsire" sub commands --
 *
 *	Set/remove the anchor element
 *----------------------------------------------------------------------
 */
static int
Tix_HLSetSite(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    int changed = 0;
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    HListElement ** changePtr;
    size_t len ;

    /* Determine which site should be changed
     **/
    len = strlen(LangString(args[-1]));
    if (strncmp(LangString(args[-1]), "anchor", len)==0) {
	changePtr = &wPtr->anchor;
    }
    else if (strncmp(LangString(args[-1]), "dragsite", len)==0) {
	changePtr = &wPtr->dragSite;
    }
    else {
	changePtr = &wPtr->dropSite;
    }

    len = strlen(LangString(args[0]));
    if (strncmp(LangString(args[0]), "set", len)==0) {
	if (argc == 2) {
	    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
		return TCL_ERROR;
	    }
	    if (*changePtr != chPtr) {
		*changePtr = chPtr;
		changed = 1;
	    }
	} else {
	    Tcl_AppendResult(interp, "wrong # of arguments, must be: ",
		Tk_PathName(wPtr->dispData.tkwin), " ", LangString(args[-1]),
		" set entryPath", NULL);
	    return TCL_ERROR;
	}
    }
    else if (strncmp(LangString(args[0]), "clear", len)==0) {
	if (*changePtr != NULL) {
	    *changePtr = NULL;
	    changed = 1;
	}
    }
    else {
	Tcl_AppendResult(interp, "wrong option \"", LangString(args[0]), "\", ",
	    "must be clear or set", NULL);
	return TCL_ERROR;
    }

    if (changed) {
	RedrawWhenIdle(wPtr);
    }

    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "cget" sub command --
 *----------------------------------------------------------------------
 */
static int
Tix_HLCGet(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;

    return Tk_ConfigureValue(interp, wPtr->dispData.tkwin, configSpecs,
		(char *)wPtr, LangString(args[0]), 0);
}

/*----------------------------------------------------------------------
 * "configure" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLConfig(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;

    if (argc == 0) {
	return Tk_ConfigureInfo(interp, wPtr->dispData.tkwin, configSpecs,
	    (char *) wPtr,          NULL, 0);
    } else if (argc == 1) {
	return Tk_ConfigureInfo(interp, wPtr->dispData.tkwin, configSpecs,
	    (char *) wPtr, LangString(args[0]), 0);
    } else {
	return WidgetConfigure(interp, wPtr, argc, args,
	    TK_CONFIG_ARGV_ONLY);
    }
}

/*----------------------------------------------------------------------
 * "delete" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLDelete(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    size_t len;

    if (strcmp(LangString(args[0]), "all") == 0) {
	Tix_HLMarkElementDirty(wPtr, wPtr->root);
	DeleteOffsprings(wPtr, wPtr->root);

	Tix_HLResizeWhenIdle(wPtr);
	return TCL_OK;
    }
    len = strlen(LangString(args[0]));

    if (argc != 2) {
	if ((strncmp(LangString(args[0]), "entry", len) == 0) ||
	    (strncmp(LangString(args[0]), "offsprings", len) == 0) ||
	    (strncmp(LangString(args[0]), "siblings", len) == 0)) {

	    goto wrong_arg;
	}
	else {
	    goto wrong_option;
	}
    }

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	return TCL_ERROR;
    }

    if (strncmp(LangString(args[0]), "entry", len) == 0) {
	Tix_HLMarkElementDirty(wPtr, chPtr->parent);
	DeleteNode(wPtr, chPtr);
    }
    else if (strncmp(LangString(args[0]), "offsprings", len) == 0) {
	Tix_HLMarkElementDirty(wPtr, chPtr);
	DeleteOffsprings(wPtr, chPtr);
    }
    else if (strncmp(LangString(args[0]), "siblings", len) == 0) {
	Tix_HLMarkElementDirty(wPtr, chPtr);
	DeleteSiblings(wPtr, chPtr);
    }
    else {
	goto wrong_arg;
    }

    Tix_HLResizeWhenIdle(wPtr);
    return TCL_OK;

wrong_arg:

    Tcl_AppendResult(interp, 
	"wrong # of arguments, should be pathName delete ", LangString(args[0]),
	" entryPath", NULL);
    return TCL_ERROR;

wrong_option:

    Tcl_AppendResult(interp, "unknown option \"", LangString(args[0]),
	"\" must be all, entry, offsprings or siblings", NULL);
    return TCL_ERROR;

}

/*----------------------------------------------------------------------
 * "entrycget" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLEntryCget(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[0]))) == NULL) {
	return TCL_ERROR;
    }
    if (chPtr->col[0].iPtr == NULL) {
	Tcl_AppendResult(interp, "Item \"", LangString(args[0]), 
	    "\" does not exist",          NULL);
	return TCL_ERROR;
    }
    return Tix_ConfigureValue2(interp, wPtr->dispData.tkwin, (char *)chPtr,
	entryConfigSpecs, chPtr->col[0].iPtr, LangString(args[1]), 0);
}

/*----------------------------------------------------------------------
 * "entryconfigure" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLEntryConfig(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[0]))) == NULL) {
	return TCL_ERROR;
    }

    if (argc == 1) {
	return Tix_ConfigureInfo2(interp, wPtr->dispData.tkwin,
	    (char*)chPtr, entryConfigSpecs, chPtr->col[0].iPtr,
	             NULL, 0);
    } else if (argc == 2) {
	return Tix_ConfigureInfo2(interp, wPtr->dispData.tkwin,
	    (char*)chPtr, entryConfigSpecs, chPtr->col[0].iPtr,
	    (char *) LangString(args[1]), 0);
    } else {
	return ConfigElement(wPtr, chPtr, argc-1, args+1,
	    TK_CONFIG_ARGV_ONLY, 0);
    }
}

/*----------------------------------------------------------------------
 * "geometryinfo" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLGeometryInfo(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    int qSize[2];
    double first[2], last[2];
    char string[80];

    if (argc == 2) {
	if (Tcl_GetInt(interp, args[0], &qSize[0]) != TCL_OK) {
	    return TCL_ERROR;
	}
	if (Tcl_GetInt(interp, args[1], &qSize[1]) != TCL_OK) {
	    return TCL_ERROR;
	}
    } else {
	qSize[0] = Tk_Width(wPtr->dispData.tkwin);
	qSize[1] = Tk_Height(wPtr->dispData.tkwin);
    }
    qSize[0] -= 2*wPtr->borderWidth + 2*wPtr->highlightWidth;
    qSize[1] -= 2*wPtr->borderWidth + 2*wPtr->highlightWidth;

    Tix_GetScrollFractions(wPtr->totalSize[0], qSize[0], wPtr->leftPixel,
	&first[0], &last[0]);
    Tix_GetScrollFractions(wPtr->totalSize[1], qSize[1], wPtr->topPixel,
	&first[1], &last[1]);

    sprintf(string, "{%f %f} {%f %f}", first[0], last[0], first[1], last[1]);
    Tcl_AppendResult(interp, string, NULL);

    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "hide" sub command
 *----------------------------------------------------------------------
 */

/* %% ToDo: implement the siblings ... etc options, to match those of "delete"
 */
static int
Tix_HLHide(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;

#if 0
    size_t len = strlen(LangString(args[1]));
#endif

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	return TCL_ERROR;
    }

    Tix_HLMarkElementDirty(wPtr, chPtr->parent);
    chPtr->hidden = 1;

    Tix_HLResizeWhenIdle(wPtr);
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "show" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLShow(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;

#if 0
    size_t len = strlen(LangString(args[1]));
#endif

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	return TCL_ERROR;
    }

    Tix_HLMarkElementDirty(wPtr, chPtr->parent);
    chPtr->hidden = 0;

    Tix_HLResizeWhenIdle(wPtr);
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "info" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLInfo(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    size_t len = strlen(LangString(args[0]));
    
    if (strncmp(LangString(args[0]), "anchor", len)==0) {
	if (wPtr->anchor) {
	    Tcl_AppendResult(interp, wPtr->anchor->pathName, NULL);
	}
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "children", len)==0) {
	HListElement * ptr;

	if (argc == 1) {
	    chPtr = wPtr->root;
	} else {
	    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
		return TCL_ERROR;
	    }
	}

	for (ptr=chPtr->childHead; ptr; ptr=ptr->next) {
	    Tcl_AppendElement(interp, ptr->pathName);
	}
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "data", len)==0) {
	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    return TCL_ERROR;
	}

	Tcl_AppendResult(interp, chPtr->data, NULL);
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "dragsite", len)==0) {
	if (wPtr->dragSite) {
	    Tcl_AppendResult(interp, wPtr->dragSite->pathName, NULL);
	}
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "dropsite", len)==0) {
	if (wPtr->dropSite) {
	    Tcl_AppendResult(interp, wPtr->dropSite->pathName, NULL);
	}
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "exists", len)==0) {
	chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]));

	if (chPtr) {
	    Tcl_AppendResult(interp, "1", NULL);
	} else {
	    Tcl_ResetResult(interp);
	    Tcl_AppendResult(interp, "0", NULL);
	}
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "hidden", len)==0) {
	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    return TCL_ERROR;
	}
	if (chPtr->hidden) {
	    Tcl_AppendElement(interp, "1");
	} else {
	    Tcl_AppendElement(interp, "0");
	}

	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "next", len)==0) {
	HListElement * nextPtr;

	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    return TCL_ERROR;
	}
	nextPtr = FindNextEntry(wPtr, chPtr);
	if (nextPtr) {
	    Tcl_AppendResult(interp, nextPtr->pathName, NULL);
	}	    

	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "parent", len)==0) {
	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    return TCL_ERROR;
	}

	Tcl_AppendResult(interp, chPtr->parent->pathName, NULL);
	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "prev", len)==0) {
	HListElement * nextPtr;

	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    return TCL_ERROR;
	}
	nextPtr = FindPrevEntry(wPtr, chPtr);
	if (nextPtr) {
	    Tcl_AppendResult(interp, nextPtr->pathName, NULL);
	}	    

	return TCL_OK;
    }
    else if (strncmp(LangString(args[0]), "selection", len)==0) {
	return CurSelection(interp, wPtr, wPtr->root);
    }
    else {
	Tcl_AppendResult(interp, "unknown option \"", LangString(args[0]), 
	    "\": must be anchor, children, data, dragsite, dropsite, exists, ",
	    "hidden, next, parent, prev or selection",
	    NULL);
	return TCL_ERROR;
    }
}

/*----------------------------------------------------------------------
 * "nearest" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLNearest(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int y;

    if (Tcl_GetInt(interp, args[0], &y) != TCL_OK) {
	return TCL_ERROR;
    }
    if (wPtr->root->dirty || wPtr->allDirty) {
	/* We must update the geometry NOW otherwise we will get a wrong entry
	 */
	CancelResizeWhenIdle(wPtr);
	WidgetComputeGeometry((ClientData)wPtr);
    }

    if ((chPtr = FindElementAtPosition(wPtr, y)) != NULL) {
	Tcl_AppendResult(interp, chPtr->pathName, NULL);
    }
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "see" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLSee(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int x, y;
    int cXSize, cYSize;		/* element size */
    int wXSize, wYSize;		/* size of the listbox window area */
    int top, left;		/* new top and left offset of the HLIst */

    if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[0]))) == NULL) {
	return TCL_ERROR;
    }

    x = ElementLeftPixel(wPtr, chPtr);
    y = ElementTopPixel(wPtr, chPtr);
    if (chPtr->col[0].iPtr) {
	cXSize = Tix_DItemWidth(chPtr->col[0].iPtr);
    } else {
	cXSize = chPtr->col[0].width;
    }
    cYSize = chPtr->height;
    wXSize = Tk_Width(wPtr->dispData.tkwin) - 
      (2*wPtr->borderWidth + 2*wPtr->highlightWidth);
    wYSize = Tk_Height(wPtr->dispData.tkwin) -
      (2*wPtr->borderWidth + 2*wPtr->highlightWidth);

    if (wXSize < 0 || wYSize < 0) {
	/* The window is probably not visible */
	return TCL_OK;
    }

    /* Align on the X direction */
    left = wPtr->leftPixel;
    if ((x < wPtr->leftPixel) || (x+cXSize > wPtr->leftPixel+wXSize)) {
	if (wXSize > cXSize) {
	    left = x - (wXSize-cXSize)/2;
	} else {
	    left = x;
	}
    }

    /* Align on the Y direction */
    top = wPtr->topPixel;

    if ((wPtr->topPixel-y) > wYSize || (y-wPtr->topPixel-wYSize) > wYSize) {
	/* far away, make it middle */
	top = y - (wYSize-cYSize)/2;
    }
    else if (y < wPtr->topPixel) {
	top = y;
    }
    else if (y+cYSize > wPtr->topPixel+wYSize){
	top = y+cYSize - wYSize ;
    }
    wPtr->leftPixel = left;
    wPtr->topPixel  = top;

    UpdateScrollBars(wPtr, 0);
    RedrawWhenIdle(wPtr);

    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "selection" sub command
 * 	Modify the selection in this HList box
 *----------------------------------------------------------------------
 */
static int
Tix_HLSelection(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    size_t len = strlen(LangString(args[0]));
    int code = TCL_OK;
    int changed = 0;

    if (strncmp(LangString(args[0]), "clear", len)==0) {
	if (argc == 1) {
	    HL_SelectionClearAll(wPtr, wPtr->root);
	    changed = 1;
	}
	else {
	    HListElement * from = NULL;
	    HListElement * to   = NULL;

	    if ((from = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
		code = TCL_ERROR;
		goto done;
	    }
	    
	    if (argc == 3) {
		if ((to = Tix_HLFindElement(interp, wPtr, LangString(args[2]))) == NULL) {
		    code = TCL_ERROR;
		    goto done;
		}
	    }
	    
	    if (to == NULL) {
		if (from->selected == 1) {
		    HL_SelectionClear(wPtr, from);
		    changed = 1;
		}
	    }
	    else {
		changed = SelectionModifyRange(wPtr, from, to, 0);
	    }
	}
    }
    else if (strncmp(LangString(args[0]), "includes", len)==0) {
	if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    code = TCL_ERROR;
	    goto done;
	}
	if (chPtr->selected) {
	    Tcl_AppendResult(interp, "1", NULL);
	} else {
	    Tcl_AppendResult(interp, "0", NULL);
	}
    }
    else if (strncmp(LangString(args[0]), "set", len)==0) {
	HListElement * from = NULL;
	HListElement * to   = NULL;

	if (argc < 2 || argc > 3) {
	    Tix_ArgcError(interp, argc+2, args-2, 3, "from ?to?");
	    code = TCL_ERROR;
	    goto done;
	}

	if ((from = Tix_HLFindElement(interp, wPtr, LangString(args[1]))) == NULL) {
	    code = TCL_ERROR;
	    goto done;
	}

	if (argc == 3) {
	    if ((to = Tix_HLFindElement(interp, wPtr, LangString(args[2]))) == NULL) {
		code = TCL_ERROR;
		goto done;
	    }
	}

	if (to == NULL) {
	    if (!from->selected && !from->hidden) {
		SelectionAdd(wPtr, from);
		changed = 1;
	    }
	}
	else {
	    changed = SelectionModifyRange(wPtr, from, to, 1);
	}
    }
    else {
	Tcl_AppendResult(interp, "unknown option \"", LangString(args[0]), 
	    "\": must be anchor, clear, includes or set", NULL);
	code = TCL_ERROR;
    }

  done:
    if (changed) {
	RedrawWhenIdle(wPtr);
    }

    return code;
}

/*----------------------------------------------------------------------
 * "xview" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLXView(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int leftPixel;

    if (argc == 0) {
	char string[20];

	sprintf(string, "%d", wPtr->leftPixel);
	Tcl_AppendResult(interp, string, NULL);
	return TCL_OK;
    }
    else if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[0]))) != NULL) {
	leftPixel = ElementLeftPixel(wPtr, chPtr);
    }
    else if (Tcl_GetInt(interp, args[0], &leftPixel) == TCL_OK) {
	/* %% todo backward-compatible mode */

    }
    else {
	int type, count;
	double fraction;

	Tcl_ResetResult(interp);

	/* Tk_GetScrollInfo () wants strange argc,args combinations .. */
	type = Tk_GetScrollInfo(interp, argc+2, args-2, &fraction, &count);
	switch (type) {
	  case TK_SCROLL_ERROR:
	    return TCL_ERROR;

	  case TK_SCROLL_MOVETO:
	    leftPixel = (int)(fraction * (double)wPtr->totalSize[0]);
	    break;

	  case TK_SCROLL_PAGES:
	    leftPixel = XScrollByPages(wPtr, count);
	    break;

	  case TK_SCROLL_UNITS:
	    leftPixel = XScrollByUnits(wPtr, count);
	    break;
	}
    }

    wPtr->leftPixel = leftPixel;
    UpdateScrollBars(wPtr, 0);

    RedrawWhenIdle(wPtr);

    Tcl_ResetResult(interp);
    return TCL_OK;
}

/*----------------------------------------------------------------------
 * "yview" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLYView(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int topPixel;


    if (argc == 0) {
	char string[20];

	sprintf(string, "%d", wPtr->topPixel);
	Tcl_AppendResult(interp, string, NULL);
	return TCL_OK;
    }
    else if ((chPtr = Tix_HLFindElement(interp, wPtr, LangString(args[0]))) != NULL) {
	topPixel = ElementTopPixel(wPtr, chPtr);
    }
    else if (Tcl_GetInt(interp, args[0], &topPixel) == TCL_OK) {
	/* %% todo backward-compatible mode */
    }
    else {
	int type, count;
	double fraction;

	Tcl_ResetResult(interp);

	/* Tk_GetScrollInfo () wants strange argc,args combinations .. */
	type = Tk_GetScrollInfo(interp, argc+2, args-2, &fraction, &count);
	switch (type) {
	  case TK_SCROLL_ERROR:
	    return TCL_ERROR;

	  case TK_SCROLL_MOVETO:
	    topPixel = (int)(fraction * (double)wPtr->totalSize[1]);
	    break;

	  case TK_SCROLL_PAGES:
	    topPixel = YScrollByPages(wPtr, count);
	    break;

	  case TK_SCROLL_UNITS:
	    topPixel = YScrollByUnits(wPtr, count);
	    break;
	}
    }

    wPtr->topPixel = topPixel;
    UpdateScrollBars(wPtr, 0);

    RedrawWhenIdle(wPtr);

    Tcl_ResetResult(interp);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * WidgetConfigure --
 *
 *	This procedure is called to process an args/argc list in
 *	conjunction with the Tk option database to configure (or
 *	reconfigure) a HList widget.
 *
 * Results:
 *	The return value is a standard Tcl result.  If TCL_ERROR is
 *	returned, then Tcl_GetResult(interp) contains an error message.
 *
 * Side effects:
 *	Configuration information, such as colors, border width,
 *	etc. get set for wPtr;  old resources get freed,
 *	if there were any.
 *
 *----------------------------------------------------------------------
 */
static int
WidgetConfigure(interp, wPtr, argc, args, flags)
    Tcl_Interp *interp;			/* Used for error reporting. */
    WidgetPtr wPtr;			/* Information about widget. */
    int argc;				/* Number of valid entries in args. */
    Arg *args;			/* Arguments. */
    int flags;				/* Flags to pass to
					 * Tk_ConfigureWidget. */
{
    XGCValues gcValues;
    GC newGC;
    XFontStruct *oldFontPtr;
    int oldColumns;
    Tix_StyleTemplate stTmpl;

    oldFontPtr = wPtr->fontPtr;
    oldColumns = wPtr->numColumns;
    if (Tk_ConfigureWidget(interp, wPtr->dispData.tkwin, configSpecs,
	    argc, args, (char *) wPtr, flags) != TCL_OK) {
	return TCL_ERROR;
    }

    if (wPtr->initialized && oldColumns != wPtr->numColumns) {
	Tcl_AppendResult(interp, "Cannot change the number of columns ",
	             NULL);
	wPtr->numColumns = oldColumns;
	return TCL_ERROR;
    }
    if (wPtr->numColumns < 1) {
	wPtr->numColumns = 1;
    }

    if (wPtr->separator == 0 || wPtr->separator[0] == 0) {
	if (wPtr->separator != 0) {
	    ckfree(wPtr->separator);
	}
	wPtr->separator = (char*)strdup(".");
    }

    if (oldFontPtr != wPtr->fontPtr) {
	/* Font has been changed (initialized) */
	TkComputeTextGeometry(wPtr->fontPtr, "0", 1,
	    0, &wPtr->scrollUnit[0], &wPtr->scrollUnit[1]);
    }

    /*
     * A few options need special processing, such as setting the
     * background from a 3-D border, or filling in complicated
     * defaults that couldn't be specified to Tk_ConfigureWidget.
     */

    Tk_SetBackgroundFromBorder(wPtr->dispData.tkwin, wPtr->border);

    /*
     * Note: GraphicsExpose events are disabled in normalGC because it's
     * used to copy stuff from an off-screen pixmap onto the screen (we know
     * that there's no problem with obscured areas).
     */

    /* The background GC */
    gcValues.foreground 	= wPtr->normalBg->pixel;
    gcValues.graphics_exposures = False;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCGraphicsExposures, &gcValues);
    if (wPtr->backgroundGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->backgroundGC);
    }
    wPtr->backgroundGC = newGC;

    /* The normal text GC */
    gcValues.font 		= wPtr->fontPtr->fid;
    gcValues.foreground 	= wPtr->normalFg->pixel;
    gcValues.background 	= wPtr->normalBg->pixel;
    gcValues.graphics_exposures = False;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCBackground|GCFont|GCGraphicsExposures, &gcValues);
    if (wPtr->normalGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->normalGC);
    }
    wPtr->normalGC = newGC;

    /* The selected text GC */
    gcValues.font 		= wPtr->fontPtr->fid;
    gcValues.foreground 	= wPtr->selectFg->pixel;
    gcValues.background 	= Tk_3DBorderColor(wPtr->selectBorder)->pixel;
    gcValues.graphics_exposures = False;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCBackground|GCFont|GCGraphicsExposures, &gcValues);
    if (wPtr->selectGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->selectGC);
    }
    wPtr->selectGC = newGC;

    /* The dotted anchor lines */
    gcValues.foreground 	= wPtr->normalFg->pixel;
    gcValues.background 	= wPtr->normalBg->pixel;
    gcValues.graphics_exposures = False;
    gcValues.line_style         = LineDoubleDash;
    gcValues.dashes 		= 2;
    gcValues.subwindow_mode	= IncludeInferiors;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCBackground|GCGraphicsExposures|GCLineStyle|GCDashList|
	    GCSubwindowMode, &gcValues);
    if (wPtr->anchorGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->anchorGC);
    }
    wPtr->anchorGC = newGC;

    /* The sloid dropsite lines */
    gcValues.foreground 	= wPtr->normalFg->pixel;
    gcValues.background 	= wPtr->normalBg->pixel;
    gcValues.graphics_exposures = False;
    gcValues.subwindow_mode	= IncludeInferiors;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCBackground|GCGraphicsExposures|GCSubwindowMode,
	    &gcValues);
    if (wPtr->dropSiteGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->dropSiteGC);
    }
    wPtr->dropSiteGC = newGC;

    /* The highlight border */
    gcValues.background 	= wPtr->selectFg->pixel;
    gcValues.foreground 	= wPtr->highlightColorPtr->pixel;
    gcValues.subwindow_mode	= IncludeInferiors;

    newGC = Tk_GetGC(wPtr->dispData.tkwin,
	GCForeground|GCBackground|GCGraphicsExposures, &gcValues);
    if (wPtr->highlightGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->highlightGC);
    }
    wPtr->highlightGC = newGC;

    /* We must set the options of the default styles so that
     * -- the default styles will change according to what is in
     *    stTmpl
     */
    stTmpl.fontPtr 			= wPtr->fontPtr;
    stTmpl.pad[0]  			= wPtr->padX;
    stTmpl.pad[1]  			= wPtr->padY;
    stTmpl.colors[TIX_DITEM_NORMAL].fg  = wPtr->normalFg;
    stTmpl.colors[TIX_DITEM_NORMAL].bg  = wPtr->normalBg;
    stTmpl.colors[TIX_DITEM_SELECTED].fg= wPtr->selectFg;
    stTmpl.colors[TIX_DITEM_SELECTED].bg= Tk_3DBorderColor(wPtr->selectBorder);
    stTmpl.flags = TIX_DITEM_FONT|TIX_DITEM_NORMAL_BG|
	TIX_DITEM_SELECTED_BG|TIX_DITEM_NORMAL_FG|TIX_DITEM_SELECTED_FG |
	TIX_DITEM_PADX|TIX_DITEM_PADY;
    Tix_SetDefaultStyleTemplate(wPtr->dispData.tkwin, &stTmpl);

    /* Probably the size of the elements in this has changed */
    Tix_HLResizeWhenIdle(wPtr);

    return TCL_OK;
}

/*
 *--------------------------------------------------------------
 *
 * WidgetEventProc --
 *
 *	This procedure is invoked by the Tk dispatcher for various
 *	events on HLists.
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
WidgetEventProc(clientData, eventPtr)
    ClientData clientData;	/* Information about window. */
    XEvent *eventPtr;		/* Information about event. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;

    switch (eventPtr->type) {
      case DestroyNotify:
	if (wPtr->dispData.tkwin != NULL) {
	    wPtr->dispData.tkwin = NULL;
	    Lang_DeleteWidget(wPtr->dispData.interp,wPtr->widgetCmd);

	}
	CancelResizeWhenIdle(wPtr);
	CancelRedrawWhenIdle(wPtr);
	Tk_EventuallyFree((ClientData) wPtr, WidgetDestroy);
	break;

      case ConfigureNotify:
	RedrawWhenIdle(wPtr);
	UpdateScrollBars(wPtr, 1);
	break;

      case Expose:
	RedrawWhenIdle(wPtr);
	break;

      case FocusIn:
	wPtr->hasFocus = 1;
	RedrawWhenIdle(wPtr);
	break;

      case FocusOut:
	wPtr->hasFocus = 0;
	RedrawWhenIdle(wPtr);
	break;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * WidgetDestroy --
 *
 *	This procedure is invoked by Tk_EventuallyFree or Tk_Release
 *	to clean up the internal structure of a HList at a safe time
 *	(when no-one is using it anymore).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Everything associated with the HList is freed up.
 *
 *----------------------------------------------------------------------
 */
static void
WidgetDestroy(clientData)
    ClientData clientData;	/* Info about my widget. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;

    if (wPtr->root != NULL) {
	DeleteOffsprings(wPtr, wPtr->root);
	FreeElement(wPtr, wPtr->root);
    }

    if (wPtr->backgroundGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->backgroundGC);
    }
    if (wPtr->normalGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->normalGC);
    }
    if (wPtr->selectGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->selectGC);
    }
    if (wPtr->anchorGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->anchorGC);
    }
    if (wPtr->dropSiteGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->dropSiteGC);
    }
    if (wPtr->highlightGC != None) {
	Tk_FreeGC(wPtr->dispData.display, wPtr->highlightGC);
    }
    if (wPtr->reqSize != NULL) {
	ckfree((char*)wPtr->reqSize);
    }
    if (wPtr->actualSize != NULL) {
	ckfree((char*)wPtr->actualSize);
    }

    if (!Tix_IsLinkListEmpty(wPtr->mappedWindows)) {
	/*
	 * All mapped windows should have been unmapped when the
	 * the entries were deleted
	 */
	panic("tixHList: mappedWindows not NULL");
    }

    Tk_FreeOptions(configSpecs, (char *) wPtr, wPtr->dispData.display, 0);
    ckfree((char *) wPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * WidgetCmdDeletedProc --
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
WidgetCmdDeletedProc(clientData)
    ClientData clientData;	/* Pointer to widget record for widget. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;

    /*
     * This procedure could be invoked either because the window was
     * destroyed and the command was then deleted (in which case tkwin
     * is NULL) or because the command was deleted, and then this procedure
     * destroys the widget.
     */
    if (wPtr->dispData.tkwin != NULL) {
	Tk_Window tkwin = wPtr->dispData.tkwin;
	wPtr->dispData.tkwin = NULL;
	Tk_DestroyWindow(tkwin);
    }
}

/*
 *--------------------------------------------------------------
 *
 * WidgetComputeGeometry --
 *
 *	This procedure is invoked to process the Tcl command
 *	that corresponds to a widget managed by this module.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	none
 *
 *--------------------------------------------------------------
 */
static void
WidgetComputeGeometry(clientData)
    ClientData clientData;
{
    WidgetPtr wPtr = (WidgetPtr)clientData;
    int i, reqW, reqH;
    int sizeChanged = 0;
    int width = 0;
    wPtr->resizing = 0;

    /* Update geometry request */
    if (wPtr->root->dirty || wPtr->allDirty) {
	ComputeElementGeometry(wPtr, wPtr->root, 0);
	width = 0;
	for (i=0; i<wPtr->numColumns; i++) {
	    if (wPtr->reqSize[i].width != UNINITIALIZED) {
		wPtr->actualSize[i].width = wPtr->reqSize[i].width;
	    }
	    else {
		wPtr->actualSize[i].width = wPtr->root->col[i].width;
	    }
	    width += wPtr->actualSize[i].width;
	}
	sizeChanged = 1;
	wPtr->allDirty = 0;
    }
    wPtr->totalSize[0] = width;
    wPtr->totalSize[1] = wPtr->root->allHeight;

    if (wPtr->width > 0) {
	reqW = wPtr->width * wPtr->scrollUnit[0];
    } else {
	reqW = width;
    }
    if (wPtr->height > 0) {
	reqH = wPtr->height * wPtr->scrollUnit[1];
    } else {
	reqH = wPtr->root->allHeight;
    }

    wPtr->totalSize[0] += 2*wPtr->borderWidth + 2*wPtr->highlightWidth;
    wPtr->totalSize[1] += 2*wPtr->borderWidth + 2*wPtr->highlightWidth;
    reqW 	       += 2*wPtr->borderWidth + 2*wPtr->highlightWidth;
    reqH 	       += 2*wPtr->borderWidth + 2*wPtr->highlightWidth;

    /* Now we need to handle the multiple columns mode */

    Tk_GeometryRequest(wPtr->dispData.tkwin, reqW, reqH);

    /* Update scrollbars */
    UpdateScrollBars(wPtr, sizeChanged);

    RedrawWhenIdle(wPtr);
}

/*
 *----------------------------------------------------------------------
 * Tix_HLResizeWhenIdle --
 *----------------------------------------------------------------------
 */
void
Tix_HLResizeWhenIdle(wPtr)
    WidgetPtr wPtr;
{
    if (!wPtr->resizing) {
	wPtr->resizing = 1;
	Tk_DoWhenIdle(WidgetComputeGeometry, (ClientData)wPtr);
    }
    if (wPtr->redrawing) {
	CancelRedrawWhenIdle(wPtr);
    }
}

/*
 *----------------------------------------------------------------------
 * CancelResizeWhenIdle --
 *----------------------------------------------------------------------
 */
static void
CancelResizeWhenIdle(wPtr)
    WidgetPtr wPtr;
{
    if (wPtr->resizing) {
	wPtr->resizing = 0;
	Tk_CancelIdleCall(WidgetComputeGeometry, (ClientData)wPtr);
    }
}

/*
 *----------------------------------------------------------------------
 * RedrawWhenIdle --
 *----------------------------------------------------------------------
 */
static void
RedrawWhenIdle(wPtr)
    WidgetPtr wPtr;
{
    if (!wPtr->redrawing && Tk_IsMapped(wPtr->dispData.tkwin)) {
	wPtr->redrawing = 1;
	Tk_DoWhenIdle(WidgetDisplay, (ClientData)wPtr);
    }
}

/*
 *----------------------------------------------------------------------
 * CancelRedrawWhenIdle --
 *----------------------------------------------------------------------
 */
static void
CancelRedrawWhenIdle(wPtr)
    WidgetPtr wPtr;
{
    if (wPtr->redrawing) {
	wPtr->redrawing = 0;
	Tk_CancelIdleCall(WidgetDisplay, (ClientData)wPtr);
    }
}
/*
 *----------------------------------------------------------------------
 *
 * WidgetDisplay --
 *
 *	Draw the widget to the screen.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *
 *----------------------------------------------------------------------
 */
static void
WidgetDisplay(clientData)
    ClientData clientData;	/* Info about my widget. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    Pixmap pixmap;
    Tk_Window tkwin = wPtr->dispData.tkwin;

    wPtr->redrawing = 0;		/* clear the redraw flag */
    wPtr->serial ++;

    if (wPtr->wideSelect) {
	wPtr->selectWidth = Tk_Width(wPtr->dispData.tkwin) - 
	  (2*wPtr->borderWidth + 2*wPtr->highlightWidth);
	if (wPtr->selectWidth < wPtr->totalSize[0]) {
	    wPtr->selectWidth = wPtr->totalSize[0];
	}
    }

    pixmap = Tk_GetPixmap(wPtr->dispData.display, Tk_WindowId(tkwin),
	Tk_Width(tkwin), Tk_Height(tkwin), Tk_Depth(tkwin));

    /* Fill the background */
    XFillRectangle(wPtr->dispData.display, pixmap, wPtr->backgroundGC,
	0, 0, Tk_Width(tkwin), Tk_Height(tkwin));

    /* Used to clip off elements that are too low to see */
    wPtr->bottomPixel = Tk_Height(wPtr->dispData.tkwin) - 2*wPtr->borderWidth
      - 2*wPtr->highlightWidth;

    DrawElements(wPtr, pixmap, wPtr->normalGC, wPtr->root,
	wPtr->borderWidth + wPtr->highlightWidth - wPtr->leftPixel, 
	wPtr->borderWidth + wPtr->highlightWidth - wPtr->topPixel,
	wPtr->borderWidth + wPtr->highlightWidth - wPtr->leftPixel);

    if (wPtr->borderWidth > 0) {
        /* Draw the border */
        Tk_Draw3DRectangle(wPtr->dispData.tkwin, pixmap, wPtr->border,
	    wPtr->highlightWidth, wPtr->highlightWidth,
	    Tk_Width(tkwin)  - 2*wPtr->highlightWidth, 
	    Tk_Height(tkwin) - 2*wPtr->highlightWidth, wPtr->borderWidth,
	    wPtr->relief);
    }

    if (wPtr->highlightWidth > 0) {
	/* Draw the highlight */
	GC gc;

	if (wPtr->hasFocus) {
	    gc = wPtr->highlightGC;
	} else {
	    gc = Tk_3DBorderGC(wPtr->dispData.tkwin, wPtr->border,
		TK_3D_FLAT_GC);
	}
	Tk_DrawFocusHighlight(tkwin, gc, wPtr->highlightWidth, pixmap);
    }

    /*
     * Copy the information from the off-screen pixmap onto the screen,
     * then delete the pixmap.
     */

    XCopyArea(wPtr->dispData.display, pixmap, Tk_WindowId(tkwin),
	wPtr->normalGC, 0, 0, Tk_Width(tkwin), Tk_Height(tkwin), 0, 0);
    Tk_FreePixmap(wPtr->dispData.display, pixmap);

    /* unmap those windows we mapped the last time */
    Tix_UnmapInvisibleWindowItems(&wPtr->mappedWindows, wPtr->serial);
}

/*
 *----------------------------------------------------------------------
 *
 * DrawElements --
 *--------------------------------------------------------------
 */
static void DrawElements(wPtr, pixmap, gc, chPtr, x, y, xOffset)
    WidgetPtr wPtr;
    Pixmap pixmap;
    GC gc;
    HListElement * chPtr;
    int x;
    int y;
    int xOffset;
{
    HListElement * ptr, * lastVisible;
    int myIconX = 0, myIconY = 0;
    int childIconX, childIconY;

    if (chPtr != wPtr->root) {
	if (wPtr->bottomPixel > y  && (y + chPtr->height) >= 0) {
	    /* Otherwise element is not see at all */
	    DrawOneElement(wPtr, pixmap, gc, chPtr, x, y, xOffset);
	}
	myIconX = x + chPtr->branchX;
	myIconY = y + chPtr->branchY;

	x += wPtr->indent;
	y += chPtr->height;

	if (myIconX > x) {
	    myIconX = x;
	}
    }

     /* find the last non-hidden element, 
      * to determine when to draw the vertical line 
      */
    lastVisible = NULL;
    for (ptr = chPtr->childTail; ptr!=NULL; ptr=ptr->prev) {
 	if (! ptr->hidden) {
 	    lastVisible = ptr;
	    break;
	}
    }

    for (ptr = chPtr->childHead; ptr!=NULL; ptr=ptr->next) {
	if (ptr->hidden) {
	    continue;
	}

	childIconX = x + wPtr->selBorderWidth +Tix_DItemPadX(ptr->col[0].iPtr);
	childIconY = y + wPtr->selBorderWidth +ptr->height / 2;

	if (wPtr->bottomPixel > y  && (y + ptr->allHeight) >= 0) {
	    /* Otherwise all descendants of ptr are not seen at all
	     */
	    DrawElements(wPtr, pixmap, gc, ptr, x, y, xOffset);

	    if (wPtr->drawBranch && chPtr != wPtr->root) {
		/* Draw a horizontal branch to the child's image/bitmap */
		XDrawLine(wPtr->dispData.display, pixmap, gc, myIconX,
		    childIconY, childIconX, childIconY);
	    }
	}

	if (wPtr->drawBranch && chPtr != wPtr->root) {
	    /*
	     * NB: no branches for toplevel elements
	     */
	    if (ptr == lastVisible) {
		/* Last element. Must draw a vertical branch, even if element
		 * is not seen
		 */
		XDrawLine(wPtr->dispData.display, pixmap, gc, myIconX, myIconY,
		    myIconX, childIconY);
	    }
	}
	y += ptr->allHeight;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * DrawOneElement --
 *--------------------------------------------------------------
 */
static void DrawOneElement(wPtr, pixmap, gc, chPtr, x, y, xOffset)
    WidgetPtr wPtr;
    Pixmap pixmap;
    GC gc;
    HListElement * chPtr;
    int x;
    int y;
    int xOffset;
{
    int i;
    XPoint points[4];
    int flags = TIX_DITEM_NORMAL_FG;
    int selectWidth, selectX;

    x = xOffset + chPtr->indent;

    if (wPtr->wideSelect) {
	selectWidth = wPtr->selectWidth;
	selectX = xOffset;
    } else {
	selectWidth = Tix_DItemWidth(chPtr->col[0].iPtr)
	  + 2*wPtr->selBorderWidth;
	selectX = x;
    }

    if (chPtr->selected) {
	Tk_Fill3DRectangle(wPtr->dispData.tkwin, pixmap, wPtr->selectBorder,
	    selectX, y, selectWidth, chPtr->height, wPtr->selBorderWidth,
	    TK_RELIEF_RAISED);
	gc = wPtr->selectGC;
	flags |= TIX_DITEM_SELECTED_FG;
#if 0
	flags |= TIX_DITEM_SELECTED_BG;
#endif
    }

    if (chPtr == wPtr->anchor && wPtr->hasFocus) {
	XDrawRectangle(Tk_Display(wPtr->dispData.tkwin), pixmap,
	    wPtr->anchorGC, selectX, y, selectWidth-1, chPtr->height-1);
	/* Draw these points so that the corners will not be rounded */
	points[0].x = selectX;
	points[0].y = y;
	points[1].x = selectX + selectWidth - 1;
	points[1].y = y;
	points[2].x = selectX;
	points[2].y = y + chPtr->height - 1;
	points[3].x = selectX + selectWidth - 1;
	points[3].y = y + chPtr->height - 1;
	XDrawPoints(Tk_Display(wPtr->dispData.tkwin), pixmap, wPtr->anchorGC,
	    points, 4, CoordModeOrigin);

	flags |= TIX_DITEM_ACTIVE_FG;
    }
    if (chPtr == wPtr->dropSite) {
	XDrawRectangle(Tk_Display(wPtr->dispData.tkwin), pixmap,
	    wPtr->dropSiteGC, selectX, y, selectWidth-1, chPtr->height-1);
    }

    /* Now Draw the display items */
    x = xOffset;
    for (i=0; i<wPtr->numColumns; i++) {
	int drawX = x;
	Tix_DItem * iPtr = chPtr->col[i].iPtr;

	if (i == 0) {
	    drawX += chPtr->indent;
	}

	if (iPtr != NULL) {
	    Tix_DItemDisplay(pixmap, gc, iPtr,
		drawX + wPtr->selBorderWidth, y + wPtr->selBorderWidth,
		wPtr->actualSize[i].width - 2*wPtr->selBorderWidth,
		chPtr->height - 2*wPtr->selBorderWidth, flags);

	    if (Tix_DItemType(iPtr) == TIX_DITEM_WINDOW) {
		Tix_SetWindowItemSerial(&wPtr->mappedWindows,iPtr, 0,
		    wPtr->serial);
	    }
	}

	x += wPtr->actualSize[i].width;
    }
}

/*----------------------------------------------------------------------
 * DItemSizeChanged --
 *
 *	This is called whenever the size of one of the HList's items
 *	changes its size.
 *----------------------------------------------------------------------
 */
static void DItemSizeChanged(iPtr)
    Tix_DItem *iPtr;
{
    HListElement * chPtr = (HListElement *)iPtr->base.clientData;

    if (chPtr) {	/* Perhaps we haven't set the clientData yet! */
	Tix_HLMarkElementDirty(chPtr->wPtr, chPtr);
	Tix_HLResizeWhenIdle(chPtr->wPtr);
    }
}

/*
 *--------------------------------------------------------------
 *
 * AllocElement --
 *
 *	Allocates a new structure for the new element and record it
 *	in the hash table
 *
 * Results:
 *	a pointer to the new element's structure
 *
 * Side effects:
 *	Has table is changed
 *--------------------------------------------------------------
 */
static HListElement *
AllocElement(wPtr, parent, pathName, name, ditemType)
    WidgetPtr wPtr;
    HListElement * parent;
    char * pathName;
    char * name;
    char * ditemType;
{
    HListElement      * chPtr;
    Tcl_HashEntry     * hashPtr;
    int			dummy;
    Tix_DItem 	      * iPtr;

    if (ditemType == NULL) {
	iPtr = NULL;
    } else {
	if ((iPtr = Tix_DItemCreate(&wPtr->dispData, ditemType)) == NULL) {
	    return NULL;
	}
    }

    chPtr = (HListElement*)ckalloc(sizeof(HListElement));

    if (pathName) {
	/* pathName == 0 is the root element */
	hashPtr = Tcl_CreateHashEntry(&wPtr->childTable, pathName, &dummy);
	Tcl_SetHashValue(hashPtr, (char*)chPtr);
    }

    if (parent) {
	++ parent->numCreatedChild;
    }

    if (wPtr->numColumns > 1) {
	chPtr->col 		= Tix_HLAllocColumn(wPtr);
    } else {
	chPtr->col		= &chPtr->_oneCol;
	chPtr->_oneCol.iPtr	= NULL;
	chPtr->_oneCol.width	= 0;
    }
    if (pathName) {
	chPtr->pathName		= (char*)strdup(pathName);
    } else {
	chPtr->pathName		= NULL;
    }

    if (name) {
	chPtr->name		= (char*)strdup(name);
    } else {
	chPtr->name		= NULL;
    }

    chPtr->wPtr			= wPtr;
    chPtr->parent		= parent;
    chPtr->prev			= NULL;
    chPtr->next			= NULL;
    chPtr->childHead		= NULL;
    chPtr->childTail		= NULL;
    chPtr->numSelectedChild	= 0;
    chPtr->numCreatedChild	= 0;
    chPtr->col[0].iPtr		= iPtr;

    chPtr->height 		= 0;
    chPtr->allHeight 		= 0;
    chPtr->selected 		= 0;
    chPtr->dirty 		= 0;
    chPtr->hidden 		= 0;
    chPtr->state		= tkNormalUid;
    chPtr->data			= NULL;
    chPtr->branchX		= 0;
    chPtr->branchY		= 0;

    if (iPtr) {
	iPtr->base.clientData = (ClientData)chPtr;
    }

    return chPtr;
}

static void FreeElement(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    Tcl_HashEntry * hashPtr;
    int i;

    if (chPtr->selected) {
	HL_SelectionClear(wPtr, chPtr);
    }
    if (wPtr->anchor == chPtr) {
	wPtr->anchor = NULL;
    }
    if (wPtr->dragSite == chPtr) {
	wPtr->dragSite = NULL;
    }
    if (wPtr->dropSite == chPtr) {
	wPtr->dropSite = NULL;
    }

    /* Free all the display items */
    for (i=0; i<wPtr->numColumns; i++) {
	if (chPtr->col[i].iPtr) {
	    if (Tix_DItemType(chPtr->col[i].iPtr) == TIX_DITEM_WINDOW) {
		Tix_WindowItemListRemove(&wPtr->mappedWindows,
		    chPtr->col[i].iPtr);
	    }
	    Tix_DItemFree(chPtr->col[i].iPtr);
	}
    }

    if (chPtr->col != &chPtr->_oneCol) {
	/* This space was allocated dynamically */
	ckfree((char*)chPtr->col);
    }

    if (chPtr->pathName) {
	/* Root does not have an entry in the hash table */
	if ((hashPtr = Tcl_FindHashEntry(&wPtr->childTable, chPtr->pathName))){
	    Tcl_DeleteHashEntry(hashPtr);
	}
    }
    if (chPtr->name != NULL) {
	ckfree(chPtr->name);
    }
    if (chPtr->pathName != NULL) {
	ckfree(chPtr->pathName);
    }

    ckfree((char*)chPtr);
}

static void AppendList(wPtr, parent, chPtr, at, afterPtr, beforePtr)
    WidgetPtr wPtr;
    HListElement *parent;
    HListElement *chPtr;
    int at;			/* At what position should this entry be added
				 * default is "-1": add at the end */
    HListElement *afterPtr;	/* after which entry should this entry be
				 * added. Default is NULL : ignore */
    HListElement *beforePtr;	/* before which entry should this entry be
				 * added. Default is NULL : ignore */
{
    if (parent->childHead == NULL) {
	parent->childHead = chPtr;
	parent->childTail = chPtr;
	chPtr->prev = NULL;
	chPtr->next = NULL;
    }
    else {
	if (at >= 0) {
	    /*
	     * Find the current element at the "at" position
	     */
	    HListElement *ptr;
	    for (ptr=parent->childHead;
		 ptr!=NULL && at > 0;
		 ptr=ptr->next, --at) {
		; /* do nothing, just keep counting */
	    }
	    if (ptr != NULL) {
		/*
		 * We need to insert the new element *before* ptr.E.g,
		 * if at == 0, then the new element should be the first
		 * of the list
		 */
		beforePtr = ptr;
	    } else {
		/* Seems like we walked past the end of the list. Well, do
		 * nothing here. By default, the new element will be
		 * append to the end of the list
		 */
	    }
	}
	if (afterPtr != NULL) {
	    if (afterPtr == parent->childTail) {
		parent->childTail = chPtr;
	    } else {
		afterPtr->next->prev = chPtr;
	    }
	    chPtr->prev = afterPtr;
	    chPtr->next = afterPtr->next;
	    afterPtr->next = chPtr;
	    return;
	}
	if (beforePtr !=NULL) {
	    if (beforePtr == parent->childHead) {
		parent->childHead = chPtr;
	    } else {
		beforePtr->prev->next = chPtr;
	    }
	    chPtr->prev = beforePtr->prev;
	    chPtr->next = beforePtr;
	    beforePtr->prev = chPtr;
	    return;
	}

	/*
	 * By default, append it at the end of the list
	 */
	parent->childTail->next = chPtr;
	chPtr->prev = parent->childTail;
	chPtr->next = NULL;
	parent->childTail = chPtr;
    }
}

/*
 *--------------------------------------------------------------
 *
 * NewElement --
 *
 *	This procedure is creates a new element and record it both
 *	the hash table and in the tree.
 *
 * Results:
 *	pointer to new element
 *
 * Side effects:
 *	Hash table and tree changed if successful
 *--------------------------------------------------------------
 */
static HListElement *
NewElement(interp, wPtr, argc, args, pathName, defParentName, newArgc)
    Tcl_Interp *interp;
    WidgetPtr wPtr;
    int argc;
    Arg *args;
    char * pathName;		/* Default pathname, if -pathname is not
				 * specified in the options */
    char * defParentName;	/* Default parent name (will NULL if pathName 
				 * is not NULL */
    int * newArgc;
{
#define FIXED_SPACE 20
    char fixedSpace[FIXED_SPACE+1];
    char *p, *parentName = NULL;
    char *name;				/* Last part of the name */
    int i, n, numChars;
    HListElement *parent;
    HListElement *chPtr;
    char sep = wPtr->separator[0];
    int allocated = 0;
    char * ditemType = NULL;
    HListElement *afterPtr  = NULL;
    HListElement *beforePtr = NULL;
    int at = -1;
    int numSwitches = 0;		/* counter on how many of the
					 * -after, -before and -at switches
					 * have been used. No more than one
					 * of then can be used */
    /*------------------------------------------------------------
     * (1) We need to determine the options:
     *     -itemtype, -after, -before and/or -at.
     *
     *------------------------------------------------------------
     */
    if (argc > 0) {
	size_t len;
	if (argc %2 != 0) {
	    Tcl_AppendResult(interp, "value for \"", LangString(args[argc-1]),
		"\" missing", NULL);
	    chPtr = NULL;
	    goto done;
	}
	for (n=i=0; i<argc; i+=2) {
	    len = strlen(LangString(args[i]));
	    if (strncmp(LangString(args[i]), "-itemtype", len) == 0) {
		ditemType = LangString(args[i+1]);
		goto copy;
	    }
	    else if (strncmp(LangString(args[i]), "-after", len) == 0) {
		afterPtr = Tix_HLFindElement(interp, wPtr, LangString(args[i+1]));
		if (afterPtr == NULL) {
		    chPtr = NULL;
		    goto done;
		}
		++ numSwitches;
		continue;
	    }
	    else if (strncmp(LangString(args[i]), "-before", len) == 0) {
		beforePtr = Tix_HLFindElement(interp, wPtr, LangString(args[i+1]));
		if (beforePtr == NULL) {
		    chPtr = NULL;
		    goto done;
		}
		++ numSwitches;
		continue;
	    }
	    else if (strncmp(LangString(args[i]), "-at", len) == 0) {
		if (Tcl_GetInt(interp, args[i+1], &at) != TCL_OK) {
		    chPtr = NULL;
		    goto done;
		}
		++ numSwitches;
		continue;
	    }

	  copy:
	    if (n!=i) {
		LangSetString(args+n, LangString(args[i]));
		LangSetString(args+n+1, LangString(args[i+1]));
	    }
	    n+=2;
	}
	* newArgc = n;
    } else {
	* newArgc = 0;
    }
    if (numSwitches > 1) {
	Tcl_AppendResult(interp, "No more than one of the -after, -before ",
	    "and -at options can be used", NULL);
	chPtr = NULL;
	goto done;
    }
    if (ditemType == NULL) {
	ditemType = wPtr->diTypePtr->name;
    }
    if (Tix_GetDItemType(interp, ditemType) == NULL) {
	chPtr = NULL;
	goto done;
    }

    /*------------------------------------------------------------
     * (2) Create the new entry. The method depends on whether
     * 	   the "add" or "addchild" command has been called
     *------------------------------------------------------------
     */
    if (pathName == NULL) {
	/* (2.a) Called by the "addchild" command. We need to generate
	 *     a default name for the child
	 *
	 */
	char buff[40];

	parentName = defParentName;
	if (parentName == NULL) {
	    parent = wPtr->root;
	} else {
	    if ((parent=Tix_HLFindElement(interp, wPtr, parentName))== NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "parent element \"", parentName,
		    "\" does not exist",          NULL);
		chPtr = NULL;
		goto done;
	    }
	}

	/* Generate a default name for this entry */
	sprintf(buff, "%d", parent->numCreatedChild);
	name = (char*)strdup(buff);

	if (parentName == NULL) {
	    pathName = name;
	}
	else {
	    pathName = ckalloc(strlen(parentName)+1+ strlen(name)+1);
	    allocated = 1;
	    sprintf(pathName, "%s%c%s", parentName, sep, name);
	}
    }
    else {
	/* (2.b) Called by the "add" command.
	 *
	 * Strip the parent's name out of pathName (it's everything up
	 * to the last dot).  There are two tricky parts: (a) must
	 * copy the parent's name somewhere else to avoid modifying
	 * the pathName string (for large names, space for the copy
	 * will have to be malloc'ed);  (b) must special-case the
	 * situation where the parent is ".".
	 */

	if ((p = strrchr(pathName, (int)sep)) == NULL) {
	    /* This is a toplevel element  (no "." in it) */
	    name = pathName;
	    parentName = NULL;
	}
	else {
	    name = p+1;
	    numChars = p-pathName;
	    if (numChars > FIXED_SPACE) {
		parentName = (char *) ckalloc((unsigned)(numChars+1));
	    } else {
		parentName = fixedSpace;
	    }
	    if (numChars == 0) {
		if ((pathName[0] == sep) && (pathName[1] == '\0')) {
		    parentName = 0;
		} else {
		    parentName[0] = sep;
		    parentName[1] = '\0';
		}
	    }
	    else {
		strncpy(parentName, pathName, (size_t) numChars);
		parentName[numChars] = '\0';
	    }
	}

	if (parentName == NULL) {
	    parent = wPtr->root;
	} else {
	    if ((parent = Tix_HLFindElement(interp, wPtr, parentName))==NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp, "parent element \"", parentName,
		"\" does not exist",          NULL);
		chPtr = NULL;
		goto done;
	    }
	}

    }
    if (Tix_HLFindElement(interp, wPtr, pathName) != NULL) {
	Tcl_AppendResult(interp, "element \"", pathName,
	    "\" already exists",          NULL);
	chPtr = NULL;
	goto done;
    }
    else {
	if (afterPtr != NULL && afterPtr->parent != parent) {
	    Tcl_AppendResult(interp, "cannot add entry after \"",
		afterPtr->pathName, "\"", NULL);
	    chPtr = NULL;
	    goto done;
	}
	if (beforePtr != NULL && beforePtr->parent != parent) {
	    Tcl_AppendResult(interp, "cannot add entry before \"",
		beforePtr->pathName, "\"", NULL);
	    chPtr = NULL;
	    goto done;
	}

	Tcl_ResetResult(interp);
	if ((chPtr = AllocElement(wPtr, parent, pathName, name, ditemType))
	     == NULL) {
	    /* Some error, now chPtr == NULL */
	    goto done;
	}
	AppendList(wPtr, parent, chPtr, at, afterPtr, beforePtr);
	Tix_HLMarkElementDirty(wPtr, chPtr);
	Tix_HLResizeWhenIdle(wPtr);
	goto done;		/* success */
    }

  done:
    if (allocated) {
	ckfree((char*)pathName);
    }
    if (parentName && parentName != fixedSpace && parentName !=defParentName) {
	ckfree((char*)parentName);
    }
    return chPtr;
}

/*
 *--------------------------------------------------------------
 *
 * ConfigElement --
 *
 *	This procedure configures the element according to the options.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	Hash table and tree changed if successful
 *--------------------------------------------------------------
 */
static int ConfigElement(wPtr, chPtr, argc, args, flags, forced)
    WidgetPtr wPtr;
    HListElement *chPtr;
    int argc;
    Arg *args;
    int flags;
    int forced;			/* We need a "forced" configure to ensure that
				 * the DItem is initialized properly */
{
    int sizeChanged;

    if (Tix_WidgetConfigure2(wPtr->dispData.interp, wPtr->dispData.tkwin,
	(char*)chPtr, entryConfigSpecs, chPtr->col[0].iPtr, argc, args, flags,
	forced, &sizeChanged) != TCL_OK) {
	return TCL_ERROR;
    }

    if (sizeChanged) {
	Tix_HLMarkElementDirty(wPtr, chPtr);
	Tix_HLResizeWhenIdle(wPtr);
    } else {
	RedrawWhenIdle(wPtr);
    }

    return TCL_OK;
}

/*
 *--------------------------------------------------------------
 *
 * FindElementAtPosition --
 *
 *	Finds an element nearest to a Y position
 *
 * Results:
 *	Pointer to the element.
 *
 * Side effects:
 *	None
 *--------------------------------------------------------------
 */
static HListElement * FindElementAtPosition(wPtr, y)
    WidgetPtr wPtr;
    int y;
{
    HListElement * chPtr = wPtr->root;
    int top = 0;

    y -= wPtr->borderWidth + wPtr->highlightWidth;
    y += wPtr->topPixel;

    if (y < 0) {
	if (wPtr->root != NULL) {
	    return wPtr->root->childHead;
	} else {
	    return NULL;
	} 
    }
    if (y > chPtr->allHeight) {
	for (chPtr=wPtr->root;
	     chPtr != NULL && chPtr->childTail != NULL;
	     chPtr=chPtr->childTail) {
	    ;	/* Keep counting */
	}
	if (chPtr==wPtr->root) {
	    return NULL;
	} else {
	    return chPtr;
	}
    }

    while (1) {
	if (! chPtr->hidden) {
	    if (top <= y && y < top + chPtr->height) {
		return chPtr;
	    }
	    top += chPtr->height;
	}
	for (chPtr=chPtr->childHead; chPtr!=NULL; chPtr=chPtr->next) {
	    if (! chPtr->hidden) {
		if (top <= y && y < top + chPtr->allHeight) {
		    break;
		}
		top += chPtr->allHeight;
	    }
	}
	if (!chPtr) {
	    /* If we come to here we are in serious trouble:
	     * tree data is not consistent !
	     */
	    break;
	}
    }

    return NULL;		/* just to supress compiler warnings */
}
 
/*
 *--------------------------------------------------------------
 *
 * Tix_HLFindElement --
 *
 *	Finds an element according to its pathname.
 *
 * Results:
 *	Pointer to the element if found. Otherwise NULL.
 *
 * Side effects:
 *	None
 *--------------------------------------------------------------
 */
HListElement * Tix_HLFindElement(interp, wPtr, pathName)
    Tcl_Interp * interp;
    WidgetPtr wPtr;
    char * pathName;
{
    Tcl_HashEntry     * hashPtr;

    if (pathName) {
	hashPtr = Tcl_FindHashEntry(&wPtr->childTable, pathName);

	if (hashPtr) {
	    return (HListElement*) Tcl_GetHashValue(hashPtr);
	} else {
	    Tcl_AppendResult(interp, "Entry \"", pathName,
		"\" not found", NULL);
	    return NULL;
	}
    }
    else {
	/* pathName == 0 is the root element */
	return wPtr->root;
    }
}

/*
 *--------------------------------------------------------------
 *
 * SelectionModifyRange --
 *
 *	Select or de-select all the elements between from and to 
 *	(inclusive), according to the "select" argument.
 *
 *	select == 1 : select
 *	select == 0 : de-select
 *
 * Return value:
 *	Whether the selection was actually changed
 *--------------------------------------------------------------
 */
static int SelectionModifyRange(wPtr, from, to, select)
    WidgetPtr wPtr;
    HListElement * from;
    HListElement * to;
    int select;
{
    int changed = 0;

    if (ElementTopPixel(wPtr, from) > ElementTopPixel(wPtr, to)) {
	HListElement * tmp;
	tmp  = to;
	to   = from;
	from = tmp;
    }

    while (1) {
	if (!from->hidden && (int)from->selected != select) {
	    if (select) {
		SelectionAdd(wPtr, from);
	    } else {
		HL_SelectionClear(wPtr, from);
		changed = 1;
	    }
	}

	if (from == to) {
	    /* Iterated to the end of the region */
	    break;
	}

	/* Go to the next list entry */
	if (from->childHead) {
	    from = from->childHead;
	}
	else if (from->next) {
	    from = from->next;
	}
	else {
	    /* go to a different branch */
	    while (from->parent->next == NULL && from != wPtr->root) {
		from = from->parent;
	    }
	    if (from == wPtr->root) {
		/* Iterated over all list entries */
		break;
	    } else {
		from = from->parent->next;
	    }
	}
    }

    return changed;
}

/*
 *--------------------------------------------------------------
 *
 * ElementTopPixel --
 *
 *--------------------------------------------------------------
 */
static int ElementTopPixel(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    int top;
    HListElement * ptr;

    if (chPtr == wPtr->root) {
	return 0;
    }
    top = ElementTopPixel(wPtr, chPtr->parent);
    top += chPtr->parent->height;

    for (ptr=chPtr->parent->childHead; ptr!=NULL; ptr=ptr->next) {
	if (ptr == chPtr) {
	    break;
	}
	top += ptr->allHeight;
    }
    return top;
}

/*
 *--------------------------------------------------------------
 *
 * ElementLeftPixel --
 *
 *--------------------------------------------------------------
 */
static int ElementLeftPixel(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    int left;

    if (chPtr == wPtr->root || chPtr->parent == wPtr->root) {
	return 0;
    }

    left = ElementLeftPixel(wPtr, chPtr->parent);
    left += wPtr->indent;

    return left;
}

/*
 *--------------------------------------------------------------
 *
 * CurSelection --
 *
 *	returns the current selection in the result of interp;
 *
 *--------------------------------------------------------------
 */
static int CurSelection(interp, wPtr, chPtr)
    Tcl_Interp * interp;
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    HListElement * ptr;

    /* Since this recursion starts with wPtr->root, we determine
     * whether a node is selected when its *parent* is called. This
     * will save one level of recursion (otherwise all leave nodes will
     * be recursed once and will be slow ...
     */
    for (ptr=chPtr->childHead; ptr; ptr=ptr->next) {
	if (ptr->selected) {
	    Tcl_AppendElement(interp, ptr->pathName);
	}
	if (ptr->childHead) {
	    CurSelection(interp, wPtr, ptr);
	}
    }
    return TCL_OK;
}

/*
 *--------------------------------------------------------------
 *
 * Tix_HLMarkElementDirty --
 *
 *	Marks a element "dirty", i.e., its geometry needs to be
 *	recalculated.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The element and all its ancestores are marked dirty
 *--------------------------------------------------------------
 */
void Tix_HLMarkElementDirty(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement *chPtr;
{
    HListElement *ptr;

    for (ptr=chPtr; ptr!= NULL && ptr->dirty == 0; ptr=ptr->parent) {
	ptr->dirty = 1;
    }
}

/*
 *--------------------------------------------------------------
 *
 * ComputeElementGeometry --
 *
 *	Compute the geometry of this element (if its dirty) and the
 *	geometry of all its dirty child elements
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The element and all its ancestores are marked dirty
 *--------------------------------------------------------------
 */
static void ComputeElementGeometry(wPtr, chPtr, indent)
    WidgetPtr wPtr;
    HListElement *chPtr;
    int indent;
{
    HListElement *ptr;
    int i;

    if (!chPtr->dirty && !wPtr->allDirty) {
	return;
    } else {
	chPtr->dirty = 0;
    }

    if (chPtr == wPtr->root) {
	int i;
	chPtr->height = 0;
	chPtr->indent = 0;
	for (i=0; i<wPtr->numColumns; i++) {
	    chPtr->col[i].width = 0;
	}
    } else {
	ComputeOneElementGeometry(wPtr, chPtr, indent);
	indent += wPtr->indent;
    }

    chPtr->allHeight = chPtr->height;

    for (ptr=chPtr->childHead; ptr!=NULL; ptr=ptr->next) {
	if (ptr->hidden) {
	    continue;
	}
	if (ptr->dirty || wPtr->allDirty) {
	    ComputeElementGeometry(wPtr, ptr, indent);
	}

	/* Propagate the child's size to the parent 
	 *
	 */
	for (i=0; i<wPtr->numColumns; i++) {
	    if (chPtr->col[i].width < ptr->col[i].width) {
		chPtr->col[i].width = ptr->col[i].width;
	    }
	}
	chPtr->allHeight += ptr->allHeight;
    }
}

/*
 *--------------------------------------------------------------
 *
 * ComputeOneElementGeometry --
 *
 *	Compute the geometry of the element itself, not including 
 *	its children, according to its current display type.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The chPtr->height fields are updated.
 *--------------------------------------------------------------
 */
static void ComputeOneElementGeometry(wPtr, chPtr, indent)
    WidgetPtr wPtr;
    HListElement *chPtr;
    int indent;
{
    int i;

    chPtr->indent = indent;
    chPtr->height = 0;

    ComputeBranchPosition(wPtr, chPtr);

    for (i=0; i<wPtr->numColumns; i++) {
	Tix_DItem * iPtr = chPtr->col[i].iPtr;
	int width  = 2*wPtr->selBorderWidth;
	int height = 2*wPtr->selBorderWidth;

	if (iPtr != NULL) {
	    Tix_DItemCalculateSize(iPtr);
	    width  += Tix_DItemWidth (iPtr);
	    height += Tix_DItemHeight(iPtr);

	}
	if (chPtr->height < height) {
	    chPtr->height = height;
	}
	chPtr->col[i].width = width;
    }
    chPtr->col[0].width += indent;
}

/*
 *--------------------------------------------------------------
 *
 * ComputeBranchPosition --
 *
 *	Compute the position of the branches
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The chPtr->branchX and chPtr->branchY fields are updated.
 *--------------------------------------------------------------
 */
static void ComputeBranchPosition(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement *chPtr;
{
    Tix_DItem * iPtr = chPtr->col[0].iPtr;


    if (iPtr && Tix_DItemType(iPtr) == TIX_DITEM_IMAGETEXT) {
	/*
	 * Calculate the bottom-middle position of the bitmap/image branch
	 */
	if (iPtr->imagetext.image != NULL) {
	    chPtr->branchX = iPtr->imagetext.imageW / 2;
	    chPtr->branchY = iPtr->imagetext.imageH;
	    if (Tix_DItemHeight(iPtr) > iPtr->imagetext.imageH) {
		chPtr->branchY +=  (Tix_DItemHeight(iPtr) -
		iPtr->imagetext.imageH) /2;
	    }
	}
	else if (iPtr->imagetext.bitmap != None) {
	    chPtr->branchX = iPtr->imagetext.bitmapW / 2;
	    chPtr->branchY = iPtr->imagetext.bitmapH;
	    if (Tix_DItemHeight(iPtr) >iPtr->imagetext.bitmapH) {
		chPtr->branchY += (Tix_DItemHeight(iPtr) - 
		    iPtr->imagetext.bitmapH) /2;
	    }
	}
	else {
	    chPtr->branchX = wPtr->indent/2;
	    chPtr->branchY = Tix_DItemHeight(iPtr);
	}
    }
    else {
	chPtr->branchX = wPtr->indent/2;
	chPtr->branchY = Tix_DItemHeight(iPtr);
    }

    chPtr->branchX += Tix_DItemPadX(iPtr) + wPtr->selBorderWidth;
    chPtr->branchY += Tix_DItemPadY(iPtr) + wPtr->selBorderWidth;
}

/*
 *----------------------------------------------------------------------
 * SelectionAdd --
 *--------------------------------------------------------------
 */
static void SelectionAdd(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    if (chPtr->selected) {		/* sanity check */
	return;
    }

    chPtr->selected = 1;
    SelectionNotifyAncestors(wPtr, chPtr->parent);
}

/*
 *----------------------------------------------------------------------
 * HL_SelectionClear --
 *--------------------------------------------------------------
 */
static void HL_SelectionClear(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    if (! chPtr->selected) {		/* sanity check */
	return;
    }

    chPtr->selected = 0;
    HL_SelectionClearNotifyAncestors(wPtr, chPtr->parent);
}

/*
 *----------------------------------------------------------------------
 * HL_SelectionClearAll --
 *--------------------------------------------------------------
 */
static void HL_SelectionClearAll(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    HListElement * ptr;

    chPtr->selected = 0;

    if (chPtr->numSelectedChild == 0) {
	return;
    } else {
	chPtr->numSelectedChild = 0;

	for (ptr=chPtr->childHead; ptr; ptr=ptr->next) {
	    HL_SelectionClearAll(wPtr, ptr);
	}
    }
}

/*
 *----------------------------------------------------------------------
 * SelectionNotifyAncestors --
 *
 *	!!This has nothing to do with SelectionNotify in X!!
 *
 *	HList keeps a counter in every entry on how many of its
 *	child entries has been selected. This will make the
 *	"selection clear" very efficient. To keep this counter
 *	up-to-date, we must call SelectionNotifyAncestors() or
 *	HL_SelectionClearNotifyAncestors every time the selection
 *	has changed.
 *--------------------------------------------------------------
 */
static void SelectionNotifyAncestors(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    chPtr->numSelectedChild ++;

    if (chPtr->selected || (chPtr->numSelectedChild > 1)) {
	/* My ancestors already know that I have selections */
	return;
    } else {
	if (chPtr != wPtr->root) {
	    SelectionNotifyAncestors(wPtr, chPtr->parent);
	}
    }
}

static void HL_SelectionClearNotifyAncestors(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    chPtr->numSelectedChild --;

    if (chPtr->selected || (chPtr->numSelectedChild > 0)) {
	/* I still have selections, don't need to notify parent */
	return;
    } else {
	if (chPtr != wPtr->root) {
	    SelectionNotifyAncestors(wPtr, chPtr->parent);
	}
    }
}
/*
 *----------------------------------------------------------------------
 * DeleteOffsprings --
 *--------------------------------------------------------------
 */
static void DeleteOffsprings(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    HListElement * ptr;
    HListElement * toFree;

    ptr=chPtr->childHead;
    while (ptr) {
        DeleteOffsprings(wPtr, ptr);
        toFree = ptr;
        ptr=ptr->next;
        FreeElement(wPtr, toFree);
    }

    chPtr->childHead = 0;
    chPtr->childTail = 0;
}

/*
 *----------------------------------------------------------------------
 * DeleteSiblings --
 *--------------------------------------------------------------
 */
static void DeleteSiblings(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    HListElement * ptr;

    for (ptr=chPtr->parent->childHead; ptr; ptr=ptr->next) {
	if (ptr != chPtr) {
	    DeleteNode(wPtr, ptr);
	}
    }
}

/*
 *----------------------------------------------------------------------
 * DeleteNode --
 *--------------------------------------------------------------
 */
static void DeleteNode(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    HListElement * ptr,  * last;

    if (chPtr->parent == NULL) {
	/* This is root node : can't delete */
	return;
    }

    DeleteOffsprings(wPtr, chPtr);

    for (last=NULL,ptr=chPtr->parent->childHead; ptr; last=ptr,ptr=ptr->next) {
	if (ptr == chPtr) {
	    break;
	}
    }

    if (!ptr) {
	/* ** error:
	 * for some strange reasons the link is not in its parent's list
	 */
	return;
    }
#if 0
    if (ptr == last) {
	/* parent's head */
	chPtr->parent->childHead = ptr->next;
    } else {
	last->next = ptr->next;
    }
    if (ptr == chPtr->parent->childTail) {
	chPtr->parent->childTail = last;
    }
#else
    /* Patch by Richard Ball */
    if (ptr == chPtr->parent->childHead) {
	/* deleting parent's first child */
        chPtr->parent->childHead = ptr->next;
    } else {
        last->next = ptr->next;
    }
    if (ptr == chPtr->parent->childTail) {
        /* deleting parent's last child */
        chPtr->parent->childTail = last;
    }
#endif



    FreeElement(wPtr, ptr);
}

/*
 *----------------------------------------------------------------------
 * UpdateOneScrollBar --
 *--------------------------------------------------------------
 */
static void UpdateOneScrollBar(wPtr, command, total, window, first)
    WidgetPtr wPtr;
    LangCallback *command;
    int total;
    int window;
    int first;
{
    char string[100];
    double d_first, d_last;

    Tix_GetScrollFractions(total, window, first, &d_first, &d_last);

    sprintf(string, " %g %g", d_first, d_last);
    if (LangDoCallback(wPtr->dispData.interp, command, 0, 2, " %g %g", d_first, d_last)
	!= TCL_OK) {
	Tcl_AddErrorInfo(wPtr->dispData.interp,
		"\n    (scrolling command executed by tixHList)");
	Tk_BackgroundError(wPtr->dispData.interp);
    }
}

/*----------------------------------------------------------------------
 *  UpdateScrollBars
 *----------------------------------------------------------------------
 */
static void UpdateScrollBars(wPtr, sizeChanged)
    WidgetPtr wPtr;
    int sizeChanged;
{
    int total, window, first;

    CheckScrollBar(wPtr, TIX_X);
    CheckScrollBar(wPtr, TIX_Y);
 
    if (wPtr->xScrollCmd) {
	total  = wPtr->totalSize[0];
	window = Tk_Width(wPtr->dispData.tkwin)
	  - 2*wPtr->borderWidth - 2*wPtr->highlightWidth;
	first  = wPtr->leftPixel;

	UpdateOneScrollBar(wPtr, wPtr->xScrollCmd, total, window, first);
    }

    if (wPtr->yScrollCmd) {
	total  = wPtr->totalSize[1];
	window = Tk_Height(wPtr->dispData.tkwin)
	  - 2*wPtr->borderWidth - 2*wPtr->highlightWidth;
	first  = wPtr->topPixel;

	UpdateOneScrollBar(wPtr, wPtr->yScrollCmd, total, window, first);
    }

    if (wPtr->sizeCmd && sizeChanged) {
	if (LangDoCallback(wPtr->dispData.interp, wPtr->sizeCmd, 0, 0) != TCL_OK) {
	    Tcl_AddErrorInfo(wPtr->dispData.interp,
		"\n    (size command executed by tixHList)");
	    Tk_BackgroundError(wPtr->dispData.interp);
	}
    }
}

/*----------------------------------------------------------------------
 * XScrollByUnits
 *----------------------------------------------------------------------
 */
static int XScrollByUnits(wPtr, count)
    WidgetPtr wPtr;
    int count;
{
    return wPtr->leftPixel + count*wPtr->scrollUnit[0];
}

/*----------------------------------------------------------------------
 * XScrollByPages
 *----------------------------------------------------------------------
 */
static int XScrollByPages(wPtr, count)
    WidgetPtr wPtr;
    int count;
{
    return wPtr->leftPixel + count*Tk_Width(wPtr->dispData.tkwin);
}

/*----------------------------------------------------------------------
 * YScrollByUnits
 *----------------------------------------------------------------------
 */
static int YScrollByUnits(wPtr, count)
    WidgetPtr wPtr;
    int count;
{
    HListElement * chPtr;
    int height;

    if ((chPtr = FindElementAtPosition(wPtr, 0))) {
	height = chPtr->height;
    } else if (wPtr->root->childHead) {
	height = wPtr->root->childHead->height;
    } else {
	height = 0;
    }

    return wPtr->topPixel + count*height;
}

/*----------------------------------------------------------------------
 * YScrollByPages
 *----------------------------------------------------------------------
 */
static int YScrollByPages(wPtr, count)
    WidgetPtr wPtr;
    int count;
{
    int window = Tk_Height(wPtr->dispData.tkwin)
      - 2*wPtr->borderWidth - 2*wPtr->highlightWidth;

    return wPtr->topPixel + count*window;
}

/*----------------------------------------------------------------------
 * CheckScrollBar
 *
 *	Make sures that the seeting of the scrollbars are correct: i.e.
 *	the bottom element will never be scrolled up by too much.
 *----------------------------------------------------------------------
 */
static void CheckScrollBar(wPtr, which)
    WidgetPtr wPtr;
    int which;
{
    int window;
    int total;
    int first;

    if (which == TIX_Y) {
	window = Tk_Height(wPtr->dispData.tkwin)
	  - 2*wPtr->borderWidth - 2*wPtr->highlightWidth;
	total  = wPtr->totalSize[1];
	first  = wPtr->topPixel;
    } else {
	window = Tk_Width(wPtr->dispData.tkwin)
	  - 2*wPtr->borderWidth - 2*wPtr->highlightWidth;
	total  = wPtr->totalSize[0];
	first  = wPtr->leftPixel;
    }

    /* Check whether the topPixel is out of bound */
    if (first < 0) {
	first = 0;
    } else {
	if (window > total) {
	    first = 0;
	} else if ((first + window) > total) {
	    first = total - window;
	}
    }

    if (which == TIX_Y) {
	wPtr->topPixel = first;
    } else {
	wPtr->leftPixel = first;
    }
}

/*----------------------------------------------------------------------
 * Find the element that's immediately below this element.
 *
 *----------------------------------------------------------------------
 */
static HListElement *
FindNextEntry(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    if (chPtr->childHead) {
	return chPtr->childHead;
    }
    if (chPtr->next) {
	return chPtr->next;
    }
	
    /* go to a different branch */
    while (1) {
        if (chPtr == wPtr->root) {
	    return (HListElement *)NULL;
        }
	chPtr = chPtr->parent;
        if (chPtr->next) {
            return chPtr->next;
        }
    }

    /* Never reached, just to supress compiler warnings*/
    return (HListElement *)NULL;
}

/*----------------------------------------------------------------------
 * Find the element that's immediately above this element.
 *
 *----------------------------------------------------------------------
 */
static HListElement *
FindPrevEntry(wPtr, chPtr)
    WidgetPtr wPtr;
    HListElement * chPtr;
{
    if (chPtr->prev) {
	/* Find the bottom of this sub-tree
	 */
	for (chPtr=chPtr->prev; chPtr->childTail; chPtr = chPtr->childTail)
	  ;

	return chPtr;
    } else {
	if (chPtr->parent == wPtr->root) {
	    return 0;
	} else {
	    return chPtr->parent;
	}
    }
}
