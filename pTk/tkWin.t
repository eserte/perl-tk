#ifdef _TKWIN
#ifndef Lang_WinEvent
VFUNC(int,Lang_WinEvent,V_Lang_WinEvent,_ANSI_ARGS_((Tk_Window tkwin,
			    UINT message, WPARAM wParam, LPARAM lParam,
			    LRESULT *result)))
#endif

#ifndef Tk_AttachHWND
VFUNC(Window,Tk_AttachHWND,V_Tk_AttachHWND,_ANSI_ARGS_((Tk_Window tkwin,
			    HWND hwnd)))
#endif

#ifndef Tk_GetHINSTANCE
VFUNC(HINSTANCE,Tk_GetHINSTANCE,V_Tk_GetHINSTANCE,_ANSI_ARGS_((void)))
#endif

#ifndef Tk_GetHWND
VFUNC(HWND,Tk_GetHWND,V_Tk_GetHWND,_ANSI_ARGS_((Window window)))
#endif

#ifndef Tk_HWNDToWindow
VFUNC(Tk_Window,Tk_HWNDToWindow,V_Tk_HWNDToWindow,_ANSI_ARGS_((HWND hwnd)))
#endif

#ifndef Tk_PointerEvent
VFUNC(void,Tk_PointerEvent,V_Tk_PointerEvent,_ANSI_ARGS_((HWND hwnd,
			    int x, int y)))
#endif

#ifndef Tk_TranslateWinEvent
VFUNC(int,Tk_TranslateWinEvent,V_Tk_TranslateWinEvent,_ANSI_ARGS_((HWND hwnd,
			    UINT message, WPARAM wParam, LPARAM lParam,
			    LRESULT *result)))
#endif

#endif /* _TKWIN */
