#include "Lang.h"
#ifdef WIN32
#include "tkWinInt.h"
#include "tkIntPlatDecls_f.h"
static TkintplatdeclsVtab TkintplatdeclsVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkIntPlatDecls.t"
#undef VFUNC
#undef VVAR
};
TkintplatdeclsVtab *TkintplatdeclsVptr;
TkintplatdeclsVtab *TkintplatdeclsVGet() { return TkintplatdeclsVptr = &TkintplatdeclsVtable;}
#endif
