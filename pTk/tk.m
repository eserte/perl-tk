#ifndef _TK_VM
#define _TK_VM
#include "tk_f.h"
#ifndef NO_VTABLES
#ifndef LangEventCallback
#  define LangEventCallback (*TkVptr->V_LangEventCallback)
#endif

#ifndef LangFindVar
#  define LangFindVar (*TkVptr->V_LangFindVar)
#endif

#ifndef LangFontObj
#  define LangFontObj (*TkVptr->V_LangFontObj)
#endif

#ifndef LangObjectObj
#  define LangObjectObj (*TkVptr->V_LangObjectObj)
#endif

#ifndef LangWidgetObj
#  define LangWidgetObj (*TkVptr->V_LangWidgetObj)
#endif

#ifndef Lang_CreateImage
#  define Lang_CreateImage (*TkVptr->V_Lang_CreateImage)
#endif

#ifndef Lang_CreateWidget
#  define Lang_CreateWidget (*TkVptr->V_Lang_CreateWidget)
#endif

#ifndef Lang_DeleteWidget
#  define Lang_DeleteWidget (*TkVptr->V_Lang_DeleteWidget)
#endif

#ifndef TkOffsetParseProc
#  define TkOffsetParseProc (*TkVptr->V_TkOffsetParseProc)
#endif

#ifndef TkOffsetPrintProc
#  define TkOffsetPrintProc (*TkVptr->V_TkOffsetPrintProc)
#endif

#ifndef TkOrientParseProc
#  define TkOrientParseProc (*TkVptr->V_TkOrientParseProc)
#endif

#ifndef TkOrientPrintProc
#  define TkOrientPrintProc (*TkVptr->V_TkOrientPrintProc)
#endif

#ifndef TkPixelParseProc
#  define TkPixelParseProc (*TkVptr->V_TkPixelParseProc)
#endif

#ifndef TkPixelPrintProc
#  define TkPixelPrintProc (*TkVptr->V_TkPixelPrintProc)
#endif

#ifndef TkStateParseProc
#  define TkStateParseProc (*TkVptr->V_TkStateParseProc)
#endif

#ifndef TkStatePrintProc
#  define TkStatePrintProc (*TkVptr->V_TkStatePrintProc)
#endif

#ifndef TkTileParseProc
#  define TkTileParseProc (*TkVptr->V_TkTileParseProc)
#endif

#ifndef TkTilePrintProc
#  define TkTilePrintProc (*TkVptr->V_TkTilePrintProc)
#endif

#ifndef Tk_3DBorderColor
#  define Tk_3DBorderColor (*TkVptr->V_Tk_3DBorderColor)
#endif

#ifndef Tk_3DBorderGC
#  define Tk_3DBorderGC (*TkVptr->V_Tk_3DBorderGC)
#endif

#ifndef Tk_3DHorizontalBevel
#  define Tk_3DHorizontalBevel (*TkVptr->V_Tk_3DHorizontalBevel)
#endif

#ifndef Tk_3DVerticalBevel
#  define Tk_3DVerticalBevel (*TkVptr->V_Tk_3DVerticalBevel)
#endif

#ifndef Tk_BindEvent
#  define Tk_BindEvent (*TkVptr->V_Tk_BindEvent)
#endif

#ifndef Tk_ChangeScreen
#  define Tk_ChangeScreen (*TkVptr->V_Tk_ChangeScreen)
#endif

#ifndef Tk_ChangeWindowAttributes
#  define Tk_ChangeWindowAttributes (*TkVptr->V_Tk_ChangeWindowAttributes)
#endif

#ifndef Tk_CharBbox
#  define Tk_CharBbox (*TkVptr->V_Tk_CharBbox)
#endif

#ifndef Tk_ClearSelection
#  define Tk_ClearSelection (*TkVptr->V_Tk_ClearSelection)
#endif

#ifndef Tk_ClipboardAppend
#  define Tk_ClipboardAppend (*TkVptr->V_Tk_ClipboardAppend)
#endif

#ifndef Tk_ClipboardClear
#  define Tk_ClipboardClear (*TkVptr->V_Tk_ClipboardClear)
#endif

#ifndef Tk_ComputeTextLayout
#  define Tk_ComputeTextLayout (*TkVptr->V_Tk_ComputeTextLayout)
#endif

#ifndef Tk_ConfigureInfo
#  define Tk_ConfigureInfo (*TkVptr->V_Tk_ConfigureInfo)
#endif

#ifndef Tk_ConfigureValue
#  define Tk_ConfigureValue (*TkVptr->V_Tk_ConfigureValue)
#endif

#ifndef Tk_ConfigureWidget
#  define Tk_ConfigureWidget (*TkVptr->V_Tk_ConfigureWidget)
#endif

#ifndef Tk_ConfigureWindow
#  define Tk_ConfigureWindow (*TkVptr->V_Tk_ConfigureWindow)
#endif

#ifndef Tk_CoordsToWindow
#  define Tk_CoordsToWindow (*TkVptr->V_Tk_CoordsToWindow)
#endif

#ifndef Tk_CreateBinding
#  define Tk_CreateBinding (*TkVptr->V_Tk_CreateBinding)
#endif

#ifndef Tk_CreateBindingTable
#  define Tk_CreateBindingTable (*TkVptr->V_Tk_CreateBindingTable)
#endif

#ifndef Tk_CreateErrorHandler
#  define Tk_CreateErrorHandler (*TkVptr->V_Tk_CreateErrorHandler)
#endif

#ifndef Tk_CreateEventHandler
#  define Tk_CreateEventHandler (*TkVptr->V_Tk_CreateEventHandler)
#endif

#ifndef Tk_CreateGenericHandler
#  define Tk_CreateGenericHandler (*TkVptr->V_Tk_CreateGenericHandler)
#endif

#ifndef Tk_CreateImageType
#  define Tk_CreateImageType (*TkVptr->V_Tk_CreateImageType)
#endif

#ifndef Tk_CreateSelHandler
#  define Tk_CreateSelHandler (*TkVptr->V_Tk_CreateSelHandler)
#endif

#ifndef Tk_CreateWindow
#  define Tk_CreateWindow (*TkVptr->V_Tk_CreateWindow)
#endif

#ifndef Tk_CreateWindowFromPath
#  define Tk_CreateWindowFromPath (*TkVptr->V_Tk_CreateWindowFromPath)
#endif

#ifndef Tk_CreateXSelHandler
#  define Tk_CreateXSelHandler (*TkVptr->V_Tk_CreateXSelHandler)
#endif

#ifndef Tk_DefineBitmap
#  define Tk_DefineBitmap (*TkVptr->V_Tk_DefineBitmap)
#endif

#ifndef Tk_DefineCursor
#  define Tk_DefineCursor (*TkVptr->V_Tk_DefineCursor)
#endif

#ifndef Tk_DeleteAllBindings
#  define Tk_DeleteAllBindings (*TkVptr->V_Tk_DeleteAllBindings)
#endif

#ifndef Tk_DeleteBinding
#  define Tk_DeleteBinding (*TkVptr->V_Tk_DeleteBinding)
#endif

#ifndef Tk_DeleteBindingTable
#  define Tk_DeleteBindingTable (*TkVptr->V_Tk_DeleteBindingTable)
#endif

#ifndef Tk_DeleteErrorHandler
#  define Tk_DeleteErrorHandler (*TkVptr->V_Tk_DeleteErrorHandler)
#endif

#ifndef Tk_DeleteEventHandler
#  define Tk_DeleteEventHandler (*TkVptr->V_Tk_DeleteEventHandler)
#endif

#ifndef Tk_DeleteGenericHandler
#  define Tk_DeleteGenericHandler (*TkVptr->V_Tk_DeleteGenericHandler)
#endif

#ifndef Tk_DeleteImage
#  define Tk_DeleteImage (*TkVptr->V_Tk_DeleteImage)
#endif

#ifndef Tk_DeleteSelHandler
#  define Tk_DeleteSelHandler (*TkVptr->V_Tk_DeleteSelHandler)
#endif

#ifndef Tk_DestroyWindow
#  define Tk_DestroyWindow (*TkVptr->V_Tk_DestroyWindow)
#endif

#ifndef Tk_DisplayName
#  define Tk_DisplayName (*TkVptr->V_Tk_DisplayName)
#endif

#ifndef Tk_DistanceToTextLayout
#  define Tk_DistanceToTextLayout (*TkVptr->V_Tk_DistanceToTextLayout)
#endif

#ifndef Tk_Draw3DPolygon
#  define Tk_Draw3DPolygon (*TkVptr->V_Tk_Draw3DPolygon)
#endif

#ifndef Tk_Draw3DRectangle
#  define Tk_Draw3DRectangle (*TkVptr->V_Tk_Draw3DRectangle)
#endif

#ifndef Tk_DrawChars
#  define Tk_DrawChars (*TkVptr->V_Tk_DrawChars)
#endif

#ifndef Tk_DrawFocusHighlight
#  define Tk_DrawFocusHighlight (*TkVptr->V_Tk_DrawFocusHighlight)
#endif

#ifndef Tk_DrawTextLayout
#  define Tk_DrawTextLayout (*TkVptr->V_Tk_DrawTextLayout)
#endif

#ifndef Tk_EventInfo
#  define Tk_EventInfo (*TkVptr->V_Tk_EventInfo)
#endif

#ifndef Tk_EventWindow
#  define Tk_EventWindow (*TkVptr->V_Tk_EventWindow)
#endif

#ifndef Tk_Fill3DPolygon
#  define Tk_Fill3DPolygon (*TkVptr->V_Tk_Fill3DPolygon)
#endif

#ifndef Tk_Fill3DRectangle
#  define Tk_Fill3DRectangle (*TkVptr->V_Tk_Fill3DRectangle)
#endif

#ifndef Tk_FontId
#  define Tk_FontId (*TkVptr->V_Tk_FontId)
#endif

#ifndef Tk_Free3DBorder
#  define Tk_Free3DBorder (*TkVptr->V_Tk_Free3DBorder)
#endif

#ifndef Tk_FreeBitmap
#  define Tk_FreeBitmap (*TkVptr->V_Tk_FreeBitmap)
#endif

#ifndef Tk_FreeColor
#  define Tk_FreeColor (*TkVptr->V_Tk_FreeColor)
#endif

#ifndef Tk_FreeColormap
#  define Tk_FreeColormap (*TkVptr->V_Tk_FreeColormap)
#endif

#ifndef Tk_FreeCursor
#  define Tk_FreeCursor (*TkVptr->V_Tk_FreeCursor)
#endif

#ifndef Tk_FreeFont
#  define Tk_FreeFont (*TkVptr->V_Tk_FreeFont)
#endif

#ifndef Tk_FreeGC
#  define Tk_FreeGC (*TkVptr->V_Tk_FreeGC)
#endif

#ifndef Tk_FreeImage
#  define Tk_FreeImage (*TkVptr->V_Tk_FreeImage)
#endif

#ifndef Tk_FreeOptions
#  define Tk_FreeOptions (*TkVptr->V_Tk_FreeOptions)
#endif

#ifndef Tk_FreePixmap
#  define Tk_FreePixmap (*TkVptr->V_Tk_FreePixmap)
#endif

#ifndef Tk_FreeTextLayout
#  define Tk_FreeTextLayout (*TkVptr->V_Tk_FreeTextLayout)
#endif

#ifndef Tk_FreeTile
#  define Tk_FreeTile (*TkVptr->V_Tk_FreeTile)
#endif

#ifndef Tk_FreeXId
#  define Tk_FreeXId (*TkVptr->V_Tk_FreeXId)
#endif

#ifndef Tk_GCForColor
#  define Tk_GCForColor (*TkVptr->V_Tk_GCForColor)
#endif

#ifndef Tk_GeometryRequest
#  define Tk_GeometryRequest (*TkVptr->V_Tk_GeometryRequest)
#endif

#ifndef Tk_Get3DBorder
#  define Tk_Get3DBorder (*TkVptr->V_Tk_Get3DBorder)
#endif

#ifndef Tk_GetAllBindings
#  define Tk_GetAllBindings (*TkVptr->V_Tk_GetAllBindings)
#endif

#ifndef Tk_GetAnchor
#  define Tk_GetAnchor (*TkVptr->V_Tk_GetAnchor)
#endif

#ifndef Tk_GetAtomName
#  define Tk_GetAtomName (*TkVptr->V_Tk_GetAtomName)
#endif

#ifndef Tk_GetBinding
#  define Tk_GetBinding (*TkVptr->V_Tk_GetBinding)
#endif

#ifndef Tk_GetBitmap
#  define Tk_GetBitmap (*TkVptr->V_Tk_GetBitmap)
#endif

#ifndef Tk_GetBitmapFromData
#  define Tk_GetBitmapFromData (*TkVptr->V_Tk_GetBitmapFromData)
#endif

#ifndef Tk_GetCapStyle
#  define Tk_GetCapStyle (*TkVptr->V_Tk_GetCapStyle)
#endif

#ifndef Tk_GetColor
#  define Tk_GetColor (*TkVptr->V_Tk_GetColor)
#endif

#ifndef Tk_GetColorByValue
#  define Tk_GetColorByValue (*TkVptr->V_Tk_GetColorByValue)
#endif

#ifndef Tk_GetColormap
#  define Tk_GetColormap (*TkVptr->V_Tk_GetColormap)
#endif

#ifndef Tk_GetCursor
#  define Tk_GetCursor (*TkVptr->V_Tk_GetCursor)
#endif

#ifndef Tk_GetCursorFromData
#  define Tk_GetCursorFromData (*TkVptr->V_Tk_GetCursorFromData)
#endif

#ifndef Tk_GetDoublePixels
#  define Tk_GetDoublePixels (*TkVptr->V_Tk_GetDoublePixels)
#endif

#ifndef Tk_GetFont
#  define Tk_GetFont (*TkVptr->V_Tk_GetFont)
#endif

#ifndef Tk_GetFontFromObj
#  define Tk_GetFontFromObj (*TkVptr->V_Tk_GetFontFromObj)
#endif

#ifndef Tk_GetFontMetrics
#  define Tk_GetFontMetrics (*TkVptr->V_Tk_GetFontMetrics)
#endif

#ifndef Tk_GetGC
#  define Tk_GetGC (*TkVptr->V_Tk_GetGC)
#endif

#ifndef Tk_GetImage
#  define Tk_GetImage (*TkVptr->V_Tk_GetImage)
#endif

#ifndef Tk_GetImageMasterData
#  define Tk_GetImageMasterData (*TkVptr->V_Tk_GetImageMasterData)
#endif

#ifndef Tk_GetJoinStyle
#  define Tk_GetJoinStyle (*TkVptr->V_Tk_GetJoinStyle)
#endif

#ifndef Tk_GetJustify
#  define Tk_GetJustify (*TkVptr->V_Tk_GetJustify)
#endif

#ifndef Tk_GetNumMainWindows
#  define Tk_GetNumMainWindows (*TkVptr->V_Tk_GetNumMainWindows)
#endif

#ifndef Tk_GetPixels
#  define Tk_GetPixels (*TkVptr->V_Tk_GetPixels)
#endif

#ifndef Tk_GetPixmap
#  define Tk_GetPixmap (*TkVptr->V_Tk_GetPixmap)
#endif

#ifndef Tk_GetRelief
#  define Tk_GetRelief (*TkVptr->V_Tk_GetRelief)
#endif

#ifndef Tk_GetRootCoords
#  define Tk_GetRootCoords (*TkVptr->V_Tk_GetRootCoords)
#endif

#ifndef Tk_GetScreenMM
#  define Tk_GetScreenMM (*TkVptr->V_Tk_GetScreenMM)
#endif

#ifndef Tk_GetScrollInfo
#  define Tk_GetScrollInfo (*TkVptr->V_Tk_GetScrollInfo)
#endif

#ifndef Tk_GetSelection
#  define Tk_GetSelection (*TkVptr->V_Tk_GetSelection)
#endif

#ifndef Tk_GetTile
#  define Tk_GetTile (*TkVptr->V_Tk_GetTile)
#endif

#ifndef Tk_GetUid
#  define Tk_GetUid (*TkVptr->V_Tk_GetUid)
#endif

#ifndef Tk_GetVRootGeometry
#  define Tk_GetVRootGeometry (*TkVptr->V_Tk_GetVRootGeometry)
#endif

#ifndef Tk_GetVisual
#  define Tk_GetVisual (*TkVptr->V_Tk_GetVisual)
#endif

#ifndef Tk_GetXSelection
#  define Tk_GetXSelection (*TkVptr->V_Tk_GetXSelection)
#endif

#ifndef Tk_Grab
#  define Tk_Grab (*TkVptr->V_Tk_Grab)
#endif

#ifndef Tk_HandleEvent
#  define Tk_HandleEvent (*TkVptr->V_Tk_HandleEvent)
#endif

#ifndef Tk_IdToWindow
#  define Tk_IdToWindow (*TkVptr->V_Tk_IdToWindow)
#endif

#ifndef Tk_ImageChanged
#  define Tk_ImageChanged (*TkVptr->V_Tk_ImageChanged)
#endif

#ifndef Tk_InternAtom
#  define Tk_InternAtom (*TkVptr->V_Tk_InternAtom)
#endif

#ifndef Tk_IntersectTextLayout
#  define Tk_IntersectTextLayout (*TkVptr->V_Tk_IntersectTextLayout)
#endif

#ifndef Tk_MainLoop
#  define Tk_MainLoop (*TkVptr->V_Tk_MainLoop)
#endif

#ifndef Tk_MainWindow
#  define Tk_MainWindow (*TkVptr->V_Tk_MainWindow)
#endif

#ifndef Tk_MaintainGeometry
#  define Tk_MaintainGeometry (*TkVptr->V_Tk_MaintainGeometry)
#endif

#ifndef Tk_MakeWindowExist
#  define Tk_MakeWindowExist (*TkVptr->V_Tk_MakeWindowExist)
#endif

#ifndef Tk_ManageGeometry
#  define Tk_ManageGeometry (*TkVptr->V_Tk_ManageGeometry)
#endif

#ifndef Tk_MapWindow
#  define Tk_MapWindow (*TkVptr->V_Tk_MapWindow)
#endif

#ifndef Tk_MeasureChars
#  define Tk_MeasureChars (*TkVptr->V_Tk_MeasureChars)
#endif

#ifndef Tk_MoveResizeWindow
#  define Tk_MoveResizeWindow (*TkVptr->V_Tk_MoveResizeWindow)
#endif

#ifndef Tk_MoveToplevelWindow
#  define Tk_MoveToplevelWindow (*TkVptr->V_Tk_MoveToplevelWindow)
#endif

#ifndef Tk_MoveWindow
#  define Tk_MoveWindow (*TkVptr->V_Tk_MoveWindow)
#endif

#ifndef Tk_NameOf3DBorder
#  define Tk_NameOf3DBorder (*TkVptr->V_Tk_NameOf3DBorder)
#endif

#ifndef Tk_NameOfAnchor
#  define Tk_NameOfAnchor (*TkVptr->V_Tk_NameOfAnchor)
#endif

#ifndef Tk_NameOfBitmap
#  define Tk_NameOfBitmap (*TkVptr->V_Tk_NameOfBitmap)
#endif

#ifndef Tk_NameOfCapStyle
#  define Tk_NameOfCapStyle (*TkVptr->V_Tk_NameOfCapStyle)
#endif

#ifndef Tk_NameOfColor
#  define Tk_NameOfColor (*TkVptr->V_Tk_NameOfColor)
#endif

#ifndef Tk_NameOfCursor
#  define Tk_NameOfCursor (*TkVptr->V_Tk_NameOfCursor)
#endif

#ifndef Tk_NameOfFont
#  define Tk_NameOfFont (*TkVptr->V_Tk_NameOfFont)
#endif

#ifndef Tk_NameOfImage
#  define Tk_NameOfImage (*TkVptr->V_Tk_NameOfImage)
#endif

#ifndef Tk_NameOfJoinStyle
#  define Tk_NameOfJoinStyle (*TkVptr->V_Tk_NameOfJoinStyle)
#endif

#ifndef Tk_NameOfJustify
#  define Tk_NameOfJustify (*TkVptr->V_Tk_NameOfJustify)
#endif

#ifndef Tk_NameOfRelief
#  define Tk_NameOfRelief (*TkVptr->V_Tk_NameOfRelief)
#endif

#ifndef Tk_NameOfTile
#  define Tk_NameOfTile (*TkVptr->V_Tk_NameOfTile)
#endif

#ifndef Tk_NameToWindow
#  define Tk_NameToWindow (*TkVptr->V_Tk_NameToWindow)
#endif

#ifndef Tk_OwnSelection
#  define Tk_OwnSelection (*TkVptr->V_Tk_OwnSelection)
#endif

#ifndef Tk_PixmapOfTile
#  define Tk_PixmapOfTile (*TkVptr->V_Tk_PixmapOfTile)
#endif

#ifndef Tk_PointToChar
#  define Tk_PointToChar (*TkVptr->V_Tk_PointToChar)
#endif

#ifndef Tk_PostscriptBitmap
#  define Tk_PostscriptBitmap (*TkVptr->V_Tk_PostscriptBitmap)
#endif

#ifndef Tk_PostscriptColor
#  define Tk_PostscriptColor (*TkVptr->V_Tk_PostscriptColor)
#endif

#ifndef Tk_PostscriptFont
#  define Tk_PostscriptFont (*TkVptr->V_Tk_PostscriptFont)
#endif

#ifndef Tk_PostscriptFontName
#  define Tk_PostscriptFontName (*TkVptr->V_Tk_PostscriptFontName)
#endif

#ifndef Tk_PostscriptImage
#  define Tk_PostscriptImage (*TkVptr->V_Tk_PostscriptImage)
#endif

#ifndef Tk_PostscriptPath
#  define Tk_PostscriptPath (*TkVptr->V_Tk_PostscriptPath)
#endif

#ifndef Tk_PostscriptStipple
#  define Tk_PostscriptStipple (*TkVptr->V_Tk_PostscriptStipple)
#endif

#ifndef Tk_PostscriptY
#  define Tk_PostscriptY (*TkVptr->V_Tk_PostscriptY)
#endif

#ifndef Tk_PreserveColormap
#  define Tk_PreserveColormap (*TkVptr->V_Tk_PreserveColormap)
#endif

#ifndef Tk_QueueWindowEvent
#  define Tk_QueueWindowEvent (*TkVptr->V_Tk_QueueWindowEvent)
#endif

#ifndef Tk_RedrawImage
#  define Tk_RedrawImage (*TkVptr->V_Tk_RedrawImage)
#endif

#ifndef Tk_ResizeWindow
#  define Tk_ResizeWindow (*TkVptr->V_Tk_ResizeWindow)
#endif

#ifndef Tk_RestackWindow
#  define Tk_RestackWindow (*TkVptr->V_Tk_RestackWindow)
#endif

#ifndef Tk_RestrictEvents
#  define Tk_RestrictEvents (*TkVptr->V_Tk_RestrictEvents)
#endif

#ifndef Tk_SetAppName
#  define Tk_SetAppName (*TkVptr->V_Tk_SetAppName)
#endif

#ifndef Tk_SetBackgroundFromBorder
#  define Tk_SetBackgroundFromBorder (*TkVptr->V_Tk_SetBackgroundFromBorder)
#endif

#ifndef Tk_SetClass
#  define Tk_SetClass (*TkVptr->V_Tk_SetClass)
#endif

#ifndef Tk_SetGrid
#  define Tk_SetGrid (*TkVptr->V_Tk_SetGrid)
#endif

#ifndef Tk_SetInternalBorder
#  define Tk_SetInternalBorder (*TkVptr->V_Tk_SetInternalBorder)
#endif

#ifndef Tk_SetTileChangedProc
#  define Tk_SetTileChangedProc (*TkVptr->V_Tk_SetTileChangedProc)
#endif

#ifndef Tk_SetTileOrigin
#  define Tk_SetTileOrigin (*TkVptr->V_Tk_SetTileOrigin)
#endif

#ifndef Tk_SetWindowBackground
#  define Tk_SetWindowBackground (*TkVptr->V_Tk_SetWindowBackground)
#endif

#ifndef Tk_SetWindowBackgroundPixmap
#  define Tk_SetWindowBackgroundPixmap (*TkVptr->V_Tk_SetWindowBackgroundPixmap)
#endif

#ifndef Tk_SetWindowBorder
#  define Tk_SetWindowBorder (*TkVptr->V_Tk_SetWindowBorder)
#endif

#ifndef Tk_SetWindowBorderPixmap
#  define Tk_SetWindowBorderPixmap (*TkVptr->V_Tk_SetWindowBorderPixmap)
#endif

#ifndef Tk_SetWindowBorderWidth
#  define Tk_SetWindowBorderWidth (*TkVptr->V_Tk_SetWindowBorderWidth)
#endif

#ifndef Tk_SetWindowColormap
#  define Tk_SetWindowColormap (*TkVptr->V_Tk_SetWindowColormap)
#endif

#ifndef Tk_SetWindowVisual
#  define Tk_SetWindowVisual (*TkVptr->V_Tk_SetWindowVisual)
#endif

#ifndef Tk_SizeOfBitmap
#  define Tk_SizeOfBitmap (*TkVptr->V_Tk_SizeOfBitmap)
#endif

#ifndef Tk_SizeOfImage
#  define Tk_SizeOfImage (*TkVptr->V_Tk_SizeOfImage)
#endif

#ifndef Tk_SizeOfTile
#  define Tk_SizeOfTile (*TkVptr->V_Tk_SizeOfTile)
#endif

#ifndef Tk_StrictMotif
#  define Tk_StrictMotif (*TkVptr->V_Tk_StrictMotif)
#endif

#ifndef Tk_TextLayoutToPostscript
#  define Tk_TextLayoutToPostscript (*TkVptr->V_Tk_TextLayoutToPostscript)
#endif

#ifndef Tk_TextWidth
#  define Tk_TextWidth (*TkVptr->V_Tk_TextWidth)
#endif

#ifndef Tk_UndefineCursor
#  define Tk_UndefineCursor (*TkVptr->V_Tk_UndefineCursor)
#endif

#ifndef Tk_UnderlineChars
#  define Tk_UnderlineChars (*TkVptr->V_Tk_UnderlineChars)
#endif

#ifndef Tk_UnderlineTextLayout
#  define Tk_UnderlineTextLayout (*TkVptr->V_Tk_UnderlineTextLayout)
#endif

#ifndef Tk_Ungrab
#  define Tk_Ungrab (*TkVptr->V_Tk_Ungrab)
#endif

#ifndef Tk_UnmaintainGeometry
#  define Tk_UnmaintainGeometry (*TkVptr->V_Tk_UnmaintainGeometry)
#endif

#ifndef Tk_UnmapWindow
#  define Tk_UnmapWindow (*TkVptr->V_Tk_UnmapWindow)
#endif

#ifndef Tk_UnsetGrid
#  define Tk_UnsetGrid (*TkVptr->V_Tk_UnsetGrid)
#endif

#endif /* NO_VTABLES */
#endif /* _TK_VM */
