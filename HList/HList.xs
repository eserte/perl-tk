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
#include "tix.h"
#include "tixInt.h"
#include "../tkGlue.h"
#include "../tkGlue.m"

extern int Tix_HListCmd _ANSI_ARGS_((ClientData,Tcl_Interp *,int, Arg *));
extern Tix_DItemInfo tix_TextItemType;
extern Tix_DItemInfo tix_ImageTextType;
extern Tix_DItemInfo tix_WindowItemType;

DECLARE_VTABLES;

MODULE = Tk::HList	PACKAGE = Tk::HList

BOOT:
 {
  IMPORT_VTABLES;
  /* Initialize the display item types */

  Tix_AddDItemType(&tix_TextItemType);  
  Tix_AddDItemType(&tix_ImageTextType); 
  Tix_AddDItemType(&tix_WindowItemType);

  Lang_TkCommand("hlist",Tix_HListCmd);
 }
