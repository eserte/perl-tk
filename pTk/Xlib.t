#ifdef _XLIB
#ifndef __WIN32__
#ifndef XAllocClassHint
VFUNC(XClassHint *,XAllocClassHint,V_XAllocClassHint,_ANSI_ARGS_((void)))
#endif
#endif /* !__WIN32__ */
#ifndef XAllocColor
VFUNC(int,XAllocColor,V_XAllocColor,_ANSI_ARGS_((Display *, Colormap, XColor *)))
#endif
#ifndef XAllocNamedColor
VFUNC(int,XAllocNamedColor,V_XAllocNamedColor,_ANSI_ARGS_((Display *, Colormap, const char *, XColor *, XColor *)))
#endif
#ifndef __WIN32__
#ifndef XAllocSizeHints
VFUNC(XSizeHints *,XAllocSizeHints,V_XAllocSizeHints,_ANSI_ARGS_((void)))
#endif
#endif /* !__WIN32__ */
#ifndef XBell
VFUNC(int,XBell,V_XBell,_ANSI_ARGS_((Display *, int)))
#endif
#ifndef XChangeGC
VFUNC(int,XChangeGC,V_XChangeGC,_ANSI_ARGS_(( Display*, GC, unsigned long, XGCValues *)))
#endif
#ifndef XChangeProperty
VFUNC(int,XChangeProperty,V_XChangeProperty,_ANSI_ARGS_((Display *, Window, Atom, Atom, int, int, const unsigned char *, int)))
#endif
#ifndef XChangeWindowAttributes
VFUNC(int,XChangeWindowAttributes,V_XChangeWindowAttributes,_ANSI_ARGS_((Display *, Window, long unsigned int, XSetWindowAttributes *)))
#endif
#ifndef __WIN32__
#ifndef XCheckIfEvent
VFUNC(int,XCheckIfEvent,V_XCheckIfEvent,_ANSI_ARGS_((Display *, XEvent *, int (*) (Display *, XEvent *, char *), char *)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XCheckWindowEvent
VFUNC(int,XCheckWindowEvent,V_XCheckWindowEvent,_ANSI_ARGS_((Display *, Window, long int, XEvent *)))
#endif
#endif /* !__WIN32__ */
#ifndef XClearWindow
VFUNC(int,XClearWindow,V_XClearWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef __WIN32__
#ifndef XClipBox
VFUNC(int,XClipBox,V_XClipBox,_ANSI_ARGS_((Region, XRectangle *)))
#endif
#endif /* !__WIN32__ */
#ifndef XConfigureWindow
VFUNC(int,XConfigureWindow,V_XConfigureWindow,_ANSI_ARGS_((Display *, Window, unsigned int, XWindowChanges *)))
#endif
#ifndef __WIN32__
#ifndef XConvertSelection
VFUNC(int,XConvertSelection,V_XConvertSelection,_ANSI_ARGS_((Display *, Atom, Atom, Atom, Window, Time)))
#endif
#endif /* !__WIN32__ */
#ifndef XCopyArea
VFUNC(int,XCopyArea,V_XCopyArea,_ANSI_ARGS_((Display *, Drawable, Drawable, GC, int, int, unsigned int, unsigned int, int, int)))
#endif
#ifndef XCopyPlane
VFUNC(int,XCopyPlane,V_XCopyPlane,_ANSI_ARGS_((Display *, Drawable, Drawable, GC, int, int, unsigned int, unsigned int, int, int, long unsigned int)))
#endif
#ifndef XCreateBitmapFromData
VFUNC(Pixmap,XCreateBitmapFromData,V_XCreateBitmapFromData,_ANSI_ARGS_((Display *, Drawable, const char *, unsigned int, unsigned int)))
#endif
#ifndef XCreateColormap
VFUNC(Colormap,XCreateColormap,V_XCreateColormap,_ANSI_ARGS_((Display *, Window, Visual *, int)))
#endif
#ifndef XCreateGC
VFUNC(GC,XCreateGC,V_XCreateGC,_ANSI_ARGS_((Display *, Drawable, long unsigned int, XGCValues *)))
#endif
#ifndef XCreateGlyphCursor
VFUNC(Cursor,XCreateGlyphCursor,V_XCreateGlyphCursor,_ANSI_ARGS_((Display *, Font, Font, unsigned int, unsigned int, XColor *, XColor *)))
#endif
#ifndef XCreateImage
VFUNC(XImage *,XCreateImage,V_XCreateImage,_ANSI_ARGS_((Display *, Visual *, unsigned int, int, int, char *, unsigned int, unsigned int, int, int)))
#endif
#ifndef XCreatePixmapCursor
VFUNC(Cursor,XCreatePixmapCursor,V_XCreatePixmapCursor,_ANSI_ARGS_((Display *, Pixmap, Pixmap, XColor *, XColor *, unsigned int, unsigned int)))
#endif
#ifndef __WIN32__
#ifndef XCreateRegion
VFUNC(Region,XCreateRegion,V_XCreateRegion,_ANSI_ARGS_((void)))
#endif
#endif /* !__WIN32__ */
#ifndef XCreateWindow
VFUNC(Window,XCreateWindow,V_XCreateWindow,_ANSI_ARGS_((Display *, Window, int, int, unsigned int, unsigned int, unsigned int, int, unsigned int, Visual *, long unsigned int, XSetWindowAttributes *)))
#endif
#ifndef __WIN32__
#ifndef XDefaultColormap
VFUNC(Colormap,XDefaultColormap,V_XDefaultColormap,_ANSI_ARGS_((Display *, int)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultDepth
VFUNC(int,XDefaultDepth,V_XDefaultDepth,_ANSI_ARGS_((Display *, int)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultScreen
VFUNC(int,XDefaultScreen,V_XDefaultScreen,_ANSI_ARGS_((Display *)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XDefaultVisual
VFUNC(Visual *,XDefaultVisual,V_XDefaultVisual,_ANSI_ARGS_((Display *, int)))
#endif
#endif /* !__WIN32__ */
#ifndef XDefineCursor
VFUNC(int,XDefineCursor,V_XDefineCursor,_ANSI_ARGS_((Display *, Window, Cursor)))
#endif
#ifndef XDeleteProperty
VFUNC(int,XDeleteProperty,V_XDeleteProperty,_ANSI_ARGS_((Display *, Window, Atom)))
#endif
#ifndef __WIN32__
#ifndef XDestroyRegion
VFUNC(int,XDestroyRegion,V_XDestroyRegion,_ANSI_ARGS_((Region)))
#endif
#endif /* !__WIN32__ */
#ifndef XDestroyWindow
VFUNC(int,XDestroyWindow,V_XDestroyWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef XDrawArc
VFUNC(int,XDrawArc,V_XDrawArc,_ANSI_ARGS_((Display *, Drawable, GC, int, int, unsigned int, unsigned int, int, int)))
#endif
#ifndef __WIN32__
#ifndef XDrawImageString
VFUNC(int,XDrawImageString,V_XDrawImageString,_ANSI_ARGS_((Display *, Drawable, GC, int, int, const char *, int)))
#endif
#endif /* !__WIN32__ */
#ifndef XDrawLine
VFUNC(int,XDrawLine,V_XDrawLine,_ANSI_ARGS_((Display *, Drawable, GC, int, int, int, int)))
#endif
#ifndef XDrawLines
VFUNC(int,XDrawLines,V_XDrawLines,_ANSI_ARGS_((Display *, Drawable, GC, XPoint *, int, int)))
#endif
#ifndef XDrawPoints
VFUNC(int,XDrawPoints,V_XDrawPoints,_ANSI_ARGS_(( Display*, Drawable, GC, XPoint*, int, int)))
#endif
#ifndef XDrawRectangle
VFUNC(int,XDrawRectangle,V_XDrawRectangle,_ANSI_ARGS_((Display *, Drawable, GC, int, int, unsigned int, unsigned int)))
#endif
#ifndef XDrawString
VFUNC(int,XDrawString,V_XDrawString,_ANSI_ARGS_((Display *, Drawable, GC, int, int, const char *, int)))
#endif
#ifndef __WIN32__
#ifndef XEventsQueued
VFUNC(int,XEventsQueued,V_XEventsQueued,_ANSI_ARGS_((Display *, int)))
#endif
#endif /* !__WIN32__ */
#ifndef XFillArc
VFUNC(int,XFillArc,V_XFillArc,_ANSI_ARGS_((Display *, Drawable, GC, int, int, unsigned int, unsigned int, int, int)))
#endif
#ifndef XFillPolygon
VFUNC(int,XFillPolygon,V_XFillPolygon,_ANSI_ARGS_((Display *, Drawable, GC, XPoint *, int, int, int)))
#endif
#ifndef XFillRectangle
VFUNC(int,XFillRectangle,V_XFillRectangle,_ANSI_ARGS_((Display *, Drawable, GC, int, int, unsigned int, unsigned int)))
#endif
#ifndef XFillRectangles
VFUNC(int,XFillRectangles,V_XFillRectangles,_ANSI_ARGS_((Display *, Drawable, GC, XRectangle *, int)))
#endif
#ifndef XFlush
VFUNC(int,XFlush,V_XFlush,_ANSI_ARGS_((Display *)))
#endif
#ifndef XFree
VFUNC(int,XFree,V_XFree,_ANSI_ARGS_((XFree_arg_t *)))
#endif
#ifndef XFreeColormap
VFUNC(int,XFreeColormap,V_XFreeColormap,_ANSI_ARGS_((Display *, Colormap)))
#endif
#ifndef XFreeColors
VFUNC(int,XFreeColors,V_XFreeColors,_ANSI_ARGS_((Display *, Colormap, long unsigned int *, int, long unsigned int)))
#endif
#ifndef XFreeCursor
VFUNC(int,XFreeCursor,V_XFreeCursor,_ANSI_ARGS_((Display *, Cursor)))
#endif
#ifndef XFreeFont
VFUNC(int,XFreeFont,V_XFreeFont,_ANSI_ARGS_((Display *, XFontStruct *)))
#endif
#ifndef __WIN32__
#ifndef XFreeFontNames
VFUNC(int,XFreeFontNames,V_XFreeFontNames,_ANSI_ARGS_((char **)))
#endif
#endif /* !__WIN32__ */
#ifndef XFreeGC
VFUNC(int,XFreeGC,V_XFreeGC,_ANSI_ARGS_((Display *, GC)))
#endif
#ifndef XFreeModifiermap
VFUNC(int,XFreeModifiermap,V_XFreeModifiermap,_ANSI_ARGS_((XModifierKeymap *)))
#endif
#ifndef XGContextFromGC
VFUNC(GContext,XGContextFromGC,V_XGContextFromGC,_ANSI_ARGS_((GC)))
#endif
#ifndef XGetAtomName
VFUNC(char *,XGetAtomName,V_XGetAtomName,_ANSI_ARGS_((Display *, Atom)))
#endif
#ifndef XGetFontProperty
VFUNC(int,XGetFontProperty,V_XGetFontProperty,_ANSI_ARGS_((XFontStruct *, Atom, long unsigned int *)))
#endif
#ifndef XGetGeometry
VFUNC(int,XGetGeometry,V_XGetGeometry,_ANSI_ARGS_((Display *, Drawable, Window *, int *, int *, unsigned int *, unsigned int *, unsigned int *, unsigned int *)))
#endif
#ifndef XGetImage
VFUNC(XImage *,XGetImage,V_XGetImage,_ANSI_ARGS_((Display *, Drawable, int, int, unsigned int, unsigned int, long unsigned int, int)))
#endif
#ifndef XGetInputFocus
VFUNC(int,XGetInputFocus,V_XGetInputFocus,_ANSI_ARGS_((Display *, Window *, int *)))
#endif
#ifndef XGetModifierMapping
VFUNC(XModifierKeymap *,XGetModifierMapping,V_XGetModifierMapping,_ANSI_ARGS_((Display *)))
#endif
#ifndef __WIN32__
#ifndef XGetSelectionOwner
VFUNC(Window,XGetSelectionOwner,V_XGetSelectionOwner,_ANSI_ARGS_((Display *, Atom)))
#endif
#endif /* !__WIN32__ */
#ifndef XGetVisualInfo
VFUNC(XVisualInfo *,XGetVisualInfo,V_XGetVisualInfo,_ANSI_ARGS_((Display *, long int, XVisualInfo *, int *)))
#endif
#ifndef XGetWMColormapWindows
VFUNC(int,XGetWMColormapWindows,V_XGetWMColormapWindows,_ANSI_ARGS_((Display *, Window, Window **, int *)))
#endif
#ifndef XGetWindowAttributes
VFUNC(int,XGetWindowAttributes,V_XGetWindowAttributes,_ANSI_ARGS_((Display *, Window, XWindowAttributes *)))
#endif
#ifndef XGetWindowProperty
VFUNC(int,XGetWindowProperty,V_XGetWindowProperty,_ANSI_ARGS_((Display *, Window, Atom, long int, long int, int, Atom, Atom *, int *, long unsigned int *, long unsigned int *, unsigned char **)))
#endif
#ifndef XGrabKeyboard
VFUNC(int,XGrabKeyboard,V_XGrabKeyboard,_ANSI_ARGS_((Display *, Window, int, int, int, Time)))
#endif
#ifndef XGrabPointer
VFUNC(int,XGrabPointer,V_XGrabPointer,_ANSI_ARGS_((Display *, Window, int, unsigned int, int, int, Window, Cursor, Time)))
#endif
#ifndef XGrabServer
VFUNC(int,XGrabServer,V_XGrabServer,_ANSI_ARGS_((Display *)))
#endif
#ifndef XIconifyWindow
VFUNC(int,XIconifyWindow,V_XIconifyWindow,_ANSI_ARGS_((Display *, Window, int)))
#endif
#ifndef XInternAtom
VFUNC(Atom,XInternAtom,V_XInternAtom,_ANSI_ARGS_((Display *, const char *, int)))
#endif
#ifndef __WIN32__
#ifndef XIntersectRegion
VFUNC(int,XIntersectRegion,V_XIntersectRegion,_ANSI_ARGS_((Region, Region, Region)))
#endif
#endif /* !__WIN32__ */
#ifndef XKeycodeToKeysym
VFUNC(KeySym,XKeycodeToKeysym,V_XKeycodeToKeysym,_ANSI_ARGS_((Display *, unsigned int, int)))
#endif
#ifndef XKeysymToString
VFUNC(char *,XKeysymToString,V_XKeysymToString,_ANSI_ARGS_((KeySym)))
#endif
#ifndef __WIN32__
#ifndef XListFonts
VFUNC(char **,XListFonts,V_XListFonts,_ANSI_ARGS_(( Display*, const char *, int, int *)))
#endif
#endif /* !__WIN32__ */
#ifndef XListHosts
VFUNC(XHostAddress *,XListHosts,V_XListHosts,_ANSI_ARGS_((Display *, int *, int *)))
#endif
#ifndef __WIN32__
#ifndef XListProperties
VFUNC(Atom *,XListProperties,V_XListProperties,_ANSI_ARGS_((Display *, Window, int *)))
#endif
#endif /* !__WIN32__ */
#ifndef XLoadFont
VFUNC(Font,XLoadFont,V_XLoadFont,_ANSI_ARGS_((Display *, const char *)))
#endif
#ifndef XLoadQueryFont
VFUNC(XFontStruct *,XLoadQueryFont,V_XLoadQueryFont,_ANSI_ARGS_((Display *, const char *)))
#endif
#ifndef XLookupColor
VFUNC(int,XLookupColor,V_XLookupColor,_ANSI_ARGS_((Display *, Colormap, const char *, XColor *, XColor *)))
#endif
#ifndef XLookupString
VFUNC(int,XLookupString,V_XLookupString,_ANSI_ARGS_((XKeyEvent *, char *, int, KeySym *, XComposeStatus *)))
#endif
#ifndef XLowerWindow
VFUNC(int,XLowerWindow,V_XLowerWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef XMapWindow
VFUNC(int,XMapWindow,V_XMapWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef XMoveResizeWindow
VFUNC(int,XMoveResizeWindow,V_XMoveResizeWindow,_ANSI_ARGS_((Display *, Window, int, int, unsigned int, unsigned int)))
#endif
#ifndef XMoveWindow
VFUNC(int,XMoveWindow,V_XMoveWindow,_ANSI_ARGS_((Display *, Window, int, int)))
#endif
#ifndef XNextEvent
VFUNC(int,XNextEvent,V_XNextEvent,_ANSI_ARGS_((Display *, XEvent *)))
#endif
#ifndef XNoOp
VFUNC(int,XNoOp,V_XNoOp,_ANSI_ARGS_((Display *)))
#endif
#ifndef XOpenDisplay
VFUNC(Display *,XOpenDisplay,V_XOpenDisplay,_ANSI_ARGS_((const char *)))
#endif
#ifndef XParseColor
VFUNC(int,XParseColor,V_XParseColor,_ANSI_ARGS_((Display *, Colormap, const char *, XColor *)))
#endif
#ifndef XPutBackEvent
VFUNC(int,XPutBackEvent,V_XPutBackEvent,_ANSI_ARGS_((Display *, XEvent *)))
#endif
#ifndef __WIN32__
#ifndef XPutImage
VFUNC(int,XPutImage,V_XPutImage,_ANSI_ARGS_((Display *, Drawable, GC, XImage *, int, int, int, int, unsigned int, unsigned int)))
#endif
#endif /* !__WIN32__ */
#ifndef XQueryColors
VFUNC(int,XQueryColors,V_XQueryColors,_ANSI_ARGS_((Display *, Colormap, XColor *, int)))
#endif
#ifndef XQueryPointer
VFUNC(int,XQueryPointer,V_XQueryPointer,_ANSI_ARGS_((Display *, Window, Window *, Window *, int *, int *, int *, int *, unsigned int *)))
#endif
#ifndef XQueryTree
VFUNC(int,XQueryTree,V_XQueryTree,_ANSI_ARGS_((Display *, Window, Window *, Window *, Window **, unsigned int *)))
#endif
#ifndef XRaiseWindow
VFUNC(int,XRaiseWindow,V_XRaiseWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef XReadBitmapFile
VFUNC(int,XReadBitmapFile,V_XReadBitmapFile,_ANSI_ARGS_((Display *, Drawable, const char *, unsigned int *, unsigned int *, Pixmap *, int *, int *)))
#endif
#ifndef XRefreshKeyboardMapping
VFUNC(int,XRefreshKeyboardMapping,V_XRefreshKeyboardMapping,_ANSI_ARGS_((XMappingEvent *)))
#endif
#ifndef XResizeWindow
VFUNC(int,XResizeWindow,V_XResizeWindow,_ANSI_ARGS_((Display *, Window, unsigned int, unsigned int)))
#endif
#ifndef XRootWindow
VFUNC(Window,XRootWindow,V_XRootWindow,_ANSI_ARGS_((Display *, int)))
#endif
#ifndef XSelectInput
VFUNC(int,XSelectInput,V_XSelectInput,_ANSI_ARGS_((Display *, Window, long int)))
#endif
#ifndef XSendEvent
VFUNC(int,XSendEvent,V_XSendEvent,_ANSI_ARGS_((Display *, Window, int, long int, XEvent *)))
#endif
#ifndef XSetBackground
VFUNC(int,XSetBackground,V_XSetBackground,_ANSI_ARGS_((Display *, GC, unsigned long)))
#endif
#ifndef __WIN32__
#ifndef XSetClassHint
VFUNC(int,XSetClassHint,V_XSetClassHint,_ANSI_ARGS_((Display *, Window, XClassHint *)))
#endif
#endif /* !__WIN32__ */
#ifndef XSetClipMask
VFUNC(int,XSetClipMask,V_XSetClipMask,_ANSI_ARGS_((Display *, GC, Pixmap)))
#endif
#ifndef XSetClipOrigin
VFUNC(int,XSetClipOrigin,V_XSetClipOrigin,_ANSI_ARGS_((Display *, GC, int, int)))
#endif
#ifndef XSetCommand
VFUNC(int,XSetCommand,V_XSetCommand,_ANSI_ARGS_((Display *, Window, char **, int)))
#endif
#ifndef XSetErrorHandler
VFUNC(XErrorHandler,XSetErrorHandler,V_XSetErrorHandler,_ANSI_ARGS_((XErrorHandler)))
#endif
#ifndef XSetForeground
VFUNC(int,XSetForeground,V_XSetForeground,_ANSI_ARGS_((Display *, GC, long unsigned int)))
#endif
#ifndef XSetIconName
VFUNC(int,XSetIconName,V_XSetIconName,_ANSI_ARGS_((Display *, Window, const char *)))
#endif
#ifndef XSetInputFocus
VFUNC(int,XSetInputFocus,V_XSetInputFocus,_ANSI_ARGS_((Display *, Window, int, Time)))
#endif
#ifndef __WIN32__
#ifndef XSetRegion
VFUNC(int,XSetRegion,V_XSetRegion,_ANSI_ARGS_((Display *, GC, Region)))
#endif
#endif /* !__WIN32__ */
#ifndef XSetSelectionOwner
VFUNC(int,XSetSelectionOwner,V_XSetSelectionOwner,_ANSI_ARGS_((Display *, Atom, Window, Time)))
#endif
#ifndef XSetTSOrigin
VFUNC(int,XSetTSOrigin,V_XSetTSOrigin,_ANSI_ARGS_((Display *, GC, int, int)))
#endif
#ifndef XSetTransientForHint
VFUNC(int,XSetTransientForHint,V_XSetTransientForHint,_ANSI_ARGS_((Display *, Window, Window)))
#endif
#ifndef XSetWMClientMachine
VFUNC(void,XSetWMClientMachine,V_XSetWMClientMachine,_ANSI_ARGS_((Display *, Window, XTextProperty *)))
#endif
#ifndef XSetWMColormapWindows
VFUNC(int,XSetWMColormapWindows,V_XSetWMColormapWindows,_ANSI_ARGS_((Display *, Window, Window *, int)))
#endif
#ifndef __WIN32__
#ifndef XSetWMHints
VFUNC(int,XSetWMHints,V_XSetWMHints,_ANSI_ARGS_((Display *, Window, XWMHints *)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XSetWMName
VFUNC(void,XSetWMName,V_XSetWMName,_ANSI_ARGS_((Display *, Window, XTextProperty *)))
#endif
#endif /* !__WIN32__ */
#ifndef __WIN32__
#ifndef XSetWMNormalHints
VFUNC(void,XSetWMNormalHints,V_XSetWMNormalHints,_ANSI_ARGS_((Display *, Window, XSizeHints *)))
#endif
#endif /* !__WIN32__ */
#ifndef XSetWindowBackground
VFUNC(int,XSetWindowBackground,V_XSetWindowBackground,_ANSI_ARGS_((Display *, Window, long unsigned int)))
#endif
#ifndef XSetWindowBackgroundPixmap
VFUNC(int,XSetWindowBackgroundPixmap,V_XSetWindowBackgroundPixmap,_ANSI_ARGS_((Display *, Window, Pixmap)))
#endif
#ifndef XSetWindowBorder
VFUNC(int,XSetWindowBorder,V_XSetWindowBorder,_ANSI_ARGS_((Display *, Window, long unsigned int)))
#endif
#ifndef XSetWindowBorderPixmap
VFUNC(int,XSetWindowBorderPixmap,V_XSetWindowBorderPixmap,_ANSI_ARGS_((Display *, Window, Pixmap)))
#endif
#ifndef XSetWindowBorderWidth
VFUNC(int,XSetWindowBorderWidth,V_XSetWindowBorderWidth,_ANSI_ARGS_((Display *, Window, unsigned int)))
#endif
#ifndef XSetWindowColormap
VFUNC(int,XSetWindowColormap,V_XSetWindowColormap,_ANSI_ARGS_((Display *, Window, Colormap)))
#endif
#ifndef XStringListToTextProperty
VFUNC(int,XStringListToTextProperty,V_XStringListToTextProperty,_ANSI_ARGS_((char **, int, XTextProperty *)))
#endif
#ifndef XStringToKeysym
VFUNC(KeySym,XStringToKeysym,V_XStringToKeysym,_ANSI_ARGS_((const char *)))
#endif
#ifndef XSync
VFUNC(int,XSync,V_XSync,_ANSI_ARGS_((Display *, int)))
#endif
#ifndef XTextExtents
VFUNC(int,XTextExtents,V_XTextExtents,_ANSI_ARGS_((XFontStruct *, const char *, int, int *, int *, int *, XCharStruct *)))
#endif
#ifndef XTextWidth
VFUNC(int,XTextWidth,V_XTextWidth,_ANSI_ARGS_((XFontStruct *, const char *, int)))
#endif
#ifndef XTranslateCoordinates
VFUNC(int,XTranslateCoordinates,V_XTranslateCoordinates,_ANSI_ARGS_((Display *, Window, Window, int, int, int *, int *, Window *)))
#endif
#ifndef XUngrabKeyboard
VFUNC(int,XUngrabKeyboard,V_XUngrabKeyboard,_ANSI_ARGS_((Display *, Time)))
#endif
#ifndef XUngrabPointer
VFUNC(int,XUngrabPointer,V_XUngrabPointer,_ANSI_ARGS_((Display *, Time)))
#endif
#ifndef XUngrabServer
VFUNC(int,XUngrabServer,V_XUngrabServer,_ANSI_ARGS_((Display *)))
#endif
#ifndef __WIN32__
#ifndef XUnionRectWithRegion
VFUNC(int,XUnionRectWithRegion,V_XUnionRectWithRegion,_ANSI_ARGS_((XRectangle *, Region, Region)))
#endif
#endif /* !__WIN32__ */
#ifndef XUnmapWindow
VFUNC(int,XUnmapWindow,V_XUnmapWindow,_ANSI_ARGS_((Display *, Window)))
#endif
#ifndef XVisualIDFromVisual
VFUNC(VisualID,XVisualIDFromVisual,V_XVisualIDFromVisual,_ANSI_ARGS_((Visual *)))
#endif
#ifndef __WIN32__
#ifndef XWarpPointer
VFUNC(int,XWarpPointer,V_XWarpPointer,_ANSI_ARGS_(( Display *, Window, Window, int, int, unsigned int, unsigned int, int, int )))
#endif
#endif /* !__WIN32__ */
#ifndef XWindowEvent
VFUNC(int,XWindowEvent,V_XWindowEvent,_ANSI_ARGS_((Display *, Window, long int, XEvent *)))
#endif
#ifndef XWithdrawWindow
VFUNC(int,XWithdrawWindow,V_XWithdrawWindow,_ANSI_ARGS_((Display *, Window, int)))
#endif
#ifndef _XInitImageFuncPtrs
VFUNC(int,_XInitImageFuncPtrs,V__XInitImageFuncPtrs,_ANSI_ARGS_((XImage *image)))
#endif
#endif /* _XLIB */
