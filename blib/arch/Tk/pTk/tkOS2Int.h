/*
 * tkOS2Int.h --
 *
 *	Declarations of OS/2 PM specific shared variables and procedures.
 *
 * Copyright (c) 1996-1997 Illya Vaes
 * Copyright (c) 1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _OS2INT
#define _OS2INT

#ifndef _TKINT
#include "tkInt.h"
#endif

#define INCL_BASE
#define INCL_PM
#include <os2.h>
#undef INCL_PM
#undef INCL_BASE

#ifndef OS2
#define OS2
#endif

#ifdef __PM_WIN__		/* A file expects Win32 interface. */
typedef HDC HDC_os2;			/* Now can redefine. */
#    define WORD unsigned short
#    define TkWinDrawable TkOS2Drawable
#    define TWD_BITMAP	TOD_BITMAP
#    define DeleteObject	GpiDeleteBitmap
#    define HDC		HPS
#    define SelectObject	GpiSetBitmap
#    define DeleteDC		WinReleasePS
#    define TkWinGetDrawableDC		TkOS2GetDrawablePS
#    define TkWinReleaseDrawableDC	TkOS2ReleaseDrawablePS
#    define TkWinDCState	TkOS2PSState
#endif

typedef struct BITMAPINFOHEADER2_2colors  {
    BITMAPINFOHEADER2 header;
    RGB2 colors[2];
} BITMAPINFOHEADER2_2colors;


/*
 * A data structure of the following type holds information for
 * each window manager protocol (such as WM_DELETE_WINDOW) for
 * which a handler (i.e. a Tcl command) has been defined for a
 * particular top-level window.
 */

typedef struct ProtocolHandler {
    Atom protocol;		/* Identifies the protocol. */
    struct ProtocolHandler *nextPtr;
				/* Next in list of protocol handlers for
				 * the same top-level window, or NULL for
				 * end of list. */
    Tcl_Interp *interp;		/* Interpreter in which to invoke command. */
    LangCallback *command;	/* command to invoke when a client
				 * message for this protocol arrives. */
} ProtocolHandler;

#define HANDLER_SIZE(cmdLength) \
    ((unsigned) (sizeof(ProtocolHandler) - 3 + cmdLength))

void ProtocolFree _ANSI_ARGS_((char *clientData));

/*
 * A data structure of the following type holds window-manager-related
 * information for each top-level window in an application.
 */

typedef struct TkWmInfo {
    TkWindow *winPtr;		/* Pointer to main Tk information for
				 * this window. */
    Window reparent;            /* This is the decorative frame window
                                 * created by the window manager to wrap
                                 * a toplevel window.  This window is
                                 * a direct child of the root window. */
    Tk_Uid titleUid;		/* Title to display in window caption.  If
				 * NULL, use name of widget. */
    Tk_Uid iconName;		/* Name to display in icon. */
    Window master;		/* Master window for TRANSIENT_FOR property,
				 * or None. */
    XWMHints hints;		/* Various pieces of information for
				 * window manager. */
    Tk_Uid leaderName;		/* Path name of leader of window group
				 * (corresponds to hints.window_group).
				 * Note:  this field doesn't get updated
				 * if leader is destroyed. */
    Tk_Uid masterWindowName;	/* Path name of window specified as master
				 * in "wm transient" command, or NULL.
				 * Note:  this field doesn't get updated if
				 * masterWindowName is destroyed. */
    Tk_Window icon;		/* Window to use as icon for this window,
				 * or NULL. */
    Tk_Window iconFor;		/* Window for which this window is icon, or
				 * NULL if this isn't an icon for anyone. */
    int withdrawn;		/* Non-zero means window has been withdrawn. */

    /*
     * Information used to construct an XSizeHints structure for
     * the window manager:
     */

    int defMinWidth, defMinHeight, defMaxWidth, defMaxHeight;
                                /* Default resize limits given by system. */
    int sizeHintsFlags;		/* Flags word for XSizeHints structure.
				 * If the PBaseSize flag is set then the
				 * window is gridded;  otherwise it isn't
				 * gridded. */
    int minWidth, minHeight;	/* Minimum dimensions of window, in
				 * grid units, not pixels. */
    int maxWidth, maxHeight;	/* Maximum dimensions of window, in
				 * grid units, not pixels, or 0 to default. */
    Tk_Window gridWin;		/* Identifies the window that controls
				 * gridding for this top-level, or NULL if
				 * the top-level isn't currently gridded. */
    int widthInc, heightInc;	/* Increments for size changes (# pixels
				 * per step). */
    struct {
	int x;	/* numerator */
	int y;  /* denominator */
    } minAspect, maxAspect;	/* Min/max aspect ratios for window. */
    int reqGridWidth, reqGridHeight;
				/* The dimensions of the window (in
				 * grid units) requested through
				 * the geometry manager. */
    int gravity;		/* Desired window gravity. */

    /*
     * Information used to manage the size and location of a window.
     */

    int width, height;		/* Desired dimensions of window, specified
				 * in grid units.  These values are
				 * set by the "wm geometry" command and by
				 * ConfigureNotify events (for when wm
				 * resizes window).  -1 means user hasn't
				 * requested dimensions. */
    int x, y;			/* Desired X and Y coordinates for window.
				 * These values are set by "wm geometry",
				 * plus by ConfigureNotify events (when wm
				 * moves window).  These numbers are
				 * different than the numbers stored in
				 * winPtr->changes because (a) they could be
				 * measured from the right or bottom edge
				 * of the screen (see WM_NEGATIVE_X and
				 * WM_NEGATIVE_Y flags) and (b) if the window
				 * has been reparented then they refer to the
				 * parent rather than the window itself. */
    int xInParent, yInParent;	/* Offset of window within reparent,  measured
				 * from upper-left outer corner of parent's
				 * border to upper-left outer corner of child's
				 * border.  If not reparented then these are
				 * zero. */
    int borderWidth, borderHeight;
                                /* Width and height of window dressing, in
                                 * pixels for the current style/exStyle.  This
                                 * includes the border on both sides of the
                                 * window. */
    int configWidth, configHeight;
				/* Dimensions passed to last request that we
				 * issued to change geometry of window.  Used
				 * to eliminate redundant resize operations. */
    long style;			/* Window style of reparent. */
    long exStyle;               /* Window exStyle of reparent. */

    /*
     * List of children of the toplevel which have private colormaps.
     */

    TkWindow **cmapList;	/* Array of window with private colormaps. */
    int cmapCount;		/* Number of windows in array. */

    /*
     * Miscellaneous information.
     */

    ProtocolHandler *protPtr;	/* First in list of protocol handlers for
				 * this window (NULL means none). */
    int cmdArgc;		/* Number of elements in cmdArgv below. */
    char **cmdArgv;		/* Array of strings to store in the
				 * WM_COMMAND property.  NULL means nothing
				 * available. */
    char *clientMachine;	/* String to store in WM_CLIENT_MACHINE
				 * property, or NULL. */
    int flags;			/* Miscellaneous flags, defined below. */
    struct TkWmInfo *nextPtr;	/* Next in list of all top-level windows. */
    Arg  cmdArg;
} WmInfo;

/*
 * Flag values for WmInfo structures:
 *
 * WM_NEVER_MAPPED -		non-zero means window has never been
 *				mapped;  need to update all info when
 *				window is first mapped.
 * WM_UPDATE_PENDING -		non-zero means a call to UpdateGeometryInfo
 *				has already been scheduled for this
 *				window;  no need to schedule another one.
 * WM_NEGATIVE_X -		non-zero means x-coordinate is measured in
 *				pixels from right edge of screen, rather
 *				than from left edge.
 * WM_NEGATIVE_Y -		non-zero means y-coordinate is measured in
 *				pixels up from bottom of screen, rather than
 *				down from top.
 * WM_UPDATE_SIZE_HINTS -       non-zero means that new size hints need to be
 *                              propagated to window manager.
 * WM_SYNC_PENDING -		set to non-zero while waiting for the window
 *				manager to respond to some state change.
 * WM_MOVE_PENDING -		non-zero means the application has requested
 *				a new position for the window, but it hasn't
 *				been reflected through the window manager
 *				yet.
 * WM_COLORAMPS_EXPLICIT -	non-zero means the colormap windows were
 *				set explicitly via "wm colormapwindows".
 * WM_ADDED_TOPLEVEL_COLORMAP - non-zero means that when "wm colormapwindows"
 *				was called the top-level itself wasn't
 *				specified, so we added it implicitly at
 *				the end of the list.
 */

#define WM_NEVER_MAPPED			(1<<0)
#define WM_UPDATE_PENDING		(1<<1)
#define WM_NEGATIVE_X			(1<<2)
#define WM_NEGATIVE_Y			(1<<3)
#define WM_UPDATE_SIZE_HINTS		(1<<4)
#define WM_SYNC_PENDING			(1<<5)
#define WM_CREATE_PENDING		(1<<6)
#define WM_MOVE_PENDING			(1<<7)
#define WM_COLORMAPS_EXPLICIT		(1<<8)
#define WM_ADDED_TOPLEVEL_COLORMAP	(1<<9)
#define WM_WIDTH_NOT_RESIZABLE		(1<<10)
#define WM_HEIGHT_NOT_RESIZABLE		(1<<11)

/*
 * Window styles for various types of toplevel windows.
 */

#define WM_TOPLEVEL_STYLE (WS_CLIPCHILDREN|WS_CLIPSIBLINGS)
#define WM_OVERRIDE_STYLE (WS_CLIPCHILDREN|WS_CLIPSIBLINGS)
#define WM_TRANSIENT_STYLE (WS_CLIPCHILDREN|WS_CLIPSIBLINGS)
/* Force positioning on Tk-specified coordinates: turn off byte-alignment */
#define EX_TOPLEVEL_STYLE (FCF_NOBYTEALIGN|FCF_TITLEBAR|FCF_SIZEBORDER|FCF_MINMAX|FCF_SYSMENU|FCF_TASKLIST)
#define EX_OVERRIDE_STYLE (FCF_NOBYTEALIGN|FCF_BORDER)
#define EX_TRANSIENT_STYLE (FCF_NOBYTEALIGN|FCF_BORDER|FCF_TITLEBAR|FCF_TASKLIST)




/*
 * The TkOS2PSState is used to save the state of a presentation space
 * so that it can be restored later.
 */

typedef struct TkOS2PSState {
    HPAL palette;
    HBITMAP bitmap;
} TkOS2PSState;


/*
 * The TkOS2Drawable is the internal implementation of an X Drawable (either
 * a Window or a Pixmap).  The following constants define the valid Drawable
 * types.
 */

#define TOD_BITMAP	1
#define TOD_WINDOW	2
#define TOD_WM_WINDOW	3

/* Tk OS2 Window Classes */
#define TOC_TOPLEVEL	"TkTopLevel"
#define TOC_CHILD	"TkChild"

#define CW_USEDEFAULT	0

/* Defines for which poly... function */
#define TOP_POLYGONS	1
#define TOP_POLYLINE	2

/* OS/2 system constants */
#define MAX_LID	254

#define MAX(a,b)	( (a) > (b) ? (a) : (b) )
#define MIN(a,b)	( (a) < (b) ? (a) : (b) )

typedef struct {
    int type;
    HWND handle;
    TkWindow *winPtr;
} TkOS2Window;

typedef struct {
    int type;
    HBITMAP handle;
    Colormap colormap;
    int depth;
    HWND parent;
    HDC dc;
    HPS hps;
} TkOS2Bitmap;
    
typedef union {
    int type;
    TkOS2Window window;
    TkOS2Bitmap bitmap;
} TkOS2Drawable;

/*
 * The following macros are used to retrieve internal values from a Drawable.
 */
#define TkOS2GetHWND(w) (((TkOS2Drawable *)w)->window.handle)
#define TkOS2GetWinPtr(w) (((TkOS2Drawable*)w)->window.winPtr)
#define TkOS2GetHBITMAP(w) (((TkOS2Drawable*)w)->bitmap.handle)
#define TkOS2GetColormap(w) (((TkOS2Drawable*)w)->bitmap.colormap)

/*
 * The following macros are used to replace the Windows equivalents.
 */
#define RGB(R,G,B)       ((((ULONG)R)<<16) + (((ULONG)G)<<8) + (ULONG)B)
#define RGBFlag(F,R,G,B) ((((ULONG)F)<<24) + (((ULONG)R)<<16) + (((ULONG)G)<<8) + (ULONG)B)
#define GetFlag(RGB)     ((BYTE)(RGB>>24))
#define GetRValue(RGB)   ((BYTE)((RGB & 0xFF0000)>>16))
#define GetGValue(RGB)   ((BYTE)((RGB & 0x00FF00)>>8))
#define GetBValue(RGB)   ((BYTE)(RGB & 0x0000FF))

/*
 * The following structure is used to encapsulate palette information.
 */

typedef struct {
    HPAL palette;		/* Palette handle used when drawing. */
    ULONG size;			/* Number of entries in the palette. */
    int stale;			/* 1 if palette needs to be realized,
				 * otherwise 0.  If the palette is stale,
				 * then an idle handler is scheduled to
				 * realize the palette. */
    Tcl_HashTable refCounts;	/* Hash table of palette entry reference counts
				 * indexed by pixel value. */
} TkOS2Colormap;

/*
 * The following structure is used to remember font attributes that cannot be
 * given to GpiCreateLogFont via FATTRS.
 */

typedef struct {
    FATTRS fattrs;	/* FATTRS structure */
    POINTL shear;	/* Shear (angle) of characters, GpiSetCharShear */
    BOOL setShear;	/* Should shear be changed after GpiCreateLogFont? */
    BOOL outline;	/* Is this an outline font */
    ULONG deciPoints;	/* Pointsize for outline font, in decipoints */
    FONTMETRICS fm;	/* Fontmetrics, for concentrating outline font stuff */
} TkOS2Font;

/*
 * The following structures are used to mimic the WINDOWPOS structure that has
 * fields for minimum and maximum width/height.
 */

typedef struct {
    LONG x;
    LONG y;
} TkOS2TrackSize;
typedef struct {
    TkOS2TrackSize ptMinTrackSize;
    TkOS2TrackSize ptMaxTrackSize;
    SWP swp;
} TkOS2WINDOWPOS;

/*
 * The following macro retrieves the PM palette from a colormap.
 */

#define TkOS2GetPalette(colormap) (((TkOS2Colormap *) colormap)->palette)

/*
 * Internal procedures used by more than one source file.
 */

extern MRESULT EXPENTRY TkOS2ChildProc _ANSI_ARGS_((HWND hwnd, ULONG message,
                            MPARAM param1, MPARAM param2));
extern void		TkOS2ClipboardRender _ANSI_ARGS_((TkWindow *winPtr,
                            ULONG format));
extern HAB	 	TkOS2GetAppInstance _ANSI_ARGS_((void));
extern HPS		TkOS2GetDrawablePS _ANSI_ARGS_((Display *display,
			    Drawable d, TkOS2PSState* state));
extern TkOS2Drawable *	TkOS2GetDrawableFromHandle _ANSI_ARGS_((HWND hwnd));
extern unsigned int	TkOS2GetModifierState _ANSI_ARGS_((ULONG message,
			    USHORT flags, MPARAM param1, MPARAM param2));
extern HPAL		TkOS2GetSystemPalette _ANSI_ARGS_((void));
extern HMODULE		TkOS2GetTkModule _ANSI_ARGS_((void));
extern void		TkOS2PointerDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
extern void		TkOS2PointerEvent _ANSI_ARGS_((XEvent *event,
                            TkWindow *winPtr));
extern void		TkOS2PointerInit _ANSI_ARGS_((void));
extern void		TkOS2ReleaseDrawablePS _ANSI_ARGS_((Drawable d,
			    HPS hps, TkOS2PSState* state));
extern HPAL		TkOS2SelectPalette _ANSI_ARGS_((HPS hps, HWND hwnd,
                            Colormap colormap));
extern MRESULT EXPENTRY TkOS2FrameProc _ANSI_ARGS_((HWND hwnd, ULONG message,
                            MPARAM param1, MPARAM param2));
extern void		TkOS2UpdateCursor _ANSI_ARGS_((TkWindow *winPtr));
extern void		TkOS2WmConfigure _ANSI_ARGS_((TkWindow *winPtr,
                            SWP *pos));
extern int		TkOS2WmInstallColormaps _ANSI_ARGS_((HWND hwnd,
			    int message, int isForemost));
extern void		TkOS2WmSetLimits _ANSI_ARGS_((HWND hwnd,
                            TRACKINFO *info));
extern void 		TkOS2XInit _ANSI_ARGS_((HAB hInstance));
extern void 		TkOS2InitPM _ANSI_ARGS_((void));
extern void 		TkOS2ExitPM _ANSI_ARGS_((void));
extern LONG		TkOS2WindowHeight _ANSI_ARGS_ ((TkOS2Drawable *todPtr));
extern LONG		TkOS2WindowWidth _ANSI_ARGS_ ((TkOS2Drawable *todPtr));
extern char		*TkOS2ReverseImageLines _ANSI_ARGS_ ((XImage *image, int height));
extern BOOL		TkOS2ScaleFont _ANSI_ARGS_ ((HPS hps, ULONG pointSize,
			    ULONG pointWidth));

/* Global variables */
extern HAB hab;	/* Anchor block */
extern HMQ hmq;	/* message queue */
extern LONG aDevCaps[];	/* Device caps */
extern LONG nextLogicalFont;	/* First free logical font ID */
extern PFNWP oldFrameProc;	/* subclassed frame procedure */
extern LONG xScreen;		/* System Value Screen width */
extern LONG yScreen;		/* System Value Screen height */
extern LONG titleBar;		/* System Value Title Bar */
extern LONG xBorder;		/* System Value X nominal border */
extern LONG yBorder;		/* System Value Y nominal border */
extern LONG xSizeBorder;	/* System Value X Sizing border */
extern LONG ySizeBorder;	/* System Value Y Sizing border */
extern LONG xDlgBorder;		/* System Value X dialog-frame border */
extern LONG yDlgBorder;		/* System Value Y dialog-frame border */
extern HDC hScreenDC;		/* Device Context for screen */
extern HPS globalPS;		/* Global PS */
extern HBITMAP globalBitmap;	/* Bitmap for global PS */
extern TkOS2Font logfonts[];	/* List of logical fonts */
extern LONG nextColor;		/* Next free index in color table */
extern LONG rc;			/* For checking return values */
extern unsigned long dllHandle;	/* Handle of the Tk DLL */

#ifdef _LANG				/* Perl */
#  define REGISTER_MQ Register_MQ()
#  define DEREGISTER_MQ Deregister_MQ()

extern void Register_MQ();
extern void Deregister_MQ();
extern long PM_Pixres;
#define USE_PMRES_120 PM_Pixres

#endif 

#endif /* _OS2INT */
