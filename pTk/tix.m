#ifndef _TIX_VM
#define _TIX_VM
#include "tix_f.h"
#ifndef NO_VTABLES
#define specTable (*TixVptr->V_specTable)
#define tixConfigItemStyle (*TixVptr->V_tixConfigItemStyle)
#define tixConfigItemType (*TixVptr->V_tixConfigItemType)
#define tixConfigRelief (*TixVptr->V_tixConfigRelief)
#ifndef Tix_GetScrollFractions
#define Tix_GetScrollFractions (*TixVptr->V_Tix_GetScrollFractions)
#endif
#ifndef Tix_HandleSubCmds
#define Tix_HandleSubCmds (*TixVptr->V_Tix_HandleSubCmds)
#endif
#ifndef Tix_LinkListAppend
#define Tix_LinkListAppend (*TixVptr->V_Tix_LinkListAppend)
#endif
#ifndef Tix_LinkListDelete
#define Tix_LinkListDelete (*TixVptr->V_Tix_LinkListDelete)
#endif
#ifndef Tix_LinkListDeleteRange
#define Tix_LinkListDeleteRange (*TixVptr->V_Tix_LinkListDeleteRange)
#endif
#ifndef Tix_LinkListFind
#define Tix_LinkListFind (*TixVptr->V_Tix_LinkListFind)
#endif
#ifndef Tix_LinkListInit
#define Tix_LinkListInit (*TixVptr->V_Tix_LinkListInit)
#endif
#ifndef Tix_LinkListInsert
#define Tix_LinkListInsert (*TixVptr->V_Tix_LinkListInsert)
#endif
#ifndef Tix_LinkListIteratorInit
#define Tix_LinkListIteratorInit (*TixVptr->V_Tix_LinkListIteratorInit)
#endif
#ifndef Tix_LinkListNext
#define Tix_LinkListNext (*TixVptr->V_Tix_LinkListNext)
#endif
#ifndef Tix_LinkListStart
#define Tix_LinkListStart (*TixVptr->V_Tix_LinkListStart)
#endif
#endif /* NO_VTABLES */
#endif /* _TIX_VM */
