#include "tkPort.h"
#include "tk.h"
#include "tixPort.h"
#include "tix.h"
#include "tix_f.h"
static TixVtab TixVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tix.t"
#undef VFUNC
#undef VVAR
};
TixVtab *TixVptr;
TixVtab *TixVGet() { return TixVptr = &TixVtable;}
