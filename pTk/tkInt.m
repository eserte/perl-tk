#ifndef _TKINT_VM
#define _TKINT_VM
#include "tkInt_f.h"
#ifndef NO_VTABLES
#define tkActiveUid (*TkintVptr->V_tkActiveUid)
#define tkBitmapImageType (*TkintVptr->V_tkBitmapImageType)
#define tkDisabledUid (*TkintVptr->V_tkDisabledUid)
#define tkDisplayList (*TkintVptr->V_tkDisplayList)
#define tkMainWindowList (*TkintVptr->V_tkMainWindowList)
#define tkNormalUid (*TkintVptr->V_tkNormalUid)
#define tkPredefBitmapTable (*TkintVptr->V_tkPredefBitmapTable)
#ifndef TkAllocWindow
#  define TkAllocWindow (*TkintVptr->V_TkAllocWindow)
#endif

#ifndef TkBindDeadWindow
#  define TkBindDeadWindow (*TkintVptr->V_TkBindDeadWindow)
#endif

#ifndef TkBindEventProc
#  define TkBindEventProc (*TkintVptr->V_TkBindEventProc)
#endif

#ifndef TkBindFree
#  define TkBindFree (*TkintVptr->V_TkBindFree)
#endif

#ifndef TkBindInit
#  define TkBindInit (*TkintVptr->V_TkBindInit)
#endif

#ifndef TkCanvPostscriptCmd
#  define TkCanvPostscriptCmd (*TkintVptr->V_TkCanvPostscriptCmd)
#endif

#ifndef TkChangeEventWindow
#  define TkChangeEventWindow (*TkintVptr->V_TkChangeEventWindow)
#endif

#ifndef TkClassOption
#  define TkClassOption (*TkintVptr->V_TkClassOption)
#endif

#ifndef TkClassOptionObj
#  define TkClassOptionObj (*TkintVptr->V_TkClassOptionObj)
#endif

#ifndef TkClipBox
#  define TkClipBox (*TkintVptr->V_TkClipBox)
#endif

#ifndef TkClipInit
#  define TkClipInit (*TkintVptr->V_TkClipInit)
#endif

#ifndef TkComputeAnchor
#  define TkComputeAnchor (*TkintVptr->V_TkComputeAnchor)
#endif

#ifndef TkCreateBindingProcedure
#  define TkCreateBindingProcedure (*TkintVptr->V_TkCreateBindingProcedure)
#endif

#ifndef TkCreateCursorFromData
#  define TkCreateCursorFromData (*TkintVptr->V_TkCreateCursorFromData)
#endif

#ifndef TkCreateFrame
#  define TkCreateFrame (*TkintVptr->V_TkCreateFrame)
#endif

#ifndef TkCreateMainWindow
#  define TkCreateMainWindow (*TkintVptr->V_TkCreateMainWindow)
#endif

#ifndef TkCreateRegion
#  define TkCreateRegion (*TkintVptr->V_TkCreateRegion)
#endif

#ifndef TkCurrentTime
#  define TkCurrentTime (*TkintVptr->V_TkCurrentTime)
#endif

#ifndef TkDeadAppCmd
#  define TkDeadAppCmd (*TkintVptr->V_TkDeadAppCmd)
#endif

#ifndef TkDeleteAllImages
#  define TkDeleteAllImages (*TkintVptr->V_TkDeleteAllImages)
#endif

#ifndef TkDestroyRegion
#  define TkDestroyRegion (*TkintVptr->V_TkDestroyRegion)
#endif

#ifndef TkDoConfigureNotify
#  define TkDoConfigureNotify (*TkintVptr->V_TkDoConfigureNotify)
#endif

#ifndef TkDrawInsetFocusHighlight
#  define TkDrawInsetFocusHighlight (*TkintVptr->V_TkDrawInsetFocusHighlight)
#endif

#ifndef TkEventDeadWindow
#  define TkEventDeadWindow (*TkintVptr->V_TkEventDeadWindow)
#endif

#ifndef TkFindStateNum
#  define TkFindStateNum (*TkintVptr->V_TkFindStateNum)
#endif

#ifndef TkFindStateNumObj
#  define TkFindStateNumObj (*TkintVptr->V_TkFindStateNumObj)
#endif

#ifndef TkFindStateString
#  define TkFindStateString (*TkintVptr->V_TkFindStateString)
#endif

#ifndef TkFocusDeadWindow
#  define TkFocusDeadWindow (*TkintVptr->V_TkFocusDeadWindow)
#endif

#ifndef TkFocusFilterEvent
#  define TkFocusFilterEvent (*TkintVptr->V_TkFocusFilterEvent)
#endif

#ifndef TkFocusKeyEvent
#  define TkFocusKeyEvent (*TkintVptr->V_TkFocusKeyEvent)
#endif

#ifndef TkFontPkgFree
#  define TkFontPkgFree (*TkintVptr->V_TkFontPkgFree)
#endif

#ifndef TkFontPkgInit
#  define TkFontPkgInit (*TkintVptr->V_TkFontPkgInit)
#endif

#ifndef TkFreeBindingTags
#  define TkFreeBindingTags (*TkintVptr->V_TkFreeBindingTags)
#endif

#ifndef TkFreeCursor
#  define TkFreeCursor (*TkintVptr->V_TkFreeCursor)
#endif

#ifndef TkFreeWindowId
#  define TkFreeWindowId (*TkintVptr->V_TkFreeWindowId)
#endif

#ifndef TkGetBitmapData
#  define TkGetBitmapData (*TkintVptr->V_TkGetBitmapData)
#endif

#ifndef TkGetCursorByName
#  define TkGetCursorByName (*TkintVptr->V_TkGetCursorByName)
#endif

#ifndef TkGetDefaultScreenName
#  define TkGetDefaultScreenName (*TkintVptr->V_TkGetDefaultScreenName)
#endif

#ifndef TkGetDisplay
#  define TkGetDisplay (*TkintVptr->V_TkGetDisplay)
#endif

#ifndef TkGetDisplayOf
#  define TkGetDisplayOf (*TkintVptr->V_TkGetDisplayOf)
#endif

#ifndef TkGetFocusWin
#  define TkGetFocusWin (*TkintVptr->V_TkGetFocusWin)
#endif

#ifndef TkGetInterpNames
#  define TkGetInterpNames (*TkintVptr->V_TkGetInterpNames)
#endif

#ifndef TkGetPixelsFromObj
#  define TkGetPixelsFromObj (*TkintVptr->V_TkGetPixelsFromObj)
#endif

#ifndef TkGetPointerCoords
#  define TkGetPointerCoords (*TkintVptr->V_TkGetPointerCoords)
#endif

#ifndef TkGetScreenMMFromObj
#  define TkGetScreenMMFromObj (*TkintVptr->V_TkGetScreenMMFromObj)
#endif

#ifndef TkGetServerInfo
#  define TkGetServerInfo (*TkintVptr->V_TkGetServerInfo)
#endif

#ifndef TkGrabDeadWindow
#  define TkGrabDeadWindow (*TkintVptr->V_TkGrabDeadWindow)
#endif

#ifndef TkGrabState
#  define TkGrabState (*TkintVptr->V_TkGrabState)
#endif

#ifndef TkInOutEvents
#  define TkInOutEvents (*TkintVptr->V_TkInOutEvents)
#endif

#ifndef TkInitXId
#  define TkInitXId (*TkintVptr->V_TkInitXId)
#endif

#ifndef TkInstallFrameMenu
#  define TkInstallFrameMenu (*TkintVptr->V_TkInstallFrameMenu)
#endif

#ifndef TkIntersectRegion
#  define TkIntersectRegion (*TkintVptr->V_TkIntersectRegion)
#endif

#ifndef TkKeysymToString
#  define TkKeysymToString (*TkintVptr->V_TkKeysymToString)
#endif

#ifndef TkPointerEvent
#  define TkPointerEvent (*TkintVptr->V_TkPointerEvent)
#endif

#ifndef TkPositionInTree
#  define TkPositionInTree (*TkintVptr->V_TkPositionInTree)
#endif

#ifndef TkPostscriptImage
#  define TkPostscriptImage (*TkintVptr->V_TkPostscriptImage)
#endif

#ifndef TkPutImage
#  define TkPutImage (*TkintVptr->V_TkPutImage)
#endif

#ifndef TkQueueEventForAllChildren
#  define TkQueueEventForAllChildren (*TkintVptr->V_TkQueueEventForAllChildren)
#endif

#ifndef TkReadBitmapFile
#  define TkReadBitmapFile (*TkintVptr->V_TkReadBitmapFile)
#endif

#ifndef TkRectInRegion
#  define TkRectInRegion (*TkintVptr->V_TkRectInRegion)
#endif

#ifndef TkScrollWindow
#  define TkScrollWindow (*TkintVptr->V_TkScrollWindow)
#endif

#ifndef TkSelDeadWindow
#  define TkSelDeadWindow (*TkintVptr->V_TkSelDeadWindow)
#endif

#ifndef TkSelEventProc
#  define TkSelEventProc (*TkintVptr->V_TkSelEventProc)
#endif

#ifndef TkSelInit
#  define TkSelInit (*TkintVptr->V_TkSelInit)
#endif

#ifndef TkSelPropProc
#  define TkSelPropProc (*TkintVptr->V_TkSelPropProc)
#endif

#ifndef TkSetClassProcs
#  define TkSetClassProcs (*TkintVptr->V_TkSetClassProcs)
#endif

#ifndef TkSetPixmapColormap
#  define TkSetPixmapColormap (*TkintVptr->V_TkSetPixmapColormap)
#endif

#ifndef TkSetRegion
#  define TkSetRegion (*TkintVptr->V_TkSetRegion)
#endif

#ifndef TkSetWindowMenuBar
#  define TkSetWindowMenuBar (*TkintVptr->V_TkSetWindowMenuBar)
#endif

#ifndef TkStringToKeysym
#  define TkStringToKeysym (*TkintVptr->V_TkStringToKeysym)
#endif

#ifndef TkUnionRectWithRegion
#  define TkUnionRectWithRegion (*TkintVptr->V_TkUnionRectWithRegion)
#endif

#ifndef TkWmAddToColormapWindows
#  define TkWmAddToColormapWindows (*TkintVptr->V_TkWmAddToColormapWindows)
#endif

#ifndef TkWmDeadWindow
#  define TkWmDeadWindow (*TkintVptr->V_TkWmDeadWindow)
#endif

#ifndef TkWmFocusToplevel
#  define TkWmFocusToplevel (*TkintVptr->V_TkWmFocusToplevel)
#endif

#ifndef TkWmMapWindow
#  define TkWmMapWindow (*TkintVptr->V_TkWmMapWindow)
#endif

#ifndef TkWmNewWindow
#  define TkWmNewWindow (*TkintVptr->V_TkWmNewWindow)
#endif

#ifndef TkWmProtocolEventProc
#  define TkWmProtocolEventProc (*TkintVptr->V_TkWmProtocolEventProc)
#endif

#ifndef TkWmRemoveFromColormapWindows
#  define TkWmRemoveFromColormapWindows (*TkintVptr->V_TkWmRemoveFromColormapWindows)
#endif

#ifndef TkWmRestackToplevel
#  define TkWmRestackToplevel (*TkintVptr->V_TkWmRestackToplevel)
#endif

#ifndef TkWmSetClass
#  define TkWmSetClass (*TkintVptr->V_TkWmSetClass)
#endif

#ifndef TkWmUnmapWindow
#  define TkWmUnmapWindow (*TkintVptr->V_TkWmUnmapWindow)
#endif

#ifndef TkpChangeFocus
#  define TkpChangeFocus (*TkintVptr->V_TkpChangeFocus)
#endif

#ifndef TkpClaimFocus
#  define TkpClaimFocus (*TkintVptr->V_TkpClaimFocus)
#endif

#ifndef TkpCloseDisplay
#  define TkpCloseDisplay (*TkintVptr->V_TkpCloseDisplay)
#endif

#ifndef TkpCmapStressed
#  define TkpCmapStressed (*TkintVptr->V_TkpCmapStressed)
#endif

#ifndef TkpCreateNativeBitmap
#  define TkpCreateNativeBitmap (*TkintVptr->V_TkpCreateNativeBitmap)
#endif

#ifndef TkpDefineNativeBitmaps
#  define TkpDefineNativeBitmaps (*TkintVptr->V_TkpDefineNativeBitmaps)
#endif

#ifndef TkpGetNativeAppBitmap
#  define TkpGetNativeAppBitmap (*TkintVptr->V_TkpGetNativeAppBitmap)
#endif

#ifndef TkpGetOtherWindow
#  define TkpGetOtherWindow (*TkintVptr->V_TkpGetOtherWindow)
#endif

#ifndef TkpGetWrapperWindow
#  define TkpGetWrapperWindow (*TkintVptr->V_TkpGetWrapperWindow)
#endif

#ifndef TkpInitializeMenuBindings
#  define TkpInitializeMenuBindings (*TkintVptr->V_TkpInitializeMenuBindings)
#endif

#ifndef TkpMakeContainer
#  define TkpMakeContainer (*TkintVptr->V_TkpMakeContainer)
#endif

#ifndef TkpMakeMenuWindow
#  define TkpMakeMenuWindow (*TkintVptr->V_TkpMakeMenuWindow)
#endif

#ifndef TkpMakeWindow
#  define TkpMakeWindow (*TkintVptr->V_TkpMakeWindow)
#endif

#ifndef TkpMenuNotifyToplevelCreate
#  define TkpMenuNotifyToplevelCreate (*TkintVptr->V_TkpMenuNotifyToplevelCreate)
#endif

#ifndef TkpOpenDisplay
#  define TkpOpenDisplay (*TkintVptr->V_TkpOpenDisplay)
#endif

#ifndef TkpPrintWindowId
#  define TkpPrintWindowId (*TkintVptr->V_TkpPrintWindowId)
#endif

#ifndef TkpRedirectKeyEvent
#  define TkpRedirectKeyEvent (*TkintVptr->V_TkpRedirectKeyEvent)
#endif

#ifndef TkpScanWindowId
#  define TkpScanWindowId (*TkintVptr->V_TkpScanWindowId)
#endif

#ifndef TkpSetMainMenubar
#  define TkpSetMainMenubar (*TkintVptr->V_TkpSetMainMenubar)
#endif

#ifndef TkpSync
#  define TkpSync (*TkintVptr->V_TkpSync)
#endif

#ifndef TkpUseWindow
#  define TkpUseWindow (*TkintVptr->V_TkpUseWindow)
#endif

#ifndef TkpWindowWasRecentlyDeleted
#  define TkpWindowWasRecentlyDeleted (*TkintVptr->V_TkpWindowWasRecentlyDeleted)
#endif

#endif /* NO_VTABLES */
#endif /* _TKINT_VM */
