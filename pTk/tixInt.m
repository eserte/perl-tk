#ifndef _TIXINT_VM
#define _TIXINT_VM
#include "tixInt_f.h"
#ifndef NO_VTABLES
#ifndef TixDItemGetAnchor
#define TixDItemGetAnchor (*TixintVptr->V_TixDItemGetAnchor)
#endif
#ifndef TixDItemStyleChanged
#define TixDItemStyleChanged (*TixintVptr->V_TixDItemStyleChanged)
#endif
#ifndef TixDItemStyleFree
#define TixDItemStyleFree (*TixintVptr->V_TixDItemStyleFree)
#endif
#ifndef TixGetColorDItemGC
#define TixGetColorDItemGC (*TixintVptr->V_TixGetColorDItemGC)
#endif
#ifndef TixGetDefaultDItemStyle
#define TixGetDefaultDItemStyle (*TixintVptr->V_TixGetDefaultDItemStyle)
#endif
#ifndef Tix_AddDItemType
#define Tix_AddDItemType (*TixintVptr->V_Tix_AddDItemType)
#endif
#ifndef Tix_ConfigureInfo2
#define Tix_ConfigureInfo2 (*TixintVptr->V_Tix_ConfigureInfo2)
#endif
#ifndef Tix_DItemCalculateSize
#define Tix_DItemCalculateSize (*TixintVptr->V_Tix_DItemCalculateSize)
#endif
#ifndef Tix_DItemConfigure
#define Tix_DItemConfigure (*TixintVptr->V_Tix_DItemConfigure)
#endif
#ifndef Tix_DItemCreate
#define Tix_DItemCreate (*TixintVptr->V_Tix_DItemCreate)
#endif
#ifndef Tix_DItemDisplay
#define Tix_DItemDisplay (*TixintVptr->V_Tix_DItemDisplay)
#endif
#ifndef Tix_DItemFree
#define Tix_DItemFree (*TixintVptr->V_Tix_DItemFree)
#endif
#ifndef Tix_GetDItemType
#define Tix_GetDItemType (*TixintVptr->V_Tix_GetDItemType)
#endif
#ifndef Tix_MultiConfigureInfo
#define Tix_MultiConfigureInfo (*TixintVptr->V_Tix_MultiConfigureInfo)
#endif
#ifndef Tix_SetDefaultStyleTemplate
#define Tix_SetDefaultStyleTemplate (*TixintVptr->V_Tix_SetDefaultStyleTemplate)
#endif
#ifndef Tix_SetWindowItemSerial
#define Tix_SetWindowItemSerial (*TixintVptr->V_Tix_SetWindowItemSerial)
#endif
#ifndef Tix_SplitConfig
#define Tix_SplitConfig (*TixintVptr->V_Tix_SplitConfig)
#endif
#ifndef Tix_UnmapInvisibleWindowItems
#define Tix_UnmapInvisibleWindowItems (*TixintVptr->V_Tix_UnmapInvisibleWindowItems)
#endif
#ifndef Tix_WidgetConfigure2
#define Tix_WidgetConfigure2 (*TixintVptr->V_Tix_WidgetConfigure2)
#endif
#ifndef Tix_WindowItemListRemove
#define Tix_WindowItemListRemove (*TixintVptr->V_Tix_WindowItemListRemove)
#endif
#endif /* NO_VTABLES */
#endif /* _TIXINT_VM */
