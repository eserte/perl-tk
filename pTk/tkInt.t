#ifdef _TKINT
VVAR(Tk_Uid,tkActiveUid,V_tkActiveUid)
VVAR(TkDelayedEventProc	*,tkDelayedEventProc,V_tkDelayedEventProc)
VVAR(Tk_Uid,tkDisabledUid,V_tkDisabledUid)
VVAR(TkDisplay *,tkDisplayList,V_tkDisplayList)
VVAR(TkMainInfo		*,tkMainWindowList,V_tkMainWindowList)
VVAR(Tk_Uid,tkNormalUid,V_tkNormalUid)
VVAR(int,tkSendSerial,V_tkSendSerial)
VFUNC(void,TkBindEventProc,V_TkBindEventProc,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
VFUNC(int,TkCmapStressed,V_TkCmapStressed,_ANSI_ARGS_((Tk_Window tkwin,
			    Colormap colormap)))
VFUNC(void,TkComputeTextGeometry,V_TkComputeTextGeometry,_ANSI_ARGS_((
			    XFontStruct *fontStructPtr, char *string,
			    int numChars, int wrapLength, int *widthPtr,
			    int *heightPtr)))
VFUNC(Time,TkCurrentTime,V_TkCurrentTime,_ANSI_ARGS_((TkDisplay *dispPtr)))
VFUNC(void,TkDisplayChars,V_TkDisplayChars,_ANSI_ARGS_((Display *display,
			    Drawable drawable, GC gc,
			    XFontStruct *fontStructPtr, char *string,
			    int numChars, int x, int y, int tabOrigin,
			    int flags)))
VFUNC(void,TkDisplayText,V_TkDisplayText,_ANSI_ARGS_((Display *display,
			    Drawable drawable, XFontStruct *fontStructPtr,
			    char *string, int numChars, int x, int y,
			    int length, Tk_Justify justify, int underline,
			    GC gc)))
VFUNC(int,TkFocusFilterEvent,V_TkFocusFilterEvent,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *eventPtr)))
VFUNC(void,TkFreeWindowId,V_TkFreeWindowId,_ANSI_ARGS_((TkDisplay *dispPtr,
			    Window w)))
VFUNC(TkDisplay *,TkGetDisplay,V_TkGetDisplay,_ANSI_ARGS_((Display *display)))
VFUNC(TkWindow *,TkGetFocus,V_TkGetFocus,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(int,TkGetInterpNames,V_TkGetInterpNames,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin)))
VFUNC(int,TkGrabState,V_TkGrabState,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(void,TkGrabTriggerProc,V_TkGrabTriggerProc,_ANSI_ARGS_((XEvent *eventPtr)))
VFUNC(void,TkInOutEvents,V_TkInOutEvents,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *sourcePtr, TkWindow *destPtr,
			    int leaveType, int EnterType)))
VFUNC(int,TkMeasureChars,V_TkMeasureChars,_ANSI_ARGS_((XFontStruct *fontStructPtr,
			    char *source, int maxChars, int startX, int maxX,
			    int tabOrigin, int flags, int *nextXPtr)))
VFUNC(void,TkOptionClassChanged,V_TkOptionClassChanged,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(int,TkPointerEvent,V_TkPointerEvent,_ANSI_ARGS_((XEvent *eventPtr,
			    TkWindow *winPtr)))
VFUNC(void,TkQueueEvent,V_TkQueueEvent,_ANSI_ARGS_((TkDisplay *dispPtr,
			    XEvent *eventPtr)))
VFUNC(void,TkSelEventProc,V_TkSelEventProc,_ANSI_ARGS_((Tk_Window tkwin,
			    XEvent *eventPtr)))
VFUNC(void,TkSelInit,V_TkSelInit,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,TkSelPropProc,V_TkSelPropProc,_ANSI_ARGS_((XEvent *eventPtr)))
VFUNC(void,TkUnderlineChars,V_TkUnderlineChars,_ANSI_ARGS_((Display *display,
			    Drawable drawable, GC gc,
			    XFontStruct *fontStructPtr, char *string,
			    int x, int y, int tabOrigin, int flags,
			    int firstChar, int lastChar)))
VFUNC(void,TkWmAddToColormapWindows,V_TkWmAddToColormapWindows,_ANSI_ARGS_((
			    TkWindow *winPtr)))
VFUNC(void,TkWmMapWindow,V_TkWmMapWindow,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(void,TkWmNewWindow,V_TkWmNewWindow,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(void,TkWmProtocolEventProc,V_TkWmProtocolEventProc,_ANSI_ARGS_((TkWindow *winPtr,
			    XEvent *evenvPtr)))
VFUNC(void,TkWmRestackToplevel,V_TkWmRestackToplevel,_ANSI_ARGS_((TkWindow *winPtr,
			    int aboveBelow, TkWindow *otherPtr)))
VFUNC(void,TkWmSetClass,V_TkWmSetClass,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(void,TkWmUnmapWindow,V_TkWmUnmapWindow,_ANSI_ARGS_((TkWindow *winPtr)))
VFUNC(int,TkXFileProc,V_TkXFileProc,_ANSI_ARGS_((ClientData clientData,
			    int mask, int flags)))
#endif /* _TKINT */
