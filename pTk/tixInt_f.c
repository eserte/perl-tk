#include "tkPort.h"
#include "tixPort.h"
#include "tixInt.h"
#include "tixInt_f.h"
static TixintVtab TixintVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tixInt.t"
#undef VFUNC
#undef VVAR
};
TixintVtab *TixintVptr;
TixintVtab *TixintVGet() { return TixintVptr = &TixintVtable;}
