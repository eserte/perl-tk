/*
  Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/
#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tixPort.h"
#include "pTk/tixInt.h"
#include "tkGlue.h"
#include "tkGlue.m"
#include "pTk/tkVMacro.h"


DECLARE_VTABLES;
TixVtab     *TixVptr     ;
TixintVtab  *TixintVptr  ;

MODULE = Tk::TixGrid	PACKAGE = Tk

PROTOTYPES: DISABLE

void
tixGrid(...)
CODE:
 {
  XSRETURN(XSTkCommand(cv,1,Tix_GridCmd,items,&ST(0)));
 }


BOOT:
 {
  IMPORT_VTABLES;
  TixVptr     =     (TixVtab *) SvIV(perl_get_sv("Tk::TixVtab",5));
  TixintVptr  =  (TixintVtab *) SvIV(perl_get_sv("Tk::TixintVtab",5));
 }
