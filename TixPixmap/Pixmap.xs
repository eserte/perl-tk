/*
  Copyright (c) 1995-2000 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tixPort.h"
#include "pTk/tixInt.h"
#include "pTk/tixImgXpm.h"
#include "tkGlue.h"
#include "tkGlue.m"
#include "pTk/tkVMacro.h"

DECLARE_VTABLES;
TixVtab     *TixVptr     ;
TixintVtab  *TixintVptr  ;
TiximgxpmVtab  *TiximgxpmVptr  ;

extern Tk_ImageType tixPixmapImageType;

static void  Install _((char *, TkWindow *win));

static void
Install(class,winPtr)
char *class;
TkWindow *winPtr;
{
 TkMainInfo *mainInfo = winPtr->mainPtr;
 if (mainInfo)
  {
   Tcl_Interp *Et_Interp = mainInfo->interp;
   if (Et_Interp)
    {
#ifdef WIN32
#pragma warning(disable: 4305)
#endif
#define UNSIGNED_CHAR unsigned char
#include "pTk/tixBitmaps.h"
    }
  }
}


MODULE = Tk::Pixmap	PACKAGE = Tk::Pixmap

PROTOTYPES: DISABLE

void
Install(class,win)
char *		class
TkWindow *	win

BOOT:
 {
  IMPORT_VTABLES;
  TixVptr     =     (TixVtab *) SvIV(perl_get_sv("Tk::TixVtab",5));
  TixintVptr  =  (TixintVtab *) SvIV(perl_get_sv("Tk::TixintVtab",5));
  TiximgxpmVptr  =  (TiximgxpmVtab *) SvIV(perl_get_sv("Tk::TiximgxpmVtab",5));

  Tk_CreateImageType(&tixPixmapImageType);
 }
