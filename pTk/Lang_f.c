#include "Lang.h"
#include "Lang_f.h"
static LangVtab LangVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "Lang.t"
#undef VFUNC
#undef VVAR
};
LangVtab *LangVptr;
LangVtab *LangVGet() { return LangVptr = &LangVtable;}
