*** ../Tk/../tk4.0b3/tkInt.h	Fri Mar 17 19:22:35 1995
--- ../mTk.save/tkInt.h	Tue Mar 28 14:47:34 1995
***************
*** 25,32 ****
  #ifndef _TK
  #include "tk.h"
  #endif
! #ifndef _TCL
! #include "tcl.h"
  #endif
  
  /*
--- 25,32 ----
  #ifndef _TK
  #include "tk.h"
  #endif
! #ifndef _LANG
! #include "Lang.h"
  #endif
  
  /*
***************
*** 476,482 ****
  				/* First in list of handlers for
  				 * returning the selection in various
  				 * forms. */
- 
      /*
       * Information used by tkGeometry.c for geometry management.
       */
--- 476,481 ----
***************
*** 550,563 ****
   * to the outside world:
   */
  
  extern Tk_Uid			tkActiveUid;
- extern Tk_ImageType		tkBitmapImageType;
- extern void			(*tkDelayedEventProc) _ANSI_ARGS_((void));
  extern Tk_Uid			tkDisabledUid;
- extern Tk_PhotoImageFormat	tkImgFmtPPM;
- extern TkMainInfo		*tkMainWindowList;
  extern Tk_Uid			tkNormalUid;
! extern Tk_ImageType		tkPhotoImageType;
  extern int			tkSendSerial;
  
  /*
--- 549,562 ----
   * to the outside world:
   */
  
+ typedef void TkDelayedEventProc _ANSI_ARGS_((void));
+ 
+ 
  extern Tk_Uid			tkActiveUid;
  extern Tk_Uid			tkDisabledUid;
  extern Tk_Uid			tkNormalUid;
! extern TkMainInfo		*tkMainWindowList;
! extern TkDelayedEventProc	*tkDelayedEventProc;
  extern int			tkSendSerial;
  
  /*
***************
*** 565,593 ****
   * to the outside world:
   */
  
- extern int		TkAreaToPolygon _ANSI_ARGS_((double *polyPtr,
- 			    int numPoints, double *rectPtr));
- extern void		TkBezierPoints _ANSI_ARGS_((double control[],
- 			    int numSteps, double *coordPtr));
- extern void		TkBezierScreenPoints _ANSI_ARGS_((Tk_Canvas canvas,
- 			    double control[], int numSteps,
- 			    XPoint *xPointPtr));
  extern void		TkBindEventProc _ANSI_ARGS_((TkWindow *winPtr,
  			    XEvent *eventPtr));
! extern int		TkClipInit _ANSI_ARGS_((Tcl_Interp *interp,
  			    TkDisplay *dispPtr));
  extern int		TkCmapStressed _ANSI_ARGS_((Tk_Window tkwin,
  			    Colormap colormap));
  extern void		TkComputeTextGeometry _ANSI_ARGS_((
  			    XFontStruct *fontStructPtr, char *string,
  			    int numChars, int wrapLength, int *widthPtr,
  			    int *heightPtr));
- extern int		TkCopyAndGlobalEval _ANSI_ARGS_((Tcl_Interp *interp,
- 			    char *script));
  extern Time		TkCurrentTime _ANSI_ARGS_((TkDisplay *dispPtr));
- extern int		TkDeadAppCmd _ANSI_ARGS_((ClientData clientData,
- 			    Tcl_Interp *interp, int argc, char **argv));
- extern void		TkDeleteAllImages _ANSI_ARGS_((TkMainInfo *mainPtr));
  extern void		TkDisplayChars _ANSI_ARGS_((Display *display,
  			    Drawable drawable, GC gc,
  			    XFontStruct *fontStructPtr, char *string,
--- 564,582 ----
   * to the outside world:
   */
  
  extern void		TkBindEventProc _ANSI_ARGS_((TkWindow *winPtr,
  			    XEvent *eventPtr));
! #ifndef NO_COREXT
! COREXT int		TkClipInit _ANSI_ARGS_((Tcl_Interp *interp,
  			    TkDisplay *dispPtr));
+ #endif
  extern int		TkCmapStressed _ANSI_ARGS_((Tk_Window tkwin,
  			    Colormap colormap));
  extern void		TkComputeTextGeometry _ANSI_ARGS_((
  			    XFontStruct *fontStructPtr, char *string,
  			    int numChars, int wrapLength, int *widthPtr,
  			    int *heightPtr));
  extern Time		TkCurrentTime _ANSI_ARGS_((TkDisplay *dispPtr));
  extern void		TkDisplayChars _ANSI_ARGS_((Display *display,
  			    Drawable drawable, GC gc,
  			    XFontStruct *fontStructPtr, char *string,
***************
*** 598,662 ****
  			    char *string, int numChars, int x, int y,
  			    int length, Tk_Justify justify, int underline,
  			    GC gc));
! extern void		TkEventCleanupProc _ANSI_ARGS_((
  			    ClientData clientData, Tcl_Interp *interp));
! extern void		TkEventDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
! extern void		TkFillPolygon _ANSI_ARGS_((Tk_Canvas canvas,
! 			    double *coordPtr, int numPoints, Display *display,
! 			    Drawable drawable, GC gc, GC outlineGC));
! extern void		TkFocusDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkFocusFilterEvent _ANSI_ARGS_((TkWindow *winPtr,
  			    XEvent *eventPtr));
! extern void		TkFreeBindingTags _ANSI_ARGS_((TkWindow *winPtr));
! extern void		TkGetButtPoints _ANSI_ARGS_((double p1[], double p2[],
! 			    double width, int project, double m1[],
! 			    double m2[]));
  extern TkDisplay *	TkGetDisplay _ANSI_ARGS_((Display *display));
  extern TkWindow *	TkGetFocus _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkGetInterpNames _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin));
- extern int		TkGetMiterPoints _ANSI_ARGS_((double p1[], double p2[],
- 			    double p3[], double width, double m1[],
- 			    double m2[]));
- extern void		TkGrabDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkGrabTriggerProc _ANSI_ARGS_((XEvent *eventPtr));
! extern void		TkIncludePoint _ANSI_ARGS_((Tk_Item *itemPtr,
! 			    double *pointPtr));
! extern char *		TkInitFrame _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, int toplevel, int argc,
  			    char *argv[]));
! extern void		TkInitXId _ANSI_ARGS_((TkDisplay *dispPtr));
  extern void		TkInOutEvents _ANSI_ARGS_((XEvent *eventPtr,
  			    TkWindow *sourcePtr, TkWindow *destPtr,
  			    int leaveType, int EnterType));
- extern int		TkLineToArea _ANSI_ARGS_((double end1Ptr[2],
- 			    double end2Ptr[2], double rectPtr[4]));
- extern double		TkLineToPoint _ANSI_ARGS_((double end1Ptr[2],
- 			    double end2Ptr[2], double pointPtr[2]));
- extern int		TkMakeBezierCurve _ANSI_ARGS_((Tk_Canvas canvas,
- 			    double *pointPtr, int numPoints, int numSteps,
- 			    XPoint xPoints[], double dblPoints[]));
- extern void		TkMakeBezierPostscript _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, double *pointPtr,
- 			    int numPoints));
  extern int		TkMeasureChars _ANSI_ARGS_((XFontStruct *fontStructPtr,
  			    char *source, int maxChars, int startX, int maxX,
  			    int tabOrigin, int flags, int *nextXPtr));
  extern void		TkOptionClassChanged _ANSI_ARGS_((TkWindow *winPtr));
- extern void		TkOptionDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
- extern int		TkOvalToArea _ANSI_ARGS_((double *ovalPtr,
- 			    double *rectPtr));
- extern double		TkOvalToPoint _ANSI_ARGS_((double ovalPtr[4],
- 			    double width, int filled, double pointPtr[2]));
  extern int		TkPointerEvent _ANSI_ARGS_((XEvent *eventPtr,
  			    TkWindow *winPtr));
- extern int		TkPolygonToArea _ANSI_ARGS_((double *polyPtr,
- 			    int numPoints, double *rectPtr));
- extern double		TkPolygonToPoint _ANSI_ARGS_((double *polyPtr,
- 			    int numPoints, double *pointPtr));
  extern void		TkQueueEvent _ANSI_ARGS_((TkDisplay *dispPtr,
  			    XEvent *eventPtr));
- extern void		TkSelDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkSelEventProc _ANSI_ARGS_((Tk_Window tkwin,
  			    XEvent *eventPtr));
  extern void		TkSelInit _ANSI_ARGS_((Tk_Window tkwin));
--- 587,619 ----
  			    char *string, int numChars, int x, int y,
  			    int length, Tk_Justify justify, int underline,
  			    GC gc));
! COREXT void		TkEventCleanupProc _ANSI_ARGS_((
  			    ClientData clientData, Tcl_Interp *interp));
! COREXT void		TkEventDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
! COREXT void		TkFocusDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkFocusFilterEvent _ANSI_ARGS_((TkWindow *winPtr,
  			    XEvent *eventPtr));
! COREXT void		TkFreeBindingTags _ANSI_ARGS_((TkWindow *winPtr));
  extern TkDisplay *	TkGetDisplay _ANSI_ARGS_((Display *display));
  extern TkWindow *	TkGetFocus _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkGetInterpNames _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin));
  extern void		TkGrabTriggerProc _ANSI_ARGS_((XEvent *eventPtr));
! COREXT char *		TkInitFrame _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, int toplevel, int argc,
  			    char *argv[]));
! COREXT void		TkInitXId _ANSI_ARGS_((TkDisplay *dispPtr));
  extern void		TkInOutEvents _ANSI_ARGS_((XEvent *eventPtr,
  			    TkWindow *sourcePtr, TkWindow *destPtr,
  			    int leaveType, int EnterType));
  extern int		TkMeasureChars _ANSI_ARGS_((XFontStruct *fontStructPtr,
  			    char *source, int maxChars, int startX, int maxX,
  			    int tabOrigin, int flags, int *nextXPtr));
  extern void		TkOptionClassChanged _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkPointerEvent _ANSI_ARGS_((XEvent *eventPtr,
  			    TkWindow *winPtr));
  extern void		TkQueueEvent _ANSI_ARGS_((TkDisplay *dispPtr,
  			    XEvent *eventPtr));
  extern void		TkSelEventProc _ANSI_ARGS_((Tk_Window tkwin,
  			    XEvent *eventPtr));
  extern void		TkSelInit _ANSI_ARGS_((Tk_Window tkwin));
***************
*** 668,674 ****
  			    int firstChar, int lastChar));
  extern void		TkWmAddToColormapWindows _ANSI_ARGS_((
  			    TkWindow *winPtr));
! extern void		TkWmDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmMapWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmNewWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmProtocolEventProc _ANSI_ARGS_((TkWindow *winPtr,
--- 625,631 ----
  			    int firstChar, int lastChar));
  extern void		TkWmAddToColormapWindows _ANSI_ARGS_((
  			    TkWindow *winPtr));
! COREXT void		TkWmDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmMapWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmNewWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern void		TkWmProtocolEventProc _ANSI_ARGS_((TkWindow *winPtr,
***************
*** 679,683 ****
--- 636,652 ----
  extern void		TkWmUnmapWindow _ANSI_ARGS_((TkWindow *winPtr));
  extern int		TkXFileProc _ANSI_ARGS_((ClientData clientData,
  			    int mask, int flags));
+ 
+ #ifndef NO_COREXT
+ COREXT Tk_ImageType		tkBitmapImageType;
+ COREXT Tk_ImageType		tkPixmapImageType;
+ COREXT Tk_ImageType		tkPhotoImageType;
+ COREXT int		TkDeadAppCmd _ANSI_ARGS_((ClientData clientData,
+ 			    Tcl_Interp *interp, int argc, char **argv));
+ COREXT void		TkDeleteAllImages _ANSI_ARGS_((TkMainInfo *mainPtr));
+ COREXT void		TkGrabDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
+ COREXT void		TkOptionDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
+ COREXT void		TkSelDeadWindow _ANSI_ARGS_((TkWindow *winPtr));
+ #endif
  
  #endif  /* _TKINT */
