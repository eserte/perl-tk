#ifdef _TKINT
VVAR(Tk_Uid,tkActiveUid,V_tkActiveUid)
VVAR(Tk_Uid,tkDisabledUid,V_tkDisabledUid)
VVAR(TkDisplay *,tkDisplayList,V_tkDisplayList)
VVAR(TkMainInfo		*,tkMainWindowList,V_tkMainWindowList)
VVAR(Tk_Uid,tkNormalUid,V_tkNormalUid)
VVAR(int,tkSendSerial,V_tkSendSerial)
#ifndef TkBindEventProc
VFUNC(void,TkBindEventProc,V_TkBindEventProc,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
#endif

#ifndef TkBindFree
VFUNC(void,TkBindFree,V_TkBindFree,_ANSI_ARGS_((TkMainInfo *mainPtr)))
#endif

#ifndef TkBindInit
VFUNC(void,TkBindInit,V_TkBindInit,_ANSI_ARGS_((TkMainInfo *mainPtr)))
#endif

#ifndef TkChangeEventWindow
VFUNC(void,TkChangeEventWindow,V_TkChangeEventWindow,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *winPtr)))
#endif

#ifndef TkClipBox
VFUNC(void,TkClipBox,V_TkClipBox,_ANSI_ARGS_((TkRegion rgn,
			    XRectangle* rect_return)))
#endif

#ifndef TkClipInit
VFUNC(int,TkClipInit,V_TkClipInit,_ANSI_ARGS_((Tcl_Interp *interp,
			    TkDisplay *dispPtr)))
#endif

#ifndef TkCmapStressed
VFUNC(int,TkCmapStressed,V_TkCmapStressed,_ANSI_ARGS_((Tk_Window tkwin,
			    Colormap colormap)))
#endif

#ifndef TkComputeTextGeometry
VFUNC(void,TkComputeTextGeometry,V_TkComputeTextGeometry,_ANSI_ARGS_((
			    XFontStruct *fontStructPtr, char *string,
			    int numChars, int wrapLength, int *widthPtr,
			    int *heightPtr)))
#endif

#ifndef TkCreateCursorFromData
VFUNC(TkCursor *,TkCreateCursorFromData,V_TkCreateCursorFromData,_ANSI_ARGS_((Tk_Window tkwin,
			    char *source, char *mask, int width, int height,
			    int xHot, int yHot, XColor fg, XColor bg)))
#endif

#ifndef TkCreateFrame
VFUNC(int,TkCreateFrame,V_TkCreateFrame,_ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args,
			    int toplevel, char *appName)))
#endif

#ifndef TkCreateMainWindow
VFUNC(Tk_Window,TkCreateMainWindow,V_TkCreateMainWindow,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *screenName, char *baseName)))
#endif

#ifndef TkCreateRegion
VFUNC(TkRegion,TkCreateRegion,V_TkCreateRegion,_ANSI_ARGS_((void)))
#endif

#ifndef TkCurrentTime
VFUNC(Time,TkCurrentTime,V_TkCurrentTime,_ANSI_ARGS_((TkDisplay *dispPtr)))
#endif

#ifndef TkDeadAppCmd
VFUNC(int,TkDeadAppCmd,V_TkDeadAppCmd,_ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Arg *args)))
#endif

#ifndef TkDeleteAllImages
VFUNC(void,TkDeleteAllImages,V_TkDeleteAllImages,_ANSI_ARGS_((TkMainInfo *mainPtr)))
#endif

#ifndef TkDestroyRegion
VFUNC(void,TkDestroyRegion,V_TkDestroyRegion,_ANSI_ARGS_((TkRegion rgn)))
#endif

#ifndef TkDisplayChars
VFUNC(void,TkDisplayChars,V_TkDisplayChars,_ANSI_ARGS_((Display *display,
			    Drawable drawable, GC gc,
			    XFontStruct *fontStructPtr, char *string,
			    int numChars, int x, int y, int tabOrigin,
			    int flags)))
#endif

#ifndef TkDisplayText
VFUNC(void,TkDisplayText,V_TkDisplayText,_ANSI_ARGS_((Display *display,
			    Drawable drawable, XFontStruct *fontStructPtr,
			    char *string, int numChars, int x, int y,
			    int length, Tk_Justify justify, int underline,
			    GC gc)))
#endif

#ifndef TkEventDeadWindow
VFUNC(void,TkEventDeadWindow,V_TkEventDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkFindStateNum
VFUNC(int,TkFindStateNum,V_TkFindStateNum,_ANSI_ARGS_((Tcl_Interp *interp,
			    CONST char *option, CONST TkStateMap *mapPtr,
			    CONST char *strKey)))
#endif

#ifndef TkFindStateString
VFUNC(char *,TkFindStateString,V_TkFindStateString,_ANSI_ARGS_((
			    CONST TkStateMap *mapPtr, int numKey)))
#endif

#ifndef TkFocusDeadWindow
VFUNC(void,TkFocusDeadWindow,V_TkFocusDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkFocusFilterEvent
VFUNC(int,TkFocusFilterEvent,V_TkFocusFilterEvent,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
#endif

#ifndef TkFreeBindingTags
VFUNC(void,TkFreeBindingTags,V_TkFreeBindingTags,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkFreeCursor
VFUNC(void,TkFreeCursor,V_TkFreeCursor,_ANSI_ARGS_((TkCursor *cursorPtr)))
#endif

#ifndef TkFreeWindowId
VFUNC(void,TkFreeWindowId,V_TkFreeWindowId,_ANSI_ARGS_((TkDisplay *dispPtr,
			    Window w)))
#endif

#ifndef TkGetCursorByName
VFUNC(TkCursor *,TkGetCursorByName,V_TkGetCursorByName,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Arg string)))
#endif

#ifndef TkGetDefaultScreenName
VFUNC(char *,TkGetDefaultScreenName,V_TkGetDefaultScreenName,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *screenName)))
#endif

#ifndef TkGetDisplay
VFUNC(TkDisplay *,TkGetDisplay,V_TkGetDisplay,_ANSI_ARGS_((Display *display)))
#endif

#ifndef TkGetFocus
VFUNC(TkWindow *,TkGetFocus,V_TkGetFocus,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkGetInterpNames
VFUNC(int,TkGetInterpNames,V_TkGetInterpNames,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin)))
#endif

#ifndef TkGetPointerCoords
VFUNC(void,TkGetPointerCoords,V_TkGetPointerCoords,_ANSI_ARGS_((Tk_Window tkwin,
			    int *xPtr, int *yPtr)))
#endif

#ifndef TkGetProlog
VFUNC(int,TkGetProlog,V_TkGetProlog,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef TkGetServerInfo
VFUNC(void,TkGetServerInfo,V_TkGetServerInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin)))
#endif

#ifndef TkGrabDeadWindow
VFUNC(void,TkGrabDeadWindow,V_TkGrabDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkGrabState
VFUNC(int,TkGrabState,V_TkGrabState,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkInOutEvents
VFUNC(void,TkInOutEvents,V_TkInOutEvents,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *sourcePtr, TkWindow *destPtr,
			    int leaveType, int enterType,
			    Tcl_QueuePosition position)))
#endif

#ifndef TkInitXId
VFUNC(void,TkInitXId,V_TkInitXId,_ANSI_ARGS_((TkDisplay *dispPtr)))
#endif

#ifndef TkIntersectRegion
VFUNC(void,TkIntersectRegion,V_TkIntersectRegion,_ANSI_ARGS_((TkRegion sra,
			    TkRegion srcb, TkRegion dr_return)))
#endif

#ifndef TkKeysymToString
VFUNC(char *,TkKeysymToString,V_TkKeysymToString,_ANSI_ARGS_((KeySym keysym)))
#endif

#ifndef TkMakeWindow
VFUNC(Window,TkMakeWindow,V_TkMakeWindow,_ANSI_ARGS_((TkWindow *winPtr,
			    Window parent)))
#endif

#ifndef TkMeasureChars
VFUNC(int,TkMeasureChars,V_TkMeasureChars,_ANSI_ARGS_((XFontStruct *fontStructPtr,
			    char *source, int maxChars, int startX, int maxX,
			    int tabOrigin, int flags, int *nextXPtr)))
#endif

#ifndef TkPlatformInit
VFUNC(int,TkPlatformInit,V_TkPlatformInit,_ANSI_ARGS_((Tcl_Interp *interp)))
#endif

#ifndef TkPointerEvent
VFUNC(int,TkPointerEvent,V_TkPointerEvent,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *winPtr)))
#endif

#ifndef TkPositionInTree
VFUNC(int,TkPositionInTree,V_TkPositionInTree,_ANSI_ARGS_((TkWindow *winPtr,
			    TkWindow *treePtr)))
#endif

#ifndef TkPutImage
VFUNC(void,TkPutImage,V_TkPutImage,_ANSI_ARGS_((unsigned long *colors,
			    int ncolors, Display* display, Drawable d,
			    GC gc, XImage* image, int src_x, int src_y,
			    int dest_x, int dest_y, unsigned int width,
			    unsigned int height)))
#endif

#ifndef TkQueueEventForAllChildren
VFUNC(void,TkQueueEventForAllChildren,V_TkQueueEventForAllChildren,_ANSI_ARGS_((
			    Tk_Window tkwin, XEvent *eventPtr)))
#endif

#ifndef TkRectInRegion
VFUNC(int,TkRectInRegion,V_TkRectInRegion,_ANSI_ARGS_((TkRegion rgn,
			    int x, int y, unsigned int width,
			    unsigned int height)))
#endif

#ifndef TkScrollWindow
VFUNC(int,TkScrollWindow,V_TkScrollWindow,_ANSI_ARGS_((Tk_Window tkwin, GC gc,
			    int x, int y, int width, int height, int dx,
			    int dy, TkRegion damageRgn)))
#endif

#ifndef TkSelDeadWindow
VFUNC(void,TkSelDeadWindow,V_TkSelDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkSelEventProc
VFUNC(void,TkSelEventProc,V_TkSelEventProc,_ANSI_ARGS_((Tk_Window tkwin,
			    XEvent *eventPtr)))
#endif

#ifndef TkSelInit
VFUNC(void,TkSelInit,V_TkSelInit,_ANSI_ARGS_((Tk_Window tkwin)))
#endif

#ifndef TkSelPropProc
VFUNC(void,TkSelPropProc,V_TkSelPropProc,_ANSI_ARGS_((XEvent *eventPtr)))
#endif

#ifndef TkSetPixmapColormap
VFUNC(void,TkSetPixmapColormap,V_TkSetPixmapColormap,_ANSI_ARGS_((Pixmap pixmap,
			    Colormap colormap)))
#endif

#ifndef TkSetRegion
VFUNC(void,TkSetRegion,V_TkSetRegion,_ANSI_ARGS_((Display* display, GC gc,
			    TkRegion rgn)))
#endif

#ifndef TkStringToKeysym
VFUNC(KeySym,TkStringToKeysym,V_TkStringToKeysym,_ANSI_ARGS_((char *name)))
#endif

#ifndef TkUnderlineChars
VFUNC(void,TkUnderlineChars,V_TkUnderlineChars,_ANSI_ARGS_((Display *display,
			    Drawable drawable, GC gc,
			    XFontStruct *fontStructPtr, char *string,
			    int x, int y, int tabOrigin, int flags,
			    int firstChar, int lastChar)))
#endif

#ifndef TkUnionRectWithRegion
VFUNC(void,TkUnionRectWithRegion,V_TkUnionRectWithRegion,_ANSI_ARGS_((XRectangle* rect,
			    TkRegion src, TkRegion dr_return)))
#endif

#ifndef TkWmAddToColormapWindows
VFUNC(void,TkWmAddToColormapWindows,V_TkWmAddToColormapWindows,_ANSI_ARGS_((
			    TkWindow *winPtr)))
#endif

#ifndef TkWmDeadWindow
VFUNC(void,TkWmDeadWindow,V_TkWmDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkWmMapWindow
VFUNC(void,TkWmMapWindow,V_TkWmMapWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkWmNewWindow
VFUNC(void,TkWmNewWindow,V_TkWmNewWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkWmProtocolEventProc
VFUNC(void,TkWmProtocolEventProc,V_TkWmProtocolEventProc,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *evenvPtr)))
#endif

#ifndef TkWmRemoveFromColormapWindows
VFUNC(void,TkWmRemoveFromColormapWindows,V_TkWmRemoveFromColormapWindows,_ANSI_ARGS_((
			    TkWindow *winPtr)))
#endif

#ifndef TkWmRestackToplevel
VFUNC(void,TkWmRestackToplevel,V_TkWmRestackToplevel,_ANSI_ARGS_((TkWindow *winPtr,
			    int aboveBelow, TkWindow *otherPtr)))
#endif

#ifndef TkWmSetClass
VFUNC(void,TkWmSetClass,V_TkWmSetClass,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkWmUnmapWindow
VFUNC(void,TkWmUnmapWindow,V_TkWmUnmapWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#endif /* _TKINT */
