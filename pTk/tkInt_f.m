#ifndef _TKINT_F_VM
#define _TKINT_F_VM
#include "tkInt_f_f.h"
#define TkintVptr (*Tkint_fVptr->V_TkintVptr)
#ifndef TkintVGet
#define TkintVGet (*Tkint_fVptr->V_TkintVGet)
#endif
#endif /* _TKINT_F_VM */
