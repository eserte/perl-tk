#ifndef _TKGLUE_VM
#define _TKGLUE_VM
#include "tkGlue_f.h"
#define Call_Tk (*TkglueVptr->V_Call_Tk)
#define EnterWidgetMethods (*TkglueVptr->V_EnterWidgetMethods)
#define FindTkVarName (*TkglueVptr->V_FindTkVarName)
#define GetWindow (*TkglueVptr->V_GetWindow)
#define InterpHv (*TkglueVptr->V_InterpHv)
#define Lang_TkCommand (*TkglueVptr->V_Lang_TkCommand)
#define MakeReference (*TkglueVptr->V_MakeReference)
#define TkToMainWindow (*TkglueVptr->V_TkToMainWindow)
#define TkToWidget (*TkglueVptr->V_TkToWidget)
#define WidgetRef (*TkglueVptr->V_WidgetRef)
#define WindowCommand (*TkglueVptr->V_WindowCommand)
#define XStoWidget (*TkglueVptr->V_XStoWidget)
#endif /* _TKGLUE_VM */
