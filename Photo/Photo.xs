/*
  Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tkVMacro.h"
#include "pTk/tkImgPhoto.h"
#include "pTk/tkImgPhoto.m"
#include "pTk/imgInt.h"
#include "pTk/imgInt.m"
#include "tkGlue.h"
#include "tkGlue.m"

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
  sv_setiv(FindTkVarName("TkimgphotoVtab",1),(IV) TkimgphotoVGet());   
  sv_setiv(FindTkVarName("ImgintVtab",1),(IV) ImgintVGet());   
  Tk_CreateImageType(&tkPhotoImageType);
  Tk_CreatePhotoImageFormat(&tkImgFmtPPM);
  Tk_CreatePhotoImageFormat(&imgFmtGIF);
  Tk_CreatePhotoImageFormat(&imgFmtXBM);
  Tk_CreatePhotoImageFormat(&imgFmtXPM);
  Tk_CreatePhotoImageFormat(&imgFmtBMP);
 }
