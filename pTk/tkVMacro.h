#ifdef _LANG
#include "Lang.m"
#endif
#if defined(_TK)
#include "tk.m"
#endif 
#if defined(_TK) || defined(_XLIB_H_)
#ifndef _XLIB
#include "Xlib.h"
#endif
#include "Xlib.m"
#endif
#ifdef _TKINT
#include "tkInt.m"
#endif
#ifdef _TKIMGPHOTO
#include "tkImgPhoto.m"
#endif
#ifdef _TIX
#include "tix.m"
#endif
#ifdef _TIXINT
#include "tixInt.m"
#endif
#ifdef _TKOPTION
#include "tkOption.m"
#endif

