/*
 * tixDiStyle.c --
 *
 *	This file implements the "Display Item Styles" in the Tix library.
 *
 *
 */

#include "tkPort.h"
#include "tkInt.h"
#include "tixInt.h"

static Tix_DItemStyle* FindDefaultStyle _ANSI_ARGS_((Tix_DItemInfo * diTypePtr,
                       Tk_Window tkwin));


static int   		DItemStyleParseProc _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, Tk_Window tkwin,
			    Arg value,char *widRec, int offset));
static Arg 		DItemStylePrintProc _ANSI_ARGS_((
			    ClientData clientData, Tk_Window tkwin, 
			    char *widRec, int offset,
			    Tcl_FreeProc **freeProcPtr));
static Tix_DItemStyle*	FindStyle _ANSI_ARGS_((
			    char *styleName));
static Tix_DItemStyle* 	GetDItemStyle  _ANSI_ARGS_((
			    Tix_DispData * ddPtr, Tix_DItemInfo * diTypePtr,
			    char * styleName, int *isNew_ret));
static void 		InitHashTables _ANSI_ARGS_((void));
static void		ListAdd _ANSI_ARGS_((Tix_DItemStyle * stylePtr,
			    Tix_DItem *iPtr));
static void		ListDelete _ANSI_ARGS_((Tix_DItemStyle * stylePtr,
			    Tix_DItem *iPtr));
static void		ListDeleteAll _ANSI_ARGS_((Tix_DItemStyle * stylePtr
			    ));
static void		StyleCmdDeletedProc _ANSI_ARGS_((
			    ClientData clientData));
static int		StyleCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args));
static int		StyleConfigure _ANSI_ARGS_((Tcl_Interp *interp,
			    Tix_DItemStyle* stylePtr, int argc,
			    Arg *args, int flags));
static void		StyleDestroy _ANSI_ARGS_((
			    ClientData clientData));	
static void		DeleteStyle _ANSI_ARGS_((Tix_DItemStyle * stylePtr
			    ));
static void		DefWindowStructureProc _ANSI_ARGS_((
			    ClientData clientData, XEvent *eventPtr));

static TIX_DECLARE_SUBCMD(StyleConfigCmd);
static TIX_DECLARE_SUBCMD(StyleCGetCmd);
static TIX_DECLARE_SUBCMD(StyleDeleteCmd);
static TIX_DECLARE_SUBCMD(Tix_ItemStyleCmd);

static Tcl_HashTable styleTable;
static Tcl_HashTable defaultTable;
static int tableInited = 0;


/*
 *--------------------------------------------------------------
 *
 * TixDItemStyleFree --
 *
 *	When an item does not need a style anymore (when the item
 *	is destroyed, e.g.), it must call this procedute to free the
 *	style).
 *
 * Results:
 *	Nothing
 *
 * Side effects:
 *	The item is freed from the list of attached items in the style.
 *	Also, the style will be freed if it was already destroyed and
 *	it has no more items attached to it.
 *
 *--------------------------------------------------------------
 */
void TixDItemStyleFree(iPtr, stylePtr)
    Tix_DItem *iPtr;
    Tix_DItemStyle * stylePtr;
{
    ListDelete(stylePtr, iPtr);
}

/*
 *--------------------------------------------------------------
 *
 * Tix_ItemStyleCmd --
 *
 *	This procedure is invoked to process the "tixItemStyle" Tcl
 *	command.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	A new widget is created and configured.
 *
 *--------------------------------------------------------------
 */
static int
Tix_ItemStyleCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tix_DItemInfo * diTypePtr;
    Tk_Window tkwin = (Tk_Window)clientData;
    char * styleName = NULL;
    Tix_DispData dispData;
    char buff[100];
    int i, n;
    static int counter = 0;
    Tix_DItemStyle * stylePtr;

    if (tableInited == 0) {
	InitHashTables();
    }

    if (argc < 2) {
	return Tix_ArgcError(interp, argc, args, 1, 
	    "itemtype ?option value ...");
    }
    
    if ((diTypePtr=Tix_GetDItemType(interp, LangString(args[1]))) == NULL) {
	return TCL_ERROR;
    }
    
    /* Parse the -window option */
    if (argc > 2) {
	size_t len;
	if (argc %2 != 0) {
	    Tcl_AppendResult(interp, "value for \"", LangString(args[argc-1]),
		"\" missing", NULL);
	    return TCL_ERROR;
	}
	for (n=i=2; i<argc; i+=2) {
	    len = strlen(LangString(args[i]));
	    if (strncmp(LangString(args[i]), "-refwindow", len) == 0) {
		if ((tkwin=Tk_NameToWindow(interp,LangString(args[i+1]),tkwin)) == NULL) {
		    return TCL_ERROR;
		}
		continue;
	    }
	    if (strncmp(LangString(args[i]), "-stylename", len) == 0) {
		styleName = LangString(args[i+1]);
		if (FindStyle(styleName) != NULL) {
		    Tcl_AppendResult(interp, "style \"", LangString(args[i+1]),
			"\" already exist", NULL);
		    return TCL_ERROR;
		}
		continue;
	    }

	  copy:
	    if (n!=i) {
		LangSetString(args+n, LangString(args[i]));
		LangSetString(args+n+1, LangString(args[i+1]));
	    }
	    n+=2;
	}
	argc = n;
    }

    if (styleName == NULL) {
	/* let's make a unique name */
	sprintf(buff, "style%d", counter++);
	styleName = buff;
    }

    dispData.interp = interp;
    dispData.display = Tk_Display(tkwin);
    dispData.tkwin = tkwin;

    if ((stylePtr = GetDItemStyle(&dispData, diTypePtr,
	 styleName, NULL)) == NULL) {
	return TCL_ERROR;
    }
    if (StyleConfigure(interp, stylePtr, argc-2, args+2, 0) != TCL_OK) {
	DeleteStyle(stylePtr);
	return TCL_ERROR;
    }

    Tcl_ResetResult(interp);
    Tcl_AppendResult(interp, styleName, NULL);
    return TCL_OK;
}

static int
StyleCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;
    int argc;
    Arg *args;
{
    int code;

    static Tix_SubCmdInfo subCmdInfo[] = {
	{TIX_DEFAULT_LEN, "cget", 1, 1, StyleCGetCmd,
	   "option"},
	{TIX_DEFAULT_LEN, "configure", 0, TIX_VAR_ARGS, StyleConfigCmd,
	   "?option? ?value? ?option value ... ?"},
	{TIX_DEFAULT_LEN, "delete", 0, 0, StyleDeleteCmd,
	   ""},
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
 * "cget" sub command
 *----------------------------------------------------------------------
 */
static int
StyleCGetCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tix_DItemStyle* stylePtr= (Tix_DItemStyle*) clientData;

    return Tk_ConfigureValue(interp, stylePtr->base.tkwin,
	stylePtr->base.diTypePtr->styleConfigSpecs,
	(char *)stylePtr, LangString(args[0]), 0);
}

/*----------------------------------------------------------------------
 * "configure" sub command
 *----------------------------------------------------------------------
 */
static int
StyleConfigCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tix_DItemStyle* stylePtr= (Tix_DItemStyle*) clientData;

    if (argc == 0) {
	return Tk_ConfigureInfo(interp, stylePtr->base.tkwin,
	    stylePtr->base.diTypePtr->styleConfigSpecs,
	    (char *)stylePtr,          NULL, 0);
    } else if (argc == 1) {
	return Tk_ConfigureInfo(interp, stylePtr->base.tkwin,
	    stylePtr->base.diTypePtr->styleConfigSpecs,
	    (char *)stylePtr, LangString(args[0]), 0);
    } else {
	return StyleConfigure(interp, stylePtr, argc, args,
	    TK_CONFIG_ARGV_ONLY);
    }
}

/*----------------------------------------------------------------------
 * "delete" sub command
 *----------------------------------------------------------------------
 */
static int
StyleDeleteCmd(clientData, interp, argc, args)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tix_DItemStyle* stylePtr= (Tix_DItemStyle*) clientData;

    if (stylePtr->base.flags & TIX_STYLE_DEFAULT) {
	Tcl_AppendResult(interp, "Cannot delete default item style",
	    NULL);
	return TCL_ERROR;
    }

    DeleteStyle(stylePtr);
    return TCL_OK;
}

static int
StyleConfigure(interp, stylePtr, argc, args, flags)
    Tcl_Interp *interp;		/* Used for error reporting. */
    Tix_DItemStyle* stylePtr;	/* Information about the style;  may or may
				 * not already have values for some fields. */
    int argc;			/* Number of valid entries in args. */
    Arg *args;		/* Arguments. */
    int flags;			/* Flags to pass to Tk_ConfigureWidget. */
{
    Tix_DItemInfo * diTypePtr = stylePtr->base.diTypePtr;

    if (diTypePtr->styleConfigureProc(stylePtr, argc, args, flags) != TCL_OK) {
	return TCL_ERROR;
    }
    return TCL_OK;
}

static void
StyleDestroy(clientData)
    ClientData clientData;
{
    Tix_DItemStyle* stylePtr= (Tix_DItemStyle*) clientData;

    if ((stylePtr->base.flags & TIX_STYLE_DEFAULT)) {
	/*
	 * If this is the default style for the display items, we can't
	 * tell the display items that it has lost its style, otherwise
	 * the ditem will just attempt to create the default style again,
	 * and we will go into an infinite loop
	 */
	if (stylePtr->base.refCount == 0) {
	    ckfree((char*)stylePtr->base.name);
	    stylePtr->base.diTypePtr->styleFreeProc(stylePtr);
	}
	/*
	 * If the refcount is not zero, this style will NOT be destroyed.
	 * The real destroy will be triggered if all DItems associated with
	 * this style is destroyed (in the function ListDelete).
	 *
	 * If a widget is destroyed, it is the responsibility of the widget
	 * writer to delete all DItems associated with this widget. We can
	 * discover memory leak if the widget is destroyed but some default
	 * styles associated with it still exist
	 */
    } else {
	ListDeleteAll(stylePtr);
	stylePtr->base.refCount = 0;
	ckfree((char*)stylePtr->base.name);
	stylePtr->base.diTypePtr->styleFreeProc(stylePtr);
    }
}

static void
StyleCmdDeletedProc(clientData)
    ClientData clientData;
{
    Tix_DItemStyle * stylePtr = (Tix_DItemStyle *)clientData;

    stylePtr->base.styleCmd = NULL;
    if (stylePtr->base.flags & TIX_STYLE_DEFAULT) {
	/* Don't do anything
	 * ToDo: maybe should give a background warning:
	 */
    } else {
	DeleteStyle(stylePtr);
    }
}

static void
DeleteStyle(stylePtr)
    Tix_DItemStyle * stylePtr;
{
    Tcl_HashEntry * hashPtr;

    if (!(stylePtr->base.flags & TIX_STYLE_DELETED)) {
	stylePtr->base.flags |= TIX_STYLE_DELETED;

	if (stylePtr->base.styleCmd != NULL) {
	    Lang_DeleteObject(stylePtr->base.interp,stylePtr->base.styleCmd);


	}
	hashPtr=Tcl_FindHashEntry(&styleTable, stylePtr->base.name);
	if (hashPtr != NULL) {
	    Tcl_DeleteHashEntry(hashPtr);
	}

	Tk_EventuallyFree((ClientData)stylePtr, StyleDestroy);
    }
}

typedef struct StyleLink {
    Tix_DItemInfo * diTypePtr;
    Tix_DItemStyle* stylePtr;
    struct StyleLink * next;
} StyleLink;

typedef struct StyleInfo {
    Tix_StyleTemplate * tmplPtr;
    Tix_StyleTemplate tmpl;
    StyleLink * linkHead;
} StyleInfo;

static Tix_DItemStyle* FindDefaultStyle(diTypePtr, tkwin)
    Tix_DItemInfo * diTypePtr;
    Tk_Window tkwin;
{
    Tcl_HashEntry *hashPtr;
    StyleInfo * infoPtr;
    StyleLink * linkPtr;

    if (tableInited == 0) {
	InitHashTables();
    }
    if ((hashPtr=Tcl_FindHashEntry(&defaultTable, (char*)tkwin)) == NULL) {
	return NULL;
    }
    infoPtr = (StyleInfo *)Tcl_GetHashValue(hashPtr);
    for (linkPtr = infoPtr->linkHead; linkPtr; linkPtr=linkPtr->next) {
	if (linkPtr->diTypePtr == diTypePtr) {
	    return linkPtr->stylePtr;
	}
    } 
    return NULL;
}

static void SetDefaultStyle(diTypePtr, tkwin, stylePtr)
    Tix_DItemInfo * diTypePtr;
    Tk_Window tkwin;
    Tix_DItemStyle * stylePtr;
{
    Tcl_HashEntry *hashPtr;
    StyleInfo * infoPtr;
    StyleLink * newPtr;
    int isNew;

    if (tableInited == 0) {
	InitHashTables();
    }

    newPtr = (StyleLink *)ckalloc(sizeof(StyleLink));
    newPtr->diTypePtr = diTypePtr;
    newPtr->stylePtr  = stylePtr;

    hashPtr=Tcl_CreateHashEntry(&defaultTable, (char*)tkwin, &isNew);

    if (!isNew) {
	infoPtr = (StyleInfo *)Tcl_GetHashValue(hashPtr);
	if (infoPtr->tmplPtr) {
	    if (diTypePtr->styleSetTemplateProc != NULL) {
		diTypePtr->styleSetTemplateProc(stylePtr,
		    infoPtr->tmplPtr);
	    }
	}
    } else {
	infoPtr = (StyleInfo *)ckalloc(sizeof(StyleInfo));
	infoPtr->linkHead = NULL;
	infoPtr->tmplPtr  = NULL;

	Tk_CreateEventHandler(tkwin, StructureNotifyMask,
	    DefWindowStructureProc, (ClientData)tkwin);
	Tcl_SetHashValue(hashPtr, (char*)infoPtr);
    }
    newPtr->next = infoPtr->linkHead;
    infoPtr->linkHead = newPtr;
}

Tix_DItemStyle* TixGetDefaultDItemStyle(ddPtr, diTypePtr, iPtr, oldStylePtr)
    Tix_DispData * ddPtr;
    Tix_DItemInfo * diTypePtr;
    Tix_DItem *iPtr;
    Tix_DItemStyle* oldStylePtr;
{
    Tcl_DString dString;
    Tix_DItemStyle* stylePtr;
    int isNew;

    if (tableInited  == 0) {
	InitHashTables();
    }

    if ((stylePtr = FindDefaultStyle(diTypePtr, ddPtr->tkwin)) == NULL) {
	/*
	 * Format default name for this style+window
	 */
	Tcl_DStringInit(&dString);
	Tcl_DStringAppend(&dString, "style", 5);
	Tcl_DStringAppend(&dString, Tk_PathName(ddPtr->tkwin),
	    strlen(Tk_PathName(ddPtr->tkwin)));
	Tcl_DStringAppend(&dString, ":", 1);
	Tcl_DStringAppend(&dString, diTypePtr->name, strlen(diTypePtr->name));

	/*
	 * Create the new style
	 */
	stylePtr = GetDItemStyle(ddPtr, diTypePtr, dString.string, &isNew);
	if (isNew) {
	    diTypePtr->styleConfigureProc(stylePtr, 0, NULL, 0);
	    stylePtr->base.flags |= TIX_STYLE_DEFAULT;
	}

	SetDefaultStyle(diTypePtr, ddPtr->tkwin, stylePtr);
	Tcl_DStringFree(&dString);
    }

    if (oldStylePtr) {
	ListDelete(oldStylePtr, iPtr);
    }
    ListAdd(stylePtr, iPtr);

    return stylePtr;
}

void Tix_SetDefaultStyleTemplate(tkwin, tmplPtr)
    Tk_Window tkwin;
    Tix_StyleTemplate * tmplPtr;
{
    Tcl_HashEntry * hashPtr;
    StyleInfo * infoPtr;
    StyleLink * linkPtr;
    int isNew;

    if (tableInited == 0) {
	InitHashTables();
    }

    hashPtr=Tcl_CreateHashEntry(&defaultTable, (char*)tkwin, &isNew);
    if (!isNew) {
	infoPtr = (StyleInfo *)Tcl_GetHashValue(hashPtr);
	infoPtr->tmplPtr = &infoPtr->tmpl;
	infoPtr->tmpl = *tmplPtr;

	for (linkPtr = infoPtr->linkHead; linkPtr; linkPtr=linkPtr->next) {
	    if (linkPtr->diTypePtr->styleSetTemplateProc != NULL) {
		linkPtr->diTypePtr->styleSetTemplateProc(linkPtr->stylePtr,
		    tmplPtr);
	    }
	}
    } else {
	infoPtr = (StyleInfo *)ckalloc(sizeof(StyleInfo));
	infoPtr->linkHead = NULL;
	infoPtr->tmplPtr = &infoPtr->tmpl;
	infoPtr->tmpl = *tmplPtr;

	Tk_CreateEventHandler(tkwin, StructureNotifyMask,
	    DefWindowStructureProc, (ClientData)tkwin);
	Tcl_SetHashValue(hashPtr, (char*)infoPtr);
    }
}

static Tix_DItemStyle*
GetDItemStyle(ddPtr, diTypePtr, styleName, isNew_ret)
    Tix_DispData * ddPtr;
    Tix_DItemInfo * diTypePtr;
    char * styleName;
    int * isNew_ret;
{
    Tcl_HashEntry *hashPtr;
    int isNew;
    Tix_DItemStyle * stylePtr;

    if (tableInited == 0) {
	InitHashTables();
    }

    hashPtr = Tcl_CreateHashEntry(&styleTable, styleName, &isNew);
    if (!isNew) {
	stylePtr = (Tix_DItemStyle *)Tcl_GetHashValue(hashPtr);
    }
    else {
	stylePtr = diTypePtr->styleCreateProc(ddPtr->interp,
	    ddPtr->tkwin, diTypePtr, styleName);
	stylePtr->base.styleCmd = Lang_CreateObject(ddPtr->interp,
	    styleName, StyleCmd, (ClientData)stylePtr, StyleCmdDeletedProc);
	stylePtr->base.interp 	 = ddPtr->interp;
	stylePtr->base.tkwin  	 = ddPtr->tkwin;
	stylePtr->base.diTypePtr = diTypePtr;
	stylePtr->base.name      = (char*)strdup(styleName);
	stylePtr->base.pad[0] 	 = 0;
	stylePtr->base.pad[1] 	 = 0;
	stylePtr->base.anchor 	 = TK_ANCHOR_CENTER;
	stylePtr->base.items  	 = NULL;
	stylePtr->base.refCount  = 0;
	stylePtr->base.flags     = 0;

	Tcl_SetHashValue(hashPtr, (char*)stylePtr);
    }

    if (isNew_ret != NULL) {
	* isNew_ret = isNew;
    }
    return stylePtr;
}

static Tix_DItemStyle* FindStyle(styleName)
    char *styleName;
{
    Tcl_HashEntry *hashPtr;

    if (tableInited == 0) {
	InitHashTables();
    }
    if ((hashPtr=Tcl_FindHashEntry(&styleTable, styleName)) == NULL) {
	return NULL;
    }

    return (Tix_DItemStyle *)Tcl_GetHashValue(hashPtr);
}
    
void TixDItemStyleChanged(diTypePtr, stylePtr)
    Tix_DItemInfo * diTypePtr;
    Tix_DItemStyle * stylePtr;
{
    /* Tell all items that are associated with stylePtr that its style has
     * changed
     */
    Tix_DItemLink * linkPtr;

    for (linkPtr=stylePtr->base.items; linkPtr; linkPtr=linkPtr->next) {
	if (diTypePtr->styleChangedProc != NULL) {
	    diTypePtr->styleChangedProc(linkPtr->iPtr);
	}
    }
}

static void ListAdd(stylePtr, iPtr)
    Tix_DItemStyle * stylePtr;
    Tix_DItem *iPtr;
{
    Tix_DItemLink * linkPtr = (Tix_DItemLink *)ckalloc(sizeof(Tix_DItemLink));

    linkPtr->iPtr = iPtr;
    linkPtr->next = stylePtr->base.items;
    stylePtr->base.items = linkPtr;
    ++ stylePtr->base.refCount;
}

static void ListDelete(stylePtr, iPtr)
    Tix_DItemStyle * stylePtr;
    Tix_DItem *iPtr;
{
    Tix_DItemLink * linkPtr, *lastPtr;

    for (lastPtr=linkPtr=stylePtr->base.items; linkPtr;
	 lastPtr=linkPtr,linkPtr=linkPtr->next) {

	if (linkPtr->iPtr == iPtr) {
	    -- stylePtr->base.refCount;
	    if (linkPtr==stylePtr->base.items) {
		stylePtr->base.items = linkPtr->next;
	    } else {
		lastPtr->next = linkPtr->next;
	    }

	    ckfree((char *)linkPtr);
	    break;
	}
    }
    if ((stylePtr->base.flags & TIX_STYLE_DELETED) &&
	(stylePtr->base.flags & TIX_STYLE_DEFAULT) &&
	stylePtr->base.refCount == 0) {
	Tk_EventuallyFree((ClientData)stylePtr, StyleDestroy);
    }
}
    
static void ListDeleteAll(stylePtr)
    Tix_DItemStyle * stylePtr;
{
    Tix_DItemLink * linkPtr, *toFree;

    for (linkPtr=stylePtr->base.items; linkPtr;) {
	toFree = linkPtr;
	linkPtr = linkPtr->next;

	if (stylePtr->base.diTypePtr->lostStyleProc != NULL) {
	    stylePtr->base.diTypePtr->lostStyleProc(toFree->iPtr);
	}
	ckfree((char *)toFree);
    }
}

static void InitHashTables()
{
    if (tableInited == 0) {
	Tcl_InitHashTable(&styleTable, TCL_STRING_KEYS);
	Tcl_InitHashTable(&defaultTable, sizeof(Tk_Window)/sizeof(int));
	tableInited = 1;
    }
}

/*
 *--------------------------------------------------------------
 *
 * DefWindowStructureProc --
 *
 *	This procedure is invoked whenever StructureNotify events
 *	occur for a window that has some default style(s) associated with it
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The style(s) associated with this window will all be deleted.
 *
 *--------------------------------------------------------------
 */
static void
DefWindowStructureProc(clientData, eventPtr)
    ClientData clientData;	/* Pointer to record describing window item. */
    XEvent *eventPtr;		/* Describes what just happened. */
{
    Tk_Window tkwin = (Tk_Window)clientData;
    Tcl_HashEntry *hashPtr;
    StyleInfo * infoPtr;
    StyleLink * linkPtr, *toFree;

    if (eventPtr->type != DestroyNotify) {
	return;
    }
    if (tableInited == 0) {
	InitHashTables();
    }
    if ((hashPtr=Tcl_FindHashEntry(&defaultTable, (char*)tkwin)) == NULL) {
	return;
    }
    infoPtr = (StyleInfo *)Tcl_GetHashValue(hashPtr);
    for (linkPtr = infoPtr->linkHead; linkPtr; ) {
	toFree = linkPtr;
	linkPtr=linkPtr->next;

	DeleteStyle(toFree->stylePtr);
	ckfree((char*)toFree);
    } 

    ckfree((char*)infoPtr);
    Tcl_DeleteHashEntry(hashPtr);
}

/*----------------------------------------------------------------------
 *
 *		 The Tix Customed Config Options
 *
 *----------------------------------------------------------------------
 */

/*
 * The global data structures to use in widget configSpecs arrays
 *
 * These are declared in <tix.h>
 */

Tk_CustomOption tixConfigItemStyle = {
    DItemStyleParseProc, DItemStylePrintProc, 0,
};

/*----------------------------------------------------------------------
 *  DItemStyleParseProc --
 *
 *	Parse the text string and store the Tix_DItemStyleType information
 *	inside the widget record.
 *----------------------------------------------------------------------
 */
static int DItemStyleParseProc(clientData, interp, tkwin, value, widRec,offset)
    ClientData clientData;
    Tcl_Interp *interp;
    Tk_Window tkwin;
    Arg value;
    char *widRec;		/* Must point to a valid Tix_DItem struct */
    int offset;
{
    Tix_DItem       * iPtr = (Tix_DItem *)widRec;
    Tix_DItemStyle ** ptr = (Tix_DItemStyle **)(widRec + offset);
    Tix_DItemStyle  * oldPtr = *ptr;
    Tix_DItemStyle  * newPtr;

    if (tableInited  == 0) {
	InitHashTables();
    }

    if (value == NULL || strlen(LangString(value)) == 0) {
	/*
	 * User gives a NULL string -- meaning he wants the default
	 * style
	 */
	newPtr = NULL;
    } else {
	if ((newPtr = FindStyle(LangString(value))) == NULL) {
	    goto not_found;
	}
	if (newPtr->base.flags & TIX_STYLE_DELETED) {
	    goto not_found;
	}
	if (newPtr->base.diTypePtr != iPtr->base.diTypePtr) {
	    Tcl_AppendResult(interp, "Style type mismatch ",
	        "Needed ", iPtr->base.diTypePtr->name, " style but got ",
	        newPtr->base.diTypePtr->name, " style", NULL);
	    return TCL_ERROR;
	}
    }

    if (oldPtr != newPtr) {
	if (oldPtr != NULL) {
	    /*
	     * Release the old style
	     */
	    if (FindStyle(oldPtr->base.name) == NULL) {
		/* Old style was deleted: some error */
		panic("old stylePtr was already deleted!");
	    }
	    ListDelete(oldPtr, iPtr);
	}
	if (newPtr != NULL) {
	    /*
	     * Attach to the new style
	     */
	    ListAdd(newPtr, iPtr);
	}
    }

    *ptr = newPtr;
    return TCL_OK;

  not_found:
    Tcl_AppendResult(interp, "Display style \"", value,
	"\" not found", NULL);
    return TCL_ERROR;
}

static Arg 
DItemStylePrintProc(clientData, tkwin, widRec,offset, freeProcPtr)
    ClientData clientData;
    Tk_Window tkwin;
    char *widRec;
    int offset;
    Tcl_FreeProc **freeProcPtr;
{
    Tix_DItemStyle *stylePtr = *((Tix_DItemStyle**)(widRec+offset));

    if (stylePtr != NULL) {
	return LangObjectArg(stylePtr->base.interp, stylePtr->base.name);
    } else {
	return 0;
    }
}
