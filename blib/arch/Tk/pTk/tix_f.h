#ifndef TIX_VT
#define TIX_VT
typedef struct TixVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tix.t"
#undef VFUNC
#undef VVAR
} TixVtab;
extern TixVtab *TixVptr;
extern TixVtab *TixVGet _ANSI_ARGS_((void));
#endif /* TIX_VT */
