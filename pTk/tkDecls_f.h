#ifndef TKDECLS_VT
#define TKDECLS_VT
typedef struct TkdeclsVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkDecls.t"
#undef VFUNC
#undef VVAR
} TkdeclsVtab;
extern TkdeclsVtab *TkdeclsVptr;
extern TkdeclsVtab *TkdeclsVGet _ANSI_ARGS_((void));
#endif /* TKDECLS_VT */
