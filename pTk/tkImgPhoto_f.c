#include "tkPort.h"
#include "tkInt.h"
#include "tkImgPhoto.h"
#include "tkImgPhoto_f.h"
static TkimgphotoVtab TkimgphotoVtable =
{
#define VFUNC(type,name,mem,args) name,
#define VVAR(type,name,mem)      &name,
#include "tkImgPhoto.t"
#undef VFUNC
#undef VVAR
};
TkimgphotoVtab *TkimgphotoVptr;
TkimgphotoVtab *TkimgphotoVGet() { return TkimgphotoVptr = &TkimgphotoVtable;}
