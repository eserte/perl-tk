#ifndef TKIMGPHOTO_VT
#define TKIMGPHOTO_VT
typedef struct TkimgphotoVtab
{
#define VFUNC(type,name,mem,args) type (*mem) args;
#define VVAR(type,name,mem)       type (*mem);
#include "tkImgPhoto.t"
#undef VFUNC
#undef VVAR
} TkimgphotoVtab;
extern TkimgphotoVtab *TkimgphotoVptr;
extern TkimgphotoVtab *TkimgphotoVGet _ANSI_ARGS_((void));
#endif /* TKIMGPHOTO_VT */
