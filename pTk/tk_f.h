#ifndef TK_VT
#define TK_VT
typedef struct TkVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tk.t"
#undef VFUNC
#undef VVAR
} TkVtab;
extern TkVtab *TkVptr;
extern TkVtab *TkVGet _ANSI_ARGS_((void));
#endif /* TK_VT */
