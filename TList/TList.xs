/*
  Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
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
#include "pTk/tkVMacro.h"
#include "tkGlue.h"
#include "tkGlue.m"

extern int Tix_TListCmd _ANSI_ARGS_((ClientData,Tcl_Interp *,int, Arg *));

DECLARE_VTABLES;
TixVtab     *TixVptr     ; 
TixintVtab  *TixintVptr  ; 

MODULE = Tk::TList	PACKAGE = Tk::TList

PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  TixVptr     =     (TixVtab *) SvIV(perl_get_sv("Tk::TixVtab",5));    
  TixintVptr  =  (TixintVtab *) SvIV(perl_get_sv("Tk::TixintVtab",5)); 
  Lang_TkCommand("tlist",Tix_TListCmd);
 }
