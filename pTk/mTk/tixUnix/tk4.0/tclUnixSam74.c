/*
 * tclUnixSam74.c --
 *
 *	Initializes the stand alone module for Tcl 7.4.
 *
 */

#include "tcl.h"

#include "tclSamLib.c"

int		SamTcl_Init _ANSI_ARGS_((Tcl_Interp *interp));

int
Tclsam_Init(interp)
    Tcl_Interp *interp;		/* Interpreter to initialize. */
{
    Tcl_Eval(interp, "set tcl_library {}");
    return LoadScripts(interp);
}
