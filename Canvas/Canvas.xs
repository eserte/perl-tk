/*
  Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
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
#include "tkGlue.h"
#include "tkGlue.m"

DECLARE_VTABLES;

extern Tk_ItemType ptkCanvGridType;
extern Tk_ItemType ptkCanvGroupType;


MODULE = Tk::Canvas	PACKAGE = Tk

void
canvas(...)
CODE:
 {
  XSRETURN(XSTkCommand(cv,(Tcl_CmdProc *)Tk_CanvasObjCmd,items,&ST(0)));
 }


PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  Tk_CreateItemType(&ptkCanvGridType);
  Tk_CreateItemType(&ptkCanvGroupType);
 }
