#ifndef TKINTDECLS_VT
#define TKINTDECLS_VT
typedef struct TkintdeclsVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkIntDecls.t"
#undef VFUNC
#undef VVAR
} TkintdeclsVtab;
extern TkintdeclsVtab *TkintdeclsVptr;
extern TkintdeclsVtab *TkintdeclsVGet _ANSI_ARGS_((void));
#endif /* TKINTDECLS_VT */
