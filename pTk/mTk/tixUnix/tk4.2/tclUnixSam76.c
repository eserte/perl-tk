/*
 * tclUnixSam76.c --
 *
 *	Initializes the Tcl stand-alone module Tcl version 7.6.
 *
 * Copyright (c) 1996, Expert Interface Technologies
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "tclPort.h"
#include "tclInt.h"

#include "tclSamLib.c"

int			SamTcl_Init _ANSI_ARGS_((Tcl_Interp *interp));

int
Tclsam_Init(interp)
    Tcl_Interp *interp;		/* Interpreter to initialize. */
{
    Tcl_Eval(interp, "set tcl_library {}");
    return LoadScripts(interp);
}
