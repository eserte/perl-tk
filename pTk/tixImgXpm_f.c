#include "tixPort.h"
#include "tixInt.h"
#include "tixImgXpm.h"
#include "tixImgXpm_f.h"
static TiximgxpmVtab TiximgxpmVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tixImgXpm.t"
#undef VFUNC
#undef VVAR
};
TiximgxpmVtab *TiximgxpmVptr;
TiximgxpmVtab *TiximgxpmVGet() { return TiximgxpmVptr = &TiximgxpmVtable;}
