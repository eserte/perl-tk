/* 
 * tkUnixScrollbar.c --
 *
 *	This file implements the Unix specific portion of the scrollbar
 *	widget.
 *
 * Copyright (c) 1996 by Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: tkUnixScrlbr.c,v 1.2 1998/09/14 18:23:57 stanton Exp $
 */

#include "tk.h"
#include "tkScrollbar.h"

/*
 * Minimum slider length, in pixels (designed to make sure that the slider
 * is always easy to grab with the mouse).
 */

#define MIN_SLIDER_LENGTH	5

/*
 * Declaration of Unix specific scrollbar structure.
 */

typedef struct UnixScrollbar {
    TkScrollbar info;		/* Generic scrollbar info. */
    GC troughGC;		/* For drawing trough. */
    GC copyGC;			/* Used for copying from pixmap onto screen. */
} UnixScrollbar;

/*
 * The class procedure table for the scrollbar widget.
 */

TkClassProcs tkpScrollbarProcs = { 
    NULL,			/* createProc. */
    NULL,			/* geometryProc. */
    NULL			/* modalProc. */
};

/*
 * Forward declarations for procedures defined later in this file:
 */

static void		TileChangedProc _ANSI_ARGS_((ClientData clientData,
			    Tk_Tile tile, Tk_Item *itemPtr));

/*
 *----------------------------------------------------------------------
 *
 * TkpCreateScrollbar --
 *
 *	Allocate a new TkScrollbar structure.
 *
 * Results:
 *	Returns a newly allocated TkScrollbar structure.
 *
 * Side effects:
 *	Registers an event handler for the widget.
 *
 *----------------------------------------------------------------------
 */

TkScrollbar *
TkpCreateScrollbar(tkwin)
    Tk_Window tkwin;
{
    UnixScrollbar *scrollPtr = (UnixScrollbar *)ckalloc(sizeof(UnixScrollbar));
    ((UnixScrollbar*)scrollPtr)->troughGC = None;
    ((UnixScrollbar*)scrollPtr)->copyGC = None;

    Tk_CreateEventHandler(tkwin,
	    ExposureMask|StructureNotifyMask|FocusChangeMask,
	    TkScrollbarEventProc, (ClientData) scrollPtr);

    return (TkScrollbar *) scrollPtr;
}

/*
 *--------------------------------------------------------------
 *
 * TkpDisplayScrollbar --
 *
 *	This procedure redraws the contents of a scrollbar window.
 *	It is invoked as a do-when-idle handler, so it only runs
 *	when there's nothing else for the application to do.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Information appears on the screen.
 *
 *--------------------------------------------------------------
 */

void
TkpDisplayScrollbar(clientData)
    ClientData clientData;	/* Information about window. */
{
    register TkScrollbar *scrollPtr = (TkScrollbar *) clientData;
    register Tk_Window tkwin = scrollPtr->tkwin;
    XPoint points[7];
    Tk_3DBorder border;
    int relief, width, elementBorderWidth;
    Pixmap pixmap;
    GC fillGC;

    if ((scrollPtr->tkwin == NULL) || !Tk_IsMapped(tkwin)) {
	goto done;
    }

    if (scrollPtr->vertical) {
	width = Tk_Width(tkwin) - 2*scrollPtr->inset;
    } else {
	width = Tk_Height(tkwin) - 2*scrollPtr->inset;
    }
    elementBorderWidth = scrollPtr->elementBorderWidth;
    if (elementBorderWidth < 0) {
	elementBorderWidth = scrollPtr->borderWidth;
    }

    /*
     * In order to avoid screen flashes, this procedure redraws
     * the scrollbar in a pixmap, then copies the pixmap to the
     * screen in a single operation.  This means that there's no
     * point in time where the on-sreen image has been cleared.
     */

    pixmap = Tk_GetPixmap(scrollPtr->display, Tk_WindowId(tkwin),
	    Tk_Width(tkwin), Tk_Height(tkwin), Tk_Depth(tkwin));

    if (scrollPtr->highlightWidth != 0) {
	GC gc;

	if (scrollPtr->flags & GOT_FOCUS) {
	    gc = Tk_GCForColor(scrollPtr->highlightColorPtr, pixmap);
	} else {
	    gc = Tk_GCForColor(scrollPtr->highlightBgColorPtr, pixmap);
	}
	Tk_DrawFocusHighlight(tkwin, gc, scrollPtr->highlightWidth, pixmap);
    }
    Tk_Draw3DRectangle(tkwin, pixmap, scrollPtr->bgBorder,
	    scrollPtr->highlightWidth, scrollPtr->highlightWidth,
	    Tk_Width(tkwin) - 2*scrollPtr->highlightWidth,
	    Tk_Height(tkwin) - 2*scrollPtr->highlightWidth,
	    scrollPtr->borderWidth, scrollPtr->relief);
    if (scrollPtr->tile != NULL) {
	if (scrollPtr->tsoffset.flags) {
	    int w=0; int h=0;
	    if (scrollPtr->tsoffset.flags & (TK_OFFSET_CENTER|TK_OFFSET_MIDDLE)) {
		    Tk_SizeOfTile(scrollPtr->tile, &w, &h);
	    }
	    if (scrollPtr->tsoffset.flags & TK_OFFSET_LEFT) {
		w = 0;
	    } else if (scrollPtr->tsoffset.flags & TK_OFFSET_RIGHT) {
		w = Tk_Width(tkwin);
	    } else {
		w = (Tk_Width(tkwin) - w) / 2;
	    }
	    if (scrollPtr->tsoffset.flags & TK_OFFSET_TOP) {
		h = 0;
	    } else if (scrollPtr->tsoffset.flags & TK_OFFSET_BOTTOM) {
		h = Tk_Height(tkwin);
	    } else {
		h = (Tk_Height(tkwin) - h) / 2;
	    }
	    XSetTSOrigin(scrollPtr->display, ((UnixScrollbar*)scrollPtr)->copyGC, w , h);
	} else {
	    Tk_SetTileOrigin(tkwin, ((UnixScrollbar*)scrollPtr)->copyGC, scrollPtr->tsoffset.xoffset,
		    scrollPtr->tsoffset.yoffset);
	}
    }
    if (scrollPtr->activeTile != NULL) {
	Tk_TSOffset *tsoffset = &scrollPtr->tsoffset;
	if (!tsoffset) {
	    Tk_SetTileOrigin(tkwin, scrollPtr->activeTileGC, 0, 0);
	} else if (tsoffset->flags) {
	    int w=0; int h=0;
	    if (tsoffset->flags & (TK_OFFSET_CENTER|TK_OFFSET_MIDDLE)) {
		    Tk_SizeOfTile(scrollPtr->activeTile, &w, &h);
	    }
	    if (tsoffset->flags & TK_OFFSET_LEFT) {
		w = 0;
	    } else if (tsoffset->flags & TK_OFFSET_RIGHT) {
		w = Tk_Width(tkwin);
	    } else {
		w = (Tk_Width(tkwin) - w) / 2;
	    }
	    if (tsoffset->flags & TK_OFFSET_TOP) {
		h = 0;
	    } else if (tsoffset->flags & TK_OFFSET_BOTTOM) {
		h = Tk_Height(tkwin);
	    } else {
		h = (Tk_Height(tkwin) - h) / 2;
	    }
	    XSetTSOrigin(scrollPtr->display, scrollPtr->activeTileGC, w , h);
	} else {
	    Tk_SetTileOrigin(tkwin, scrollPtr->activeTileGC, tsoffset->xoffset,
		    tsoffset->yoffset);
	}
    }
    if (scrollPtr->troughTile != NULL) {
	Tk_TSOffset *tsoffset = &scrollPtr->tsoffset;
	if (!tsoffset) {
	    Tk_SetTileOrigin(tkwin, ((UnixScrollbar*)scrollPtr)->troughGC, 0, 0);
	} else if (tsoffset->flags) {
	    int w=0; int h=0;
	    if (tsoffset->flags & (TK_OFFSET_CENTER|TK_OFFSET_MIDDLE)) {
		    Tk_SizeOfTile(scrollPtr->troughTile, &w, &h);
	    }
	    if (tsoffset->flags & TK_OFFSET_LEFT) {
		w = 0;
	    } else if (tsoffset->flags & TK_OFFSET_RIGHT) {
		w = Tk_Width(tkwin);
	    } else {
		w = (Tk_Width(tkwin) - w) / 2;
	    }
	    if (tsoffset->flags & TK_OFFSET_TOP) {
		h = 0;
	    } else if (tsoffset->flags & TK_OFFSET_BOTTOM) {
		h = Tk_Height(tkwin);
	    } else {
		h = (Tk_Height(tkwin) - h) / 2;
	    }
	    XSetTSOrigin(scrollPtr->display, ((UnixScrollbar*)scrollPtr)->troughGC, w , h);
	} else {
	    Tk_SetTileOrigin(tkwin, ((UnixScrollbar*)scrollPtr)->troughGC, tsoffset->xoffset,
		    tsoffset->yoffset);
	}
    }
    XFillRectangle(scrollPtr->display, pixmap,
	    ((UnixScrollbar*)scrollPtr)->troughGC,
	    scrollPtr->inset, scrollPtr->inset,
	    (unsigned) (Tk_Width(tkwin) - 2*scrollPtr->inset),
	    (unsigned) (Tk_Height(tkwin) - 2*scrollPtr->inset));

    /*
     * Draw the top or left arrow.  The coordinates of the polygon
     * points probably seem odd, but they were carefully chosen with
     * respect to X's rules for filling polygons.  These point choices
     * cause the arrows to just fill the narrow dimension of the
     * scrollbar and be properly centered.
     */

    fillGC = NULL;
    if (scrollPtr->tile != NULL) {
	fillGC = ((UnixScrollbar*)scrollPtr)->copyGC;
    }
    if (scrollPtr->activeField == TOP_ARROW) {
	border = scrollPtr->activeBorder;
	relief = scrollPtr->activeField == TOP_ARROW ? scrollPtr->activeRelief
		: TK_RELIEF_RAISED;
	if (scrollPtr->activeTile != NULL) {
	    fillGC = scrollPtr->activeTileGC;
	}
    } else {
	border = scrollPtr->bgBorder;
	relief = TK_RELIEF_RAISED;
    }
    if (scrollPtr->vertical) {
	points[0].x = scrollPtr->inset - 1;
	points[0].y = scrollPtr->arrowLength + scrollPtr->inset - 1;
	points[1].x = width + scrollPtr->inset;
	points[1].y = points[0].y;
	points[2].x = width/2 + scrollPtr->inset;
	points[2].y = scrollPtr->inset - 1;
    } else {
	points[0].x = scrollPtr->arrowLength + scrollPtr->inset - 1;
	points[0].y = scrollPtr->inset - 1;
	points[1].x = scrollPtr->inset;
	points[1].y = width/2 + scrollPtr->inset;
	points[2].x = points[0].x;
	points[2].y = width + scrollPtr->inset;
    }
    if (fillGC != NULL) {
	XFillPolygon(scrollPtr->display, pixmap, fillGC, points, 3,
		     Convex, CoordModeOrigin);
	Tk_Draw3DPolygon(tkwin, pixmap, border, points, 3,
		elementBorderWidth, relief);
    } else {
	Tk_Fill3DPolygon(tkwin, pixmap, border, points, 3,
	elementBorderWidth, relief);
    }

    /*
     * Display the bottom or right arrow.
     */

    fillGC = NULL;
    if (scrollPtr->tile != NULL) {
	fillGC = ((UnixScrollbar*)scrollPtr)->copyGC;
    }
    if (scrollPtr->activeField == BOTTOM_ARROW) {
	border = scrollPtr->activeBorder;
	relief = scrollPtr->activeField == BOTTOM_ARROW
		? scrollPtr->activeRelief : TK_RELIEF_RAISED;
	if (scrollPtr->activeTile != NULL) {
	    fillGC = scrollPtr->activeTileGC;
	}
    } else {
	border = scrollPtr->bgBorder;
	relief = TK_RELIEF_RAISED;
    }
    if (scrollPtr->vertical) {
	points[0].x = scrollPtr->inset;
	points[0].y = Tk_Height(tkwin) - scrollPtr->arrowLength
		- scrollPtr->inset + 1;
	points[1].x = width/2 + scrollPtr->inset;
	points[1].y = Tk_Height(tkwin) - scrollPtr->inset;
	points[2].x = width + scrollPtr->inset;
	points[2].y = points[0].y;
    } else {
	points[0].x = Tk_Width(tkwin) - scrollPtr->arrowLength
		- scrollPtr->inset + 1;
	points[0].y = scrollPtr->inset - 1;
	points[1].x = points[0].x;
	points[1].y = width + scrollPtr->inset;
	points[2].x = Tk_Width(tkwin) - scrollPtr->inset;
	points[2].y = width/2 + scrollPtr->inset;
    }
    if (fillGC != NULL) {
	XFillPolygon(scrollPtr->display, pixmap, fillGC, points, 3, Convex, 
		CoordModeOrigin);
	Tk_Draw3DPolygon(tkwin, pixmap, border, points, 3,
		elementBorderWidth, relief);
    } else {
	Tk_Fill3DPolygon(tkwin, pixmap, border,
		points, 3, elementBorderWidth, relief);
    }

    /*
     * Display the slider.
     */

    fillGC = NULL;
    if (scrollPtr->tile != NULL) {
	fillGC = ((UnixScrollbar*)scrollPtr)->copyGC;
    }
    if (scrollPtr->activeField == SLIDER) {
	border = scrollPtr->activeBorder;
	relief = scrollPtr->activeField == SLIDER ? scrollPtr->activeRelief
		: TK_RELIEF_RAISED;
	if (scrollPtr->activeTile != NULL) {
	    fillGC = scrollPtr->activeTileGC;
	}
    } else {
	border = scrollPtr->bgBorder;
	relief = TK_RELIEF_RAISED;
    }
    if (scrollPtr->vertical) {
	if (fillGC != NULL) {
	    XFillRectangle(scrollPtr->display, pixmap, fillGC,
		scrollPtr->inset, scrollPtr->sliderFirst, width - 1, 
		scrollPtr->sliderLast - scrollPtr->sliderFirst - 1);
	    Tk_Draw3DRectangle(tkwin, pixmap, border,
	        scrollPtr->inset, scrollPtr->sliderFirst,
	        width, scrollPtr->sliderLast - scrollPtr->sliderFirst,
		elementBorderWidth, relief);
	} else {
	    Tk_Fill3DRectangle(tkwin, pixmap, border,
		    scrollPtr->inset, scrollPtr->sliderFirst,
		    width, scrollPtr->sliderLast - scrollPtr->sliderFirst,
		    elementBorderWidth, relief);
	}
    } else {
	if (fillGC != NULL) {
	    XFillRectangle(scrollPtr->display, pixmap, fillGC,
		scrollPtr->sliderFirst, scrollPtr->inset,
		scrollPtr->sliderLast - scrollPtr->sliderFirst - 1, width - 1);
	    Tk_Draw3DRectangle(tkwin, pixmap, border,
		scrollPtr->sliderFirst, scrollPtr->inset,
		scrollPtr->sliderLast - scrollPtr->sliderFirst, width,
		elementBorderWidth, relief);
	} else {
	    Tk_Fill3DRectangle(tkwin, pixmap, border,
		    scrollPtr->sliderFirst, scrollPtr->inset,
		    scrollPtr->sliderLast - scrollPtr->sliderFirst, width,
		    elementBorderWidth, relief);
	}
    }

    if (scrollPtr->tile != NULL) {
	XSetTSOrigin(scrollPtr->display, ((UnixScrollbar*)scrollPtr)->copyGC, 0, 0);
    }
    if (scrollPtr->troughTile != NULL) {
	XSetTSOrigin(scrollPtr->display, ((UnixScrollbar*)scrollPtr)->troughGC, 0, 0);
    }
    if (scrollPtr->activeTileGC != NULL) {
	XSetTSOrigin(scrollPtr->display, scrollPtr->activeTileGC, 0, 0);
    }

    /*
     * Copy the information from the off-screen pixmap onto the screen,
     * then delete the pixmap.
     */

    XCopyArea(scrollPtr->display, pixmap, Tk_WindowId(tkwin),
	    ((UnixScrollbar*)scrollPtr)->copyGC, 0, 0,
	    (unsigned) Tk_Width(tkwin), (unsigned) Tk_Height(tkwin), 0, 0);
    Tk_FreePixmap(scrollPtr->display, pixmap);

    done:
    scrollPtr->flags &= ~REDRAW_PENDING;
}

/*
 *----------------------------------------------------------------------
 *
 * TkpComputeScrollbarGeometry --
 *
 *	After changes in a scrollbar's size or configuration, this
 *	procedure recomputes various geometry information used in
 *	displaying the scrollbar.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The scrollbar will be displayed differently.
 *
 *----------------------------------------------------------------------
 */

extern void
TkpComputeScrollbarGeometry(scrollPtr)
    register TkScrollbar *scrollPtr;	/* Scrollbar whose geometry may
					 * have changed. */
{
    int width, fieldLength;

    if (scrollPtr->highlightWidth < 0) {
	scrollPtr->highlightWidth = 0;
    }
    scrollPtr->inset = scrollPtr->highlightWidth + scrollPtr->borderWidth;
    width = (scrollPtr->vertical) ? Tk_Width(scrollPtr->tkwin)
	    : Tk_Height(scrollPtr->tkwin);
    scrollPtr->arrowLength = width - 2*scrollPtr->inset + 1;
    fieldLength = (scrollPtr->vertical ? Tk_Height(scrollPtr->tkwin)
	    : Tk_Width(scrollPtr->tkwin))
	    - 2*(scrollPtr->arrowLength + scrollPtr->inset);
    if (fieldLength < 0) {
	fieldLength = 0;
    }
    scrollPtr->sliderFirst = fieldLength*scrollPtr->firstFraction;
    scrollPtr->sliderLast = fieldLength*scrollPtr->lastFraction;

    /*
     * Adjust the slider so that some piece of it is always
     * displayed in the scrollbar and so that it has at least
     * a minimal width (so it can be grabbed with the mouse).
     */

    if (scrollPtr->sliderFirst > (fieldLength - 2*scrollPtr->borderWidth)) {
	scrollPtr->sliderFirst = fieldLength - 2*scrollPtr->borderWidth;
    }
    if (scrollPtr->sliderFirst < 0) {
	scrollPtr->sliderFirst = 0;
    }
    if (scrollPtr->sliderLast < (scrollPtr->sliderFirst
	    + MIN_SLIDER_LENGTH)) {
	scrollPtr->sliderLast = scrollPtr->sliderFirst + MIN_SLIDER_LENGTH;
    }
    if (scrollPtr->sliderLast > fieldLength) {
	scrollPtr->sliderLast = fieldLength;
    }
    scrollPtr->sliderFirst += scrollPtr->arrowLength + scrollPtr->inset;
    scrollPtr->sliderLast += scrollPtr->arrowLength + scrollPtr->inset;

    /*
     * Register the desired geometry for the window (leave enough space
     * for the two arrows plus a minimum-size slider, plus border around
     * the whole window, if any).  Then arrange for the window to be
     * redisplayed.
     */

    if (scrollPtr->vertical) {
	Tk_GeometryRequest(scrollPtr->tkwin,
		scrollPtr->width + 2*scrollPtr->inset,
		2*(scrollPtr->arrowLength + scrollPtr->borderWidth
		+ scrollPtr->inset));
    } else {
	Tk_GeometryRequest(scrollPtr->tkwin,
		2*(scrollPtr->arrowLength + scrollPtr->borderWidth
		+ scrollPtr->inset), scrollPtr->width + 2*scrollPtr->inset);
    }
    Tk_SetInternalBorder(scrollPtr->tkwin, scrollPtr->inset);
}

/*
 *----------------------------------------------------------------------
 *
 * TkpDestroyScrollbar --
 *
 *	Free data structures associated with the scrollbar control.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Frees the GCs associated with the scrollbar.
 *
 *----------------------------------------------------------------------
 */

void
TkpDestroyScrollbar(scrollPtr)
    TkScrollbar *scrollPtr;
{
    UnixScrollbar *unixScrollPtr = (UnixScrollbar *)scrollPtr;

    if (unixScrollPtr->troughGC != None) {
	Tk_FreeGC(scrollPtr->display, unixScrollPtr->troughGC);
    }
    if (unixScrollPtr->copyGC != None) {
	Tk_FreeGC(scrollPtr->display, unixScrollPtr->copyGC);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkpConfigureScrollbar --
 *
 *	This procedure is called after the generic code has finished
 *	processing configuration options, in order to configure
 *	platform specific options.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Configuration info may get changed.
 *
 *----------------------------------------------------------------------
 */

void
TkpConfigureScrollbar(scrollPtr)
    register TkScrollbar *scrollPtr;	/* Information about widget;  may or
					 * may not already have values for
					 * some fields. */
{
    XGCValues gcValues;
    GC new = None;
    Pixmap pixmap;
    int flags;
    UnixScrollbar *unixScrollPtr = (UnixScrollbar *) scrollPtr;

    if (scrollPtr->activeTile != NULL) {
	Tk_SetTileChangedProc(scrollPtr->activeTile, TileChangedProc,
	    (ClientData)scrollPtr, (Tk_Item *) NULL);

	pixmap = Tk_PixmapOfTile(scrollPtr->activeTile);
	if (pixmap != None) {
	    unsigned int gcMask;

	    gcMask = (GCTile | GCFillStyle);
	    gcValues.fill_style = FillTiled;
	    gcValues.tile = pixmap;

	    new = Tk_GetGC(scrollPtr->tkwin, gcMask, &gcValues);
	}
    }
    if (scrollPtr->activeTileGC != None) {
	Tk_FreeGC(scrollPtr->display, scrollPtr->activeTileGC);
    }
    scrollPtr->activeTileGC = new;

    Tk_SetBackgroundFromBorder(scrollPtr->tkwin, scrollPtr->bgBorder);

    gcValues.foreground = scrollPtr->troughColorPtr->pixel;
    flags = GCForeground;
    if (scrollPtr->troughTile != NULL) {
	Tk_SetTileChangedProc(scrollPtr->troughTile, TileChangedProc,
	    (ClientData)scrollPtr, (Tk_Item *) NULL);
	if ((pixmap = Tk_PixmapOfTile(scrollPtr->troughTile)) != None) {
	    gcValues.fill_style = FillTiled;
	    gcValues.tile = pixmap;
	    flags = GCTile|GCFillStyle;
	}
    }
    new = Tk_GetGC(scrollPtr->tkwin, flags, &gcValues);
    if (unixScrollPtr->troughGC != None) {
	Tk_FreeGC(scrollPtr->display, unixScrollPtr->troughGC);
    }
    unixScrollPtr->troughGC = new;
    gcValues.graphics_exposures = False;
    flags = GCGraphicsExposures;
    if (scrollPtr->tile != NULL) {
	Tk_SetTileChangedProc(scrollPtr->tile, TileChangedProc,
	    (ClientData)scrollPtr, (Tk_Item *) NULL);
	if ((pixmap = Tk_PixmapOfTile(scrollPtr->tile)) != None) {
	    gcValues.fill_style = FillTiled;
	    gcValues.tile = pixmap;
	    flags |= GCTile|GCFillStyle;
	}
    }
    new = Tk_GetGC(scrollPtr->tkwin, flags, &gcValues);
    if (((UnixScrollbar*)scrollPtr)->copyGC != None) {
	Tk_FreeGC(scrollPtr->display, ((UnixScrollbar*)scrollPtr)->copyGC);
    }
    ((UnixScrollbar*)scrollPtr)->copyGC = new;
}

/*
 *----------------------------------------------------------------------
 *
 * TileChangedProc
 *
 * Results:
 *  None.
 *
 *----------------------------------------------------------------------
 */
/* ARGSUSED */
static void
TileChangedProc(clientData, tile, itemPtr)
    ClientData clientData;
    Tk_Tile tile;
    Tk_Item *itemPtr;           /* Not used */
{
    TkpConfigureScrollbar((TkScrollbar *) clientData);
}

/*
 *--------------------------------------------------------------
 *
 * TkpScrollbarPosition --
 *
 *	Determine the scrollbar element corresponding to a
 *	given position.
 *
 * Results:
 *	One of TOP_ARROW, TOP_GAP, etc., indicating which element
 *	of the scrollbar covers the position given by (x, y).  If
 *	(x,y) is outside the scrollbar entirely, then OUTSIDE is
 *	returned.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

int
TkpScrollbarPosition(scrollPtr, x, y)
    register TkScrollbar *scrollPtr;	/* Scrollbar widget record. */
    int x, y;				/* Coordinates within scrollPtr's
					 * window. */
{
    int length, width, tmp;

    if (scrollPtr->vertical) {
	length = Tk_Height(scrollPtr->tkwin);
	width = Tk_Width(scrollPtr->tkwin);
    } else {
	tmp = x;
	x = y;
	y = tmp;
	length = Tk_Width(scrollPtr->tkwin);
	width = Tk_Height(scrollPtr->tkwin);
    }

    if ((x < scrollPtr->inset) || (x >= (width - scrollPtr->inset))
	    || (y < scrollPtr->inset) || (y >= (length - scrollPtr->inset))) {
	return OUTSIDE;
    }

    /*
     * All of the calculations in this procedure mirror those in
     * TkpDisplayScrollbar.  Be sure to keep the two consistent.
     */

    if (y < (scrollPtr->inset + scrollPtr->arrowLength)) {
	return TOP_ARROW;
    }
    if (y < scrollPtr->sliderFirst) {
	return TOP_GAP;
    }
    if (y < scrollPtr->sliderLast) {
	return SLIDER;
    }
    if (y >= (length - (scrollPtr->arrowLength + scrollPtr->inset))) {
	return BOTTOM_ARROW;
    }
    return BOTTOM_GAP;
}
