#ifdef _LANG
#include "Lang.m"
#endif

#if defined(_TK)
#include "tk.m"
#endif 

#if defined(_TK) || defined(_XLIB_H_)
#if !defined(_XLIB) && !defined(_XLIB_H_)
#include "Xlib.h"
#endif
#if defined(_XLIB_H) && !defined(_XLIB)
#define _XLIB
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
#ifdef _TIXIMGXPM
#include "tixImgXpm.m"
#endif
#ifdef _TKWIN
#include "tkWin.m"
#endif
#ifdef _TKWININT
#include "tkWinInt.m"
#endif
#ifdef _IMGINT
#include "imgInt.m"
#endif

