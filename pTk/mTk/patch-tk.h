*** /home/isp/nick/tcl/tk4.0b3/tk.h	Sat Mar 18 00:02:18 1995
--- ../mTk.save/tk.h	Tue Mar 28 16:46:16 1995
***************
*** 21,32 ****
  #define TK_MAJOR_VERSION 4
  #define TK_MINOR_VERSION 0
  
- #ifndef _TCL
- #include <tcl.h>
- #endif
  #ifndef _XLIB_H
  #include <X11/Xlib.h>
  #endif
  #ifdef __STDC__
  #include <stddef.h>
  #endif
--- 21,32 ----
  #define TK_MAJOR_VERSION 4
  #define TK_MINOR_VERSION 0
  
  #ifndef _XLIB_H
  #include <X11/Xlib.h>
  #endif
+ #ifndef _LANG
+ #include "Lang.h"
+ #endif
  #ifdef __STDC__
  #include <stddef.h>
  #endif
***************
*** 44,50 ****
   */
  
  typedef struct Tk_BindingTable_ *Tk_BindingTable;
- typedef struct Tk_Canvas_ *Tk_Canvas;
  typedef struct Tk_ErrorHandler_ *Tk_ErrorHandler;
  typedef struct Tk_Image__ *Tk_Image;
  typedef struct Tk_ImageMaster_ *Tk_ImageMaster;
--- 44,49 ----
***************
*** 108,116 ****
   */
  
  typedef int (Tk_OptionParseProc) _ANSI_ARGS_((ClientData clientData,
! 	Tcl_Interp *interp, Tk_Window tkwin, char *value, char *widgRec,
  	int offset));
! typedef char *(Tk_OptionPrintProc) _ANSI_ARGS_((ClientData clientData,
  	Tk_Window tkwin, char *widgRec, int offset,
  	Tcl_FreeProc **freeProcPtr));
  
--- 107,115 ----
   */
  
  typedef int (Tk_OptionParseProc) _ANSI_ARGS_((ClientData clientData,
! 	Tcl_Interp *interp, Tk_Window tkwin, Arg value, char *widgRec,
  	int offset));
! typedef Arg (Tk_OptionPrintProc) _ANSI_ARGS_((ClientData clientData,
  	Tk_Window tkwin, char *widgRec, int offset,
  	Tcl_FreeProc **freeProcPtr));
  
***************
*** 181,187 ****
  #define TK_CONFIG_MM		19
  #define TK_CONFIG_WINDOW	20
  #define TK_CONFIG_CUSTOM	21
! #define TK_CONFIG_END		22
  
  /*
   * Macro to use to fill in "offset" fields of Tk_ConfigInfos.
--- 180,192 ----
  #define TK_CONFIG_MM		19
  #define TK_CONFIG_WINDOW	20
  #define TK_CONFIG_CUSTOM	21
! #define TK_CONFIG_CALLBACK	22
! #define TK_CONFIG_LANGARG	23
! #define TK_CONFIG_SCALARVAR	24
! #define TK_CONFIG_HASHVAR	25
! #define TK_CONFIG_ARRAYVAR	26
! #define TK_CONFIG_IMAGE		27
! #define TK_CONFIG_END		28
  
  /*
   * Macro to use to fill in "offset" fields of Tk_ConfigInfos.
***************
*** 448,652 ****
  /*
   *--------------------------------------------------------------
   *
-  * Procedure prototypes and structures used for defining new canvas
-  * items:
-  *
-  *--------------------------------------------------------------
-  */
- 
- /*
-  * For each item in a canvas widget there exists one record with
-  * the following structure.  Each actual item is represented by
-  * a record with the following stuff at its beginning, plus additional
-  * type-specific stuff after that.
-  */
- 
- #define TK_TAG_SPACE 3
- 
- typedef struct Tk_Item  {
-     int id;				/* Unique identifier for this item
- 					 * (also serves as first tag for
- 					 * item). */
-     struct Tk_Item *nextPtr;		/* Next in display list of all
- 					 * items in this canvas.  Later items
- 					 * in list are drawn on top of earlier
- 					 * ones. */
-     Tk_Uid staticTagSpace[TK_TAG_SPACE];/* Built-in space for limited # of
- 					 * tags. */
-     Tk_Uid *tagPtr;			/* Pointer to array of tags.  Usually
- 					 * points to staticTagSpace, but
- 					 * may point to malloc-ed space if
- 					 * there are lots of tags. */
-     int tagSpace;			/* Total amount of tag space available
- 					 * at tagPtr. */
-     int numTags;			/* Number of tag slots actually used
- 					 * at *tagPtr. */
-     struct Tk_ItemType *typePtr;	/* Table of procedures that implement
- 					 * this type of item. */
-     int x1, y1, x2, y2;			/* Bounding box for item, in integer
- 					 * canvas units. Set by item-specific
- 					 * code and guaranteed to contain every
- 					 * pixel drawn in item.  Item area
- 					 * includes x1 and y1 but not x2
- 					 * and y2. */
- 
-     /*
-      *------------------------------------------------------------------
-      * Starting here is additional type-specific stuff;  see the
-      * declarations for individual types to see what is part of
-      * each type.  The actual space below is determined by the
-      * "itemInfoSize" of the type's Tk_ItemType record.
-      *------------------------------------------------------------------
-      */
- } Tk_Item;
- 
- /*
-  * Records of the following type are used to describe a type of
-  * item (e.g.  lines, circles, etc.) that can form part of a
-  * canvas widget.
-  */
- 
- typedef int	Tk_ItemCreateProc _ANSI_ARGS_((Tcl_Interp *interp,
- 		    Tk_Canvas canvas, Tk_Item *itemPtr, int argc,
- 		    char **argv));
- typedef int	Tk_ItemConfigureProc _ANSI_ARGS_((Tcl_Interp *interp,
- 		    Tk_Canvas canvas, Tk_Item *itemPtr, int argc,
- 		    char **argv, int flags));
- typedef int	Tk_ItemCoordProc _ANSI_ARGS_((Tcl_Interp *interp,
- 		    Tk_Canvas canvas, Tk_Item *itemPtr, int argc,
- 		    char **argv));
- typedef void	Tk_ItemDeleteProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, Display *display));
- typedef void	Tk_ItemDisplayProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, Display *display, Drawable dst,
- 		    int x, int y, int width, int height));
- typedef double	Tk_ItemPointProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, double *pointPtr));
- typedef int	Tk_ItemAreaProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, double *rectPtr));
- typedef int	Tk_ItemPostscriptProc _ANSI_ARGS_((Tcl_Interp *interp,
- 		    Tk_Canvas canvas, Tk_Item *itemPtr, int prepass));
- typedef void	Tk_ItemScaleProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, double originX, double originY,
- 		    double scaleX, double scaleY));
- typedef void	Tk_ItemTranslateProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, double deltaX, double deltaY));
- typedef int	Tk_ItemIndexProc _ANSI_ARGS_((Tcl_Interp *interp,
- 		    Tk_Canvas canvas, Tk_Item *itemPtr, char *indexString,
- 		    int *indexPtr));
- typedef void	Tk_ItemCursorProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, int index));
- typedef int	Tk_ItemSelectionProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, int offset, char *buffer,
- 		    int maxBytes));
- typedef void	Tk_ItemInsertProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, int beforeThis, char *string));
- typedef void	Tk_ItemDCharsProc _ANSI_ARGS_((Tk_Canvas canvas,
- 		    Tk_Item *itemPtr, int first, int last));
- 
- typedef struct Tk_ItemType {
-     char *name;				/* The name of this type of item, such
- 					 * as "line". */
-     int itemSize;			/* Total amount of space needed for
- 					 * item's record. */
-     Tk_ItemCreateProc *createProc;	/* Procedure to create a new item of
- 					 * this type. */
-     Tk_ConfigSpec *configSpecs;		/* Pointer to array of configuration
- 					 * specs for this type.  Used for
- 					 * returning configuration info. */
-     Tk_ItemConfigureProc *configProc;	/* Procedure to call to change
- 					 * configuration options. */
-     Tk_ItemCoordProc *coordProc;	/* Procedure to call to get and set
- 					 * the item's coordinates. */
-     Tk_ItemDeleteProc *deleteProc;	/* Procedure to delete existing item of
- 					 * this type. */
-     Tk_ItemDisplayProc *displayProc;	/* Procedure to display items of
- 					 * this type. */
-     int alwaysRedraw;			/* Non-zero means displayProc should
- 					 * be called even when the item has
- 					 * been moved off-screen. */
-     Tk_ItemPointProc *pointProc;	/* Computes distance from item to
- 					 * a given point. */
-     Tk_ItemAreaProc *areaProc;		/* Computes whether item is inside,
- 					 * outside, or overlapping an area. */
-     Tk_ItemPostscriptProc *postscriptProc;
- 					/* Procedure to write a Postscript
- 					 * description for items of this
- 					 * type. */
-     Tk_ItemScaleProc *scaleProc;	/* Procedure to rescale items of
- 					 * this type. */
-     Tk_ItemTranslateProc *translateProc;/* Procedure to translate items of
- 					 * this type. */
-     Tk_ItemIndexProc *indexProc;	/* Procedure to determine index of
- 					 * indicated character.  NULL if
- 					 * item doesn't support indexing. */
-     Tk_ItemCursorProc *icursorProc;	/* Procedure to set insert cursor pos.
- 					 * to just before a given position. */
-     Tk_ItemSelectionProc *selectionProc;/* Procedure to return selection (in
- 					 * STRING format) when it is in this
- 					 * item. */
-     Tk_ItemInsertProc *insertProc;	/* Procedure to insert something into
- 					 * an item. */
-     Tk_ItemDCharsProc *dCharsProc;	/* Procedure to delete characters
- 					 * from an item. */
-     struct Tk_ItemType *nextPtr;	/* Used to link types together into
- 					 * a list. */
- } Tk_ItemType;
- 
- /*
-  * The following declaration is for use in the Tk_ConfigSpec arrays
-  * for canvas items:  it handles the -tags option.
-  */
- 
- EXTERN Tk_CustomOption tk_CanvasTagsOption;
- 
- /*
-  * The following structure provides information about the selection and
-  * the insertion cursor.  It is needed by only a few items, such as
-  * those that display text.  It is shared by the generic canvas code
-  * and the item-specific code, but most of the fields should be written
-  * only by the canvas generic code.
-  */
- 
- typedef struct Tk_CanvasTextInfo {
-     Tk_3DBorder selBorder;	/* Border and background for selected
- 				 * characters.  Read-only to items.*/
-     int selBorderWidth;		/* Width of border around selection. 
- 				 * Read-only to items. */
-     XColor *selFgColorPtr;	/* Foreground color for selected text.
- 				 * Read-only to items. */
-     Tk_Item *selItemPtr;	/* Pointer to selected item.  NULL means
- 				 * selection isn't in this canvas.
- 				 * Writable by items. */
-     int selectFirst;		/* Index of first selected character. 
- 				 * Writable by items. */
-     int selectLast;		/* Index of last selected character. 
- 				 * Writable by items. */
-     Tk_Item *anchorItemPtr;	/* Item corresponding to "selectAnchor":
- 				 * not necessarily selItemPtr.   Read-only
- 				 * to items. */
-     int selectAnchor;		/* Fixed end of selection (i.e. "select to"
- 				 * operation will use this as one end of the
- 				 * selection).  Writable by items. */
-     Tk_3DBorder insertBorder;	/* Used to draw vertical bar for insertion
- 				 * cursor.  Read-only to items. */
-     int insertWidth;		/* Total width of insertion cursor.  Read-only
- 				 * to items. */
-     int insertBorderWidth;	/* Width of 3-D border around insert cursor.
- 				 * Read-only to items. */
-     Tk_Item *focusItemPtr;	/* Item that currently has the input focus,
- 				 * or NULL if no such item.  Read-only to
- 				 * items.  */
-     int gotFocus;		/* Non-zero means that the canvas widget has
- 				 * the input focus.  Read-only to items.*/
-     int cursorOn;		/* Non-zero means that an insertion cursor
- 				 * should be displayed in focusItemPtr.
- 				 * Read-only to items.*/
- } Tk_CanvasTextInfo;
- 
- /*
-  *--------------------------------------------------------------
-  *
   * Procedure prototypes and structures used for managing images:
   *
   *--------------------------------------------------------------
--- 453,458 ----
***************
*** 705,803 ****
  /*
   *--------------------------------------------------------------
   *
-  * Additional definitions used to manage images of type "photo".
-  *
-  *--------------------------------------------------------------
-  */
- 
- /*
-  * The following type is used to identify a particular photo image
-  * to be manipulated:
-  */
- 
- typedef void *Tk_PhotoHandle;
- 
- /*
-  * The following structure describes a block of pixels in memory:
-  */
- 
- typedef struct Tk_PhotoImageBlock {
-     unsigned char *pixelPtr;	/* Pointer to the first pixel. */
-     int		width;		/* Width of block, in pixels. */
-     int		height;		/* Height of block, in pixels. */
-     int		pitch;		/* Address difference between corresponding
- 				 * pixels in successive lines. */
-     int		pixelSize;	/* Address difference between successive
- 				 * pixels in the same line. */
-     int		offset[3];	/* Address differences between the red, green
- 				 * and blue components of the pixel and the
- 				 * pixel as a whole. */
- } Tk_PhotoImageBlock;
- 
- /*
-  * Procedure prototypes and structures used in reading and
-  * writing photo images:
-  */
- 
- typedef struct Tk_PhotoImageFormat Tk_PhotoImageFormat;
- typedef int (Tk_ImageFileMatchProc) _ANSI_ARGS_((FILE *f, char *fileName,
- 	char *formatString, int *widthPtr, int *heightPtr));
- typedef int (Tk_ImageStringMatchProc) _ANSI_ARGS_((char *string,
- 	char *formatString, int *widthPtr, int *heightPtr));
- typedef int (Tk_ImageFileReadProc) _ANSI_ARGS_((Tcl_Interp *interp,
- 	FILE *f, char *fileName, char *formatString, Tk_PhotoHandle imageHandle,
- 	int destX, int destY, int width, int height, int srcX, int srcY));
- typedef int (Tk_ImageStringReadProc) _ANSI_ARGS_((Tcl_Interp *interp,
- 	char *string, char *formatString, Tk_PhotoHandle imageHandle,
- 	int destX, int destY, int width, int height, int srcX, int srcY));
- typedef int (Tk_ImageFileWriteProc) _ANSI_ARGS_((Tcl_Interp *interp,
- 	char *fileName, char *formatString, Tk_PhotoImageBlock *blockPtr));
- typedef int (Tk_ImageStringWriteProc) _ANSI_ARGS_((Tcl_Interp *interp,
- 	Tcl_DString *dataPtr, char *formatString,
- 	Tk_PhotoImageBlock *blockPtr));
- 
- /*
-  * The following structure represents a particular file format for
-  * storing images (e.g., PPM, GIF, JPEG, etc.).  It provides information
-  * to allow image files of that format to be recognized and read into
-  * a photo image.
-  */
- 
- struct Tk_PhotoImageFormat {
-     char *name;			/* Name of image file format */
-     Tk_ImageFileMatchProc *fileMatchProc;
- 				/* Procedure to call to determine whether
- 				 * an image file matches this format. */
-     Tk_ImageStringMatchProc *stringMatchProc;
- 				/* Procedure to call to determine whether
- 				 * the data in a string matches this format. */
-     Tk_ImageFileReadProc *fileReadProc;
- 				/* Procedure to call to read data from
- 				 * an image file into a photo image. */
-     Tk_ImageStringReadProc *stringReadProc;
- 				/* Procedure to call to read data from
- 				 * a string into a photo image. */
-     Tk_ImageFileWriteProc *fileWriteProc;
- 				/* Procedure to call to write data from
- 				 * a photo image to a file. */
-     Tk_ImageStringWriteProc *stringWriteProc;
- 				/* Procedure to call to obtain a string
- 				 * representation of the data in a photo
- 				 * image.*/
-     struct Tk_PhotoImageFormat *nextPtr;
- 				/* Next in list of all photo image formats
- 				 * currently known.  Filled in by Tk, not
- 				 * by image format handler. */
- };
- 
- /*
-  *--------------------------------------------------------------
-  *
   * Additional procedure types defined by Tk.
   *
   *--------------------------------------------------------------
   */
  
  typedef int (Tk_ErrorProc) _ANSI_ARGS_((ClientData clientData,
  	XErrorEvent *errEventPtr));
  typedef void (Tk_EventProc) _ANSI_ARGS_((ClientData clientData,
--- 511,529 ----
  /*
   *--------------------------------------------------------------
   *
   * Additional procedure types defined by Tk.
   *
   *--------------------------------------------------------------
   */
  
+ #define TK_EVENTTYPE_NONE    0
+ #define TK_EVENTTYPE_STRING  1
+ #define TK_EVENTTYPE_NUMBER  2
+ #define TK_EVENTTYPE_WINDOW  3
+ #define TK_EVENTTYPE_ATOM    4
+ #define TK_EVENTTYPE_DISPLAY 5
+ #define TK_EVENTTYPE_DATA    6
+ 
  typedef int (Tk_ErrorProc) _ANSI_ARGS_((ClientData clientData,
  	XErrorEvent *errEventPtr));
  typedef void (Tk_EventProc) _ANSI_ARGS_((ClientData clientData,
***************
*** 810,823 ****
--- 536,563 ----
  	XEvent *eventPtr));
  typedef int (Tk_GetSelProc) _ANSI_ARGS_((ClientData clientData,
  	Tcl_Interp *interp, char *portion));
+ typedef int (Tk_GetXSelProc) _ANSI_ARGS_((ClientData clientData,
+ 	Tcl_Interp *interp, long *portion, int numValues,
+ 	int format, Atom type, Tk_Window tkwin));
  typedef void (Tk_IdleProc) _ANSI_ARGS_((ClientData clientData));
  typedef void (Tk_LostSelProc) _ANSI_ARGS_((ClientData clientData));
  typedef Bool (Tk_RestrictProc) _ANSI_ARGS_((Display *display, XEvent *eventPtr,
  	char *arg));
  typedef int (Tk_SelectionProc) _ANSI_ARGS_((ClientData clientData,
  	int offset, char *buffer, int maxBytes));
+ typedef int (Tk_XSelectionProc) _ANSI_ARGS_((ClientData clientData,
+ 	int offset, long *buffer, int maxBytes, 
+ 	Atom type, Tk_Window tkwin));
  typedef void (Tk_TimerProc) _ANSI_ARGS_((ClientData clientData));
  
+ 
+ typedef struct {
+     char *name;			/* Name of command. */
+     int (*cmdProc) _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp,
+ 	    int argc, char **argv));
+ 				/* Command procedure. */
+ } Tk_Cmd;
+ 
  /*
   *--------------------------------------------------------------
   *
***************
*** 826,831 ****
--- 566,576 ----
   *--------------------------------------------------------------
   */
  
+ 
+ EXTERN char *		Tk_EventInfo _ANSI_ARGS_((int letter, Tk_Window tkwin, XEvent *eventPtr, 
+ 			    KeySym keySym, int *numPtr, int *isNum, int *type, 
+                             int num_size, char *numStorage));
+ 
  EXTERN XColor *		Tk_3DBorderColor _ANSI_ARGS_((Tk_3DBorder border));
  EXTERN GC		Tk_3DBorderGC _ANSI_ARGS_((Tk_Window tkwin,
  			    Tk_3DBorder border, int which));
***************
*** 845,878 ****
  			    ClientData *objectPtr));
  EXTERN void		Tk_CancelIdleCall _ANSI_ARGS_((Tk_IdleProc *idleProc,
  			    ClientData clientData));
- EXTERN void		Tk_CanvasDrawableCoords _ANSI_ARGS_((Tk_Canvas canvas,
- 			    double x, double y, short *drawableXPtr,
- 			    short *drawableYPtr));
- EXTERN void		Tk_CanvasEventuallyRedraw _ANSI_ARGS_((
- 			    Tk_Canvas canvas, int x1, int y1, int x2,
- 			    int y2));
- EXTERN int		Tk_CanvasGetCoord _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, char *string,
- 			    double *doublePtr));
- EXTERN Tk_CanvasTextInfo *Tk_CanvasGetTextInfo _ANSI_ARGS_((Tk_Canvas canvas));
- EXTERN int		Tk_CanvasPsBitmap _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, Pixmap bitmap, int x, int y,
- 			    int width, int height));
- EXTERN int		Tk_CanvasPsColor _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, XColor *colorPtr));
- EXTERN int		Tk_CanvasPsFont _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, XFontStruct *fontStructPtr));
- EXTERN void		Tk_CanvasPsPath _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, double *coordPtr, int numPoints));
- EXTERN int		Tk_CanvasPsStipple _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Canvas canvas, Pixmap bitmap));
- EXTERN double		Tk_CanvasPsY _ANSI_ARGS_((Tk_Canvas canvas, double y));
- EXTERN void		Tk_CanvasSetStippleOrigin _ANSI_ARGS_((
- 			    Tk_Canvas canvas, GC gc));
- EXTERN Tk_Window	Tk_CanvasTkwin _ANSI_ARGS_((Tk_Canvas canvas));
- EXTERN void		Tk_CanvasWindowCoords _ANSI_ARGS_((Tk_Canvas canvas,
- 			    double x, double y, short *screenXPtr,
- 			    short *screenYPtr));
  EXTERN void		Tk_ChangeWindowAttributes _ANSI_ARGS_((Tk_Window tkwin,
  			    unsigned long valueMask,
  			    XSetWindowAttributes *attsPtr));
--- 590,595 ----
***************
*** 899,905 ****
  			    Tk_Window tkwin));
  EXTERN unsigned long	Tk_CreateBinding _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_BindingTable bindingTable, ClientData object,
! 			    char *eventString, char *command, int append));
  EXTERN Tk_BindingTable	Tk_CreateBindingTable _ANSI_ARGS_((Tcl_Interp *interp));
  EXTERN Tk_ErrorHandler	Tk_CreateErrorHandler _ANSI_ARGS_((Display *display,
  			    int errNum, int request, int minorCode,
--- 616,622 ----
  			    Tk_Window tkwin));
  EXTERN unsigned long	Tk_CreateBinding _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_BindingTable bindingTable, ClientData object,
! 			    char *eventString, Arg command, int append));
  EXTERN Tk_BindingTable	Tk_CreateBindingTable _ANSI_ARGS_((Tcl_Interp *interp));
  EXTERN Tk_ErrorHandler	Tk_CreateErrorHandler _ANSI_ARGS_((Display *display,
  			    int errNum, int request, int minorCode,
***************
*** 915,930 ****
  			    Tk_GenericProc *proc, ClientData clientData));
  EXTERN void		Tk_CreateImageType _ANSI_ARGS_((
  			    Tk_ImageType *typePtr));
- EXTERN void		Tk_CreateItemType _ANSI_ARGS_((Tk_ItemType *typePtr));
  EXTERN Tk_Window	Tk_CreateMainWindow _ANSI_ARGS_((Tcl_Interp *interp,
  			    char *screenName, char *baseName,
  			    char *className));
- EXTERN void		Tk_CreatePhotoImageFormat _ANSI_ARGS_((
- 			    Tk_PhotoImageFormat *formatPtr));
  EXTERN void		Tk_CreateSelHandler _ANSI_ARGS_((Tk_Window tkwin,
  			    Atom selection, Atom target,
  			    Tk_SelectionProc *proc, ClientData clientData,
  			    Atom format));
  EXTERN Tk_TimerToken	Tk_CreateTimerHandler _ANSI_ARGS_((int milliseconds,
  			    Tk_TimerProc *proc, ClientData clientData));
  EXTERN Tk_Window	Tk_CreateWindow _ANSI_ARGS_((Tcl_Interp *interp,
--- 632,648 ----
  			    Tk_GenericProc *proc, ClientData clientData));
  EXTERN void		Tk_CreateImageType _ANSI_ARGS_((
  			    Tk_ImageType *typePtr));
  EXTERN Tk_Window	Tk_CreateMainWindow _ANSI_ARGS_((Tcl_Interp *interp,
  			    char *screenName, char *baseName,
  			    char *className));
  EXTERN void		Tk_CreateSelHandler _ANSI_ARGS_((Tk_Window tkwin,
  			    Atom selection, Atom target,
  			    Tk_SelectionProc *proc, ClientData clientData,
  			    Atom format));
+ EXTERN void		Tk_CreateXSelHandler _ANSI_ARGS_((Tk_Window tkwin,
+ 			    Atom selection, Atom target,
+ 			    Tk_XSelectionProc *proc, ClientData clientData,
+ 			    Atom format));
  EXTERN Tk_TimerToken	Tk_CreateTimerHandler _ANSI_ARGS_((int milliseconds,
  			    Tk_TimerProc *proc, ClientData clientData));
  EXTERN Tk_Window	Tk_CreateWindow _ANSI_ARGS_((Tcl_Interp *interp,
***************
*** 973,979 ****
  			    int relief));
  EXTERN void		Tk_DrawFocusHighlight _ANSI_ARGS_((Tk_Window tkwin,
  			    GC gc, int width, Drawable drawable));
! EXTERN int		Tk_EventInit _ANSI_ARGS_((Tcl_Interp *interp));
  EXTERN void		Tk_EventuallyFree _ANSI_ARGS_((ClientData clientData,
  			    Tk_FreeProc *freeProc));
  EXTERN void		Tk_Fill3DPolygon _ANSI_ARGS_((Tk_Window tkwin,
--- 691,697 ----
  			    int relief));
  EXTERN void		Tk_DrawFocusHighlight _ANSI_ARGS_((Tk_Window tkwin,
  			    GC gc, int width, Drawable drawable));
! COREXT int		Tk_EventInit _ANSI_ARGS_((Tcl_Interp *interp));
  EXTERN void		Tk_EventuallyFree _ANSI_ARGS_((ClientData clientData,
  			    Tk_FreeProc *freeProc));
  EXTERN void		Tk_Fill3DPolygon _ANSI_ARGS_((Tk_Window tkwin,
***************
*** 984,990 ****
  			    Drawable drawable, Tk_3DBorder border, int x,
  			    int y, int width, int height, int borderWidth,
  			    int relief));
- EXTERN Tk_PhotoHandle	Tk_FindPhoto _ANSI_ARGS_((char *imageName));
  EXTERN void		Tk_Free3DBorder _ANSI_ARGS_((Tk_3DBorder border));
  EXTERN void		Tk_FreeBitmap _ANSI_ARGS_((Display *display,
  			    Pixmap bitmap));
--- 702,707 ----
***************
*** 1014,1020 ****
  			    char *string, Tk_Anchor *anchorPtr));
  EXTERN char *		Tk_GetAtomName _ANSI_ARGS_((Tk_Window tkwin,
  			    Atom atom));
! EXTERN char *		Tk_GetBinding _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_BindingTable bindingTable, ClientData object,
  			    char *eventString));
  EXTERN Pixmap		Tk_GetBitmap _ANSI_ARGS_((Tcl_Interp *interp,
--- 731,737 ----
  			    char *string, Tk_Anchor *anchorPtr));
  EXTERN char *		Tk_GetAtomName _ANSI_ARGS_((Tk_Window tkwin,
  			    Atom atom));
! EXTERN LangCallback *	Tk_GetBinding _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_BindingTable bindingTable, ClientData object,
  			    char *eventString));
  EXTERN Pixmap		Tk_GetBitmap _ANSI_ARGS_((Tcl_Interp *interp,
***************
*** 1031,1037 ****
  EXTERN Colormap		Tk_GetColormap _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, char *string));
  EXTERN Cursor		Tk_GetCursor _ANSI_ARGS_((Tcl_Interp *interp,
! 			    Tk_Window tkwin, Tk_Uid string));
  EXTERN Cursor		Tk_GetCursorFromData _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, char *source, char *mask,
  			    int width, int height, int xHot, int yHot,
--- 748,754 ----
  EXTERN Colormap		Tk_GetColormap _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, char *string));
  EXTERN Cursor		Tk_GetCursor _ANSI_ARGS_((Tcl_Interp *interp,
! 			    Tk_Window tkwin, Arg arg));
  EXTERN Cursor		Tk_GetCursorFromData _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, char *source, char *mask,
  			    int width, int height, int xHot, int yHot,
***************
*** 1044,1050 ****
  			    Tk_Window tkwin, char *name,
  			    Tk_ImageChangedProc *changeProc,
  			    ClientData clientData));
- EXTERN Tk_ItemType *	Tk_GetItemTypes _ANSI_ARGS_((void));
  EXTERN int		Tk_GetJoinStyle _ANSI_ARGS_((Tcl_Interp *interp,
  			    char *string, int *joinPtr));
  EXTERN int		Tk_GetJustify _ANSI_ARGS_((Tcl_Interp *interp,
--- 761,766 ----
***************
*** 1067,1072 ****
--- 783,791 ----
  EXTERN int		Tk_GetSelection _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, Atom selection, Atom target,
  			    Tk_GetSelProc *proc, ClientData clientData));
+ EXTERN int		Tk_GetXSelection _ANSI_ARGS_((Tcl_Interp *interp,
+ 			    Tk_Window tkwin, Atom selection, Atom target,
+ 			    Tk_GetXSelProc *proc, ClientData clientData));
  EXTERN Tk_Uid		Tk_GetUid _ANSI_ARGS_((char *string));
  EXTERN Visual *		Tk_GetVisual _ANSI_ARGS_((Tcl_Interp *interp,
  			    Tk_Window tkwin, char *string, int *depthPtr,
***************
*** 1083,1092 ****
  			    Tk_ImageMaster master, int x, int y,
  			    int width, int height, int imageWidth,
  			    int imageHeight));
- EXTERN int		Tk_Init _ANSI_ARGS_((Tcl_Interp *interp));
  EXTERN Atom		Tk_InternAtom _ANSI_ARGS_((Tk_Window tkwin,
  			    char *name));
- EXTERN void		Tk_Main _ANSI_ARGS_((int argc, char **argv));
  EXTERN void		Tk_MainLoop _ANSI_ARGS_((void));
  EXTERN void		Tk_MaintainGeometry _ANSI_ARGS_((Tk_Window slave,
  			    Tk_Window master, int x, int y, int width,
--- 802,809 ----
***************
*** 1122,1147 ****
  EXTERN void		Tk_OwnSelection _ANSI_ARGS_((Tk_Window tkwin,
  			    Atom selection, Tk_LostSelProc *proc,
  			    ClientData clientData));
- EXTERN int		Tk_ParseArgv _ANSI_ARGS_((Tcl_Interp *interp,
- 			    Tk_Window tkwin, int *argcPtr, char **argv,
- 			    Tk_ArgvInfo *argTable, int flags));
- EXTERN void		Tk_PhotoPutBlock _ANSI_ARGS_((Tk_PhotoHandle handle,
- 			    Tk_PhotoImageBlock *blockPtr, int x, int y,
- 			    int width, int height));
- EXTERN void		Tk_PhotoPutZoomedBlock _ANSI_ARGS_((
- 			    Tk_PhotoHandle handle,
- 			    Tk_PhotoImageBlock *blockPtr, int x, int y,
- 			    int width, int height, int zoomX, int zoomY,
- 			    int decimateX, int decimateY));
- EXTERN int		Tk_PhotoGetImage _ANSI_ARGS_((Tk_PhotoHandle handle,
- 			    Tk_PhotoImageBlock *blockPtr));
- EXTERN void		Tk_PhotoBlank _ANSI_ARGS_((Tk_PhotoHandle handle));
- EXTERN void		Tk_PhotoExpand _ANSI_ARGS_((Tk_PhotoHandle handle,
- 			    int width, int height ));
- EXTERN void		Tk_PhotoGetSize _ANSI_ARGS_((Tk_PhotoHandle handle,
- 			    int *widthPtr, int *heightPtr));
- EXTERN void		Tk_PhotoSetSize _ANSI_ARGS_((Tk_PhotoHandle handle,
- 			    int width, int height));
  EXTERN void		Tk_Preserve _ANSI_ARGS_((ClientData clientData));
  EXTERN void		Tk_RedrawImage _ANSI_ARGS_((Tk_Image image, int imageX,
  			    int imageY, int width, int height,
--- 839,844 ----
***************
*** 1192,1197 ****
--- 889,895 ----
  			    Tk_Window master));
  EXTERN void		Tk_UnmapWindow _ANSI_ARGS_((Tk_Window tkwin));
  EXTERN void		Tk_UnsetGrid _ANSI_ARGS_((Tk_Window tkwin));
+ EXTERN Tk_Window	Tk_EventWindow _ANSI_ARGS_((XEvent *eventPtr));
  
  
  EXTERN int		tk_NumMainWindows;
***************
*** 1200,1278 ****
   * Tcl commands exported by Tk:
   */
  
! EXTERN int		Tk_AfterCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_BellCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_BindCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_BindtagsCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ButtonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_CanvasCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_CheckbuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ClipboardCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_DestroyCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_EntryCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ExitCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_FileeventCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_FrameCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_FocusCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_GrabCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ImageCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_LabelCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ListboxCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_LowerCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_MenuCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_MenubuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_MessageCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_OptionCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_PackCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_PlaceCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_RadiobuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_RaiseCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ScaleCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_ScrollbarCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_SelectionCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_SendCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_TextCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_TkCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_TkwaitCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_UpdateCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_WinfoCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! EXTERN int		Tk_WmCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
  
  #endif /* _TK */
--- 898,1024 ----
   * Tcl commands exported by Tk:
   */
  
! COREXT int		Tk_AfterCmd _ANSI_ARGS_((ClientData clientData,
! 			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_BellCmd _ANSI_ARGS_((ClientData clientData,
! 			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_BindCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_BindtagsCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ButtonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_CanvasCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_CheckbuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ClipboardCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_DestroyCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_EntryCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ExitCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_FileeventCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_FrameCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_FocusCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_GrabCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ImageCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ListboxCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_LowerCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_MenuCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_LabelCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ListboxCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_MenubuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_MessageCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_OptionCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_PackCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_PlaceCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ScaleCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_ScrollbarCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_SelectionCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_RadiobuttonCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_RaiseCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_PropertyCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_SendCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_TextCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_TkCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_TkwaitCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_UpdateCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_WinfoCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
! COREXT int		Tk_WmCmd _ANSI_ARGS_((ClientData clientData,
  			    Tcl_Interp *interp, int argc, char **argv));
+ 
+ EXTERN Tcl_Command	Lang_CreateWidget _ANSI_ARGS_((Tcl_Interp *interp,
+ 			    Tk_Window, Tcl_CmdProc *proc,
+ 			    ClientData clientData,
+ 			    Tcl_CmdDeleteProc *deleteProc));
+ 
+ EXTERN Tcl_Command	Lang_CreateImage _ANSI_ARGS_((Tcl_Interp *interp,
+ 			    char *cmdName, Tcl_CmdProc *proc,
+ 			    ClientData clientData,
+ 			    Tcl_CmdDeleteProc *deleteProc,
+ 			    Tk_ImageType *typePtr));
+ 
+ EXTERN void		Lang_DeleteWidget _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Command cmd));
+ EXTERN void		Lang_DeleteImage  _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Command cmd));
+ EXTERN void		Tk_WidgetResult _ANSI_ARGS_((Tcl_Interp *interp, Tk_Window));
+ EXTERN void		Tk_ImageResult _ANSI_ARGS_((Tcl_Interp *interp, char *));
+ 
+ EXTERN void		LangSetWidget _ANSI_ARGS_((Tcl_Interp *interp,Arg *, Tk_Window));
+ EXTERN void		LangSetImage  _ANSI_ARGS_((Tcl_Interp *interp,Arg *, char *));
+ 
+ EXTERN void		Tk_ChangeScreen _ANSI_ARGS_((Tcl_Interp *interp,
+ 			    char *dispName, int screenIndex));
+ 
+ EXTERN void		Tk_AppendWidget _ANSI_ARGS_((Tcl_Interp *interp, Tk_Window));
+ EXTERN void		Tk_AppendImage  _ANSI_ARGS_((Tcl_Interp *interp, char *));
+ 
+ EXTERN Var LangFindVar _ANSI_ARGS_((Tcl_Interp * interp, Tk_Window, char *name));
+ 
+ EXTERN void		Tk_DeadCommands _ANSI_ARGS_((Tcl_Interp *interp, Tk_Cmd *cmdPtr));
+ EXTERN void		Tk_EnterCommands _ANSI_ARGS_((Tcl_Interp *interp, ClientData clientData,
+ 			    Tk_Cmd *cmdPtr));
+ 
+ #ifndef NO_COREXT
+ COREXT int		Tk_ParseArgv _ANSI_ARGS_((Tcl_Interp *interp,
+ 			    Tk_Window tkwin, int *argcPtr, char **argv,
+ 			    Tk_ArgvInfo *argTable, int flags));
+ 
+ 
+ COREXT void		Tk_DeadMainWindow _ANSI_ARGS_((Tcl_Interp *interp));
+ COREXT void		LangDeadWindow _ANSI_ARGS_((Tcl_Interp *interp, Tk_Window));
+ COREXT void		LangClientMessage _ANSI_ARGS_((Tcl_Interp *interp,Tk_Window, XEvent *));
+ COREXT Tk_Cmd Tk_Widgets[];
+ COREXT Tk_Cmd Tk_Commands[];
+ #endif
  
  #endif /* _TK */
