#ifdef _TK
VVAR(int,tk_NumMainWindows,V_tk_NumMainWindows)
VFUNC(Var,LangFindVar,V_LangFindVar,_ANSI_ARGS_((Tcl_Interp * interp, Tk_Window, char *name)))
VFUNC(Arg,LangObjectArg,V_LangObjectArg,_ANSI_ARGS_((Tcl_Interp *interp, char *)))
VFUNC(Arg,LangWidgetArg,V_LangWidgetArg,_ANSI_ARGS_((Tcl_Interp *interp, Tk_Window)))
VFUNC(Tcl_Command,Lang_CreateImage,V_Lang_CreateImage,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *cmdName, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc,
			    Tk_ImageType *typePtr)))
VFUNC(Tcl_Command,Lang_CreateWidget,V_Lang_CreateWidget,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window, Tcl_CmdProc *proc,
			    ClientData clientData,
			    Tcl_CmdDeleteProc *deleteProc)))
VFUNC(void,Lang_DeleteWidget,V_Lang_DeleteWidget,_ANSI_ARGS_((Tcl_Interp *interp, Tcl_Command cmd)))
VFUNC(int,Tix_ArgcError,V_Tix_ArgcError,_ANSI_ARGS_((Tcl_Interp *interp, 
			    int argc, Arg *args, int prefixCount,
			    char *message)))
VFUNC(XColor *,Tk_3DBorderColor,V_Tk_3DBorderColor,_ANSI_ARGS_((Tk_3DBorder border)))
VFUNC(GC,Tk_3DBorderGC,V_Tk_3DBorderGC,_ANSI_ARGS_((Tk_Window tkwin,
			    Tk_3DBorder border, int which)))
VFUNC(void,Tk_3DHorizontalBevel,V_Tk_3DHorizontalBevel,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int leftIn,
			    int rightIn, int topBevel, int relief)))
VFUNC(void,Tk_3DVerticalBevel,V_Tk_3DVerticalBevel,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int leftBevel,
			    int relief)))
VFUNC(void,Tk_AddOption,V_Tk_AddOption,_ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *value, int priority)))
VFUNC(void,Tk_BackgroundError,V_Tk_BackgroundError,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tk_BindEvent,V_Tk_BindEvent,_ANSI_ARGS_((Tk_BindingTable bindingTable,
			    XEvent *eventPtr, Tk_Window tkwin, int numObjects,
			    ClientData *objectPtr)))
VFUNC(void,Tk_CancelIdleCall,V_Tk_CancelIdleCall,_ANSI_ARGS_((Tk_IdleProc *idleProc,
			    ClientData clientData)))
VFUNC(void,Tk_ChangeScreen,V_Tk_ChangeScreen,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *dispName, int screenIndex)))
VFUNC(void,Tk_ChangeWindowAttributes,V_Tk_ChangeWindowAttributes,_ANSI_ARGS_((Tk_Window tkwin,
			    unsigned long valueMask,
			    XSetWindowAttributes *attsPtr)))
VFUNC(void,Tk_ClearSelection,V_Tk_ClearSelection,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom selection)))
VFUNC(int,Tk_ClipboardAppend,V_Tk_ClipboardAppend,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Atom target, Atom format,
			    char* buffer)))
VFUNC(int,Tk_ClipboardClear,V_Tk_ClipboardClear,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin)))
VFUNC(int,Tk_ConfigureInfo,V_Tk_ConfigureInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_ConfigSpec *specs,
			    char *widgRec, char *argvName, int flags)))
VFUNC(int,Tk_ConfigureValue,V_Tk_ConfigureValue,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_ConfigSpec *specs,
			    char *widgRec, char *argvName, int flags)))
VFUNC(int,Tk_ConfigureWidget,V_Tk_ConfigureWidget,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_ConfigSpec *specs,
			    int argc, Arg *args, char *widgRec,
			    int flags)))
VFUNC(void,Tk_ConfigureWindow,V_Tk_ConfigureWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    unsigned int valueMask, XWindowChanges *valuePtr)))
VFUNC(Tk_Window,Tk_CoordsToWindow,V_Tk_CoordsToWindow,_ANSI_ARGS_((int rootX, int rootY,
			    Tk_Window tkwin)))
VFUNC(unsigned long,Tk_CreateBinding,V_Tk_CreateBinding,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_BindingTable bindingTable, ClientData object,
			    char *eventString, Arg command, int append)))
VFUNC(Tk_BindingTable,Tk_CreateBindingTable,V_Tk_CreateBindingTable,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(Tk_ErrorHandler,Tk_CreateErrorHandler,V_Tk_CreateErrorHandler,_ANSI_ARGS_((Display *display,
			    int errNum, int request, int minorCode,
			    Tk_ErrorProc *errorProc, ClientData clientData)))
VFUNC(void,Tk_CreateEventHandler,V_Tk_CreateEventHandler,_ANSI_ARGS_((Tk_Window token,
			    unsigned long mask, Tk_EventProc *proc,
			    ClientData clientData)))
VFUNC(void,Tk_CreateFileHandler,V_Tk_CreateFileHandler,_ANSI_ARGS_((int fd, int mask,
			    Tk_FileProc *proc, ClientData clientData)))
VFUNC(void,Tk_CreateFileHandler2,V_Tk_CreateFileHandler2,_ANSI_ARGS_((int fd,
			    Tk_FileProc2 *proc, ClientData clientData)))
VFUNC(void,Tk_CreateGenericHandler,V_Tk_CreateGenericHandler,_ANSI_ARGS_((
			    Tk_GenericProc *proc, ClientData clientData)))
VFUNC(void,Tk_CreateImageType,V_Tk_CreateImageType,_ANSI_ARGS_((
			    Tk_ImageType *typePtr)))
VFUNC(Tk_Window,Tk_CreateMainWindow,V_Tk_CreateMainWindow,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *screenName, char *baseName,
			    char *className)))
VFUNC(void,Tk_CreateSelHandler,V_Tk_CreateSelHandler,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom selection, Atom target,
			    Tk_SelectionProc *proc, ClientData clientData,
			    Atom format)))
VFUNC(Tk_TimerToken,Tk_CreateTimerHandler,V_Tk_CreateTimerHandler,_ANSI_ARGS_((int milliseconds,
			    Tk_TimerProc *proc, ClientData clientData)))
VFUNC(Tk_Window,Tk_CreateWindow,V_Tk_CreateWindow,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window parent, char *name, char *screenName)))
VFUNC(Tk_Window,Tk_CreateWindowFromPath,V_Tk_CreateWindowFromPath,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin,
			    char *pathName, char *screenName)))
VFUNC(void,Tk_CreateXSelHandler,V_Tk_CreateXSelHandler,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom selection, Atom target,
			    Tk_XSelectionProc *proc, ClientData clientData,
			    Atom format)))
VFUNC(int,Tk_DefineBitmap,V_Tk_DefineBitmap,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Uid name, char *source, int width,
			    int height)))
VFUNC(void,Tk_DefineCursor,V_Tk_DefineCursor,_ANSI_ARGS_((Tk_Window window,
			    Cursor cursor)))
VFUNC(void,Tk_DeleteAllBindings,V_Tk_DeleteAllBindings,_ANSI_ARGS_((
			    Tk_BindingTable bindingTable, ClientData object)))
VFUNC(int,Tk_DeleteBinding,V_Tk_DeleteBinding,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_BindingTable bindingTable, ClientData object,
			    char *eventString)))
VFUNC(void,Tk_DeleteBindingTable,V_Tk_DeleteBindingTable,_ANSI_ARGS_((
			    Tk_BindingTable bindingTable)))
VFUNC(void,Tk_DeleteErrorHandler,V_Tk_DeleteErrorHandler,_ANSI_ARGS_((
			    Tk_ErrorHandler handler)))
VFUNC(void,Tk_DeleteEventHandler,V_Tk_DeleteEventHandler,_ANSI_ARGS_((Tk_Window token,
			    unsigned long mask, Tk_EventProc *proc,
			    ClientData clientData)))
VFUNC(void,Tk_DeleteFileHandler,V_Tk_DeleteFileHandler,_ANSI_ARGS_((int fd)))
VFUNC(void,Tk_DeleteGenericHandler,V_Tk_DeleteGenericHandler,_ANSI_ARGS_((
			    Tk_GenericProc *proc, ClientData clientData)))
VFUNC(void,Tk_DeleteImage,V_Tk_DeleteImage,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *name)))
VFUNC(void,Tk_DeleteSelHandler,V_Tk_DeleteSelHandler,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom selection, Atom target)))
VFUNC(void,Tk_DeleteTimerHandler,V_Tk_DeleteTimerHandler,_ANSI_ARGS_((
			    Tk_TimerToken token)))
VFUNC(void,Tk_DestroyWindow,V_Tk_DestroyWindow,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(char *,Tk_DisplayName,V_Tk_DisplayName,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(int,Tk_DoOneEvent,V_Tk_DoOneEvent,_ANSI_ARGS_((int flags)))
VFUNC(void,Tk_DoWhenIdle,V_Tk_DoWhenIdle,_ANSI_ARGS_((Tk_IdleProc *proc,
			    ClientData clientData)))
VFUNC(void,Tk_Draw3DPolygon,V_Tk_Draw3DPolygon,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border,
			    XPoint *pointPtr, int numPoints, int borderWidth,
			    int leftRelief)))
VFUNC(void,Tk_Draw3DRectangle,V_Tk_Draw3DRectangle,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int borderWidth,
			    int relief)))
VFUNC(void,Tk_DrawFocusHighlight,V_Tk_DrawFocusHighlight,_ANSI_ARGS_((Tk_Window tkwin,
			    GC gc, int width, Drawable drawable)))
VFUNC(char *,Tk_EventInfo,V_Tk_EventInfo,_ANSI_ARGS_((int letter, Tk_Window tkwin, XEvent *eventPtr, 
			    KeySym keySym, int *numPtr, int *isNum, int *type, 
                            int num_size, char *numStorage)))
VFUNC(Tk_Window,Tk_EventWindow,V_Tk_EventWindow,_ANSI_ARGS_((XEvent *eventPtr)))
VFUNC(void,Tk_EventuallyFree,V_Tk_EventuallyFree,_ANSI_ARGS_((ClientData clientData,
			    Tk_FreeProc *freeProc)))
VFUNC(void,Tk_Fill3DPolygon,V_Tk_Fill3DPolygon,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border,
			    XPoint *pointPtr, int numPoints, int borderWidth,
			    int leftRelief)))
VFUNC(void,Tk_Fill3DRectangle,V_Tk_Fill3DRectangle,_ANSI_ARGS_((Tk_Window tkwin,
			    Drawable drawable, Tk_3DBorder border, int x,
			    int y, int width, int height, int borderWidth,
			    int relief)))
VFUNC(void,Tk_Free3DBorder,V_Tk_Free3DBorder,_ANSI_ARGS_((Tk_3DBorder border)))
VFUNC(void,Tk_FreeBitmap,V_Tk_FreeBitmap,_ANSI_ARGS_((Display *display,
			    Pixmap bitmap)))
VFUNC(void,Tk_FreeColor,V_Tk_FreeColor,_ANSI_ARGS_((XColor *colorPtr)))
VFUNC(void,Tk_FreeColormap,V_Tk_FreeColormap,_ANSI_ARGS_((Display *display,
			    Colormap colormap)))
VFUNC(void,Tk_FreeCursor,V_Tk_FreeCursor,_ANSI_ARGS_((Display *display,
			    Cursor cursor)))
VFUNC(void,Tk_FreeFontStruct,V_Tk_FreeFontStruct,_ANSI_ARGS_((
			    XFontStruct *fontStructPtr)))
VFUNC(void,Tk_FreeGC,V_Tk_FreeGC,_ANSI_ARGS_((Display *display, GC gc)))
VFUNC(void,Tk_FreeImage,V_Tk_FreeImage,_ANSI_ARGS_((Tk_Image image)))
VFUNC(void,Tk_FreeOptions,V_Tk_FreeOptions,_ANSI_ARGS_((Tk_ConfigSpec *specs,
			    char *widgRec, Display *display, int needFlags)))
VFUNC(void,Tk_FreePixmap,V_Tk_FreePixmap,_ANSI_ARGS_((Display *display,
			    Pixmap pixmap)))
VFUNC(void,Tk_FreeXId,V_Tk_FreeXId,_ANSI_ARGS_((Display *display, XID xid)))
VFUNC(GC,Tk_GCForColor,V_Tk_GCForColor,_ANSI_ARGS_((XColor *colorPtr,
			    Drawable drawable)))
VFUNC(void,Tk_GeometryRequest,V_Tk_GeometryRequest,_ANSI_ARGS_((Tk_Window tkwin,
			    int reqWidth,  int reqHeight)))
VFUNC(Tk_3DBorder,Tk_Get3DBorder,V_Tk_Get3DBorder,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_Uid colorName)))
VFUNC(void,Tk_GetAllBindings,V_Tk_GetAllBindings,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_BindingTable bindingTable, ClientData object)))
VFUNC(int,Tk_GetAnchor,V_Tk_GetAnchor,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tk_Anchor *anchorPtr)))
VFUNC(char *,Tk_GetAtomName,V_Tk_GetAtomName,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom atom)))
VFUNC(LangCallback *,Tk_GetBinding,V_Tk_GetBinding,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_BindingTable bindingTable, ClientData object,
			    char *eventString)))
VFUNC(Pixmap,Tk_GetBitmap,V_Tk_GetBitmap,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_Uid string)))
VFUNC(Pixmap,Tk_GetBitmapFromData,V_Tk_GetBitmapFromData,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *source,
			    int width, int height)))
VFUNC(int,Tk_GetCapStyle,V_Tk_GetCapStyle,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int *capPtr)))
VFUNC(XColor *,Tk_GetColor,V_Tk_GetColor,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_Uid name)))
VFUNC(XColor *,Tk_GetColorByValue,V_Tk_GetColorByValue,_ANSI_ARGS_((Tk_Window tkwin,
			    XColor *colorPtr)))
VFUNC(Colormap,Tk_GetColormap,V_Tk_GetColormap,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *string)))
VFUNC(Cursor,Tk_GetCursor,V_Tk_GetCursor,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Arg arg)))
VFUNC(Cursor,Tk_GetCursorFromData,V_Tk_GetCursorFromData,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *source, char *mask,
			    int width, int height, int xHot, int yHot,
			    Tk_Uid fg, Tk_Uid bg)))
VFUNC(XFontStruct *,Tk_GetFontStruct,V_Tk_GetFontStruct,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Tk_Uid name)))
VFUNC(GC,Tk_GetGC,V_Tk_GetGC,_ANSI_ARGS_((Tk_Window tkwin,
			    unsigned long valueMask, XGCValues *valuePtr)))
VFUNC(Tk_Image,Tk_GetImage,V_Tk_GetImage,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *name,
			    Tk_ImageChangedProc *changeProc,
			    ClientData clientData)))
VFUNC(int,Tk_GetJoinStyle,V_Tk_GetJoinStyle,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, int *joinPtr)))
VFUNC(int,Tk_GetJustify,V_Tk_GetJustify,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, Tk_Justify *justifyPtr)))
VFUNC(Tk_Uid,Tk_GetOption,V_Tk_GetOption,_ANSI_ARGS_((Tk_Window tkwin, char *name,
			    char *className)))
VFUNC(int,Tk_GetPixels,V_Tk_GetPixels,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *string, int *intPtr)))
VFUNC(Pixmap,Tk_GetPixmap,V_Tk_GetPixmap,_ANSI_ARGS_((Display *display, Drawable d,
			    int width, int height, int depth)))
VFUNC(int,Tk_GetRelief,V_Tk_GetRelief,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, int *reliefPtr)))
VFUNC(void,Tk_GetRootCoords,V_Tk_GetRootCoords,_ANSI_ARGS_((Tk_Window tkwin,
			    int *xPtr, int *yPtr)))
VFUNC(int,Tk_GetScreenMM,V_Tk_GetScreenMM,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *string, double *doublePtr)))
VFUNC(int,Tk_GetScrollInfo,V_Tk_GetScrollInfo,_ANSI_ARGS_((Tcl_Interp *interp,
			    int argc, Arg *args, double *dblPtr,
			    int *intPtr)))
VFUNC(int,Tk_GetSelection,V_Tk_GetSelection,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Atom selection, Atom target,
			    Tk_GetSelProc *proc, ClientData clientData)))
VFUNC(Tk_Uid,Tk_GetUid,V_Tk_GetUid,_ANSI_ARGS_((char *string)))
VFUNC(void,Tk_GetVRootGeometry,V_Tk_GetVRootGeometry,_ANSI_ARGS_((Tk_Window tkwin,
			    int *xPtr, int *yPtr, int *widthPtr,
			    int *heightPtr)))
VFUNC(Visual *,Tk_GetVisual,V_Tk_GetVisual,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, char *string, int *depthPtr,
			    Colormap *colormapPtr)))
VFUNC(int,Tk_GetXSelection,V_Tk_GetXSelection,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, Atom selection, Atom target,
			    Tk_GetXSelProc *proc, ClientData clientData)))
VFUNC(int,Tk_Grab,V_Tk_Grab,_ANSI_ARGS_((Tcl_Interp *interp,
			    Tk_Window tkwin, int grabGlobal)))
VFUNC(void,Tk_HandleEvent,V_Tk_HandleEvent,_ANSI_ARGS_((XEvent *eventPtr)))
VFUNC(Tk_Window,Tk_IdToWindow,V_Tk_IdToWindow,_ANSI_ARGS_((Display *display,
			    Window window)))
VFUNC(void,Tk_ImageChanged,V_Tk_ImageChanged,_ANSI_ARGS_((
			    Tk_ImageMaster master, int x, int y,
			    int width, int height, int imageWidth,
			    int imageHeight)))
VFUNC(Atom,Tk_InternAtom,V_Tk_InternAtom,_ANSI_ARGS_((Tk_Window tkwin,
			    char *name)))
VFUNC(void,Tk_MainLoop,V_Tk_MainLoop,_ANSI_ARGS_((void)))
VFUNC(Tk_Window,Tk_MainWindow,V_Tk_MainWindow,_ANSI_ARGS_((Tcl_Interp *interp)))
VFUNC(void,Tk_MaintainGeometry,V_Tk_MaintainGeometry,_ANSI_ARGS_((Tk_Window slave,
			    Tk_Window master, int x, int y, int width,
			    int height)))
VFUNC(void,Tk_MakeWindowExist,V_Tk_MakeWindowExist,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,Tk_ManageGeometry,V_Tk_ManageGeometry,_ANSI_ARGS_((Tk_Window tkwin,
			    Tk_GeomMgr *mgrPtr, ClientData clientData)))
VFUNC(void,Tk_MapWindow,V_Tk_MapWindow,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,Tk_MoveResizeWindow,V_Tk_MoveResizeWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    int x, int y, int width, int height)))
VFUNC(void,Tk_MoveToplevelWindow,V_Tk_MoveToplevelWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    int x, int y)))
VFUNC(void,Tk_MoveWindow,V_Tk_MoveWindow,_ANSI_ARGS_((Tk_Window tkwin, int x,
			    int y)))
VFUNC(char *,Tk_NameOf3DBorder,V_Tk_NameOf3DBorder,_ANSI_ARGS_((Tk_3DBorder border)))
VFUNC(char *,Tk_NameOfAnchor,V_Tk_NameOfAnchor,_ANSI_ARGS_((Tk_Anchor anchor)))
VFUNC(char *,Tk_NameOfBitmap,V_Tk_NameOfBitmap,_ANSI_ARGS_((Display *display,
			    Pixmap bitmap)))
VFUNC(char *,Tk_NameOfCapStyle,V_Tk_NameOfCapStyle,_ANSI_ARGS_((int cap)))
VFUNC(char *,Tk_NameOfColor,V_Tk_NameOfColor,_ANSI_ARGS_((XColor *colorPtr)))
VFUNC(char *,Tk_NameOfCursor,V_Tk_NameOfCursor,_ANSI_ARGS_((Display *display,
			    Cursor cursor)))
VFUNC(char *,Tk_NameOfFontStruct,V_Tk_NameOfFontStruct,_ANSI_ARGS_((
			    XFontStruct *fontStructPtr)))
VFUNC(char *,Tk_NameOfImage,V_Tk_NameOfImage,_ANSI_ARGS_((
			    Tk_ImageMaster imageMaster)))
VFUNC(char *,Tk_NameOfJoinStyle,V_Tk_NameOfJoinStyle,_ANSI_ARGS_((int join)))
VFUNC(char *,Tk_NameOfJustify,V_Tk_NameOfJustify,_ANSI_ARGS_((Tk_Justify justify)))
VFUNC(char *,Tk_NameOfRelief,V_Tk_NameOfRelief,_ANSI_ARGS_((int relief)))
VFUNC(Tk_Window,Tk_NameToWindow,V_Tk_NameToWindow,_ANSI_ARGS_((Tcl_Interp *interp,
			    char *pathName, Tk_Window tkwin)))
VFUNC(void,Tk_OwnSelection,V_Tk_OwnSelection,_ANSI_ARGS_((Tk_Window tkwin,
			    Atom selection, Tk_LostSelProc *proc,
			    ClientData clientData)))
VFUNC(void,Tk_Preserve,V_Tk_Preserve,_ANSI_ARGS_((ClientData clientData)))
VFUNC(void,Tk_RedrawImage,V_Tk_RedrawImage,_ANSI_ARGS_((Tk_Image image, int imageX,
			    int imageY, int width, int height,
			    Drawable drawable, int drawableX, int drawableY)))
VFUNC(void,Tk_Release,V_Tk_Release,_ANSI_ARGS_((ClientData clientData)))
VFUNC(void,Tk_ResizeWindow,V_Tk_ResizeWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    int width, int height)))
VFUNC(int,Tk_RestackWindow,V_Tk_RestackWindow,_ANSI_ARGS_((Tk_Window tkwin,
			    int aboveBelow, Tk_Window other)))
VFUNC(Tk_RestrictProc *,Tk_RestrictEvents,V_Tk_RestrictEvents,_ANSI_ARGS_((Tk_RestrictProc *proc,
			    char *arg, char **prevArgPtr)))
VFUNC(char *,Tk_SetAppName,V_Tk_SetAppName,_ANSI_ARGS_((Tk_Window tkwin,
			    char *name)))
VFUNC(void,Tk_SetBackgroundFromBorder,V_Tk_SetBackgroundFromBorder,_ANSI_ARGS_((
			    Tk_Window tkwin, Tk_3DBorder border)))
VFUNC(void,Tk_SetClass,V_Tk_SetClass,_ANSI_ARGS_((Tk_Window tkwin,
			    char *className)))
VFUNC(void,Tk_SetGrid,V_Tk_SetGrid,_ANSI_ARGS_((Tk_Window tkwin,
			    int reqWidth, int reqHeight, int gridWidth,
			    int gridHeight)))
VFUNC(void,Tk_SetInternalBorder,V_Tk_SetInternalBorder,_ANSI_ARGS_((Tk_Window tkwin,
			    int width)))
VFUNC(void,Tk_SetWindowBackground,V_Tk_SetWindowBackground,_ANSI_ARGS_((Tk_Window tkwin,
			    unsigned long pixel)))
VFUNC(void,Tk_SetWindowBackgroundPixmap,V_Tk_SetWindowBackgroundPixmap,_ANSI_ARGS_((
			    Tk_Window tkwin, Pixmap pixmap)))
VFUNC(void,Tk_SetWindowBorder,V_Tk_SetWindowBorder,_ANSI_ARGS_((Tk_Window tkwin,
			    unsigned long pixel)))
VFUNC(void,Tk_SetWindowBorderPixmap,V_Tk_SetWindowBorderPixmap,_ANSI_ARGS_((Tk_Window tkwin,
			    Pixmap pixmap)))
VFUNC(void,Tk_SetWindowBorderWidth,V_Tk_SetWindowBorderWidth,_ANSI_ARGS_((Tk_Window tkwin,
			    int width)))
VFUNC(void,Tk_SetWindowColormap,V_Tk_SetWindowColormap,_ANSI_ARGS_((Tk_Window tkwin,
			    Colormap colormap)))
VFUNC(int,Tk_SetWindowVisual,V_Tk_SetWindowVisual,_ANSI_ARGS_((Tk_Window tkwin,
			    Visual *visual, int depth,
			    Colormap colormap)))
VFUNC(void,Tk_SizeOfBitmap,V_Tk_SizeOfBitmap,_ANSI_ARGS_((Display *display,
			    Pixmap bitmap, int *widthPtr,
			    int *heightPtr)))
VFUNC(void,Tk_SizeOfImage,V_Tk_SizeOfImage,_ANSI_ARGS_((Tk_Image image,
			    int *widthPtr, int *heightPtr)))
VFUNC(void,Tk_Sleep,V_Tk_Sleep,_ANSI_ARGS_((int ms)))
VFUNC(int,Tk_StrictMotif,V_Tk_StrictMotif,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,Tk_UndefineCursor,V_Tk_UndefineCursor,_ANSI_ARGS_((Tk_Window window)))
VFUNC(void,Tk_Ungrab,V_Tk_Ungrab,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,Tk_UnmaintainGeometry,V_Tk_UnmaintainGeometry,_ANSI_ARGS_((Tk_Window slave,
			    Tk_Window master)))
VFUNC(void,Tk_UnmapWindow,V_Tk_UnmapWindow,_ANSI_ARGS_((Tk_Window tkwin)))
VFUNC(void,Tk_UnsetGrid,V_Tk_UnsetGrid,_ANSI_ARGS_((Tk_Window tkwin)))
#endif /* _TK */
