#ifdef _TKINT
VVAR(Tk_Uid,tkActiveUid,V_tkActiveUid)
VVAR(Tk_ImageType,tkBitmapImageType,V_tkBitmapImageType)
VVAR(Tk_Uid,tkDisabledUid,V_tkDisabledUid)
VVAR(TkDisplay *,tkDisplayList,V_tkDisplayList)
VVAR(TkMainInfo		*,tkMainWindowList,V_tkMainWindowList)
VVAR(Tk_Uid,tkNormalUid,V_tkNormalUid)
VVAR(Tcl_HashTable,tkPredefBitmapTable,V_tkPredefBitmapTable)
#ifndef TkAllocWindow
VFUNC(TkWindow *,TkAllocWindow,V_TkAllocWindow,_ANSI_ARGS_((TkDisplay *dispPtr,
			    int screenNum, TkWindow *parentPtr)))
#endif

#ifndef TkBindDeadWindow
VFUNC(void,TkBindDeadWindow,V_TkBindDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

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

#ifndef TkCanvPostscriptCmd
VFUNC(int,TkCanvPostscriptCmd,V_TkCanvPostscriptCmd,_ANSI_ARGS_((struct TkCanvas *canvasPtr,
			    Tcl_Interp *interp, int argc, Tcl_Obj **objv)))
#endif

#ifndef TkChangeEventWindow
VFUNC(void,TkChangeEventWindow,V_TkChangeEventWindow,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *winPtr)))
#endif

#ifndef TkClassOption
VFUNC(void,TkClassOption,V_TkClassOption,_ANSI_ARGS_((Tk_Window tkwin,
			    char *defaultname, int *argcp, Arg **argvp)))
#endif

#ifndef TkClassOptionObj
VFUNC(void,TkClassOptionObj,V_TkClassOptionObj,_ANSI_ARGS_((Tk_Window tkwin,
			    char *defaultname, int *objcp, Tcl_Obj * CONST **objvp)))
#endif

#ifndef TkClipBox
VFUNC(void,TkClipBox,V_TkClipBox,_ANSI_ARGS_((TkRegion rgn,
			    XRectangle* rect_return)))
#endif

#ifndef TkClipInit
VFUNC(int,TkClipInit,V_TkClipInit,_ANSI_ARGS_((Tcl_Interp *interp,
			    TkDisplay *dispPtr)))
#endif

#ifndef TkComputeAnchor
VFUNC(void,TkComputeAnchor,V_TkComputeAnchor,_ANSI_ARGS_((Tk_Anchor anchor,
			    Tk_Window tkwin, int padX, int padY,
			    int innerWidth, int innerHeight, int *xPtr,
			    int *yPtr)))
#endif

#ifndef TkCreateBindingProcedure
VFUNC(unsigned long,TkCreateBindingProcedure,V_TkCreateBindingProcedure,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_BindingTable bindingTable,
			    ClientData object, char *eventString,
			    TkBindEvalProc *evalProc, TkBindFreeProc *freeProc,
			    ClientData clientData)))
#endif

#ifndef TkCreateCursorFromData
VFUNC(TkCursor *,TkCreateCursorFromData,V_TkCreateCursorFromData,_ANSI_ARGS_((Tk_Window tkwin,
			    char *source, char *mask, int width, int height,
			    int xHot, int yHot, XColor fg, XColor bg)))
#endif

#ifndef TkCreateFrame
VFUNC(int,TkCreateFrame,V_TkCreateFrame,_ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, Tcl_Obj **objv,
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
			    Tcl_Interp *interp, int argc, Tcl_Obj **objv)))
#endif

#ifndef TkDeleteAllImages
VFUNC(void,TkDeleteAllImages,V_TkDeleteAllImages,_ANSI_ARGS_((TkMainInfo *mainPtr)))
#endif

#ifndef TkDestroyRegion
VFUNC(void,TkDestroyRegion,V_TkDestroyRegion,_ANSI_ARGS_((TkRegion rgn)))
#endif

#ifndef TkDoConfigureNotify
VFUNC(void,TkDoConfigureNotify,V_TkDoConfigureNotify,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkDrawInsetFocusHighlight
VFUNC(void,TkDrawInsetFocusHighlight,V_TkDrawInsetFocusHighlight,_ANSI_ARGS_((
			    Tk_Window tkwin, GC gc, int width,
			    Drawable drawable, int padding)))
#endif

#ifndef TkEventDeadWindow
VFUNC(void,TkEventDeadWindow,V_TkEventDeadWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkFindStateNum
VFUNC(int,TkFindStateNum,V_TkFindStateNum,_ANSI_ARGS_((Tcl_Interp *interp,
			    CONST char *option, CONST TkStateMap *mapPtr,
			    CONST char *strKey)))
#endif

#ifndef TkFindStateNumObj
VFUNC(int,TkFindStateNumObj,V_TkFindStateNumObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tcl_Obj *optionPtr, CONST TkStateMap *mapPtr,
			    Tcl_Obj *keyPtr)))
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

#ifndef TkFocusKeyEvent
VFUNC(TkWindow *,TkFocusKeyEvent,V_TkFocusKeyEvent,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
#endif

#ifndef TkFontPkgFree
VFUNC(void,TkFontPkgFree,V_TkFontPkgFree,_ANSI_ARGS_((TkMainInfo *mainPtr)))
#endif

#ifndef TkFontPkgInit
VFUNC(void,TkFontPkgInit,V_TkFontPkgInit,_ANSI_ARGS_((TkMainInfo *mainPtr)))
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

#ifndef TkGetBitmapData
VFUNC(char *,TkGetBitmapData,V_TkGetBitmapData,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, char *fileName, int *widthPtr,
			    int *heightPtr, int *hotXPtr, int *hotYPtr)))
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

#ifndef TkGetDisplayOf
VFUNC(int,TkGetDisplayOf,V_TkGetDisplayOf,_ANSI_ARGS_((Tcl_Interp *interp,
			    int objc, Tcl_Obj *CONST objv[],
			    Tk_Window *tkwinPtr)))
#endif

#ifndef TkGetFocusWin
VFUNC(TkWindow *,TkGetFocusWin,V_TkGetFocusWin,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkGetInterpNames
VFUNC(int,TkGetInterpNames,V_TkGetInterpNames,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin)))
#endif

#ifndef TkGetPixelsFromObj
VFUNC(int,TkGetPixelsFromObj,V_TkGetPixelsFromObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tcl_Obj *obj, int *intPtr)))
#endif

#ifndef TkGetPointerCoords
VFUNC(void,TkGetPointerCoords,V_TkGetPointerCoords,_ANSI_ARGS_((Tk_Window tkwin,
			    int *xPtr, int *yPtr)))
#endif

#ifndef TkGetScreenMMFromObj
VFUNC(int,TkGetScreenMMFromObj,V_TkGetScreenMMFromObj,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tcl_Obj *obj, double *doublePtr)))
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

#ifndef TkInstallFrameMenu
VFUNC(void,TkInstallFrameMenu,V_TkInstallFrameMenu,_ANSI_ARGS_((Tk_Window tkwin)))
#endif

#ifndef TkIntersectRegion
VFUNC(void,TkIntersectRegion,V_TkIntersectRegion,_ANSI_ARGS_((TkRegion sra,
			    TkRegion srcb, TkRegion dr_return)))
#endif

#ifndef TkKeysymToString
VFUNC(char *,TkKeysymToString,V_TkKeysymToString,_ANSI_ARGS_((KeySym keysym)))
#endif

#ifndef TkPointerEvent
VFUNC(int,TkPointerEvent,V_TkPointerEvent,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *winPtr)))
#endif

#ifndef TkPositionInTree
VFUNC(int,TkPositionInTree,V_TkPositionInTree,_ANSI_ARGS_((TkWindow *winPtr,
			    TkWindow *treePtr)))
#endif

#ifndef TkPostscriptImage
VFUNC(int,TkPostscriptImage,V_TkPostscriptImage,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_PostscriptInfo psInfo,
			    XImage *ximage, int x, int y, int width,
			    int height)))
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
			    TkWindow *winPtr, XEvent *eventPtr)))
#endif

#ifndef TkReadBitmapFile
VFUNC(int,TkReadBitmapFile,V_TkReadBitmapFile,_ANSI_ARGS_((Tcl_Interp *interp,
			    Display* display,
			    Drawable d, CONST char* filename,
			    unsigned int* width_return,
			    unsigned int* height_return,
			    Pixmap* bitmap_return,
			    int* x_hot_return, int* y_hot_return)))
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

#ifndef TkSetClassProcs
VFUNC(void,TkSetClassProcs,V_TkSetClassProcs,_ANSI_ARGS_((Tk_Window tkwin,
			    TkClassProcs *procs, ClientData instanceData)))
#endif

#ifndef TkSetPixmapColormap
VFUNC(void,TkSetPixmapColormap,V_TkSetPixmapColormap,_ANSI_ARGS_((Pixmap pixmap,
			    Colormap colormap)))
#endif

#ifndef TkSetRegion
VFUNC(void,TkSetRegion,V_TkSetRegion,_ANSI_ARGS_((Display* display, GC gc,
			    TkRegion rgn)))
#endif

#ifndef TkSetWindowMenuBar
VFUNC(void,TkSetWindowMenuBar,V_TkSetWindowMenuBar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Arg oldMenuName,
			    Arg menuName)))
#endif

#ifndef TkStringToKeysym
VFUNC(KeySym,TkStringToKeysym,V_TkStringToKeysym,_ANSI_ARGS_((char *name)))
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

#ifndef TkWmFocusToplevel
VFUNC(TkWindow *,TkWmFocusToplevel,V_TkWmFocusToplevel,_ANSI_ARGS_((TkWindow *winPtr)))
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

#ifndef TkpChangeFocus
VFUNC(int,TkpChangeFocus,V_TkpChangeFocus,_ANSI_ARGS_((TkWindow *winPtr,
			    int force)))
#endif

#ifndef TkpClaimFocus
VFUNC(void,TkpClaimFocus,V_TkpClaimFocus,_ANSI_ARGS_((TkWindow *topLevelPtr,
			    int force)))
#endif

#ifndef TkpCloseDisplay
VFUNC(void,TkpCloseDisplay,V_TkpCloseDisplay,_ANSI_ARGS_((TkDisplay *dispPtr)))
#endif

#ifndef TkpCmapStressed
VFUNC(int,TkpCmapStressed,V_TkpCmapStressed,_ANSI_ARGS_((Tk_Window tkwin,
			    Colormap colormap)))
#endif

#ifndef TkpCreateNativeBitmap
VFUNC(Pixmap,TkpCreateNativeBitmap,V_TkpCreateNativeBitmap,_ANSI_ARGS_((Display *display,
			    char * source)))
#endif

#ifndef TkpDefineNativeBitmaps
VFUNC(void,TkpDefineNativeBitmaps,V_TkpDefineNativeBitmaps,_ANSI_ARGS_((void)))
#endif

#ifndef TkpGetNativeAppBitmap
VFUNC(Pixmap,TkpGetNativeAppBitmap,V_TkpGetNativeAppBitmap,_ANSI_ARGS_((Display *display,
			    char *name, int *width, int *height)))
#endif

#ifndef TkpGetOtherWindow
VFUNC(TkWindow *,TkpGetOtherWindow,V_TkpGetOtherWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkpGetWrapperWindow
VFUNC(TkWindow *,TkpGetWrapperWindow,V_TkpGetWrapperWindow,_ANSI_ARGS_((TkWindow *winPtr)))
#endif

#ifndef TkpInitializeMenuBindings
VFUNC(void,TkpInitializeMenuBindings,V_TkpInitializeMenuBindings,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_BindingTable bindingTable)))
#endif

#ifndef TkpMakeContainer
VFUNC(void,TkpMakeContainer,V_TkpMakeContainer,_ANSI_ARGS_((Tk_Window tkwin)))
#endif

#ifndef TkpMakeMenuWindow
VFUNC(void,TkpMakeMenuWindow,V_TkpMakeMenuWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    int transient)))
#endif

#ifndef TkpMakeWindow
VFUNC(Window,TkpMakeWindow,V_TkpMakeWindow,_ANSI_ARGS_((TkWindow *winPtr,
			    Window parent)))
#endif

#ifndef TkpMenuNotifyToplevelCreate
VFUNC(void,TkpMenuNotifyToplevelCreate,V_TkpMenuNotifyToplevelCreate,_ANSI_ARGS_((
			    Tcl_Interp *, char *menuName)))
#endif

#ifndef TkpOpenDisplay
VFUNC(TkDisplay *,TkpOpenDisplay,V_TkpOpenDisplay,_ANSI_ARGS_((char *display_name)))
#endif

#ifndef TkpPrintWindowId
VFUNC(void,TkpPrintWindowId,V_TkpPrintWindowId,_ANSI_ARGS_((char *buf,
			    Window window)))
#endif

#ifndef TkpRedirectKeyEvent
VFUNC(void,TkpRedirectKeyEvent,V_TkpRedirectKeyEvent,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
#endif

#ifndef TkpScanWindowId
VFUNC(int,TkpScanWindowId,V_TkpScanWindowId,_ANSI_ARGS_((Tcl_Interp *interp,
			    Arg string, int *idPtr)))
#endif

#ifndef TkpSetMainMenubar
VFUNC(void,TkpSetMainMenubar,V_TkpSetMainMenubar,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *menuName)))
#endif

#ifndef TkpSync
VFUNC(void,TkpSync,V_TkpSync,_ANSI_ARGS_((Display *display)))
#endif

#ifndef TkpUseWindow
VFUNC(int,TkpUseWindow,V_TkpUseWindow,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Arg string)))
#endif

#ifndef TkpWindowWasRecentlyDeleted
VFUNC(int,TkpWindowWasRecentlyDeleted,V_TkpWindowWasRecentlyDeleted,_ANSI_ARGS_((Window win,
			    TkDisplay *dispPtr)))
#endif

#endif /* _TKINT */
