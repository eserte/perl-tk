#ifndef _TKINT_VM
#define _TKINT_VM
#include "tkInt_f.h"
#ifndef NO_VTABLES
#define tkActiveUid (*TkintVptr->V_tkActiveUid)
#define tkDisabledUid (*TkintVptr->V_tkDisabledUid)
#define tkDisplayList (*TkintVptr->V_tkDisplayList)
#define tkMainWindowList (*TkintVptr->V_tkMainWindowList)
#define tkNormalUid (*TkintVptr->V_tkNormalUid)
#define tkSendSerial (*TkintVptr->V_tkSendSerial)
#ifndef TkBindEventProc
#  define TkBindEventProc (*TkintVptr->V_TkBindEventProc)
#endif

#ifndef TkBindFree
#  define TkBindFree (*TkintVptr->V_TkBindFree)
#endif

#ifndef TkBindInit
#  define TkBindInit (*TkintVptr->V_TkBindInit)
#endif

#ifndef TkChangeEventWindow
#  define TkChangeEventWindow (*TkintVptr->V_TkChangeEventWindow)
#endif

#ifndef TkClipBox
#  define TkClipBox (*TkintVptr->V_TkClipBox)
#endif

#ifndef TkClipInit
#  define TkClipInit (*TkintVptr->V_TkClipInit)
#endif

#ifndef TkCmapStressed
#  define TkCmapStressed (*TkintVptr->V_TkCmapStressed)
#endif

#ifndef TkComputeTextGeometry
#  define TkComputeTextGeometry (*TkintVptr->V_TkComputeTextGeometry)
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

#ifndef TkDisplayChars
#  define TkDisplayChars (*TkintVptr->V_TkDisplayChars)
#endif

#ifndef TkDisplayText
#  define TkDisplayText (*TkintVptr->V_TkDisplayText)
#endif

#ifndef TkEventDeadWindow
#  define TkEventDeadWindow (*TkintVptr->V_TkEventDeadWindow)
#endif

#ifndef TkFindStateNum
#  define TkFindStateNum (*TkintVptr->V_TkFindStateNum)
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

#ifndef TkFreeBindingTags
#  define TkFreeBindingTags (*TkintVptr->V_TkFreeBindingTags)
#endif

#ifndef TkFreeCursor
#  define TkFreeCursor (*TkintVptr->V_TkFreeCursor)
#endif

#ifndef TkFreeWindowId
#  define TkFreeWindowId (*TkintVptr->V_TkFreeWindowId)
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

#ifndef TkGetFocus
#  define TkGetFocus (*TkintVptr->V_TkGetFocus)
#endif

#ifndef TkGetInterpNames
#  define TkGetInterpNames (*TkintVptr->V_TkGetInterpNames)
#endif

#ifndef TkGetPointerCoords
#  define TkGetPointerCoords (*TkintVptr->V_TkGetPointerCoords)
#endif

#ifndef TkGetProlog
#  define TkGetProlog (*TkintVptr->V_TkGetProlog)
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

#ifndef TkIntersectRegion
#  define TkIntersectRegion (*TkintVptr->V_TkIntersectRegion)
#endif

#ifndef TkKeysymToString
#  define TkKeysymToString (*TkintVptr->V_TkKeysymToString)
#endif

#ifndef TkMakeWindow
#  define TkMakeWindow (*TkintVptr->V_TkMakeWindow)
#endif

#ifndef TkMeasureChars
#  define TkMeasureChars (*TkintVptr->V_TkMeasureChars)
#endif

#ifndef TkPlatformInit
#  define TkPlatformInit (*TkintVptr->V_TkPlatformInit)
#endif

#ifndef TkPointerEvent
#  define TkPointerEvent (*TkintVptr->V_TkPointerEvent)
#endif

#ifndef TkPositionInTree
#  define TkPositionInTree (*TkintVptr->V_TkPositionInTree)
#endif

#ifndef TkPutImage
#  define TkPutImage (*TkintVptr->V_TkPutImage)
#endif

#ifndef TkQueueEventForAllChildren
#  define TkQueueEventForAllChildren (*TkintVptr->V_TkQueueEventForAllChildren)
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

#ifndef TkSetPixmapColormap
#  define TkSetPixmapColormap (*TkintVptr->V_TkSetPixmapColormap)
#endif

#ifndef TkSetRegion
#  define TkSetRegion (*TkintVptr->V_TkSetRegion)
#endif

#ifndef TkStringToKeysym
#  define TkStringToKeysym (*TkintVptr->V_TkStringToKeysym)
#endif

#ifndef TkUnderlineChars
#  define TkUnderlineChars (*TkintVptr->V_TkUnderlineChars)
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

#endif /* NO_VTABLES */
#endif /* _TKINT_VM */
