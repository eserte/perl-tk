/*
  Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#define Tcl_Interp SV 

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tkVMacro.h"
#include "pTk/tkImgPhoto.h"
#include "pTk/tkImgPhoto.m"
#include "tkGlue.h"
#include "tkGlue.m"

/* Old here means FILE * rather than Tcl_Chan 
 * Switch to later ASAP ...
 */
extern Tk_PhotoImageFormat	imgOldFmtBMP;
extern Tk_PhotoImageFormat	imgOldFmtGIF;
extern Tk_PhotoImageFormat	imgOldFmtXBM;
extern Tk_PhotoImageFormat	imgOldFmtXPM;


DECLARE_VTABLES;


MODULE = Tk::Photo	PACKAGE = Tk::Photo

PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  sv_setiv(FindTkVarName("TkimgphotoVtab",1),(IV) TkimgphotoVGet());   
  Tk_CreateImageType(&tkPhotoImageType);
  Tk_CreatePhotoImageFormat(&tkImgFmtPPM);
  Tk_CreatePhotoImageFormat(&imgOldFmtGIF);
  Tk_CreatePhotoImageFormat(&imgOldFmtXBM);
  Tk_CreatePhotoImageFormat(&imgOldFmtXPM);
  Tk_CreatePhotoImageFormat(&imgOldFmtBMP);
 }
