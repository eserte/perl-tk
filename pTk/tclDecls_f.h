#ifndef TCLDECLS_VT
#define TCLDECLS_VT
typedef struct TcldeclsVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tclDecls.t"
#undef VFUNC
#undef VVAR
} TcldeclsVtab;
extern TcldeclsVtab *TcldeclsVptr;
extern TcldeclsVtab *TcldeclsVGet _ANSI_ARGS_((void));
#endif /* TCLDECLS_VT */
