#include "tkGlue.h"
#include "tkGlue_f.h"
static TkglueVtab TkglueVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkGlue.t"
#undef VFUNC
#undef VVAR
};
TkglueVtab *TkglueVptr;
TkglueVtab *TkglueVGet() { return TkglueVptr = &TkglueVtable;}
