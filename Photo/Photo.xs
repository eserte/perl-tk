/*
  Copyright (c) 1995 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#define Tcl_Interp SV 

#include "tkPort.h"
#include "tkInt.h"
#include "tkVMacro.h"
#include "../tkGlue.h"
#include "../tkGlue.m"
#include "tkImgPhoto.h"
#include "tkImgPhoto.m"

DECLARE_VTABLES;


MODULE = Tk::Photo	PACKAGE = Tk::Photo

BOOT:
 {
  IMPORT_VTABLES;
  sv_setiv(FindTkVarName("TkimgphotoVtab",1),(IV) TkimgphotoVGet());   
  Tk_CreateImageType(&tkPhotoImageType);
  Tk_CreatePhotoImageFormat(&tkImgFmtPPM);
  Tk_CreatePhotoImageFormat(&tkImgFmtGIF);
 }
