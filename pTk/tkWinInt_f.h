#ifndef TKWININT_VT
#define TKWININT_VT
#ifdef WIN32
typedef struct TkwinintVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkWinInt.t"
#undef VFUNC
#undef VVAR
} TkwinintVtab;
extern TkwinintVtab *TkwinintVptr;
extern TkwinintVtab *TkwinintVGet _ANSI_ARGS_((void));
#endif /* WIN32 */
#endif /* TKWININT_VT */
