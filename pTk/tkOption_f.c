#include "tk.h"
#include "tkInt.h"
#include "tkOption.h"
#include "tkOption_f.h"
static TkoptionVtab TkoptionVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkOption.t"
#undef VFUNC
#undef VVAR
};
TkoptionVtab *TkoptionVptr;
TkoptionVtab *TkoptionVGet() { return TkoptionVptr = &TkoptionVtable;}
