#ifndef _TKWININT_VM
#define _TKWININT_VM
#include "tkWinInt_f.h"
#ifndef NO_VTABLES
#define tkpIsWin32s (*TkwinintVptr->V_tkpIsWin32s)
#ifndef TclWinGetTclInstance
#  define TclWinGetTclInstance (*TkwinintVptr->V_TclWinGetTclInstance)
#endif

#ifndef TkWin32DllPresent
#  define TkWin32DllPresent (*TkwinintVptr->V_TkWin32DllPresent)
#endif

#ifndef TkWinCancelMouseTimer
#  define TkWinCancelMouseTimer (*TkwinintVptr->V_TkWinCancelMouseTimer)
#endif

#ifndef TkWinClipboardRender
#  define TkWinClipboardRender (*TkwinintVptr->V_TkWinClipboardRender)
#endif

#ifndef TkWinEmbeddedEventProc
#  define TkWinEmbeddedEventProc (*TkwinintVptr->V_TkWinEmbeddedEventProc)
#endif

#ifndef TkWinFillRect
#  define TkWinFillRect (*TkwinintVptr->V_TkWinFillRect)
#endif

#ifndef TkWinGetBorderPixels
#  define TkWinGetBorderPixels (*TkwinintVptr->V_TkWinGetBorderPixels)
#endif

#ifndef TkWinGetDrawableDC
#  define TkWinGetDrawableDC (*TkwinintVptr->V_TkWinGetDrawableDC)
#endif

#ifndef TkWinGetModifierState
#  define TkWinGetModifierState (*TkwinintVptr->V_TkWinGetModifierState)
#endif

#ifndef TkWinGetSystemPalette
#  define TkWinGetSystemPalette (*TkwinintVptr->V_TkWinGetSystemPalette)
#endif

#ifndef TkWinGetWrapperWindow
#  define TkWinGetWrapperWindow (*TkwinintVptr->V_TkWinGetWrapperWindow)
#endif

#ifndef TkWinHandleMenuEvent
#  define TkWinHandleMenuEvent (*TkwinintVptr->V_TkWinHandleMenuEvent)
#endif

#ifndef TkWinIndexOfColor
#  define TkWinIndexOfColor (*TkwinintVptr->V_TkWinIndexOfColor)
#endif

#ifndef TkWinReleaseDrawableDC
#  define TkWinReleaseDrawableDC (*TkwinintVptr->V_TkWinReleaseDrawableDC)
#endif

#ifndef TkWinResendEvent
#  define TkWinResendEvent (*TkwinintVptr->V_TkWinResendEvent)
#endif

#ifndef TkWinSelectPalette
#  define TkWinSelectPalette (*TkwinintVptr->V_TkWinSelectPalette)
#endif

#ifndef TkWinSetMenu
#  define TkWinSetMenu (*TkwinintVptr->V_TkWinSetMenu)
#endif

#ifndef TkWinSetWindowPos
#  define TkWinSetWindowPos (*TkwinintVptr->V_TkWinSetWindowPos)
#endif

#ifndef TkWinWmCleanup
#  define TkWinWmCleanup (*TkwinintVptr->V_TkWinWmCleanup)
#endif

#ifndef TkWinXCleanup
#  define TkWinXCleanup (*TkwinintVptr->V_TkWinXCleanup)
#endif

#ifndef TkWinXInit
#  define TkWinXInit (*TkwinintVptr->V_TkWinXInit)
#endif

#endif /* NO_VTABLES */
#endif /* _TKWININT_VM */
