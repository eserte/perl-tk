/* tixWidget.c --
 *
 *	Constructs Tix-based compound widgets
 */

#include <tclInt.h>
#include <tkPort.h>
#include <tk.h>
#include <tix.h>

static int			ParseOptions _ANSI_ARGS_((
				    Tcl_Interp * interp,TixClassRecord * cPtr,
				    char *widRec, int argc, char** argv));

TIX_DECLARE_CMD(Tix_InstanceCmd);

/*----------------------------------------------------------------------
 * Tix_CreateWidgetCmd
 *
 * 	Create an instance object of a Tix widget class.
 *
 * argv[0]  = object name.
 * argv[1+] = args 
 */
TIX_DEFINE_CMD(Tix_CreateWidgetCmd)
{
    TixClassRecord * cPtr;
    char * widRec;
    char * rootCmd = NULL;
    int    i, code = TCL_OK;
    char   * tmpArgv[3];
    char * value;
    TixConfigSpec * spec;

    if (argc <= 1) {
	return Tix_ArgcError(interp, argc, argv, 1, "pathname ?arg? ...");
    }

    cPtr = (TixClassRecord *)clientData;
    widRec = argv[1];

    /* Set up the widget record */
    rootCmd = ckalloc(strlen(widRec)+10);
    sprintf(rootCmd, "%s:root", widRec);
    Tcl_SetVar2(interp, widRec, "className", cPtr->className, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "ClassName", cPtr->ClassName, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "context",   cPtr->className, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "w:root",    widRec,  	      TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "rootCmd",   rootCmd,         TCL_GLOBAL_ONLY);

    /* We need to create the root widget in order to parse the options
     * database
     */
    if (Tix_CallMethod(interp, cPtr->className, widRec, "CreateRootWidget",
	    argc-2, argv+2) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    Tcl_ResetResult(interp);
    /* Parse the options specified in the option database and supplied
     * in the command line.
     */
    if (ParseOptions(interp, cPtr, widRec, argc-2, argv+2) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* Rename the root widget command and create a new TCL command for
     * this widget
     */
    tmpArgv[0] = "rename";
    tmpArgv[1] = widRec;
    tmpArgv[2] = rootCmd;

    if (Tcl_RenameCmd((ClientData)0, interp, 3, tmpArgv) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    Tcl_CreateCommand(interp, widRec, Tix_InstanceCmd,
	(ClientData)cPtr, (void (*)()) NULL);

    /* Now call the initialization methods defined by the Tix Intrinsics
     */
    if (Tix_CallMethod(interp, cPtr->className, widRec, "InitWidgetRec",
	    0, 0) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    if (Tix_CallMethod(interp, cPtr->className, widRec, "ConstructWidget",
	    0, 0) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    if (Tix_CallMethod(interp, cPtr->className, widRec, "SetBindings",
		0, 0) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* The widget has been successfully initialized. Now call the config
     * method for all -forceCall options
     */
    for (i=0; i<cPtr->nSpecs; i++) {
	spec = cPtr->specs[i];
	if (spec->forceCall) {
	    value = Tcl_GetVar2(interp, widRec, spec->argvName,
		TCL_GLOBAL_ONLY);
	    if (Tix_CallConfigMethod(interp, cPtr, widRec, spec,
		    value)!=TCL_OK){
		code = TCL_ERROR;
		goto done;
	    }
	}
    }

    Tcl_SetResult(interp, widRec, TCL_VOLATILE);

  done:
    if (code != TCL_OK) {
	/* %% TCL CORE USED !! %% */
	Interp *iPtr = (Interp *) interp;
	char * oldResult, * oldErrorInfo, * oldErrorCode;
	Tk_Window topLevel, tkwin;

	/* We need to save the old error message because
	 * interp->result may be changed by some of the following function
	 * calls.
	 */
	if (interp->result) {
	    oldResult = (char*)strdup(interp->result);
	} else {
	    oldResult = NULL;
	}
	oldErrorInfo = Tcl_GetVar2(interp, "errorInfo", NULL, TCL_GLOBAL_ONLY);
	oldErrorCode = Tcl_GetVar2(interp, "errorCode", NULL, TCL_GLOBAL_ONLY);

	Tcl_ResetResult(interp);

	/* (1) window */
	topLevel = cPtr->mainWindow;

	if (tkwin = Tk_NameToWindow(interp, widRec, topLevel)) {
	    Tk_DestroyWindow(tkwin);
	}

	/* (2) widget command + root command */
	Tcl_DeleteCommand(interp, widRec);
	Tcl_DeleteCommand(interp, rootCmd);

	/* (3) widget record */
	Tcl_UnsetVar(interp, widRec, TCL_GLOBAL_ONLY);

	if (oldResult) {
	    Tcl_SetResult(interp, oldResult, TCL_DYNAMIC);
	}
	if (oldErrorInfo) {
	    Tcl_SetVar2(interp, "errorInfo", NULL, oldErrorInfo,
		TCL_GLOBAL_ONLY);
	}
	if (oldErrorCode) {
	    Tcl_SetVar2(interp, "errorInfo", NULL, oldErrorInfo,
		TCL_GLOBAL_ONLY);
	}
	iPtr->flags |= ERR_IN_PROGRESS;
    }
    if (rootCmd) {
	ckfree(rootCmd);
    }

    return code;
}

/*----------------------------------------------------------------------
 * Subroutines for object instantiation.
 *
 *
 *----------------------------------------------------------------------
 */
static int ParseOptions(interp, cPtr, widRec, argc, argv)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char *widRec;
    int argc;
    char** argv;
{
    int i;
    int flag = TCL_GLOBAL_ONLY;
    TixConfigSpec *spec;
    Tk_Window tkwin;
    char * value;
    static Tk_Window topLevel = NULL;

    if ((argc %2) != 0) {
	Tcl_AppendResult(interp, "missing argument for \"", argv[argc-1],
	    "\"", NULL);
	return TCL_ERROR;
    }

    if (topLevel == NULL) {
	topLevel = Tk_MainWindow(interp);
    }

    if ((tkwin = Tk_NameToWindow(interp, widRec, topLevel)) == NULL) {
	return TCL_ERROR;
    }

    /* Set all specs by their default values */
    for (i=0; i<cPtr->nSpecs; i++) {
	spec = cPtr->specs[i];

	if (!spec->isAlias) {
	    if ((value=Tk_GetOption(tkwin,spec->dbName,spec->dbClass))==NULL) {
		value = spec->defValue;
	    }
	    if (Tix_ChangeOneOption(interp, cPtr, widRec, spec,
		value, 1, 0)!=TCL_OK) {
		return TCL_ERROR;
	    }
	}
    }

    /* Set specs according to argument line values */
    for (i=0; i<argc; i+=2) {
	spec = Tix_FindConfigSpecByName(interp, cPtr, argv[i]);

	if (spec == NULL) {	/* this is an invalid flag */
	    return TCL_ERROR;
	}
	
	if (Tix_ChangeOneOption(interp, cPtr, widRec, spec,
		argv[i+1], 0, 1)!=TCL_OK) {
	    return TCL_ERROR;
	}
    }

    return TCL_OK;
}
