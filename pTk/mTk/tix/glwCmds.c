/* 
 * glwCmds.c
 *
 *	TCL bindings of Various GL commands.
 */
#include <tk.h>
#include <tix.h>
#include <gl.h>

/*
 * Calls gflush() so that GL graphics calls are flushed to the display
 * hardware.
 *
 * argv = none
 *
 */
TIX_DEFINE_CMD(glw_Flush)
{
    if (argc!=1) {
	return Tix_ArgcError(interp, argc, argv, 1, "");
    }

    gflush();

    return TCL_OK;
}
