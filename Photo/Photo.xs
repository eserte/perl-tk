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
#include "tkGlue.h"
#include "tkGlue.m"
#include "pTk/tkVMacro.h"
#include "pTk/tkImgPhoto.h"
#include "pTk/tkImgPhoto.m"
#include "pTk/imgInt.h"
#include "pTk/imgInt.m"

extern Tk_PhotoImageFormat	imgFmtBMP;
extern Tk_PhotoImageFormat	imgFmtGIF;
extern Tk_PhotoImageFormat	imgFmtXBM;
extern Tk_PhotoImageFormat	imgFmtXPM;


DECLARE_VTABLES;


MODULE = Tk::Photo	PACKAGE = Tk::Photo

PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  install_vtab("TkimgphotoVtab",TkimgphotoVGet(),sizeof(TkimgphotoVtab));
  install_vtab("ImgintVtab",ImgintVGet(),sizeof(ImgintVtab));
  Tk_CreateImageType(&tkPhotoImageType);
#if 0
  Tk_CreatePhotoImageFormat(&tkImgFmtPPM);
#endif
  Tk_CreateOldPhotoImageFormat(&tkImgFmtPPM);
  Tk_CreatePhotoImageFormat(&imgFmtGIF);
  Tk_CreatePhotoImageFormat(&imgFmtXBM);
  Tk_CreatePhotoImageFormat(&imgFmtXPM);
  Tk_CreatePhotoImageFormat(&imgFmtBMP);
 }
