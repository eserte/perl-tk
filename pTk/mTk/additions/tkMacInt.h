/*
 * tkMacInt.h --
 *
 *	Declarations of Macintosh specific shared variables and procedures.
 *
 * Copyright (c) 1995-1996 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tkMacInt.h 1.53 96/12/17 15:22:19
 */

#ifndef _TKMACINT
#define _TKMACINT

#include "tk.h"

#include <AppleEvents.h>
#include <Windows.h>
#include <QDOffscreen.h>

struct TkWindowPrivate {
    VOID *winPtr;     	/* Ptr to tk window or NULL if Pixmap */
    GWorldPtr portPtr;     	/* Either WindowRef or off screen world */
    int xOff;	       		/* X offset from toplevel window */
    int yOff;		       	/* Y offset from toplevel window */
    RgnHandle clipRgn;		/* Visable region of window */
    RgnHandle aboveClipRgn;	/* Visable region of window & it's children */
    int referenceCount;		/* Don't delete toplevel until children are
				 * gone. */
    struct TkWindowPrivate *toplevel;	/* Pointer to the toplevel
					 * datastruct. */
    int flags;			/* Various state see defines below. */
};
typedef struct TkWindowPrivate MacDrawable;

/*
 * Defines use for the flags field of the MacDrawable data structure.
 */
 
#define TK_SCROLLBAR_GROW	1
#define TK_CLIP_INVALID		2
#define TK_EMBED_WINDOW		4

/*
 * Defines use for the flags argument to TkGenWMConfigureEvent.
 */
 
#define TK_LOCATION_CHANGED	1
#define TK_SIZE_CHANGED		2
#define TK_BOTH_CHANGED		3

/*
 * This variable is exported and can be used by extensions.
 */
extern QDGlobalsPtr tcl_macQdPtr;

/*
 * Variables shared among various Mac Tk modules but are not
 * exported to the outside world.
 */
 
extern int tkMacAppInFront;
extern Tk_Window tkMacFocusWin;

/*
 * Globals shared among Macintosh Tk
 */
 
extern MenuHandle gAppleM;	/* Handle to the Apple Menu */
extern MenuHandle gFileM;		/* Handles to menus */
extern MenuHandle gEditM;		/* Handles to menus */

/*
 * The following types and defines are for MDEF support.
 */

#if STRUCTALIGNMENTSUPPORTED
#pragma options align=mac8k
#endif
typedef struct TkMenuLowMemGlobals {
    long menuDisable;
    short menuTop;
    short menuBottom;
    short mbSaveLoc;
    Rect itemRect;
} TkMenuLowMemGlobals;
#if STRUCTALIGNMENTSUPPORTED
#pragma options align=reset
#endif

typedef pascal void (*TkMenuDefProcPtr) (short message, MenuHandle theMenu,
	Rect *menuRectPtr, Point hitPt, short *whichItemPtr,
	TkMenuLowMemGlobals *globalsPtr);
enum {
    tkUppMenuDefProcInfo = kPascalStackBased
	    | STACK_ROUTINE_PARAMETER(1, SIZE_CODE(sizeof(short)))
	    | STACK_ROUTINE_PARAMETER(2, SIZE_CODE(sizeof(MenuRef)))
	    | STACK_ROUTINE_PARAMETER(3, SIZE_CODE(sizeof(Rect*)))
	    | STACK_ROUTINE_PARAMETER(4, SIZE_CODE(sizeof(Point)))
	    | STACK_ROUTINE_PARAMETER(5, SIZE_CODE(sizeof(short*)))
	    | STACK_ROUTINE_PARAMETER(6, SIZE_CODE(sizeof(TkMenuLowMemGlobals *)))
};

#if GENERATINGCFM
typedef UniversalProcPtr TkMenuDefUPP;
#else
typedef TkMenuDefProcPtr TkMenuDefUPP;
#endif

#if GENERATINGCFM
#define TkNewMenuDefProc(userRoutine)	\
	(TkMenuDefUPP) NewRoutineDescriptor((ProcPtr)(userRoutine), \
	tkUppMenuDefProcInfo, GetCurrentArchitecture())
#else
#define TkNewMenuDefProc(userRoutine) 	\
	((TkMenuDefUPP) (userRoutine))
#endif

#if GENERATINGCFM
#define TkCallMenuDefProc(userRoutine, message, theMenu, menuRectPtr, hitPt, \
	whichItemPtr, globalsPtr) \
	CallUniversalProc((UniversalProcPtr)(userRoutine), TkUppMenuDefProcInfo, \
	(message), (theMenu), (menuRectPtr), (hitPt), (whichItemPtr), \
	(globalsPtr))
#else
#define TkCallMenuDefProc(userRoutine, message, theMenu, menuRectPtr, hitPt, \
	whichItemPtr, globalsPtr) \
	(*(userRoutine))((message), (theMenu), (menuRectPtr), (hitPt), \
	(whichItemPtr), (globalsPtr))
#endif

/*
 * Internal procedures shared among Macintosh Tk modules but not exported
 * to the outside world:
 */

extern void 		TkAboutDlg _ANSI_ARGS_((void));
extern void		TkCreateMacEventSource _ANSI_ARGS_((void));
extern void 		TkFontList _ANSI_ARGS_((Tcl_Interp *interp,
			    Display *display));
extern int		TkGenerateButtonEvent _ANSI_ARGS_((int x, int y,
			    Window window, unsigned int state));
extern int 		TkGetCharPositions _ANSI_ARGS_((
			    XFontStruct *font_struct, char *string,
			    int count, short *buffer));
extern unsigned int	TkMacButtonKeyState _ANSI_ARGS_((void));
extern int		TkMacConvertEvent _ANSI_ARGS_((EventRecord *eventPtr));
extern int		TkMacDispatchMenuEvent _ANSI_ARGS_((int menuID, 
			    int index));
extern void		TkMacInstallCursor _ANSI_ARGS_((int resizeOverride));
extern int		TkMacConvertTkEvent _ANSI_ARGS_((EventRecord *eventPtr,
			    Window window));
extern void		TkMacHandleTearoffMenu _ANSI_ARGS_((void));
extern void		TkMacDoHLEvent _ANSI_ARGS_((EventRecord *theEvent));
extern void 		TkMacFontInfo _ANSI_ARGS_((Font fontId, short *family,
			    short *style, short *size));
extern Time		TkMacGenerateTime _ANSI_ARGS_(());
extern GWorldPtr 	TkMacGetDrawablePort _ANSI_ARGS_((Drawable drawable));
extern Window 		TkMacGetXWindow _ANSI_ARGS_((WindowRef macWinPtr));
extern int		TkMacGrowToplevel _ANSI_ARGS_((WindowRef whichWindow,
			    Point start));
extern void 		TkMacHandleMenuSelect _ANSI_ARGS_((long mResult,
			    int optionKeyPressed));
extern void		TkMacInitAppleEvents _ANSI_ARGS_((Tcl_Interp *interp));
extern void 		TkMacInitMenus _ANSI_ARGS_((Tcl_Interp 	*interp));
extern int		TkMacIsCharacterMissing _ANSI_ARGS_((Tk_Font tkfont,
			    unsigned int searchChar));
extern BitMapPtr	TkMacMakeStippleMap(Drawable, Drawable);
extern void		TkMacSetUpClippingRgn _ANSI_ARGS_((Drawable drawable));
extern void		TkMacSetUpGraphicsPort _ANSI_ARGS_((GC gc));
extern int		TkMacUseMenuID _ANSI_ARGS_((int macID));
extern void		TkMacWindowOffset _ANSI_ARGS_((WindowRef wRef, 
			    int *xOffset, int *yOffset));
extern void		TkResumeClipboard _ANSI_ARGS_((void));
extern int 		TkSetMacColor _ANSI_ARGS_((unsigned long pixel,
			    RGBColor *macColor));
extern void		TkSuspendClipboard _ANSI_ARGS_((void));
extern int		TkMacZoomToplevel _ANSI_ARGS_((WindowPtr whichWindow, 
			    Point where, short zoomPart));
extern Tk_Window	Tk_TopCoordsToWindow _ANSI_ARGS_((Tk_Window tkwin,
			    int rootX, int rootY, int *newX, int *newY));

/*
 * The following prototypes need to go into tkMac.h
 */
EXTERN void		Tk_UpdatePointer _ANSI_ARGS_((Tk_Window tkwin,
			    int x, int y, int state));

#endif /* _TKMACINT */
