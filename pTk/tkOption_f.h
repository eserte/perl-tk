#ifndef TKOPTION_VT
#define TKOPTION_VT
typedef struct TkoptionVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkOption.t"
#undef VFUNC
#undef VVAR
} TkoptionVtab;
extern TkoptionVtab *TkoptionVptr;
extern TkoptionVtab *TkoptionVGet _ANSI_ARGS_((void));
#endif /* TKOPTION_VT */
