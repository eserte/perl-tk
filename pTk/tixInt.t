#ifdef _TIXINT
#ifndef TixDItemGetAnchor
VFUNC(void,TixDItemGetAnchor,V_TixDItemGetAnchor,_ANSI_ARGS_((Tk_Anchor anchor,
			    int x, int y, int cav_w, int cav_h,
			    int width, int height, int * x_ret, int * y_ret)))
#endif
#ifndef TixDItemStyleChanged
VFUNC(void,TixDItemStyleChanged,V_TixDItemStyleChanged,_ANSI_ARGS_((
			    Tix_DItemInfo * diTypePtr,
			    Tix_DItemStyle * stylePtr)))
#endif
#ifndef TixDItemStyleFree
VFUNC(void,TixDItemStyleFree,V_TixDItemStyleFree,_ANSI_ARGS_((Tix_DItem *iPtr, 
			    Tix_DItemStyle * stylePtr)))
#endif
#ifndef TixGetColorDItemGC
VFUNC(void,TixGetColorDItemGC,V_TixGetColorDItemGC,_ANSI_ARGS_((
			    Tix_DItem * iPtr, GC * backGC_ret,
			    GC * foreGC_ret, int flags)))
#endif
#ifndef TixGetDefaultDItemStyle
VFUNC(Tix_DItemStyle*,TixGetDefaultDItemStyle,V_TixGetDefaultDItemStyle,_ANSI_ARGS_((
			    Tix_DispData * ddPtr, Tix_DItemInfo * diTypePtr,
			    Tix_DItem *iPtr, Tix_DItemStyle* oldStylePtr)))
#endif
#ifndef Tix_AddDItemType
VFUNC(void,Tix_AddDItemType,V_Tix_AddDItemType,_ANSI_ARGS_((
			    Tix_DItemInfo * diTypePtr)))
#endif
#ifndef Tix_ConfigureInfo2
VFUNC(int,Tix_ConfigureInfo2,V_Tix_ConfigureInfo2,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin,
			    char *entRec, Tk_ConfigSpec *entConfigSpecs,
			    Tix_DItem * iPtr, char *argvName, int flags)))
#endif
#ifndef Tix_DItemCalculateSize
VFUNC(void,Tix_DItemCalculateSize,V_Tix_DItemCalculateSize,_ANSI_ARGS_((
			    Tix_DItem * iPtr)))
#endif
#ifndef Tix_DItemConfigure
VFUNC(int,Tix_DItemConfigure,V_Tix_DItemConfigure,_ANSI_ARGS_((
			    Tix_DItem * diPtr, int argc,
			    Arg *args, int flags)))
#endif
#ifndef Tix_DItemCreate
VFUNC(Tix_DItem *,Tix_DItemCreate,V_Tix_DItemCreate,_ANSI_ARGS_((Tix_DispData * ddPtr,
			    char * type)))
#endif
#ifndef Tix_DItemDisplay
VFUNC(void,Tix_DItemDisplay,V_Tix_DItemDisplay,_ANSI_ARGS_((
			    Pixmap pixmap, GC gc, Tix_DItem * iPtr,
			    int x, int y, int width, int height, int flag)))
#endif
#ifndef Tix_DItemFree
VFUNC(void,Tix_DItemFree,V_Tix_DItemFree,_ANSI_ARGS_((
			    Tix_DItem * iPtr)))
#endif
#ifndef Tix_GetDItemType
VFUNC(Tix_DItemInfo *,Tix_GetDItemType,V_Tix_GetDItemType,_ANSI_ARGS_((
			    Tcl_Interp * interp, char *type)))
#endif
#ifndef Tix_MultiConfigureInfo
VFUNC(int,Tix_MultiConfigureInfo,V_Tix_MultiConfigureInfo,_ANSI_ARGS_((
			    Tcl_Interp * interp,
			    Tk_Window tkwin, Tk_ConfigSpec **specsList,
			    int numLists, char **widgRecList, char *argvName,
			    int flags, int request)))
#endif
#ifndef Tix_SetDefaultStyleTemplate
VFUNC(void,Tix_SetDefaultStyleTemplate,V_Tix_SetDefaultStyleTemplate,_ANSI_ARGS_((
			    Tk_Window tkwin, Tix_StyleTemplate * tmplPtr)))
#endif
#ifndef Tix_SetWindowItemSerial
VFUNC(void,Tix_SetWindowItemSerial,V_Tix_SetWindowItemSerial,_ANSI_ARGS_((
			    Tix_LinkList * lPtr, Tix_DItem * iPtr,
			    ClientData clientData, int serial)))
#endif
#ifndef Tix_SplitConfig
VFUNC(int,Tix_SplitConfig,V_Tix_SplitConfig,_ANSI_ARGS_((Tcl_Interp * interp,
			    Tk_Window tkwin, Tk_ConfigSpec  ** specsList,
			    int numLists, int argc, Arg *args,
			    Tix_ArgumentList * argListPtr)))
#endif
#ifndef Tix_UnmapInvisibleWindowItems
VFUNC(void,Tix_UnmapInvisibleWindowItems,V_Tix_UnmapInvisibleWindowItems,_ANSI_ARGS_((
			    Tix_LinkList * lPtr, int serial)))
#endif
#ifndef Tix_WidgetConfigure2
VFUNC(int,Tix_WidgetConfigure2,V_Tix_WidgetConfigure2,_ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin, char * entRec,
			    Tk_ConfigSpec *entConfigSpecs,
			    Tix_DItem * iPtr, int argc, Arg *args,
			    int flags, int forced, int * sizeChanged_ret)))
#endif
#ifndef Tix_WindowItemListRemove
VFUNC(void,Tix_WindowItemListRemove,V_Tix_WindowItemListRemove,_ANSI_ARGS_((
			    Tix_LinkList * lPtr, Tix_DItem * iPtr)))
#endif
#endif /* _TIXINT */
