#ifndef TKINT_VT
#define TKINT_VT
typedef struct TkintVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkInt.t"
#undef VFUNC
#undef VVAR
} TkintVtab;
extern TkintVtab *TkintVptr;
extern TkintVtab *TkintVGet _ANSI_ARGS_((void));
#endif /* TKINT_VT */
