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
#include "pTk/tix.h"
#include "pTk/tixInt.h"
#include "pTk/tkVMacro.h"
#include "tkGlue.h"
#include "tkGlue.m"

extern int Tix_NoteBookFrameCmd _ANSI_ARGS_((ClientData,Tcl_Interp *,int, Arg *));

DECLARE_VTABLES;    
TixVtab     *TixVptr     ; 
TixintVtab  *TixintVptr  ; 

MODULE = Tk::NBFrame	PACKAGE = Tk

PROTOTYPES: DISABLE

void
nbframe(...)
CODE:
 {
  XSRETURN(XSTkCommand(cv,Tix_NoteBookFrameCmd,items,&ST(0)));
 }


BOOT:
 {
  IMPORT_VTABLES;
  TixVptr     =     INT2PTR(TixVtab *, SvIV(perl_get_sv("Tk::TixVtab",5)));
  TixintVptr  =  INT2PTR(TixintVtab *, SvIV(perl_get_sv("Tk::TixintVtab",5)));
 }
