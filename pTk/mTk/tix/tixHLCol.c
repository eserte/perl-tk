/*
 *  tixHLCol.c ---
 *
 *
 *	Implements columns inside tixHList widgets
 *
 *
 * Copyright (c) 1994-1995 Ioi Kim Lam. All rights reserved.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include <tkPort.h>
#include <tkInt.h>
#include <tixInt.h>
#include <tixHList.h>

#ifdef TO_REMOVE
#include <string.h>
#endif

static TIX_DECLARE_SUBCMD(Tix_HLItemCreate);
static TIX_DECLARE_SUBCMD(Tix_HLItemConfig);
static TIX_DECLARE_SUBCMD(Tix_HLItemCGet);
static TIX_DECLARE_SUBCMD(Tix_HLItemDelete);
static TIX_DECLARE_SUBCMD(Tix_HLColWidth);


HListColumn * Tix_HLAllocColumn(wPtr)
    WidgetPtr wPtr;
{
    HListColumn * column;
    int i;

    column =
      (HListColumn*)ckalloc(sizeof(HListColumn)*wPtr->numColumns);
    for (i=0; i<wPtr->numColumns; i++) {
	column[i].iPtr = NULL;
	column[i].width = UNINITIALIZED;
    }
    return column;
}

/*----------------------------------------------------------------------
 * "item" sub command
 *----------------------------------------------------------------------
 */
int
Tix_HLItem(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    static Tix_SubCmdInfo subCmdInfo[] = {
	{TIX_DEFAULT_LEN, "cget", 3, 3, Tix_HLItemCGet,
	   "entryPath column option"},
	{TIX_DEFAULT_LEN, "configure", 2, TIX_VAR_ARGS, Tix_HLItemConfig,
	   "entryPath column ?option? ?value ...?"},
	{TIX_DEFAULT_LEN, "create", 2, TIX_VAR_ARGS, Tix_HLItemCreate,
	   "entryPath column ?option value ...?"},
	{TIX_DEFAULT_LEN, "delete", 2, 2, Tix_HLItemDelete,
	   "entryPath column"},
    };
    static Tix_CmdInfo cmdInfo = {
	Tix_ArraySize(subCmdInfo), 1, TIX_VAR_ARGS, "?option? ?arg ...?",
    };

    return Tix_HandleSubCmds(&cmdInfo, subCmdInfo, clientData,
	interp, argc+1, argv-1);
}

/*----------------------------------------------------------------------
 * "item cget" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLItemCGet(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int column;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, argv[0])) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_GetInt(interp, argv[1], &column) != TCL_OK) {
	return TCL_ERROR;
    }
    if (column >= wPtr->numColumns || column < 0) {
	Tcl_AppendResult(interp, "Column \"", argv[1], 
	    "\" does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    if (chPtr->col[column].iPtr == NULL) {
	/* ToDo: sloppy error msg */
	Tcl_AppendResult(interp, "Specified item does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    return Tk_ConfigureValue(interp, wPtr->dispData.tkwin, 
	chPtr->col[column].iPtr->base.diTypePtr->itemConfigSpecs,
	(char *)chPtr->col[column].iPtr, argv[2], 0);
}

/*----------------------------------------------------------------------
 * "item configure" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLItemConfig(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int column;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, argv[0])) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_GetInt(interp, argv[1], &column) != TCL_OK) {
	return TCL_ERROR;
    }
    if (column >= wPtr->numColumns || column < 0) {
	Tcl_AppendResult(interp, "Column \"", argv[1], 
	    "\" does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    if (chPtr->col[column].iPtr == NULL) {
	/* ToDo: sloppy error msg */
	Tcl_AppendResult(interp, "Specified item does not exist", (char*)NULL);
	return TCL_ERROR;
    }

    if (argc == 2) {
	return Tk_ConfigureInfo(interp, wPtr->dispData.tkwin, 
	    chPtr->col[column].iPtr->base.diTypePtr->itemConfigSpecs,
	    (char *)chPtr->col[column].iPtr, NULL, 0);
    } else if (argc == 3) {
	return Tk_ConfigureInfo(interp, wPtr->dispData.tkwin, 
	    chPtr->col[column].iPtr->base.diTypePtr->itemConfigSpecs,
	    (char *)chPtr->col[column].iPtr, argv[2], 0);
    } else {
	Tix_HLMarkElementDirty(wPtr, chPtr);
	Tix_HLResizeWhenIdle(wPtr);

	return Tix_DItemConfigure(chPtr->col[column].iPtr,
	    argc-2, argv+2, TK_CONFIG_ARGV_ONLY);
    }
}

/*----------------------------------------------------------------------
 * "item create" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLItemCreate(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int column, i;
    size_t len;
    Tix_DItem * iPtr;
    char * ditemType = NULL;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, argv[0])) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_GetInt(interp, argv[1], &column) != TCL_OK) {
	return TCL_ERROR;
    }
    if (column >= wPtr->numColumns || column < 0) {
	Tcl_AppendResult(interp, "Column \"", argv[1], 
	    "\" does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    if (argc %2) {
	Tcl_AppendResult(interp, "value for \"", argv[argc-1],
	    "\" missing", NULL);
	return TCL_ERROR;
    }
    for (i=2; i<argc; i+=2) {
	len = strlen(argv[i]);
	if (strncmp(argv[i], "-itemtype", len) == 0) {
	    ditemType = argv[i+1];
	}
    }
    if (ditemType == NULL) {
	ditemType = wPtr->diTypePtr->name;
    }
    if (column != 0 && strcmp(ditemType, "window") == 0) {
	/* The current implementation does not allow this! Sorry!
	 */
	Tcl_AppendResult(interp, "Window items can only be created for ",
	    "column 0", (char*)NULL);
	return TCL_ERROR;
    }

    iPtr = Tix_DItemCreate(&wPtr->dispData, ditemType);
    if (iPtr == NULL) {
	return TCL_ERROR;
    }
    iPtr->base.clientData = (ClientData)chPtr;
    if (Tix_DItemConfigure(iPtr, argc-2, argv+2, 0) != TCL_OK) {
	return TCL_ERROR;
    }

    if (chPtr->col[column].iPtr != NULL) {
	if (Tix_DItemType(chPtr->col[column].iPtr) == TIX_DITEM_WINDOW) {
	    Tix_WindowItemListRemove(&wPtr->mappedWindows,
		chPtr->col[column].iPtr);
	}
	Tix_DItemFree(chPtr->col[column].iPtr);
    }
    chPtr->col[column].iPtr = iPtr;
    Tix_HLMarkElementDirty(wPtr, chPtr);
    Tix_HLResizeWhenIdle(wPtr);

    return TCL_OK;
}
/*----------------------------------------------------------------------
 * "item delete" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLItemDelete(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    HListElement * chPtr;
    int column;

    if ((chPtr = Tix_HLFindElement(interp, wPtr, argv[0])) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_GetInt(interp, argv[1], &column) != TCL_OK) {
	return TCL_ERROR;
    }
    if (column >= wPtr->numColumns || column < 0) {
	Tcl_AppendResult(interp, "Column \"", argv[1], 
	    "\" does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    if (column == 0) {
	Tcl_AppendResult(interp, "Cannot delete item at column 0",(char*)NULL);
	return TCL_ERROR;
    }
    if (chPtr->col[column].iPtr == NULL) {
	/* ToDo: sloppy error msg */
	Tcl_AppendResult(interp, "Specified item does not exist", (char*)NULL);
	return TCL_ERROR;
    }

    if (Tix_DItemType(chPtr->col[column].iPtr) == TIX_DITEM_WINDOW) {
	Tix_WindowItemListRemove(&wPtr->mappedWindows,
	    chPtr->col[column].iPtr);
    }

    /* Free the item and leave a blank! */

    Tix_DItemFree(chPtr->col[column].iPtr);
    chPtr->col[column].iPtr = NULL;

    Tix_HLMarkElementDirty(wPtr, chPtr);
    Tix_HLResizeWhenIdle(wPtr);

    return TCL_OK;
}
/*----------------------------------------------------------------------
 * "column" sub command
 *----------------------------------------------------------------------
 */
int
Tix_HLColumn(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    static Tix_SubCmdInfo subCmdInfo[] = {
	{TIX_DEFAULT_LEN, "width", 1, 3, Tix_HLColWidth,
	   "column ?-char? ?size?"},
    };
    static Tix_CmdInfo cmdInfo = {
	Tix_ArraySize(subCmdInfo), 1, TIX_VAR_ARGS, "?option? ?arg ...?",
    };

    return Tix_HandleSubCmds(&cmdInfo, subCmdInfo, clientData,
	interp, argc+1, argv-1);
}

/*----------------------------------------------------------------------
 * "column width" sub command
 *----------------------------------------------------------------------
 */
static int
Tix_HLColWidth(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    WidgetPtr wPtr = (WidgetPtr) clientData;
    int column;
    char buff[128];
    int newWidth;

    if (Tcl_GetInt(interp, argv[0], &column) != TCL_OK) {
	return TCL_ERROR;
    }
    if (column >= wPtr->numColumns || column < 0) {
	Tcl_AppendResult(interp, "Column \"", argv[0], 
	    "\" does not exist", (char*)NULL);
	return TCL_ERROR;
    }
    if (argc == 1) {
	/* Query */
	if (wPtr->reqSize[column].width != UNINITIALIZED) {
	    sprintf(buff, "%d", wPtr->reqSize[column].width);
	    Tcl_AppendResult(interp, buff, NULL);
	}
	/* Otherwise we return a empty string to indicate that this column
	 * size is not initialized */
	return TCL_OK;
    }
    else if (argc == 2) {
	if (argv[1][0] == '\0') {
	    newWidth = UNINITIALIZED;
	    goto setwidth;
	}
	if (Tk_GetPixels(interp, wPtr->dispData.tkwin, argv[1],
		 &newWidth) != TCL_OK) {
	    return TCL_ERROR;
	}
 	if (newWidth < 0) {
	    newWidth = 0;
	}
    }
    else if (argc == 3 && strcmp(argv[1], "-char")==0) {
	if (argv[2][0] == '\0') {
	    newWidth = UNINITIALIZED;
	    goto setwidth;
	}
	if (Tcl_GetInt(interp, argv[2], &newWidth) != TCL_OK) {
	    return TCL_ERROR;
	}
	if (newWidth < 0) {
	    newWidth = 0;
	}
	newWidth *= wPtr->scrollUnit[0];
    }
    else {
	return Tix_ArgcError(interp, argc+3, argv-3, 3,
	    "column ?-char? ?size?");
    }

  setwidth:

    if (wPtr->reqSize[column].width == newWidth) {
	return TCL_OK;
    } else {
	wPtr->reqSize[column].width = newWidth;
    }

    if (wPtr->actualSize[column].width == newWidth) {
	return TCL_OK;
    } else {
	wPtr->allDirty = 1;
	Tix_HLResizeWhenIdle(wPtr);
	return TCL_OK;
    }
}
