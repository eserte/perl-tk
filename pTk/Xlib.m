#ifndef _XLIB_VM
#define _XLIB_VM
#include "Xlib_f.h"
#ifndef NO_VTABLES
#ifndef __WIN32__
#ifndef XAllocClassHint
#define XAllocClassHint (*XlibVptr->V_XAllocClassHint)
#endif
#endif /* !__WIN32__ */
#ifndef XAllocColor
#define XAllocColor (*XlibVptr->V_XAllocColor)
#endif
#ifndef XAllocNamedColor
#define XAllocNamedColor (*XlibVptr->V_XAllocNamedColor)
#endif
#ifndef __WIN32__
#ifndef XAllocSizeHints
#define XAllocSizeHints (*XlibVptr->V_XAllocSizeHints)
#endif
#endif /* !__WIN32__ */
#ifndef XBell
#define XBell (*XlibVptr->V_XBell)
#endif
#ifndef XChangeGC
#define XChangeGC (*XlibVptr->V_XChangeGC)
#endif
#ifndef XChangeProperty
#define XChangeProperty (*XlibVptr->V_XChangeProperty)
#endif
#ifndef XChangeWindowAttributes
#define XChangeWindowAttributes (*XlibVptr->V_XChangeWindowAttributes)
#endif
#ifndef __WIN32__
#ifndef XCheckIfEvent
#define XCheckIfEvent (*XlibVptr->V_XCheckIfEvent)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XCheckWindowEvent
#define XCheckWindowEvent (*XlibVptr->V_XCheckWindowEvent)
#endif
#endif /* !__WIN32__ */
#ifndef XClearWindow
#define XClearWindow (*XlibVptr->V_XClearWindow)
#endif
#ifndef __WIN32__
#ifndef XClipBox
#define XClipBox (*XlibVptr->V_XClipBox)
#endif
#endif /* !__WIN32__ */
#ifndef XConfigureWindow
#define XConfigureWindow (*XlibVptr->V_XConfigureWindow)
#endif
#ifndef __WIN32__
#ifndef XConvertSelection
#define XConvertSelection (*XlibVptr->V_XConvertSelection)
#endif
#endif /* !__WIN32__ */
#ifndef XCopyArea
#define XCopyArea (*XlibVptr->V_XCopyArea)
#endif
#ifndef XCopyPlane
#define XCopyPlane (*XlibVptr->V_XCopyPlane)
#endif
#ifndef XCreateBitmapFromData
#define XCreateBitmapFromData (*XlibVptr->V_XCreateBitmapFromData)
#endif
#ifndef XCreateColormap
#define XCreateColormap (*XlibVptr->V_XCreateColormap)
#endif
#ifndef XCreateGC
#define XCreateGC (*XlibVptr->V_XCreateGC)
#endif
#ifndef XCreateGlyphCursor
#define XCreateGlyphCursor (*XlibVptr->V_XCreateGlyphCursor)
#endif
#ifndef XCreateImage
#define XCreateImage (*XlibVptr->V_XCreateImage)
#endif
#ifndef XCreatePixmapCursor
#define XCreatePixmapCursor (*XlibVptr->V_XCreatePixmapCursor)
#endif
#ifndef __WIN32__
#ifndef XCreateRegion
#define XCreateRegion (*XlibVptr->V_XCreateRegion)
#endif
#endif /* !__WIN32__ */
#ifndef XCreateWindow
#define XCreateWindow (*XlibVptr->V_XCreateWindow)
#endif
#ifndef __WIN32__
#ifndef XDefaultColormap
#define XDefaultColormap (*XlibVptr->V_XDefaultColormap)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultDepth
#define XDefaultDepth (*XlibVptr->V_XDefaultDepth)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultScreen
#define XDefaultScreen (*XlibVptr->V_XDefaultScreen)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultVisual
#define XDefaultVisual (*XlibVptr->V_XDefaultVisual)
#endif
#endif /* !__WIN32__ */
#ifndef XDefineCursor
#define XDefineCursor (*XlibVptr->V_XDefineCursor)
#endif
#ifndef XDeleteProperty
#define XDeleteProperty (*XlibVptr->V_XDeleteProperty)
#endif
#ifndef __WIN32__
#ifndef XDestroyRegion
#define XDestroyRegion (*XlibVptr->V_XDestroyRegion)
#endif
#endif /* !__WIN32__ */
#ifndef XDestroyWindow
#define XDestroyWindow (*XlibVptr->V_XDestroyWindow)
#endif
#ifndef XDrawArc
#define XDrawArc (*XlibVptr->V_XDrawArc)
#endif
#ifndef __WIN32__
#ifndef XDrawImageString
#define XDrawImageString (*XlibVptr->V_XDrawImageString)
#endif
#endif /* !__WIN32__ */
#ifndef XDrawLine
#define XDrawLine (*XlibVptr->V_XDrawLine)
#endif
#ifndef XDrawLines
#define XDrawLines (*XlibVptr->V_XDrawLines)
#endif
#ifndef XDrawPoints
#define XDrawPoints (*XlibVptr->V_XDrawPoints)
#endif
#ifndef XDrawRectangle
#define XDrawRectangle (*XlibVptr->V_XDrawRectangle)
#endif
#ifndef XDrawString
#define XDrawString (*XlibVptr->V_XDrawString)
#endif
#ifndef __WIN32__
#ifndef XEventsQueued
#define XEventsQueued (*XlibVptr->V_XEventsQueued)
#endif
#endif /* !__WIN32__ */
#ifndef XFillArc
#define XFillArc (*XlibVptr->V_XFillArc)
#endif
#ifndef XFillPolygon
#define XFillPolygon (*XlibVptr->V_XFillPolygon)
#endif
#ifndef XFillRectangle
#define XFillRectangle (*XlibVptr->V_XFillRectangle)
#endif
#ifndef XFillRectangles
#define XFillRectangles (*XlibVptr->V_XFillRectangles)
#endif
#ifndef XFlush
#define XFlush (*XlibVptr->V_XFlush)
#endif
#ifndef XFree
#define XFree (*XlibVptr->V_XFree)
#endif
#ifndef XFreeColormap
#define XFreeColormap (*XlibVptr->V_XFreeColormap)
#endif
#ifndef XFreeColors
#define XFreeColors (*XlibVptr->V_XFreeColors)
#endif
#ifndef XFreeCursor
#define XFreeCursor (*XlibVptr->V_XFreeCursor)
#endif
#ifndef XFreeFont
#define XFreeFont (*XlibVptr->V_XFreeFont)
#endif
#ifndef __WIN32__
#ifndef XFreeFontNames
#define XFreeFontNames (*XlibVptr->V_XFreeFontNames)
#endif
#endif /* !__WIN32__ */
#ifndef XFreeGC
#define XFreeGC (*XlibVptr->V_XFreeGC)
#endif
#ifndef XFreeModifiermap
#define XFreeModifiermap (*XlibVptr->V_XFreeModifiermap)
#endif
#ifndef XGContextFromGC
#define XGContextFromGC (*XlibVptr->V_XGContextFromGC)
#endif
#ifndef XGetAtomName
#define XGetAtomName (*XlibVptr->V_XGetAtomName)
#endif
#ifndef XGetFontProperty
#define XGetFontProperty (*XlibVptr->V_XGetFontProperty)
#endif
#ifndef XGetGeometry
#define XGetGeometry (*XlibVptr->V_XGetGeometry)
#endif
#ifndef XGetImage
#define XGetImage (*XlibVptr->V_XGetImage)
#endif
#ifndef XGetInputFocus
#define XGetInputFocus (*XlibVptr->V_XGetInputFocus)
#endif
#ifndef XGetModifierMapping
#define XGetModifierMapping (*XlibVptr->V_XGetModifierMapping)
#endif
#ifndef __WIN32__
#ifndef XGetSelectionOwner
#define XGetSelectionOwner (*XlibVptr->V_XGetSelectionOwner)
#endif
#endif /* !__WIN32__ */
#ifndef XGetVisualInfo
#define XGetVisualInfo (*XlibVptr->V_XGetVisualInfo)
#endif
#ifndef XGetWMColormapWindows
#define XGetWMColormapWindows (*XlibVptr->V_XGetWMColormapWindows)
#endif
#ifndef XGetWindowAttributes
#define XGetWindowAttributes (*XlibVptr->V_XGetWindowAttributes)
#endif
#ifndef XGetWindowProperty
#define XGetWindowProperty (*XlibVptr->V_XGetWindowProperty)
#endif
#ifndef XGrabKeyboard
#define XGrabKeyboard (*XlibVptr->V_XGrabKeyboard)
#endif
#ifndef XGrabPointer
#define XGrabPointer (*XlibVptr->V_XGrabPointer)
#endif
#ifndef XGrabServer
#define XGrabServer (*XlibVptr->V_XGrabServer)
#endif
#ifndef XIconifyWindow
#define XIconifyWindow (*XlibVptr->V_XIconifyWindow)
#endif
#ifndef XInternAtom
#define XInternAtom (*XlibVptr->V_XInternAtom)
#endif
#ifndef __WIN32__
#ifndef XIntersectRegion
#define XIntersectRegion (*XlibVptr->V_XIntersectRegion)
#endif
#endif /* !__WIN32__ */
#ifndef XKeycodeToKeysym
#define XKeycodeToKeysym (*XlibVptr->V_XKeycodeToKeysym)
#endif
#ifndef XKeysymToString
#define XKeysymToString (*XlibVptr->V_XKeysymToString)
#endif
#ifndef __WIN32__
#ifndef XListFonts
#define XListFonts (*XlibVptr->V_XListFonts)
#endif
#endif /* !__WIN32__ */
#ifndef XListHosts
#define XListHosts (*XlibVptr->V_XListHosts)
#endif
#ifndef __WIN32__
#ifndef XListProperties
#define XListProperties (*XlibVptr->V_XListProperties)
#endif
#endif /* !__WIN32__ */
#ifndef XLoadFont
#define XLoadFont (*XlibVptr->V_XLoadFont)
#endif
#ifndef XLoadQueryFont
#define XLoadQueryFont (*XlibVptr->V_XLoadQueryFont)
#endif
#ifndef XLookupColor
#define XLookupColor (*XlibVptr->V_XLookupColor)
#endif
#ifndef XLookupString
#define XLookupString (*XlibVptr->V_XLookupString)
#endif
#ifndef XLowerWindow
#define XLowerWindow (*XlibVptr->V_XLowerWindow)
#endif
#ifndef XMapWindow
#define XMapWindow (*XlibVptr->V_XMapWindow)
#endif
#ifndef XMoveResizeWindow
#define XMoveResizeWindow (*XlibVptr->V_XMoveResizeWindow)
#endif
#ifndef XMoveWindow
#define XMoveWindow (*XlibVptr->V_XMoveWindow)
#endif
#ifndef XNextEvent
#define XNextEvent (*XlibVptr->V_XNextEvent)
#endif
#ifndef XNoOp
#define XNoOp (*XlibVptr->V_XNoOp)
#endif
#ifndef XOpenDisplay
#define XOpenDisplay (*XlibVptr->V_XOpenDisplay)
#endif
#ifndef XParseColor
#define XParseColor (*XlibVptr->V_XParseColor)
#endif
#ifndef XPutBackEvent
#define XPutBackEvent (*XlibVptr->V_XPutBackEvent)
#endif
#ifndef __WIN32__
#ifndef XPutImage
#define XPutImage (*XlibVptr->V_XPutImage)
#endif
#endif /* !__WIN32__ */
#ifndef XQueryColors
#define XQueryColors (*XlibVptr->V_XQueryColors)
#endif
#ifndef XQueryPointer
#define XQueryPointer (*XlibVptr->V_XQueryPointer)
#endif
#ifndef XQueryTree
#define XQueryTree (*XlibVptr->V_XQueryTree)
#endif
#ifndef XRaiseWindow
#define XRaiseWindow (*XlibVptr->V_XRaiseWindow)
#endif
#ifndef XReadBitmapFile
#define XReadBitmapFile (*XlibVptr->V_XReadBitmapFile)
#endif
#ifndef XRefreshKeyboardMapping
#define XRefreshKeyboardMapping (*XlibVptr->V_XRefreshKeyboardMapping)
#endif
#ifndef XResizeWindow
#define XResizeWindow (*XlibVptr->V_XResizeWindow)
#endif
#ifndef XRootWindow
#define XRootWindow (*XlibVptr->V_XRootWindow)
#endif
#ifndef XSelectInput
#define XSelectInput (*XlibVptr->V_XSelectInput)
#endif
#ifndef XSendEvent
#define XSendEvent (*XlibVptr->V_XSendEvent)
#endif
#ifndef XSetBackground
#define XSetBackground (*XlibVptr->V_XSetBackground)
#endif
#ifndef __WIN32__
#ifndef XSetClassHint
#define XSetClassHint (*XlibVptr->V_XSetClassHint)
#endif
#endif /* !__WIN32__ */
#ifndef XSetClipMask
#define XSetClipMask (*XlibVptr->V_XSetClipMask)
#endif
#ifndef XSetClipOrigin
#define XSetClipOrigin (*XlibVptr->V_XSetClipOrigin)
#endif
#ifndef XSetCommand
#define XSetCommand (*XlibVptr->V_XSetCommand)
#endif
#ifndef XSetErrorHandler
#define XSetErrorHandler (*XlibVptr->V_XSetErrorHandler)
#endif
#ifndef XSetForeground
#define XSetForeground (*XlibVptr->V_XSetForeground)
#endif
#ifndef XSetIconName
#define XSetIconName (*XlibVptr->V_XSetIconName)
#endif
#ifndef XSetInputFocus
#define XSetInputFocus (*XlibVptr->V_XSetInputFocus)
#endif
#ifndef __WIN32__
#ifndef XSetRegion
#define XSetRegion (*XlibVptr->V_XSetRegion)
#endif
#endif /* !__WIN32__ */
#ifndef XSetSelectionOwner
#define XSetSelectionOwner (*XlibVptr->V_XSetSelectionOwner)
#endif
#ifndef XSetTSOrigin
#define XSetTSOrigin (*XlibVptr->V_XSetTSOrigin)
#endif
#ifndef XSetTransientForHint
#define XSetTransientForHint (*XlibVptr->V_XSetTransientForHint)
#endif
#ifndef XSetWMClientMachine
#define XSetWMClientMachine (*XlibVptr->V_XSetWMClientMachine)
#endif
#ifndef XSetWMColormapWindows
#define XSetWMColormapWindows (*XlibVptr->V_XSetWMColormapWindows)
#endif
#ifndef __WIN32__
#ifndef XSetWMHints
#define XSetWMHints (*XlibVptr->V_XSetWMHints)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XSetWMName
#define XSetWMName (*XlibVptr->V_XSetWMName)
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XSetWMNormalHints
#define XSetWMNormalHints (*XlibVptr->V_XSetWMNormalHints)
#endif
#endif /* !__WIN32__ */
#ifndef XSetWindowBackground
#define XSetWindowBackground (*XlibVptr->V_XSetWindowBackground)
#endif
#ifndef XSetWindowBackgroundPixmap
#define XSetWindowBackgroundPixmap (*XlibVptr->V_XSetWindowBackgroundPixmap)
#endif
#ifndef XSetWindowBorder
#define XSetWindowBorder (*XlibVptr->V_XSetWindowBorder)
#endif
#ifndef XSetWindowBorderPixmap
#define XSetWindowBorderPixmap (*XlibVptr->V_XSetWindowBorderPixmap)
#endif
#ifndef XSetWindowBorderWidth
#define XSetWindowBorderWidth (*XlibVptr->V_XSetWindowBorderWidth)
#endif
#ifndef XSetWindowColormap
#define XSetWindowColormap (*XlibVptr->V_XSetWindowColormap)
#endif
#ifndef XStringListToTextProperty
#define XStringListToTextProperty (*XlibVptr->V_XStringListToTextProperty)
#endif
#ifndef XStringToKeysym
#define XStringToKeysym (*XlibVptr->V_XStringToKeysym)
#endif
#ifndef XSync
#define XSync (*XlibVptr->V_XSync)
#endif
#ifndef XTextExtents
#define XTextExtents (*XlibVptr->V_XTextExtents)
#endif
#ifndef XTextWidth
#define XTextWidth (*XlibVptr->V_XTextWidth)
#endif
#ifndef XTranslateCoordinates
#define XTranslateCoordinates (*XlibVptr->V_XTranslateCoordinates)
#endif
#ifndef XUngrabKeyboard
#define XUngrabKeyboard (*XlibVptr->V_XUngrabKeyboard)
#endif
#ifndef XUngrabPointer
#define XUngrabPointer (*XlibVptr->V_XUngrabPointer)
#endif
#ifndef XUngrabServer
#define XUngrabServer (*XlibVptr->V_XUngrabServer)
#endif
#ifndef __WIN32__
#ifndef XUnionRectWithRegion
#define XUnionRectWithRegion (*XlibVptr->V_XUnionRectWithRegion)
#endif
#endif /* !__WIN32__ */
#ifndef XUnmapWindow
#define XUnmapWindow (*XlibVptr->V_XUnmapWindow)
#endif
#ifndef XVisualIDFromVisual
#define XVisualIDFromVisual (*XlibVptr->V_XVisualIDFromVisual)
#endif
#ifndef __WIN32__
#ifndef XWarpPointer
#define XWarpPointer (*XlibVptr->V_XWarpPointer)
#endif
#endif /* !__WIN32__ */
#ifndef XWindowEvent
#define XWindowEvent (*XlibVptr->V_XWindowEvent)
#endif
#ifndef XWithdrawWindow
#define XWithdrawWindow (*XlibVptr->V_XWithdrawWindow)
#endif
#ifndef _XInitImageFuncPtrs
#define _XInitImageFuncPtrs (*XlibVptr->V__XInitImageFuncPtrs)
#endif
#endif /* NO_VTABLES */
#endif /* _XLIB_VM */
