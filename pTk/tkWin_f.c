#ifdef WIN32
#include "tkWin.h"
#include "tkWin_f.h"
static TkwinVtab TkwinVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkWin.t"
#undef VFUNC
#undef VVAR
};
TkwinVtab *TkwinVptr;
TkwinVtab *TkwinVGet() { return TkwinVptr = &TkwinVtable;}
#endif /* WIN32 */
