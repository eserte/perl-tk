#include "tk.h"
#include "tkDecls_f.h"
static TkdeclsVtab TkdeclsVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkDecls.t"
#undef VFUNC
#undef VVAR
};
TkdeclsVtab *TkdeclsVptr;
TkdeclsVtab *TkdeclsVGet() { return TkdeclsVptr = &TkdeclsVtable;}
