/*
 * tclUnixSam40.c --
 *
 *	Initializes the stand alone module for Tk 4.0.
 *
 */

#include "tk.h"

#include "tkSamLib.c"

int		SamTk_Init _ANSI_ARGS_((Tcl_Interp *interp));

int
Tksam_Init(interp)
    Tcl_Interp *interp;		/* Interpreter to initialize. */
{
    Tcl_Eval(interp, "set tk_library {}");
    return LoadScripts(interp);
}
