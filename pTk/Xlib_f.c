#include "tkPort.h"
/* FIXME - include gard muddle */
#undef _XLIB
#include "Xlib.h"
#include "Xlib_f.h"
static XlibVtab XlibVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "Xlib.t"
#undef VFUNC
#undef VVAR
};
XlibVtab *XlibVptr;
XlibVtab *XlibVGet() { return XlibVptr = &XlibVtable;}
