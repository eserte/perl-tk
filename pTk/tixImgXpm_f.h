#ifndef TIXIMGXPM_VT
#define TIXIMGXPM_VT
typedef struct TiximgxpmVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tixImgXpm.t"
#undef VFUNC
#undef VVAR
} TiximgxpmVtab;
extern TiximgxpmVtab *TiximgxpmVptr;
extern TiximgxpmVtab *TiximgxpmVGet _ANSI_ARGS_((void));
#endif /* TIXIMGXPM_VT */
