/* main_sgi.c
 *
 * This is a generic main for Tix 4.0 with the SGI widgets installed.
 * Edit to suit your application. I wrote this
 * file because it is just too cumbersome to use Tcl_Appinit(). Also, many
 * applications would like to have its own main() function instead of the
 * one found in tkMain.c
 *
 */
#include <tk.h>
#include <tix.h>

main(int argc, char ** argv)
{
    Tcl_Interp * interp;

    /* Initialize the Tix wish shell:
     *	- create an interpreter
     *  - create the main window [in Tk_MainWindow(interp)]
     *
     * The third argument is the application run-time command (rc) file.
     *
     * The fourth argument specifies whether wish should prompt and read
     * from the standard input. Possible values are:
     *
     * 		TIX_STDIN_ALWAYS
     *		TIX_STDIN_OPTIONAL
     *		TIX_STDIN_NONE
     *
     */
#if 0
    /*
     * don't prompt, don't parse command-line, argv, don't read rc file
     */
    interp = Tix_WishInit(0, 0, 0, TIX_STDIN_NONE);
#else
    /*
     * parse command-line, argv, read rc file
     * always prompt required.
     */
    interp = Tix_WishInit(&argc, argv, "~/.tixwishrc", TIX_STDIN_ALWAYS);
#endif

    /*
     * Initialize other optional modules here
     */

    if (TkGLX_Init(interp, Tk_MainWindow(interp))== TCL_ERROR) {
	fprintf(stderr, "TkGLX_Init() failed: %s\n", interp->result);
	exit(1);
    }


    if (TixGLW_Init(interp) == TCL_ERROR) {
	fprintf(stderr, "TixGLW_Init() failed: %s\n", interp->result);
	exit(1);
    }

    /*
     * Loop infinitely, waiting for commands to execute.  When there
     * are no windows left, Tk_MainLoop returns and we exit.
     */

    Tix_MainLoop(interp);

    /*
     * Don't exit directly, but rather invoke the Tcl "exit" command.
     * This gives the application the opportunity to redefine "exit"
     * to do additional cleanup.
     */

    Tix_Exit(interp, 0);
}
