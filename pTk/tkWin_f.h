#ifndef TKWIN_VT
#define TKWIN_VT
#ifdef WIN32
typedef struct TkwinVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkWin.t"
#undef VFUNC
#undef VVAR
} TkwinVtab;
extern TkwinVtab *TkwinVptr;
extern TkwinVtab *TkwinVGet _ANSI_ARGS_((void));
#endif /* WIN32 */
#endif /* TKWIN_VT */
