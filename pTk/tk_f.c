#include "tk.h"
#include "tk_f.h"
static TkVtab TkVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tk.t"
#undef VFUNC
#undef VVAR
};
TkVtab *TkVptr;
TkVtab *TkVGet() { return TkVptr = &TkVtable;}
