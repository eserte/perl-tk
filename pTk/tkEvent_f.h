#ifndef TKEVENT_VT
#define TKEVENT_VT
typedef struct TkeventVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkEvent.t"
#undef VFUNC
#undef VVAR
} TkeventVtab;
extern TkeventVtab *TkeventVptr;
extern TkeventVtab *TkeventVGet _ANSI_ARGS_((void));
#endif /* TKEVENT_VT */
