/* 
 * tkUtil.c --
 *
 *	This file contains miscellaneous utility procedures that
 *	are used by the rest of Tk, such as a procedure for drawing
 *	a focus highlight.
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: tkUtil.c,v 1.2 1998/09/14 18:23:20 stanton Exp $
 */

#include "tkInt.h"
#include "tkPort.h"

#ifndef _LANG
/*
 * The structure below defines the implementation of the "statekey"
 * Tcl object, used for quickly finding a mapping in a TkStateMap.
 */

static Tcl_ObjType stateKeyType = {
    "statekey",				/* name */
    (Tcl_FreeInternalRepProc *) NULL,	/* freeIntRepProc */
    (Tcl_DupInternalRepProc *) NULL,	/* dupIntRepProc */
    (Tcl_UpdateStringProc *) NULL,	/* updateStringProc */
    (Tcl_SetFromAnyProc *) NULL		/* setFromAnyProc */
};           
#endif


/*
 *--------------------------------------------------------------
 *
 * Tk_StateParseProc --
 *
 *	This procedure is invoked during option processing to handle
 *	the "-state" and "-default" options.
 *
 * Results:
 *	A standard Tcl return value.
 *
 * Side effects:
 *	The state for a given item gets replaced by the state
 *	indicated in the value argument.
 *
 *--------------------------------------------------------------
 */

int
TkStateParseProc(clientData, interp, tkwin, ovalue, widgRec, offset)
    ClientData clientData;		/* some flags.*/
    Tcl_Interp *interp;			/* Used for reporting errors. */
    Tk_Window tkwin;			/* Window containing canvas widget. */
    Arg ovalue;				/* Value of option. */
    char *widgRec;			/* Pointer to record for item. */
    int offset;				/* Offset into item. */
{
    int c;
    int flags = (int)clientData;
    size_t length;
    char *value = LangString(ovalue);

    register Tk_State *statePtr = (Tk_State *) (widgRec + offset);

    if(value == NULL || *value == 0) {
	*statePtr = TK_STATE_NULL;
	return TCL_OK;
    }

    c = value[0];
    length = strlen(value);

    if ((c == 'n') && (strncmp(value, "normal", length) == 0)) {
	*statePtr = TK_STATE_NORMAL;
	return TCL_OK;
    }
    if ((c == 'd') && (strncmp(value, "disabled", length) == 0)) {
	*statePtr = TK_STATE_DISABLED;
	return TCL_OK;
    }
    if ((c == 'a') && (flags&1) && (strncmp(value, "active", length) == 0)) {
	*statePtr = TK_STATE_ACTIVE;
	return TCL_OK;
    }
    if ((c == 'h') && (flags&2) && (strncmp(value, "hidden", length) == 0)) {
	*statePtr = TK_STATE_HIDDEN;
	return TCL_OK;
    }

    Tcl_AppendResult(interp, "bad ", (flags&4)?"-default" : "state",
	    " value \"", value, "\": must be normal",
	    (char *) NULL);
    if (flags&1) {
	Tcl_AppendResult(interp, ", active",(char *) NULL);
    }
    if (flags&2) {
	Tcl_AppendResult(interp, ", hidden",(char *) NULL);
    }
    if (flags&3) {
	Tcl_AppendResult(interp, ",",(char *) NULL);
    }
    Tcl_AppendResult(interp, " or disabled",(char *) NULL);
    *statePtr = TK_STATE_NORMAL;
    return TCL_ERROR;
}

/*
 *--------------------------------------------------------------
 *
 * Tk_StatePrintProc --
 *
 *	This procedure is invoked by the Tk configuration code
 *	to produce a printable string for the "-state"
 *	configuration option.
 *
 * Results:
 *	The return value is a string describing the state for
 *	the item referred to by "widgRec".  In addition, *freeProcPtr
 *	is filled in with the address of a procedure to call to free
 *	the result string when it's no longer needed (or NULL to
 *	indicate that the string doesn't need to be freed).
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

Arg 
TkStatePrintProc(clientData, tkwin, widgRec, offset, freeProcPtr)
    ClientData clientData;		/* Ignored. */
    Tk_Window tkwin;			/* Window containing canvas widget. */
    char *widgRec;			/* Pointer to record for item. */
    int offset;				/* Offset into item. */
    Tcl_FreeProc **freeProcPtr;		/* Pointer to variable to fill in with
					 * information about how to reclaim
					 * storage for return string. */
{
    register Tk_State *statePtr = (Tk_State *) (widgRec + offset);

    if (*statePtr==TK_STATE_NORMAL) {
	return LangStringArg("normal");
    } else if (*statePtr==TK_STATE_DISABLED) {
	return LangStringArg("disabled");
    } else if (*statePtr==TK_STATE_HIDDEN) {
	return LangStringArg("hidden");
    } else if (*statePtr==TK_STATE_ACTIVE) {
	return LangStringArg("active");
    } else {
	return LangStringArg("");
    }
}

/*
 *--------------------------------------------------------------
 *
 * Tk_OrientParseProc --
 *
 *	This procedure is invoked during option processing to handle
 *	the "-orient" option.
 *
 * Results:
 *	A standard Tcl return value.
 *
 * Side effects:
 *	The orientation for a given item gets replaced by the orientation
 *	indicated in the value argument.
 *
 *--------------------------------------------------------------
 */

int
TkOrientParseProc(clientData, interp, tkwin, ovalue, widgRec, offset)
    ClientData clientData;		/* some flags.*/
    Tcl_Interp *interp;			/* Used for reporting errors. */
    Tk_Window tkwin;			/* Window containing canvas widget. */
    Arg ovalue;				/* Value of option. */
    char *widgRec;			/* Pointer to record for item. */
    int offset;				/* Offset into item. */
{
    int c;
    size_t length;
    char *value = LangString(ovalue);

    register int *orientPtr = (int *) (widgRec + offset);

    if(value == NULL || *value == 0) {
	*orientPtr = 0;
	return TCL_OK;
    }

    c = value[0];
    length = strlen(value);

    if ((c == 'h') && (strncmp(value, "horizontal", length) == 0)) {
	*orientPtr = 0;
	return TCL_OK;
    }
    if ((c == 'v') && (strncmp(value, "vertical", length) == 0)) {
	*orientPtr = 1;
	return TCL_OK;
    }
    Tcl_AppendResult(interp, "bad orientation \"", value,
	    "\": must be vertical or horizontal",
	    (char *) NULL);
    *orientPtr = 0;
    return TCL_ERROR;
}

/*
 *--------------------------------------------------------------
 *
 * Tk_OrientPrintProc --
 *
 *	This procedure is invoked by the Tk configuration code
 *	to produce a printable string for the "-orient"
 *	configuration option.
 *
 * Results:
 *	The return value is a string describing the orientation for
 *	the item referred to by "widgRec".  In addition, *freeProcPtr
 *	is filled in with the address of a procedure to call to free
 *	the result string when it's no longer needed (or NULL to
 *	indicate that the string doesn't need to be freed).
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

Arg
TkOrientPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr)
    ClientData clientData;		/* Ignored. */
    Tk_Window tkwin;			/* Window containing canvas widget. */
    char *widgRec;			/* Pointer to record for item. */
    int offset;				/* Offset into item. */
    Tcl_FreeProc **freeProcPtr;		/* Pointer to variable to fill in with
					 * information about how to reclaim
					 * storage for return string. */
{
    register int *statePtr = (int *) (widgRec + offset);

    if (*statePtr) {
	return LangStringArg("vertical");
    } else {
	return LangStringArg("horizontal");
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_TileParseProc --
 *
 *	Converts the name of an image into a tile.
 *
 *----------------------------------------------------------------------
 */

int
TkTileParseProc(clientData, interp, tkwin, ovalue, widgRec, offset)
    ClientData clientData;	/* not used */
    Tcl_Interp *interp;		/* Interpreter to send results back to */
    Tk_Window tkwin;		/* Window on same display as tile */
    Arg ovalue;			/* Name of image */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
{
    Tk_Tile *tilePtr = (Tk_Tile *)(widgRec + offset);
    Tk_Tile tile, lastTile;
    char *value = LangString(ovalue);

    lastTile = *tilePtr;
    tile = NULL;
    if ((value != NULL) && (*value != '\0')) {
	tile = Tk_GetTile(interp, tkwin, value);
	if (tile == NULL) {
	    return TCL_ERROR;
	}
    }
    if (lastTile != NULL) {
	Tk_FreeTile(lastTile);
    }
    *tilePtr = tile;
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_TilePrintProc --
 *
 *	Returns the name of the tile.
 *
 * Results:
 *	The name of the tile is returned.
 *
 *----------------------------------------------------------------------
 */

Arg
TkTilePrintProc(clientData, tkwin, widgRec, offset, freeProcPtr)
    ClientData clientData;	/* not used */
    Tk_Window tkwin;		/* not used */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
    Tcl_FreeProc **freeProcPtr;	/* not used */
{
    Tk_Tile tile = *(Tk_Tile *)(widgRec + offset);

    return LangStringArg(Tk_NameOfTile(tile));
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_OffsetParseProc --
 *
 *	Converts the offset of a stipple or tile into the Tk_TSOffset structure.
 *
 *----------------------------------------------------------------------
 */

int
TkOffsetParseProc(clientData, interp, tkwin, ovalue, widgRec, offset)
    ClientData clientData;	/* not used */
    Tcl_Interp *interp;		/* Interpreter to send results back to */
    Tk_Window tkwin;		/* Window on same display as tile */
    Arg ovalue;			/* Name of image */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
{
    Tk_TSOffset *offsetPtr = (Tk_TSOffset *)(widgRec + offset);
    Tk_TSOffset tsoffset;
    CONST char *q, *p;
    int result;
    Tcl_Obj **args;
    int argc;  
    char *value = NULL;
    if (Tcl_ListObjGetElements(NULL,ovalue,&argc,&args) != TCL_OK) {
	goto badTSOffset;        
    }
    if (argc == 1) { 
	char *value = LangString(args[1]);
    }
    if ((value == NULL) || (*value == 0)) {
	tsoffset.flags = TK_OFFSET_CENTER|TK_OFFSET_MIDDLE;
	goto goodTSOffset;
    }
    tsoffset.flags = 0;
    p = value;

    switch(value[0]) {
	case '#':
	    if (((int)clientData) & TK_OFFSET_RELATIVE) {
		tsoffset.flags = TK_OFFSET_RELATIVE;
		argc--; 
		args++;
		break;
	    }
	    goto badTSOffset;
	case 'e':
	    switch(value[1]) {
		case '\0':
		    tsoffset.flags = TK_OFFSET_RIGHT|TK_OFFSET_MIDDLE;
		    goto goodTSOffset;
		case 'n':
		    if (value[2]!='d' || value[3]!='\0') {goto badTSOffset;}
		    tsoffset.flags = INT_MAX;
		    goto goodTSOffset;
	    }
	case 'w':
	    if (value[1] != '\0') {goto badTSOffset;}
	    tsoffset.flags = TK_OFFSET_LEFT|TK_OFFSET_MIDDLE;
	    goto goodTSOffset;
	case 'n':
	    if ((value[1] != '\0') && (value[2] != '\0')) {
		goto badTSOffset;
	    }
	    switch(value[1]) {
		case '\0': tsoffset.flags = TK_OFFSET_CENTER|TK_OFFSET_TOP;
			   goto goodTSOffset;
		case 'w': tsoffset.flags = TK_OFFSET_LEFT|TK_OFFSET_TOP;
			   goto goodTSOffset;
		case 'e': tsoffset.flags = TK_OFFSET_RIGHT|TK_OFFSET_TOP;
			   goto goodTSOffset;
	    }
	    goto badTSOffset;
	case 's':
	    if ((value[1] != '\0') && (value[2] != '\0')) {
		goto badTSOffset;
	    }
	    switch(value[1]) {
		case '\0': tsoffset.flags = TK_OFFSET_CENTER|TK_OFFSET_BOTTOM;
			   goto goodTSOffset;
		case 'w': tsoffset.flags = TK_OFFSET_LEFT|TK_OFFSET_BOTTOM;
			   goto goodTSOffset;
		case 'e': tsoffset.flags = TK_OFFSET_RIGHT|TK_OFFSET_BOTTOM;
			   goto goodTSOffset;
	    }
	    goto badTSOffset;
	case 'c':
	    if (strncmp(value, "center", strlen(value)) != 0) {
		goto badTSOffset;
	    }
	    tsoffset.flags = TK_OFFSET_CENTER|TK_OFFSET_MIDDLE;
	    goto goodTSOffset;
    }
    if (argc == 1) {
	if (((int)clientData) & TK_OFFSET_INDEX) {
	    if (Tcl_GetInt(interp, args[0], &tsoffset.flags) != TCL_OK) {
		Tcl_ResetResult(interp);
		goto badTSOffset;
	    }
	    tsoffset.flags |= TK_OFFSET_INDEX;
	    goto goodTSOffset;
	}
	goto badTSOffset;
    } else if (argc == 2) {
	result = Tk_GetPixels(interp, tkwin, LangString(args[0]), &tsoffset.xoffset);
	if (result != TCL_OK) {
	    return TCL_ERROR;
	}
	result = Tk_GetPixels(interp, tkwin, LangString(args[1]), &tsoffset.yoffset);
	if (result != TCL_OK) {
	    return TCL_ERROR;
	}
    } else {
	goto badTSOffset;
    }

goodTSOffset:
    /* below is a hack to allow the stipple/tile offset to be stored
     * in the internal tile structure. Most of the times, offsetPtr
     * is a pointer to an already existing tile structure. However
     * if this structure is not already created, we must do it
     * with Tk_GetTile()!!!!;
     */

    memcpy(offsetPtr,&tsoffset, sizeof(Tk_TSOffset));
    return TCL_OK;

badTSOffset:
    Tcl_AppendResult(interp, "bad offset \"", value,
	    "\": expected \"x,y\"", (char *) NULL);
    if (((int) clientData) & TK_OFFSET_RELATIVE) {
	Tcl_AppendResult(interp, ", \"#x,y\"", (char *) NULL);
    }
    if (((int) clientData) & TK_OFFSET_INDEX) {
	Tcl_AppendResult(interp, ", <index>", (char *) NULL);
    }
    Tcl_AppendResult(interp, ", n, ne, e, se, s, sw, w, nw, or center",
	    (char *) NULL);
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_OffsetPrintProc --
 *
 *	Returns the offset of the tile.
 *
 * Results:
 *	The offset of the tile is returned.
 *
 *----------------------------------------------------------------------
 */

Arg
TkOffsetPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr)
    ClientData clientData;	/* not used */
    Tk_Window tkwin;		/* not used */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
    Tcl_FreeProc **freeProcPtr;	/* not used */
{
    Tk_TSOffset *offsetPtr = (Tk_TSOffset *)(widgRec + offset);
    char *p, *q;

    if ((offsetPtr->flags) & TK_OFFSET_INDEX) {
	if ((offsetPtr->flags) >= INT_MAX) {
	    return LangStringArg("end");
	}
	return Tcl_NewIntObj(offsetPtr->flags & (~TK_OFFSET_INDEX));
    }
    if ((offsetPtr->flags) & TK_OFFSET_TOP) {
	if ((offsetPtr->flags) & TK_OFFSET_LEFT) {
	    return LangStringArg("nw");
	} else if ((offsetPtr->flags) & TK_OFFSET_CENTER) {
	    return LangStringArg("n");
	} else if ((offsetPtr->flags) & TK_OFFSET_RIGHT) {
	    return LangStringArg("ne");
	}
    } else if ((offsetPtr->flags) & TK_OFFSET_MIDDLE) {
	if ((offsetPtr->flags) & TK_OFFSET_LEFT) {
	    return LangStringArg("w");
	} else if ((offsetPtr->flags) & TK_OFFSET_CENTER) {
	    return LangStringArg("center");
	} else if ((offsetPtr->flags) & TK_OFFSET_RIGHT) {
	    return LangStringArg("e");
	}
    } else if ((offsetPtr->flags) & TK_OFFSET_BOTTOM) {
	if ((offsetPtr->flags) & TK_OFFSET_LEFT) {
	    return LangStringArg("sw");
	} else if ((offsetPtr->flags) & TK_OFFSET_CENTER) {
	    return LangStringArg("s");
	} else if ((offsetPtr->flags) & TK_OFFSET_RIGHT) {
	    return LangStringArg("se");
	}                                
    }
    {         
        Tcl_Obj *result = Tcl_NewListObj(0,NULL);   
        if ((offsetPtr->flags) & TK_OFFSET_RELATIVE) {
	    Tcl_ListObjAppendElement(NULL,result,LangStringArg("#"));
	}                                                       
	Tcl_ListObjAppendElement(NULL,result,Tcl_NewIntObj(offsetPtr->xoffset));
	Tcl_ListObjAppendElement(NULL,result,Tcl_NewIntObj(offsetPtr->yoffset));
	return result;
    }
}


/*
 *----------------------------------------------------------------------
 *
 * Tk_PixelParseProc --
 *
 *	Converts the name of an image into a tile.
 *
 *----------------------------------------------------------------------
 */

int
TkPixelParseProc(clientData, interp, tkwin, ovalue, widgRec, offset)
    ClientData clientData;	/* if non-NULL, negative values are
				 * allowed as well */
    Tcl_Interp *interp;		/* Interpreter to send results back to */
    Tk_Window tkwin;		/* Window on same display as tile */
    Arg ovalue;			/* Name of image */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
{
    double *doublePtr = (double *)(widgRec + offset);
    int result;

    result = Tk_GetDoublePixels(interp, tkwin, LangString(ovalue), doublePtr);

    if ((result == TCL_OK) && (clientData == NULL) && (*doublePtr < 0.0)) {
	Tcl_AppendResult(interp, "bad screen distance \"", LangString(ovalue),
		"\"", (char *) NULL);
	return TCL_ERROR;
    }
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_PixelPrintProc --
 *
 *	Returns the name of the tile.
 *
 * Results:
 *	The name of the tile is returned.
 *
 *----------------------------------------------------------------------
 */

Arg
TkPixelPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr)
    ClientData clientData;	/* not used */
    Tk_Window tkwin;		/* not used */
    char *widgRec;		/* Widget structure record */
    int offset;			/* Offset of tile in record */
    Tcl_FreeProc **freeProcPtr;	/* not used */
{
    double *doublePtr = (double *)(widgRec + offset);
    return Tcl_NewDoubleObj(*doublePtr);
}

/*
 *----------------------------------------------------------------------
 *
 * TkDrawInsetFocusHighlight --
 *
 *	This procedure draws a rectangular ring around the outside of
 *	a widget to indicate that it has received the input focus.  It
 *	takes an additional padding argument that specifies how much
 *	padding is present outside th widget.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A rectangle "width" pixels wide is drawn in "drawable",
 *	corresponding to the outer area of "tkwin".
 *
 *----------------------------------------------------------------------
 */

void
TkDrawInsetFocusHighlight(tkwin, gc, width, drawable, padding)
    Tk_Window tkwin;		/* Window whose focus highlight ring is
				 * to be drawn. */
    GC gc;			/* Graphics context to use for drawing
				 * the highlight ring. */
    int width;			/* Width of the highlight ring, in pixels. */
    Drawable drawable;		/* Where to draw the ring (typically a
				 * pixmap for double buffering). */
    int padding;		/* Width of padding outside of widget. */
{
    XRectangle rects[4];

    /*
     * On the Macintosh the highlight ring needs to be "padded"
     * out by one pixel.  Unfortunantly, none of the Tk widgets
     * had a notion of padding between the focus ring and the
     * widget.  So we add this padding here.  This introduces
     * two things to worry about:
     *
     * 1) The widget must draw the background color covering
     *    the focus ring area before calling Tk_DrawFocus.
     * 2) It is impossible to draw a focus ring of width 1.
     *    (For the Macintosh Look & Feel use width of 3)
     */
#ifdef MAC_TCL
    width--;
#endif

    rects[0].x = padding;
    rects[0].y = padding;
    rects[0].width = Tk_Width(tkwin) - (2 * padding);
    rects[0].height = width;
    rects[1].x = padding;
    rects[1].y = Tk_Height(tkwin) - width - padding;
    rects[1].width = Tk_Width(tkwin) - (2 * padding);
    rects[1].height = width;
    rects[2].x = padding;
    rects[2].y = width + padding;
    rects[2].width = width;
    rects[2].height = Tk_Height(tkwin) - 2*width - 2*padding;
    rects[3].x = Tk_Width(tkwin) - width - padding;
    rects[3].y = rects[2].y;
    rects[3].width = width;
    rects[3].height = rects[2].height;
    XFillRectangles(Tk_Display(tkwin), drawable, gc, rects, 4);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_DrawFocusHighlight --
 *
 *	This procedure draws a rectangular ring around the outside of
 *	a widget to indicate that it has received the input focus.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A rectangle "width" pixels wide is drawn in "drawable",
 *	corresponding to the outer area of "tkwin".
 *
 *----------------------------------------------------------------------
 */

void
Tk_DrawFocusHighlight(tkwin, gc, width, drawable)
    Tk_Window tkwin;		/* Window whose focus highlight ring is
				 * to be drawn. */
    GC gc;			/* Graphics context to use for drawing
				 * the highlight ring. */
    int width;			/* Width of the highlight ring, in pixels. */
    Drawable drawable;		/* Where to draw the ring (typically a
				 * pixmap for double buffering). */
{
    TkDrawInsetFocusHighlight(tkwin, gc, width, drawable, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetScrollInfo --
 *
 *	This procedure is invoked to parse "xview" and "yview"
 *	scrolling commands for widgets using the new scrolling
 *	command syntax ("moveto" or "scroll" options).
 *
 * Results:
 *	The return value is either TK_SCROLL_MOVETO, TK_SCROLL_PAGES,
 *	TK_SCROLL_UNITS, or TK_SCROLL_ERROR.  This indicates whether
 *	the command was successfully parsed and what form the command
 *	took.  If TK_SCROLL_MOVETO, *dblPtr is filled in with the
 *	desired position;  if TK_SCROLL_PAGES or TK_SCROLL_UNITS,
 *	*intPtr is filled in with the number of lines to move (may be
 *	negative);  if TK_SCROLL_ERROR, interp->result contains an
 *	error message.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int
Tk_GetScrollInfo(interp, argc, argv, dblPtr, intPtr)
    Tcl_Interp *interp;			/* Used for error reporting. */
    int argc;				/* # arguments for command. */
    char **argv;			/* Arguments for command. */
    double *dblPtr;			/* Filled in with argument "moveto"
					 * option, if any. */
    int *intPtr;			/* Filled in with number of pages
					 * or lines to scroll, if any. */
{
    int c;
    size_t length;

    length = strlen(argv[2]);
    c = argv[2][0];
    if ((c == 'm') && (strncmp(argv[2], "moveto", length) == 0)) {
	if (argc != 4) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    argv[0], " ", argv[1], " moveto fraction\"",
		    (char *) NULL);
	    return TK_SCROLL_ERROR;
	}
	if (Tcl_GetDouble(interp, argv[3], dblPtr) != TCL_OK) {
	    return TK_SCROLL_ERROR;
	}
	return TK_SCROLL_MOVETO;
    } else if ((c == 's')
	    && (strncmp(argv[2], "scroll", length) == 0)) {
	if (argc != 5) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    argv[0], " ", argv[1], " scroll number units|pages\"",
		    (char *) NULL);
	    return TK_SCROLL_ERROR;
	}
	if (Tcl_GetInt(interp, argv[3], intPtr) != TCL_OK) {
	    return TK_SCROLL_ERROR;
	}
	length = strlen(argv[4]);
	c = argv[4][0];
	if ((c == 'p') && (strncmp(argv[4], "pages", length) == 0)) {
	    return TK_SCROLL_PAGES;
	} else if ((c == 'u')
		&& (strncmp(argv[4], "units", length) == 0)) {
	    return TK_SCROLL_UNITS;
	} else {
	    Tcl_AppendResult(interp, "bad argument \"", argv[4],
		    "\": must be units or pages", (char *) NULL);
	    return TK_SCROLL_ERROR;
	}
    }
    Tcl_AppendResult(interp, "unknown option \"", argv[2],
	    "\": must be moveto or scroll", (char *) NULL);
    return TK_SCROLL_ERROR;
}

/*
 *---------------------------------------------------------------------------
 *
 * TkComputeAnchor --
 *
 *	Determine where to place a rectangle so that it will be properly
 *	anchored with respect to the given window.  Used by widgets
 *	to align a box of text inside a window.  When anchoring with
 *	respect to one of the sides, the rectangle be placed inside of
 *	the internal border of the window.
 *
 * Results:
 *	*xPtr and *yPtr set to the upper-left corner of the rectangle
 *	anchored in the window.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------------------
 */
void
TkComputeAnchor(anchor, tkwin, padX, padY, innerWidth, innerHeight, xPtr, yPtr)
    Tk_Anchor anchor;		/* Desired anchor. */
    Tk_Window tkwin;		/* Anchored with respect to this window. */
    int padX, padY;		/* Use this extra padding inside window, in
				 * addition to the internal border. */
    int innerWidth, innerHeight;/* Size of rectangle to anchor in window. */
    int *xPtr, *yPtr;		/* Returns upper-left corner of anchored
				 * rectangle. */
{
    switch (anchor) {
	case TK_ANCHOR_NW:
	case TK_ANCHOR_W:
	case TK_ANCHOR_SW:
	    *xPtr = Tk_InternalBorderWidth(tkwin) + padX;
	    break;

	case TK_ANCHOR_N:
	case TK_ANCHOR_CENTER:
	case TK_ANCHOR_S:
	    *xPtr = (Tk_Width(tkwin) - innerWidth) / 2;
	    break;

	default:
	    *xPtr = Tk_Width(tkwin) - (Tk_InternalBorderWidth(tkwin) + padX)
		    - innerWidth;
	    break;
    }

    switch (anchor) {
	case TK_ANCHOR_NW:
	case TK_ANCHOR_N:
	case TK_ANCHOR_NE:
	    *yPtr = Tk_InternalBorderWidth(tkwin) + padY;
	    break;

	case TK_ANCHOR_W:
	case TK_ANCHOR_CENTER:
	case TK_ANCHOR_E:
	    *yPtr = (Tk_Height(tkwin) - innerHeight) / 2;
	    break;

	default:
	    *yPtr = Tk_Height(tkwin) - Tk_InternalBorderWidth(tkwin) - padY
		    - innerHeight;
	    break;
    }
}

/*
 *---------------------------------------------------------------------------
 *
 * TkFindStateString --
 *
 *	Given a lookup table, map a number to a string in the table.
 *
 * Results:
 *	If numKey was equal to the numeric key of one of the elements
 *	in the table, returns the string key of that element.
 *	Returns NULL if numKey was not equal to any of the numeric keys
 *	in the table.
 *
 * Side effects.
 *	None.
 *
 *---------------------------------------------------------------------------
 */

char *
TkFindStateString(mapPtr, numKey)
    CONST TkStateMap *mapPtr;	/* The state table. */
    int numKey;			/* The key to try to find in the table. */
{
    for ( ; mapPtr->strKey != NULL; mapPtr++) {
	if (numKey == mapPtr->numKey) {
	    return mapPtr->strKey;
	}
    }
    return NULL;
}

/*
 *---------------------------------------------------------------------------
 *
 * TkFindStateNum --
 *
 *	Given a lookup table, map a string to a number in the table.
 *
 * Results:
 *	If strKey was equal to the string keys of one of the elements
 *	in the table, returns the numeric key of that element.
 *	Returns the numKey associated with the last element (the NULL
 *	string one) in the table if strKey was not equal to any of the
 *	string keys in the table.  In that case, an error message is
 *	also left in interp->result (if interp is not NULL).
 *
 * Side effects.
 *	None.
 *
 *---------------------------------------------------------------------------
 */

int
TkFindStateNum(interp, field, mapPtr, strKey)
    Tcl_Interp *interp;		/* Interp for error reporting. */
    CONST char *field;		/* String to use when constructing error. */
    CONST TkStateMap *mapPtr;	/* Lookup table. */
    CONST char *strKey;		/* String to try to find in lookup table. */
{
    CONST TkStateMap *mPtr;

    if (mapPtr->strKey == NULL) {
	panic("TkFindStateNum: no choices in lookup table");
    }

    for (mPtr = mapPtr; mPtr->strKey != NULL; mPtr++) {
	if (strcmp(strKey, mPtr->strKey) == 0) {
	    return mPtr->numKey;
	}
    }
    if (interp != NULL) {
	mPtr = mapPtr;
	Tcl_AppendResult(interp, "bad ", field, " value \"", strKey,
		"\": must be ", mPtr->strKey, (char *) NULL);
	for (mPtr++; mPtr->strKey != NULL; mPtr++) {
	    Tcl_AppendResult(interp, ", ", mPtr->strKey, (char *) NULL);
	}
    }
    return mPtr->numKey;
}                                       


int
TkFindStateNumObj(interp, optionPtr, mapPtr, keyPtr)
    Tcl_Interp *interp;		/* Interp for error reporting. */
    Tcl_Obj *optionPtr;		/* String to use when constructing error. */
    CONST TkStateMap *mapPtr;	/* Lookup table. */
    Tcl_Obj *keyPtr;		/* String key to find in lookup table. */
{
#ifdef _LANG
    return TkFindStateNum(interp, LangString(optionPtr), mapPtr, LangString(keyPtr));
#else
    CONST TkStateMap *mPtr;
    CONST char *key;
    CONST Tcl_ObjType *typePtr;

    if ((keyPtr->typePtr == &stateKeyType)
	    && (keyPtr->internalRep.twoPtrValue.ptr1 == (VOID *) mapPtr)) {
	return (int) keyPtr->internalRep.twoPtrValue.ptr2;
    }

    key = Tcl_GetStringFromObj(keyPtr, NULL);
    for (mPtr = mapPtr; mPtr->strKey != NULL; mPtr++) {
	if (strcmp(key, mPtr->strKey) == 0) {
	    typePtr = keyPtr->typePtr;
	    if ((typePtr != NULL) && (typePtr->freeIntRepProc != NULL)) {
		(*typePtr->freeIntRepProc)(keyPtr);
	    }
	    keyPtr->internalRep.twoPtrValue.ptr1 = (VOID *) mapPtr;
	    keyPtr->internalRep.twoPtrValue.ptr2 = (VOID *) mPtr->numKey;
	    keyPtr->typePtr = &stateKeyType;	    
	    return mPtr->numKey;
	}
    }
    if (interp != NULL) {
	mPtr = mapPtr;
	Tcl_AppendResult(interp, "bad ",
		Tcl_GetStringFromObj(optionPtr, NULL), " value \"", key,
		"\": must be ", mPtr->strKey, (char *) NULL);
	for (mPtr++; mPtr->strKey != NULL; mPtr++) {
	    Tcl_AppendResult(interp, ", ", mPtr->strKey, (char *) NULL);
	}
    }
    return mPtr->numKey;
#endif
}
             

