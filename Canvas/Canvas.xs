/*
  Copyright (c) 1995 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "../tkGlue.def"

#include "tkPort.h"
#include "tkInt.h"
#include "tkVMacro.h"
#include "../tkGlue.h"
#include "../tkGlue.m"

DECLARE_VTABLES;

MODULE = Tk::Canvas	PACKAGE = Tk::Canvas

BOOT:
 {
  IMPORT_VTABLES;
  Lang_TkCommand("canvas", Tk_CanvasCmd);
 }
