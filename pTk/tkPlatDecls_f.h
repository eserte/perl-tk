#ifndef TKPLATDECLS_VT
#define TKPLATDECLS_VT
#include "tkPlatDecls.h"
typedef struct TkplatdeclsVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkPlatDecls.t"
#undef VFUNC
#undef VVAR
} TkplatdeclsVtab;
extern TkplatdeclsVtab *TkplatdeclsVptr;
extern TkplatdeclsVtab *TkplatdeclsVGet _ANSI_ARGS_((void));
#endif /* TKPLATDECLS_VT */
