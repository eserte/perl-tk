#ifndef TKGLUE_VT
#define TKGLUE_VT
typedef struct TkglueVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkGlue.t"
#undef VFUNC
#undef VVAR
} TkglueVtab;
extern TkglueVtab *TkglueVptr;
extern TkglueVtab *TkglueVGet _ANSI_ARGS_((void));
#endif /* TKGLUE_VT */
