#ifndef _TKIMGPHOTO_VM
#define _TKIMGPHOTO_VM
#include "tkImgPhoto_f.h"
#define tkImgFmtGIF (*TkimgphotoVptr->V_tkImgFmtGIF)
#define tkImgFmtPPM (*TkimgphotoVptr->V_tkImgFmtPPM)
#define Tk_CreatePhotoImageFormat (*TkimgphotoVptr->V_Tk_CreatePhotoImageFormat)
#define Tk_FindPhoto (*TkimgphotoVptr->V_Tk_FindPhoto)
#define Tk_PhotoBlank (*TkimgphotoVptr->V_Tk_PhotoBlank)
#define Tk_PhotoExpand (*TkimgphotoVptr->V_Tk_PhotoExpand)
#define Tk_PhotoGetImage (*TkimgphotoVptr->V_Tk_PhotoGetImage)
#define Tk_PhotoGetSize (*TkimgphotoVptr->V_Tk_PhotoGetSize)
#define Tk_PhotoPutBlock (*TkimgphotoVptr->V_Tk_PhotoPutBlock)
#define Tk_PhotoPutZoomedBlock (*TkimgphotoVptr->V_Tk_PhotoPutZoomedBlock)
#define Tk_PhotoSetSize (*TkimgphotoVptr->V_Tk_PhotoSetSize)
#endif /* _TKIMGPHOTO_VM */
