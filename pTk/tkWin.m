#ifndef _TKWIN_VM
#define _TKWIN_VM
#include "tkWin_f.h"
#ifndef NO_VTABLES
#ifndef Lang_WinEvent
#  define Lang_WinEvent (*TkwinVptr->V_Lang_WinEvent)
#endif

#ifndef Tk_AttachHWND
#  define Tk_AttachHWND (*TkwinVptr->V_Tk_AttachHWND)
#endif

#ifndef Tk_GetHINSTANCE
#  define Tk_GetHINSTANCE (*TkwinVptr->V_Tk_GetHINSTANCE)
#endif

#ifndef Tk_GetHWND
#  define Tk_GetHWND (*TkwinVptr->V_Tk_GetHWND)
#endif

#ifndef Tk_HWNDToWindow
#  define Tk_HWNDToWindow (*TkwinVptr->V_Tk_HWNDToWindow)
#endif

#ifndef Tk_PointerEvent
#  define Tk_PointerEvent (*TkwinVptr->V_Tk_PointerEvent)
#endif

#ifndef Tk_TranslateWinEvent
#  define Tk_TranslateWinEvent (*TkwinVptr->V_Tk_TranslateWinEvent)
#endif

#endif /* NO_VTABLES */
#endif /* _TKWIN_VM */
