#include "tkInt.h"
#include "tkIntDecls_f.h"
static TkintdeclsVtab TkintdeclsVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkIntDecls.t"
#undef VFUNC
#undef VVAR
};
TkintdeclsVtab *TkintdeclsVptr;
TkintdeclsVtab *TkintdeclsVGet() { return TkintdeclsVptr = &TkintdeclsVtable;}
