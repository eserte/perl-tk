#ifndef _IMGINT_VM
#define _IMGINT_VM
#include "imgInt_f.h"
#ifndef NO_VTABLES
#ifndef ImgGetc
#  define ImgGetc (*ImgintVptr->V_ImgGetc)
#endif

#ifndef ImgPhotoPutBlock
#  define ImgPhotoPutBlock (*ImgintVptr->V_ImgPhotoPutBlock)
#endif

#ifndef ImgPutc
#  define ImgPutc (*ImgintVptr->V_ImgPutc)
#endif

#ifndef ImgRead
#  define ImgRead (*ImgintVptr->V_ImgRead)
#endif

#ifndef ImgReadInit
#  define ImgReadInit (*ImgintVptr->V_ImgReadInit)
#endif

#ifndef ImgWrite
#  define ImgWrite (*ImgintVptr->V_ImgWrite)
#endif

#ifndef ImgWriteInit
#  define ImgWriteInit (*ImgintVptr->V_ImgWriteInit)
#endif

#endif /* NO_VTABLES */
#endif /* _IMGINT_VM */
