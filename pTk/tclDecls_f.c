#include "Lang.h"
#include "tclDecls_f.h"
static TcldeclsVtab TcldeclsVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tclDecls.t"
#undef VFUNC
#undef VVAR
};
TcldeclsVtab *TcldeclsVptr;
TcldeclsVtab *TcldeclsVGet() { return TcldeclsVptr = &TcldeclsVtable;}
