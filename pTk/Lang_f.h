#ifndef LANG_VT
#define LANG_VT
typedef struct LangVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "Lang.t"
#undef VFUNC
#undef VVAR
} LangVtab;
extern LangVtab *LangVptr;
extern LangVtab *LangVGet _ANSI_ARGS_((void));
#endif /* LANG_VT */
