/* usually an application will do the following:
 *
 *	(1) call Tix_WishInit()
 *	(2) initialize optional TCL/TK modules
 *	(3) initialize application modules
 *	(4) call Tix_MainLoop();
 */

#include <stdio.h>
#include <tkPort.h>
#include <tk.h>
#include <tixInt.h>

/*
 * Declarations for various library procedures and variables (don't want
 * to include tkInt.h or tkConfig.h here, because people might copy this
 * file out of the Tk source directory to make their own modified versions).
 */

/*
 * Global variables used by the main program:
 */

static char errorExitCmd[] = "exit 1";

/*
 * Command-line options:
 */
#define INTERACTIVE_DEFAULT 3

static int  interactive	= INTERACTIVE_DEFAULT;
static char *fileName	= NULL;
static int  synchronize	= 0;
static char *name	= NULL;
static char *display	= NULL;
static char *geometry	= NULL;
static char *tix_RcFileName;

static Tk_ArgvInfo argTable[] = {
    {"-file", TK_ARGV_STRING, (char *) NULL, (char *) &fileName,
	"File from which to read commands"},
    {"-geometry", TK_ARGV_STRING, (char *) NULL, (char *) &geometry,
	"Initial geometry for window"},
    {"-display", TK_ARGV_STRING, (char *) NULL, (char *) &display,
	"Display to use"},
    {"-name", TK_ARGV_STRING, (char *) NULL, (char *) &name,
	"Name to use for application"},
    {"-sync", TK_ARGV_CONSTANT, (char *) 1, (char *) &synchronize,
	"Use synchronous mode for display server"},
    {"-interactive", TK_ARGV_CONSTANT, (char *) 1, (char *) &interactive,
	"Use interactive shell input"},
    {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,
	(char *) NULL}
};


/*
 *----------------------------------------------------------------------
 *
 * Tix_WishInit()
 *
 * This function does the following:
 *	initialize the main modules of tixwish : TCL, TK and TIX.
 *	read from the standard input (optional)
 *
 *----------------------------------------------------------------------
 */
Tcl_Interp * Tix_WishInit(argcPtr, argv, rcFileName, readStdin)
    int *argcPtr;			/* Number of arguments. */
    char **argv;			/* Array of argument strings. */
    char *rcFileName;
    int  readStdin;
{
    char *p, *msg;
    Tk_Window mainWindow;
    Tcl_Interp * interp;

    /* Initialize the main TCL interpreter
     *
     */
    interp = Tcl_CreateInterp();

#ifdef TCL_MEM_DEBUG
    Tcl_InitMemory(interp);
#endif

    /*
     * Parse command-line arguments.
     */
    if (argcPtr && argv) {
	if (Tk_ParseArgv(interp, (Tk_Window) NULL, argcPtr, argv, argTable, 0)
	        != TCL_OK) {
	    fprintf(stderr, "%s\n", interp->result);
	    exit(1);
	}
    }

    if (fileName == NULL) {
	if (argcPtr && (*argcPtr) >= 2) {
	    int i;
	    fileName = argv[1];
	    for (i=2; i<(*argcPtr); i++) {
		argv[i-1] = argv[i];
	    }
	    (*argcPtr) --;
	}
    }
    if (fileName != NULL && strcmp(fileName, "-") == 0) {
	fileName = NULL;
    }

    /*
     * Get the name of the application.
     */
    if (name == NULL) {
	if (fileName != NULL) {
	    p = fileName;
	} else if (argcPtr && argv) {
	    p = argv[0];
	} else {
	    p = "tixwish";
	}
	name = strrchr(p, '/');
	if (name != NULL) {
	    name++;
	} else {
	    name = p;
	}
    }

    /*
     * If a display was specified, put it into the DISPLAY
     * environment variable so that it will be available for
     * any sub-processes created by us.
     */

    if (display != NULL) {
	Tcl_SetVar2(interp, "env", "DISPLAY", display, TCL_GLOBAL_ONLY);
    }

    /*
     * Initialize the Tk main window
     */

    mainWindow = Tk_CreateMainWindow(interp, display, name, "Tk");

    if (mainWindow == NULL) {
	fprintf(stderr, "%s\n", interp->result);
	exit(1);
    }
    if (synchronize) {
	XSynchronize(Tk_Display(mainWindow), True);
    }
    Tk_GeometryRequest(mainWindow, 200, 200);

    /*
     * Make command-line arguments available in the Tcl variables "argc"
     * and "argv".  Also set the "geometry" variable from the geometry
     * specified on the command line.
     */
    if (argcPtr && argv) {
	Tix_SetArgv(interp, *argcPtr, argv);
    } else {
	Tix_SetArgv(interp, 0, 0);
    }

    if (fileName) {
	Tcl_SetVar(interp, "argv0", fileName, TCL_GLOBAL_ONLY);
    } else if (argv && argv[0]) {
	Tcl_SetVar(interp, "argv0", argv[0], TCL_GLOBAL_ONLY);
    } else {
	Tcl_SetVar(interp, "argv0", "tixwish", TCL_GLOBAL_ONLY);
    }

    if (geometry != NULL) {
	Tcl_SetVar(interp, "geometry", geometry, TCL_GLOBAL_ONLY);
    }

    /*
     * Set the "tcl_interactive" variable. This variable is set to true
     * if wish gives an interactive prompt.
     */

    if (fileName && (interactive == INTERACTIVE_DEFAULT)) {
	interactive = 0;
    }

#if 0
    switch (readStdin) {
      case TIX_STDIN_ALWAYS:
	interactive = 1;
	break;
      case TIX_STDIN_NONE:
	interactive = 0;
    }

    if (!isatty(0)) {
	interactive = 0;
    }
#endif

    Tcl_SetVar(interp, "tcl_interactive",
	(interactive) ? "1" : "0", TCL_GLOBAL_ONLY);

    /*
     *
     * Initialize all the *system* modules: tcl, tk and tix.
     *
     * Other modules are initialized by the application.
     *
     */
    if (Tcl_Init(interp) == TCL_ERROR) {
	goto error;
    }
    if (Tk_Init(interp) == TCL_ERROR) {
	goto error;
    }
    if (Tix_Init_Internal(interp, argcPtr, argv, 1) == TCL_ERROR) {
	goto error;
    }

    /*
     * This file is sourced in when Tix_MainLoop() is called.
     */
    tix_RcFileName = rcFileName;

    return interp;

error:
    msg = Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY);
    if (msg == NULL) {
	msg = interp->result;
    }
    fprintf(stderr, "%s\n", msg);
    Tcl_Eval(interp, errorExitCmd);	/* This will exit the wish program */

    return NULL;			/* Needed only to prevent
					 * compiler warnings. */
}



/* Tix_SetArgv()
 *
 * This sets the "argv" TCL variable. When different packages
 * start up, they may change the argv of the application. This
 * function maintains the consistency of "argv" between C and TCL modules.
 *
 */
void Tix_SetArgv(interp, argc, argv)
    Tcl_Interp * interp;
    int argc;
    char ** argv;
{
    char * args;
    char buf[10];

    if (argc && argv) {
	args = Tcl_Merge(argc-1, argv+1);
	Tcl_SetVar(interp, "argv", args, TCL_GLOBAL_ONLY);
	ckfree(args);
	sprintf(buf, "%d", argc-1);
	Tcl_SetVar(interp, "argc", buf, TCL_GLOBAL_ONLY);
    } else {
	Tcl_SetVar(interp, "argv", "", TCL_GLOBAL_ONLY);
    }
}

/* This is an internal procedure */
int Tix_AppStart(interp)
   Tcl_Interp * interp;
{
    int    code;
    char * inter;

    /*
     * Invoke the script specified on the command line, if any.
     */

    if (fileName != NULL) {
	code = Tcl_VarEval(interp, "source ", fileName, (char *) NULL);
	if (code != TCL_OK) {
	    goto error;
	}
    } else {
	/*
	 * If the a .rc file is supplied, then read it in.
	 */
	if (tix_RcFileName != NULL) {
	    Tcl_DString buffer;
	    char *fullName;
	    FILE *f;
    
	    fullName = Tcl_TildeSubst(interp, tix_RcFileName, &buffer);
	    if (fullName == NULL) {
		fprintf(stderr, "%s\n", interp->result);
	    } else {
		f = fopen(fullName, "r");
		if (f != NULL) {
		    code = Tcl_EvalFile(interp, fullName);
		    if (code != TCL_OK) {
			fprintf(stderr, "%s\n", interp->result);
		    }
		    fclose(f);
		}
	    }
	    Tcl_DStringFree(&buffer);
	}
    }

    /*
     * The TIX_DEBUG_INTERACTIVE environment variable
     * has a higher precedence
     */
    inter = getenv("TIX_DEBUG_INTERACTIVE");
    if (inter) {
	Tcl_SetVar(interp, "tcl_interactive", "1", TCL_GLOBAL_ONLY);
    }

    inter = Tcl_GetVar(interp, "tcl_interactive", TCL_GLOBAL_ONLY);
    if (inter) {
	if (Tcl_GetBoolean(interp, inter, &interactive) != TCL_OK) {
	    interactive = 0;
	}
    }

    if (interactive) {
	Tix_OpenStdin(interp);
    }

    fflush(stdout);
    return TCL_OK;
  error:
    return TCL_ERROR;
}


void Tix_MainLoop(interp)
   Tcl_Interp * interp;
{
    char * msg;

    if (Tix_AppStart(interp) != TCL_OK) {
	msg = Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY);
	if (msg == NULL) {
	    msg = interp->result;
	}
	fprintf(stderr, "%s\n", msg);
	Tcl_Eval(interp, errorExitCmd);	/* This will exit the wish program */
    }

    Tk_MainLoop();
}
