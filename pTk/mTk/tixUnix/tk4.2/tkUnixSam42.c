/*
 * tkUnixSam42.c --
 *
 *	Initializes the Tk stand-alone module Tk version 4.2.
 *
 * Copyright (c) 1996, Expert Interface Technologies
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include <tkPort.h>
#include <tkInt.h>

#if defined(__WIN32__) || defined(_WIN32)
#   define SAMTK_WINDOWS
#else
#   if defined(MAC_TCL)
#	define SAMTK_MAC
#   else
#	define SAMTK_UNIX
#       include <tkUnixInt.h>
#   endif
#endif

int			SamTk_Init _ANSI_ARGS_((Tcl_Interp *interp));

#include "tkSamLib.c"

static int
SamTkPlatformInit(interp)
    Tcl_Interp * interp;
{
#ifdef SAMTK_UNIX
    TkCreateXEventSource();
#endif
    Tcl_Eval(interp, "set tk_library {}");
    return LoadScripts(interp);
}

/*
 * The variables and table below are used to parse arguments from
 * the "argv" variable in Tk_Init.
 */

static int synchronize;
static char *name;
static char *display;
static char *geometry;
static char *colormap;
static char *visual;
static int rest = 0;

static Tk_ArgvInfo argTable[] = {
    {"-colormap", TK_ARGV_STRING, (char *) NULL, (char *) &colormap,
	"Colormap for main window"},
    {"-display", TK_ARGV_STRING, (char *) NULL, (char *) &display,
	"Display to use"},
    {"-geometry", TK_ARGV_STRING, (char *) NULL, (char *) &geometry,
	"Initial geometry for window"},
    {"-name", TK_ARGV_STRING, (char *) NULL, (char *) &name,
	"Name to use for application"},
    {"-sync", TK_ARGV_CONSTANT, (char *) 1, (char *) &synchronize,
	"Use synchronous mode for display server"},
    {"-visual", TK_ARGV_STRING, (char *) NULL, (char *) &visual,
	"Visual for main window"},
    {"--", TK_ARGV_REST, (char *) 1, (char *) &rest,
	"Pass all remaining arguments through to script"},
    {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,
	(char *) NULL}
};

int
Tksam_Init(interp)
    Tcl_Interp *interp;		/* Interpreter to initialize. */
{
    char *p;
    int argc, code;
    char **argv, *args[20];
    Tcl_DString class;
    char buffer[30];

    /*
     * If there is an "argv" variable, get its value, extract out
     * relevant arguments from it, and rewrite the variable without
     * the arguments that we used.
     */

    synchronize = 0;
    name = display = geometry = colormap = visual = NULL; 
    p = Tcl_GetVar2(interp, "argv", (char *) NULL, TCL_GLOBAL_ONLY);
    argv = NULL;
    if (p != NULL) {
	if (Tcl_SplitList(interp, p, &argc, &argv) != TCL_OK) {
	    argError:
	    Tcl_AddErrorInfo(interp,
		    "\n    (processing arguments in argv variable)");
	    return TCL_ERROR;
	}
	if (Tk_ParseArgv(interp, (Tk_Window) NULL, &argc, argv,
		argTable, TK_ARGV_DONT_SKIP_FIRST_ARG|TK_ARGV_NO_DEFAULTS)
		!= TCL_OK) {
	    ckfree((char *) argv);
	    goto argError;
	}
	p = Tcl_Merge(argc, argv);
	Tcl_SetVar2(interp, "argv", (char *) NULL, p, TCL_GLOBAL_ONLY);
	sprintf(buffer, "%d", argc);
	Tcl_SetVar2(interp, "argc", (char *) NULL, buffer, TCL_GLOBAL_ONLY);
	ckfree(p);
    }

    /*
     * Figure out the application's name and class.
     */

    if (name == NULL) {
	name = Tcl_GetVar(interp, "argv0", TCL_GLOBAL_ONLY);
	if ((name == NULL) || (*name == 0)) {
	    name = "tk";
	} else {
	    p = strrchr(name, '/');
	    if (p != NULL) {
		name = p+1;
	    }
	}
    }
    Tcl_DStringInit(&class);
    Tcl_DStringAppend(&class, name, -1);
    p = Tcl_DStringValue(&class);
    if (islower(*p)) {
	*p = toupper((unsigned char) *p);
    }

    /*
     * Create an argument list for creating the top-level window,
     * using the information parsed from argv, if any.
     */

    args[0] = "toplevel";
    args[1] = ".";
    args[2] = "-class";
    args[3] = Tcl_DStringValue(&class);
    argc = 4;
    if (display != NULL) {
	args[argc] = "-screen";
	args[argc+1] = display;
	argc += 2;

	/*
	 * If this is the first application for this process, save
	 * the display name in the DISPLAY environment variable so
	 * that it will be available to subprocesses created by us.
	 */

	if (Tk_GetNumMainWindows() == 0) {
	    Tcl_SetVar2(interp, "env", "DISPLAY", display, TCL_GLOBAL_ONLY);
	}
    }
    if (colormap != NULL) {
	args[argc] = "-colormap";
	args[argc+1] = colormap;
	argc += 2;
    }
    if (visual != NULL) {
	args[argc] = "-visual";
	args[argc+1] = visual;
	argc += 2;
    }
    args[argc] = NULL;
    code = TkCreateFrame((ClientData) NULL, interp, argc, args, 1, name);
    Tcl_DStringFree(&class);
    if (code != TCL_OK) {
	goto done;
    }
    Tcl_ResetResult(interp);
    if (synchronize) {
	XSynchronize(Tk_Display(Tk_MainWindow(interp)), True);
    }

    /*
     * Set the geometry of the main window, if requested.  Put the
     * requested geometry into the "geometry" variable.
     */

    if (geometry != NULL) {
	Tcl_SetVar(interp, "geometry", geometry, TCL_GLOBAL_ONLY);
	code = Tcl_VarEval(interp, "wm geometry . ", geometry, (char *) NULL);
	if (code != TCL_OK) {
	    goto done;
	}
    }
    if (Tcl_PkgRequire(interp, "Tcl", TCL_VERSION, 1) == NULL) {
	code = TCL_ERROR;
	goto done;
    }
    code = Tcl_PkgProvide(interp, "Tk", TK_VERSION);
    if (code != TCL_OK) {
	goto done;
    }

    /*
     * Invoke platform-specific initialization.
     */

    code = SamTkPlatformInit(interp);

    done:
    if (argv != NULL) {
	ckfree((char *) argv);
    }
    return code;
}

