#ifdef _TKWININT
VVAR(int,tkpIsWin32s,V_tkpIsWin32s)
#ifndef TclWinGetTclInstance
VFUNC(HINSTANCE,TclWinGetTclInstance,V_TclWinGetTclInstance,_ANSI_ARGS_((void)))
#endif

#ifndef TkWin32DllPresent
VFUNC(int,TkWin32DllPresent,V_TkWin32DllPresent,_ANSI_ARGS_((void)))
#endif

#ifndef TkWinCancelMouseTimer
VFUNC(void,TkWinCancelMouseTimer,V_TkWinCancelMouseTimer,_ANSI_ARGS_((void)))
#endif

#ifndef TkWinClipboardRender
VFUNC(void,TkWinClipboardRender,V_TkWinClipboardRender,_ANSI_ARGS_((TkDisplay *dispPtr,
			    UINT format)))
#endif

#ifndef TkWinEmbeddedEventProc
VFUNC(LRESULT,TkWinEmbeddedEventProc,V_TkWinEmbeddedEventProc,_ANSI_ARGS_((HWND hwnd,
			    UINT message, WPARAM wParam, LPARAM lParam)))
#endif

#ifndef TkWinFillRect
VFUNC(void,TkWinFillRect,V_TkWinFillRect,_ANSI_ARGS_((HDC dc, int x, int y,
			    int width, int height, int pixel)))
#endif

#ifndef TkWinGetBorderPixels
VFUNC(COLORREF,TkWinGetBorderPixels,V_TkWinGetBorderPixels,_ANSI_ARGS_((Tk_Window tkwin,
			    Tk_3DBorder border, int which)))
#endif

#ifndef TkWinGetDrawableDC
VFUNC(HDC,TkWinGetDrawableDC,V_TkWinGetDrawableDC,_ANSI_ARGS_((Display *display,
			    Drawable d, TkWinDCState* state)))
#endif

#ifndef TkWinGetModifierState
VFUNC(int,TkWinGetModifierState,V_TkWinGetModifierState,_ANSI_ARGS_((void)))
#endif

#ifndef TkWinGetSystemPalette
VFUNC(HPALETTE,TkWinGetSystemPalette,V_TkWinGetSystemPalette,_ANSI_ARGS_((void)))
#endif

#ifndef TkWinGetWrapperWindow
VFUNC(HWND,TkWinGetWrapperWindow,V_TkWinGetWrapperWindow,_ANSI_ARGS_((Tk_Window tkwin)))
#endif

#ifndef TkWinHandleMenuEvent
VFUNC(int,TkWinHandleMenuEvent,V_TkWinHandleMenuEvent,_ANSI_ARGS_((HWND *phwnd,
			    UINT *pMessage, WPARAM *pwParam, LPARAM *plParam,
			    LRESULT *plResult)))
#endif

#ifndef TkWinIndexOfColor
VFUNC(int,TkWinIndexOfColor,V_TkWinIndexOfColor,_ANSI_ARGS_((XColor *colorPtr)))
#endif

#ifndef TkWinReleaseDrawableDC
VFUNC(void,TkWinReleaseDrawableDC,V_TkWinReleaseDrawableDC,_ANSI_ARGS_((Drawable d,
			    HDC hdc, TkWinDCState* state)))
#endif

#ifndef TkWinResendEvent
VFUNC(LRESULT,TkWinResendEvent,V_TkWinResendEvent,_ANSI_ARGS_((WNDPROC wndproc,
			    HWND hwnd, XEvent *eventPtr)))
#endif

#ifndef TkWinSelectPalette
VFUNC(HPALETTE,TkWinSelectPalette,V_TkWinSelectPalette,_ANSI_ARGS_((HDC dc,
			    Colormap colormap)))
#endif

#ifndef TkWinSetMenu
VFUNC(void,TkWinSetMenu,V_TkWinSetMenu,_ANSI_ARGS_((Tk_Window tkwin,
			    HMENU hMenu)))
#endif

#ifndef TkWinSetWindowPos
VFUNC(void,TkWinSetWindowPos,V_TkWinSetWindowPos,_ANSI_ARGS_((HWND hwnd,
			    HWND siblingHwnd, int pos)))
#endif

#ifndef TkWinWmCleanup
VFUNC(void,TkWinWmCleanup,V_TkWinWmCleanup,_ANSI_ARGS_((HINSTANCE hInstance)))
#endif

#ifndef TkWinXCleanup
VFUNC(void,TkWinXCleanup,V_TkWinXCleanup,_ANSI_ARGS_((HINSTANCE hInstance)))
#endif

#ifndef TkWinXInit
VFUNC(void,TkWinXInit,V_TkWinXInit,_ANSI_ARGS_((HINSTANCE hInstance)))
#endif

#endif /* _TKWININT */
