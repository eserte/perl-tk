#ifdef WIN32
#include "tk.h"
#include "tkWin.h"
#include "tkWinInt.h"
#include "tkWinInt_f.h"
static TkwinintVtab TkwinintVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkWinInt.t"
#undef VFUNC
#undef VVAR
};
TkwinintVtab *TkwinintVptr;
TkwinintVtab *TkwinintVGet() { return TkwinintVptr = &TkwinintVtable;}
#endif