/* 
 * tixUtils.c
 *
 *	This file contains some utility functions for Tix, such as
 * the subcommand handling functions and option handling functions.
 *
 */

#include <tkPort.h>
#include <tk.h>
#include <tix.h>

/*
 * Declarations for various library procedures and variables (don't want
 * to include tkInt.h or tkConfig.h here, because people might copy this
 * file out of the Tk source directory to make their own modified versions).
 */

/*
 * Forward declarations for procedures defined later in this file:
 */

static void		Prompt _ANSI_ARGS_((Tcl_Interp *interp, int partial));
static void		StdinProc _ANSI_ARGS_((ClientData clientData,
			    int mask));

/*
 * Some ugly but necessary global vars used in this file
 */
static Tcl_DString command;	/* Used to assemble lines of terminal input
				 * into Tcl commands. */


/* Tix_HandleSubCmds --
 *
 *	This function makes it easier to write major-minor style TCL commands.
 * It matches the minor command (sub-command) names with names defined in
 * the cmdInfo structure and call the appropriate sub-command functions for
 * you. This function will automatically generate error messages when
 * the user calls an invalid sub-command or calls a sub-command with
 * incorrect number of arguments.
 *
 */
int Tix_HandleSubCmds(cmdInfo, subCmdInfo, clientData, interp, argc, argv)
    Tix_CmdInfo * cmdInfo;
    Tix_SubCmdInfo * subCmdInfo;
    ClientData clientData;	/* Main window associated with
				 * interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    enum {WRONG_ARGC, NO_MATCH};

    int i;
    int len;
    int error = NO_MATCH;
    Tix_SubCmdInfo * s;

    /*
     * First check if the number of arguments to the major command 
     * is correct
     */
    argc -= 1;
    if (argc < cmdInfo->minargc || 
	(cmdInfo->maxargc != TIX_VAR_ARGS && argc > cmdInfo->maxargc)) {

	Tcl_AppendResult(interp, "wrong # args: should be \"",
	    argv[0], " ", cmdInfo->info, "\".", (char *) NULL);

	return TCL_ERROR;
    }

    /*
     * Now try to match the subcommands with argv[1]
     */
    argc -= 1;
    len = strlen(argv[1]);

    for (i = 0, s = subCmdInfo; i < cmdInfo->numSubCmds; i++, s++) {
	if (s->name == TIX_DEFAULT_SUBCMD) {
	    if (s->checkArgvProc) {
	      if (!((*s->checkArgvProc)(clientData, interp, argc+1, argv+1))) {
		    /* Some improper argv in the arguments of the default
		     * subcommand
		     */
		    break;
		}
	    }
	    return (*s->proc)(clientData, interp, argc+1, argv+1);
	}

	if (s->namelen == TIX_DEFAULT_LEN) {
	    s->namelen = strlen(s->name);
	}
	if (s->name[0] == argv[1][0] && strncmp(argv[1],s->name,len)==0) {
	    if (argc < s->minargc) {
		error = WRONG_ARGC;
		break;
	    }

	    if (s->maxargc != TIX_VAR_ARGS && 
		argc > s->maxargc) {
		error = WRONG_ARGC;
		break;
	    }

	    /*
	     * Here we have a matched argc and command name --> go for it!
	     */
	    return (*s->proc)(clientData, interp, argc, argv+2);
	}
    }

    if (error == WRONG_ARGC) {
	/*
	 * got a match but incorrect number of arguments
	 */
	Tcl_AppendResult(interp, "wrong # args: should be \"",
	    argv[0], " ", argv[1], " ", s->info, (char *) NULL);
    } else {
	int max;

	/*
	 * no match: let print out all the options
	 */
	Tcl_AppendResult(interp, "unknown option \"",
	    argv[1], "\".",  (char *) NULL);
	
	if (cmdInfo->numSubCmds == 0) {
	    max = 0;
	} else {
	    if (subCmdInfo[cmdInfo->numSubCmds-1].name == TIX_DEFAULT_SUBCMD) {
		max = cmdInfo->numSubCmds-1;
	    } else {
		max = cmdInfo->numSubCmds;
	    }
	}

	if (max == 0) {
	    Tcl_AppendResult(interp,
		" This command does not take any options.",
		(char *) NULL);
	} else if (max == 1) {
	    Tcl_AppendResult(interp, 
		" Must be ", subCmdInfo->name, ".", (char *)NULL);
	} else {
	    Tcl_AppendResult(interp, " Must be ", (char *) NULL);

	    for (i = 0, s = subCmdInfo; i < max; i++, s++) {
		if (i == max-1) {
		    Tcl_AppendResult(interp,"or ",s->name, ".", (char *) NULL);
		} else if (i == max-2) {
		    Tcl_AppendResult(interp, s->name, " ", (char *) NULL); 
		} else {
		    Tcl_AppendResult(interp, s->name, ", ", (char *) NULL); 
		}
	    }
	} 
    }
    return TCL_ERROR;
}

#if 0

/*
 * Tix_Exit
 *
 * Call the "exit" tcl command so that things can be cleaned up before
 * calling the unix exit(2);
 *
 */
void Tix_Exit(interp, code)
    Tcl_Interp* interp;
    int code;
{
    if (code != 0 && interp && interp->result != 0) {
	fprintf(stderr, "%s\n", interp->result);
	fprintf(stderr, "%s\n", 
	    Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY));
    }

    if (interp) {
	Tcl_Eval(interp, "exit");
    }
    exit(code);
}

/*
 * Tix_ShellInputCmd -
 *
 * This command forces wish to read from the standard input. This makes
 * debugging a lot easier.
 *
 * If wish is already reading from stdin, this command has no effect.
 *
 */
int Tix_ShellInputCmd(clientData, interp, argc, argv)
    ClientData clientData;	/* Main window associated with
				 * interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    Tix_OpenStdin(interp);

    return TCL_OK;
}


void Tix_OpenStdin(interp)
    Tcl_Interp *interp;
{
    static int stdin_opened = 0;

    if (stdin_opened ==  0)  {
	Tk_CreateFileHandler(0, TK_READABLE, StdinProc, (ClientData) interp);
	Prompt(interp, 0);
	Tcl_DStringInit(&command);

	stdin_opened = 1;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * StdinProc --
 *
 *	This procedure is invoked by the event dispatcher whenever
 *	standard input becomes readable.  It grabs the next line of
 *	input characters, adds them to a command being assembled, and
 *	executes the command if it's complete.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Could be almost arbitrary, depending on the command that's
 *	typed.
 *
 *----------------------------------------------------------------------
 */

    /* ARGSUSED */
static void
StdinProc(clientData, mask)
    ClientData clientData;		/* Not used. */
    int mask;				/* Not used. */
{
#define BUFFER_SIZE 4000
    char input[BUFFER_SIZE+1];
    static int gotPartial = 0;
    char *cmd;
    int code, count;
    Tcl_Interp * interp = (Tcl_Interp*)clientData;

    count = read(fileno(stdin), input, BUFFER_SIZE);
    if (isatty(0)) {
	if (count <= 0) {
	    if (!gotPartial) {
		/* The user has typed the end-of-file key
		 */
		Tcl_Eval(interp, "exit");
		exit(1);
	    } else {
		count = 0;
	    }
	}
    } else {
	if (count <= 0) {
	    /* End of file */
	    Tk_CreateFileHandler(0, 0, StdinProc, (ClientData) interp);
	    return;
	}
    }

    cmd = Tcl_DStringAppend(&command, input, count);
    if (count != 0) {
	if ((input[count-1] != '\n') && (input[count-1] != ';')) {
	    gotPartial = 1;
	    goto prompt;
	}
	if (!Tcl_CommandComplete(cmd)) {
	    gotPartial = 1;
	    goto prompt;
	}
    }
    gotPartial = 0;

    /*
     * Disable the stdin file handler while evaluating the command;
     * otherwise if the command re-enters the event loop we might
     * process commands from stdin before the current command is
     * finished.  Among other things, this will trash the text of the
     * command being evaluated.
     */

    Tk_CreateFileHandler(0, 0, StdinProc, (ClientData) interp);
    code = Tcl_RecordAndEval(interp, cmd, 0);
    Tk_CreateFileHandler(0, TK_READABLE, StdinProc, (ClientData) interp);
    Tcl_DStringFree(&command);
    if (interp->result != 0 && isatty(0)) {
	printf("%s\n", interp->result);
    }

    /*
     * Output a prompt.
     */

  prompt:
    Prompt(interp, gotPartial);
}

/*
 *----------------------------------------------------------------------
 *
 * Prompt --
 *
 *	Issue a prompt on standard output, or invoke a script
 *	to issue the prompt.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A prompt gets output, and a Tcl script may be evaluated
 *	in interp.
 *
 *----------------------------------------------------------------------
 */

static void
Prompt(interp, partial)
    Tcl_Interp *interp;			/* Interpreter to use for prompting. */
    int partial;			/* Non-zero means there already
					 * exists a partial command, so use
					 * the secondary prompt. */
{
    char *promptCmd;
    int code;

    promptCmd = Tcl_GetVar(interp,
	partial ? "tcl_prompt2" : "tcl_prompt1", TCL_GLOBAL_ONLY);
    if (promptCmd == NULL) {
	defaultPrompt:
	if (!partial && isatty(0)){
	    fputs("% ", stdout);
	}
    } else {
	code = Tcl_Eval(interp, promptCmd);
	if (code != TCL_OK) {
	    Tcl_AddErrorInfo(interp,
		    "\n    (script that generates prompt)");
	    fprintf(stderr, "%s\n", interp->result);
	    goto defaultPrompt;
	}
    }
    fflush(stdout);
}

/*
 *----------------------------------------------------------------------
 *
 * Tix_LoadTclLibrary --
 *
 *	Loads in a TCL library for an application according to 
 *	the library settings.
 *
 * Results:
 *	TCL_OK or TCL_ERROR
 *
 * envName	the environment variable that indicates the library
 * tclName	the TCL variable that points to the TCL library.
 * initFile	the file to load in during initialization.
 * defDir	the default directory to search if the user hasn't set
 *		the environment variable.
 * appName	the name of the application.
 *----------------------------------------------------------------------
 */
static char _format[350] = "lappend auto_path $%s \n\
	if [file exists $%s/%s] {\n\
	    source $%s/%s\n\
        } else {\n\
	    set msg \"can't find $%s/%s;\\n      perhaps you \"\n\
	    append msg \"need to install %s \\n      or set your %s \"\n\
	    append msg \"environment variable?\"\n\
	    error $msg\n\
        }";

int
Tix_LoadTclLibrary(interp, envName, tclName, initFile, defDir, appName)
    Tcl_Interp *interp;
    char *envName;
    char *tclName;
    char *initFile;
    char *defDir;
    char *appName;
{
    char * libDir, *initCmd;	/* should be big enough */
    size_t size;
    int code;
    /* I have to use a magic number here because some compilers don't like
     * []'s
     */
    char *format;
    format = _format;

    if (!(libDir = getenv(envName))) {
	libDir = defDir; 
    }

    size = strlen(format) + strlen(tclName)*4 + strlen(initFile)*3
	+ strlen(appName) + strlen(envName) + 100;
    initCmd = ckalloc(sizeof(char) * size);

    Tcl_SetVar(interp, tclName, libDir, TCL_GLOBAL_ONLY);

    sprintf(initCmd, format,
	tclName, 
	tclName, initFile,
	tclName, initFile,
	tclName, initFile,
	appName, envName
    );

    code =  Tcl_Eval(interp, initCmd);
    ckfree(initCmd);
    return code;
}

/*----------------------------------------------------------------------
 * Tix_CreateCommands --
 *
 *
 *	Creates a list of commands stored in the array "commands"
 *
 */

void Tix_CreateCommands(interp, commands, clientData, deleteProc)
    Tcl_Interp *interp;
    Tix_TclCmd *commands;
    ClientData clientData;
    Tcl_CmdDeleteProc *deleteProc;
{
    Tix_TclCmd * cmdPtr;

    for (cmdPtr = commands; cmdPtr->name != NULL; cmdPtr++) {
	Tcl_CreateCommand(interp, cmdPtr->name,
	     cmdPtr->cmdProc, clientData, deleteProc);
    }
}

#endif


/*----------------------------------------------------------------------
 * Tix_GetScrollFractions --
 *
 * Compute the fractions of a scroll-able widget.
 *
 */
void Tix_GetScrollFractions(total, window, first, first_ret, last_ret)
    int total;
    int window;
    int first;
    double * first_ret;
    double * last_ret;
{
    if (total == 0 || total < window) {
	*first_ret = 0.0;
	*last_ret  = 1.0;
    } else {
	*first_ret = (double)(first) / (double)(total);
	*last_ret  = (double)(first+window) / (double)(total);
    }
}

/*----------------------------------------------------------------------
 *
 *		 The Tix Customed Config Options
 *
 *----------------------------------------------------------------------
 */

/*----------------------------------------------------------------------
 *  ReliefParseProc --
 *
 *	Parse the text string and store the Tix_Relief information
 *	inside the widget record.
 *----------------------------------------------------------------------
 */
static int ReliefParseProc(clientData, interp, tkwin, avalue, widRec,offset)
    ClientData clientData;
    Tcl_Interp *interp;
    Tk_Window tkwin;
    Arg avalue;
    char *widRec;		/* Must point to a valid Tix_DItem struct */
    int offset;
{
    Tix_Relief * ptr = (Tix_Relief *)(widRec + offset);
    Tix_Relief   newVal;
    char *value = LangString(avalue);

    if (value != NULL) {
	size_t len = strlen(value);

	if (strncmp(value, "raised", len) == 0) {
	    newVal = TIX_RELIEF_RAISED;
	} else if (strncmp(value, "flat", len) == 0) {
	    newVal = TIX_RELIEF_FLAT;
	} else if (strncmp(value, "sunken", len) == 0) {
	    newVal = TIX_RELIEF_SUNKEN;
	} else if (strncmp(value, "groove", len) == 0) {
	    newVal = TIX_RELIEF_GROOVE;
	} else if (strncmp(value, "ridge", len) == 0) {
	    newVal = TIX_RELIEF_RIDGE;
	} else if (strncmp(value, "solid", len) == 0) {
	    newVal = TIX_RELIEF_SOLID;
	} else {
	    goto error;
	}
    } else {
	value = "";
	goto error;
    }

    *ptr = newVal;
    return TCL_OK;

  error:
    Tcl_AppendResult(interp, "bad relief type \"", value,
	"\":  must be flat, groove, raised, ridge, solid or sunken", NULL);
    return TCL_ERROR;
}

static Arg 
ReliefPrintProc(clientData, tkwin, widRec,offset, freeProcPtr)
    ClientData clientData;
    Tk_Window tkwin;
    char *widRec;
    int offset;
    Tcl_FreeProc **freeProcPtr;
{
    Tix_Relief *ptr = (Tix_Relief*)(widRec+offset);
    Arg result = NULL;

    switch (*ptr) {
      case TIX_RELIEF_RAISED:
	LangSetString(&result,"raised");
        break;
      case TIX_RELIEF_FLAT:
	LangSetString(&result,"flat");
        break;
      case TIX_RELIEF_SUNKEN:
	LangSetString(&result,"sunken");
        break;
      case TIX_RELIEF_GROOVE:
	LangSetString(&result,"groove");
        break;
      case TIX_RELIEF_RIDGE:
	LangSetString(&result,"ridge");
        break;
      case TIX_RELIEF_SOLID:
	LangSetString(&result,"solid");
        break;
      default:
	LangSetString(&result,"unknown");
        break;
    }
    return result;
}
/*
 * The global data structures to use in widget configSpecs arrays
 *
 * These are declared in <tix.h>
 */

Tk_CustomOption tixConfigRelief = {
    ReliefParseProc, ReliefPrintProc, 0,
};
