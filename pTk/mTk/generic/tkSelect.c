/* 
 * tkSelect.c --
 *
 *	This file manages the selection for the Tk toolkit,
 *	translating between the standard X ICCCM conventions
 *	and Tcl commands.
 *
 * Copyright (c) 1990-1993 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tkSelect.c 1.56 96/03/21 13:16:29
 */

#include "tkInt.h"
#include "tkSelect.h"

/*
 * When a selection handler is set up by invoking "selection handle",
 * one of the following data structures is set up to hold information
 * about the command to invoke and its interpreter.
 */

typedef struct {
    Tcl_Interp *interp;		/* Interpreter in which to invoke command. */
    LangCallback *command;	/* Command to invoke.  Actual space is
				 * allocated as large as necessary.  This
				 * must be the last entry in the structure. */
} CommandInfo;

/*
 * When selection ownership is claimed with the "selection own" Tcl command,
 * one of the following structures is created to record the Tcl command
 * to be executed when the selection is lost again.
 */

typedef struct LostCommand {
    Tcl_Interp *interp;		/* Interpreter in which to invoke command. */
    LangCallback *command;	/* Command to invoke.  Actual space is
				 * allocated as large as necessary.  This
				 * must be the last entry in the structure. */
} LostCommand;

/*
 * Shared variables:
 */

TkSelInProgress *pendingPtr = NULL;
				/* Topmost search in progress, or
				 * NULL if none. */

/*
 * Forward declarations for procedures defined in this file:
 */

static int		HandleTclCommand _ANSI_ARGS_((ClientData clientData,
			    int offset, char *buffer, int maxBytes));
static void		LostSelection _ANSI_ARGS_((ClientData clientData));
static int		SelGetProc _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, char *portion));
static void		SelRcvIncrProc _ANSI_ARGS_((ClientData clientData,
			    XEvent *eventPtr));
static void		SelTimeoutProc _ANSI_ARGS_((ClientData clientData));
static void		FreeHandler _ANSI_ARGS_((ClientData clientData));
static int		HandleCompat _ANSI_ARGS_((ClientData clientData,
			    int offset, long *buffer, int maxBytes, 
			    Atom type, Tk_Window tkwin));
static int		CompatXSelProc _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, long *portion,
			    int numItems, int format,
			    Atom type, Tk_Window tkwin));

/*
 *--------------------------------------------------------------
 *
 * Tk_CreateSelHandler --
 *
 *	This procedure is called to register a procedure
 *	as the handler for selection requests of a particular
 *	target type on a particular window for a particular
 *	selection.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	In the future, whenever the selection is in tkwin's
 *	window and someone requests the selection in the
 *	form given by target, proc will be invoked to provide
 *	part or all of the selection in the given form.  If
 *	there was already a handler declared for the given
 *	window, target and selection type, then it is replaced.
 *	Proc should have the following form:
 *
 *	int
 *	proc(clientData, offset, buffer, maxBytes)
 *	    ClientData clientData;
 *	    int offset;
 *	    char *buffer;
 *	    int maxBytes;
 *	{
 *	}
 *
 *	The clientData argument to proc will be the same as
 *	the clientData argument to this procedure.  The offset
 *	argument indicates which portion of the selection to
 *	return:  skip the first offset bytes.  Buffer is a
 *	pointer to an area in which to place the converted
 *	selection, and maxBytes gives the number of bytes
 *	available at buffer.  Proc should place the selection
 *	in buffer as a string, and return a count of the number
 *	of bytes of selection actually placed in buffer (not
 *	including the terminating NULL character).  If the
 *	return value equals maxBytes, this is a sign that there
 *	is probably still more selection information available.
 *
 *--------------------------------------------------------------
 */

void
Tk_CreateXSelHandler(tkwin, selection, target, proc, clientData, format)
    Tk_Window tkwin;		/* Token for window. */
    Atom selection;		/* Selection to be handled. */
    Atom target;		/* The kind of selection conversions
				 * that can be handled by proc,
				 * e.g. TARGETS or STRING. */
    Tk_XSelectionProc *proc;	/* Procedure to invoke to convert
				 * selection to type "target". */
    ClientData clientData;	/* Value to pass to proc. */
    Atom format;		/* Format in which the selection
				 * information should be returned to
				 * the requestor. XA_STRING is best by
				 * far, but anything listed in the ICCCM
				 * will be tolerated (blech). */
{
    register TkSelHandler *selPtr;
    TkWindow *winPtr = (TkWindow *) tkwin;

    if (winPtr->dispPtr->multipleAtom == None) {
	TkSelInit(tkwin);
    }

    /*
     * See if there's already a handler for this target and selection on
     * this window.  If so, re-use it.  If not, create a new one.
     */

    for (selPtr = winPtr->selHandlerList; ; selPtr = selPtr->nextPtr) {
	if (selPtr == NULL) {
	    selPtr = (TkSelHandler *) ckalloc(sizeof(TkSelHandler));
	    selPtr->nextPtr = winPtr->selHandlerList;
	    winPtr->selHandlerList = selPtr;
	    break;
	}
	if ((selPtr->selection == selection) && (selPtr->target == target)) {

	    /*
	     * Special case:  when replacing handler created by
	     * "selection handle", free up memory.  Should there be a
	     * callback to allow other clients to do this too?
	     */

	    if (selPtr->proc == HandleCompat) {
                FreeHandler(selPtr->clientData);
	    }
	    break;
	}
    }
    selPtr->selection = selection;
    selPtr->target = target;
    selPtr->format = format;
    selPtr->proc = proc;
    selPtr->clientData = clientData;
    if (format == XA_STRING) {
	selPtr->size = 8;
    } else {
	selPtr->size = 32;
    }
}

typedef struct CompatHandler
{
 Tk_SelectionProc *proc;	/* Procedure to invoke to convert
				 * selection to type "target". */
 ClientData clientData;		/* Value to pass to proc. */
} CompatHandler;

static int 
HandleCompat(clientData, offset, Xbuffer, maxBytes, type, tkwin)
ClientData clientData;
int offset;
long *Xbuffer;
int maxBytes;
Atom type;
Tk_Window tkwin;
{CompatHandler *cd = (CompatHandler *) clientData;
 if (type == XA_STRING)
  {
   return (*cd->proc)(cd->clientData, offset, (char *) Xbuffer, maxBytes);
  }
 else
  {
   char buffer[TK_SEL_BYTES_AT_ONCE];
   int count = (*cd->proc)(cd->clientData, offset, buffer, maxBytes);
   buffer[count] = '\0';
   return TkSelCvtToX(Xbuffer, buffer, type, tkwin, maxBytes);
  }
}


void
Tk_CreateSelHandler(tkwin, selection, target, proc, clientData, format)
    Tk_Window tkwin;		/* Token for window. */
    Atom selection;		/* Selection to be handled. */
    Atom target;		/* The kind of selection conversions
				 * that can be handled by proc,
				 * e.g. TARGETS or STRING. */
    Tk_SelectionProc *proc;	/* Procedure to invoke to convert
				 * selection to type "target". */
    ClientData clientData;	/* Value to pass to proc. */
    Atom format;		/* Format in which the selection
				 * information should be returned to
				 * the requestor. XA_STRING is best by
				 * far, but anything listed in the ICCCM
				 * will be tolerated (blech). */
{
 CompatHandler *cd = (CompatHandler *) ckalloc(sizeof(CompatHandler));
 cd->clientData = clientData;
 cd->proc       = proc;
 Tk_CreateXSelHandler(tkwin, selection, target, HandleCompat, 
                      (ClientData) cd, format);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_DeleteSelHandler --
 *
 *	Remove the selection handler for a given window, target, and
 *	selection, if it exists.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The selection handler for tkwin and target is removed.  If there
 *	is no such handler then nothing happens.
 *
 *----------------------------------------------------------------------
 */

void
Tk_DeleteSelHandler(tkwin, selection, target)
    Tk_Window tkwin;			/* Token for window. */
    Atom selection;			/* The selection whose handler
					 * is to be removed. */
    Atom target;			/* The target whose selection
					 * handler is to be removed. */
{
    TkWindow *winPtr = (TkWindow *) tkwin;
    register TkSelHandler *selPtr, *prevPtr;
    register TkSelInProgress *ipPtr;

    /*
     * Find the selection handler to be deleted, or return if it doesn't
     * exist.
     */ 

    for (selPtr = winPtr->selHandlerList, prevPtr = NULL; ;
	    prevPtr = selPtr, selPtr = selPtr->nextPtr) {
	if (selPtr == NULL) {
	    return;
	}
	if ((selPtr->selection == selection) && (selPtr->target == target)) {
	    break;
	}
    }

    /*
     * If ConvertSelection is processing this handler, tell it that the
     * handler is dead.
     */

    for (ipPtr = pendingPtr; ipPtr != NULL; ipPtr = ipPtr->nextPtr) {
	if (ipPtr->selPtr == selPtr) {
	    ipPtr->selPtr = NULL;
	}
    }

    /*
     * Free resources associated with the handler.
     */

    if (prevPtr == NULL) {
	winPtr->selHandlerList = selPtr->nextPtr;
    } else {
	prevPtr->nextPtr = selPtr->nextPtr;
    }
    if (selPtr->proc == HandleCompat) {
        FreeHandler(selPtr->clientData);
    }
    ckfree((char *) selPtr);
}

/*
 *--------------------------------------------------------------
 *
 * Tk_OwnSelection --
 *
 *	Arrange for tkwin to become the owner of a selection.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	From now on, requests for the selection will be directed
 *	to procedures associated with tkwin (they must have been
 *	declared with calls to Tk_CreateSelHandler).  When the
 *	selection is lost by this window, proc will be invoked
 *	(see the manual entry for details).  This procedure may
 *	invoke callbacks, including Tcl scripts, so any calling
 *	function should be reentrant at the point where
 *	Tk_OwnSelection is invoked.
 *
 *--------------------------------------------------------------
 */

void
Tk_OwnSelection(tkwin, selection, proc, clientData)
    Tk_Window tkwin;		/* Window to become new selection
				 * owner. */
    Atom selection;		/* Selection that window should own. */
    Tk_LostSelProc *proc;	/* Procedure to call when selection
				 * is taken away from tkwin. */
    ClientData clientData;	/* Arbitrary one-word argument to
				 * pass to proc. */
{
    register TkWindow *winPtr = (TkWindow *) tkwin;
    TkDisplay *dispPtr = winPtr->dispPtr;
    TkSelectionInfo *infoPtr;
    Tk_LostSelProc *clearProc = NULL;
    ClientData clearData = NULL;	/* Initialization needed only to
					 * prevent compiler warning. */
    
    
    if (dispPtr->multipleAtom == None) {
	TkSelInit(tkwin);
    }
    Tk_MakeWindowExist(tkwin);

    /*
     * This code is somewhat tricky.  First, we find the specified selection
     * on the selection list.  If the previous owner is in this process, and
     * is a different window, then we need to invoke the clearProc.  However,
     * it's dangerous to call the clearProc right now, because it could
     * invoke a Tcl script that wrecks the current state (e.g. it could
     * delete the window).  To be safe, defer the call until the end of the
     * procedure when we no longer care about the state.
     */

    for (infoPtr = dispPtr->selectionInfoPtr; infoPtr != NULL;
	    infoPtr = infoPtr->nextPtr) {
	if (infoPtr->selection == selection) {
	    break;
	}
    }
    if (infoPtr == NULL) {
	infoPtr = (TkSelectionInfo*) ckalloc(sizeof(TkSelectionInfo));
	infoPtr->selection = selection;
	infoPtr->nextPtr = dispPtr->selectionInfoPtr;
	dispPtr->selectionInfoPtr = infoPtr;
    } else if (infoPtr->clearProc != NULL) {
	if (infoPtr->owner != tkwin) {
	    clearProc = infoPtr->clearProc;
	    clearData = infoPtr->clearData;
	} else if (infoPtr->clearProc == LostSelection) {
	    /*
	     * If the selection handler is one created by "selection own",
	     * be sure to free the record for it;  otherwise there will be
	     * a memory leak.
	     */

	    ckfree((char *) infoPtr->clearData);
	}
    }

    infoPtr->owner = tkwin;
    infoPtr->serial = NextRequest(winPtr->display);
    infoPtr->clearProc = proc;
    infoPtr->clearData = clientData;

    /*
     * Note that we are using CurrentTime, even though ICCCM recommends against
     * this practice (the problem is that we don't necessarily have a valid
     * time to use).  We will not be able to retrieve a useful timestamp for
     * the TIMESTAMP target later.
     */

    infoPtr->time = CurrentTime;

    /*
     * Note that we are not checking to see if the selection claim succeeded.
     * If the ownership does not change, then the clearProc may never be
     * invoked, and we will return incorrect information when queried for the
     * current selection owner.
     */

    XSetSelectionOwner(winPtr->display, infoPtr->selection, winPtr->window,
	    infoPtr->time);

    /*
     * Now that we are done, we can invoke clearProc without running into
     * reentrancy problems.
     */

    if (clearProc != NULL) {
	(*clearProc)(clearData);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_ClearSelection --
 *
 *	Eliminate the specified selection on tkwin's display, if there is one.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The specified selection is cleared, so that future requests to retrieve
 *	it will fail until some application owns it again.  This procedure
 *	invokes callbacks, possibly including Tcl scripts, so any calling
 *	function should be reentrant at the point Tk_ClearSelection is invoked.
 *
 *----------------------------------------------------------------------
 */

void
Tk_ClearSelection(tkwin, selection)
    Tk_Window tkwin;		/* Window that selects a display. */
    Atom selection;		/* Selection to be cancelled. */
{
    register TkWindow *winPtr = (TkWindow *) tkwin;
    TkDisplay *dispPtr = winPtr->dispPtr;
    TkSelectionInfo *infoPtr;
    TkSelectionInfo *prevPtr;
    TkSelectionInfo *nextPtr;
    Tk_LostSelProc *clearProc = NULL;
    ClientData clearData = NULL;	/* Initialization needed only to
					 * prevent compiler warning. */

    if (dispPtr->multipleAtom == None) {
	TkSelInit(tkwin);
    }

    for (infoPtr = dispPtr->selectionInfoPtr, prevPtr = NULL;
	     infoPtr != NULL; infoPtr = nextPtr) {
	nextPtr = infoPtr->nextPtr;
	if (infoPtr->selection == selection) {
	    if (prevPtr == NULL) {
		dispPtr->selectionInfoPtr = nextPtr;
	    } else {
		prevPtr->nextPtr = nextPtr;
	    }
	    break;
	}
	prevPtr = infoPtr;
    }
    
    if (infoPtr != NULL) {
	clearProc = infoPtr->clearProc;
	clearData = infoPtr->clearData;
	ckfree((char *) infoPtr);
    }
    XSetSelectionOwner(winPtr->display, selection, None, CurrentTime);

    if (clearProc != NULL) {
	(*clearProc)(clearData);
    }
}

/*
 *--------------------------------------------------------------
 *
 * Tk_GetSelection --
 *
 *	Retrieve the value of a selection and pass it off (in
 *	pieces, possibly) to a given procedure.
 *
 * Results:
 *	The return value is a standard Tcl return value.
 *	If an error occurs (such as no selection exists)
 *	then an error message is left in interp->result.
 *
 * Side effects:
 *	The standard X11 protocols are used to retrieve the
 *	selection.  When it arrives, it is passed to proc.  If
 *	the selection is very large, it will be passed to proc
 *	in several pieces.  Proc should have the following
 *	structure:
 *
 *	int
 *	proc(clientData, interp, portion)
 *	    ClientData clientData;
 *	    Tcl_Interp *interp;
 *	    char *portion;
 *	{
 *	}
 *
 *	The interp and clientData arguments to proc will be the
 *	same as the corresponding arguments to Tk_GetSelection.
 *	The portion argument points to a character string
 *	containing part of the selection, and numBytes indicates
 *	the length of the portion, not including the terminating
 *	NULL character.  If the selection arrives in several pieces,
 *	the "portion" arguments in separate calls will contain
 *	successive parts of the selection.  Proc should normally
 *	return TCL_OK.  If it detects an error then it should return
 *	TCL_ERROR and leave an error message in interp->result; the
 *	remainder of the selection retrieval will be aborted.
 *
 *--------------------------------------------------------------
 */

int
Tk_GetXSelection(interp, tkwin, selection, target, proc, clientData)
    Tcl_Interp *interp;		/* Interpreter to use for reporting
				 * errors. */
    Tk_Window tkwin;		/* Window on whose behalf to retrieve
				 * the selection (determines display
				 * from which to retrieve). */
    Atom selection;		/* Selection to retrieve. */
    Atom target;		/* Desired form in which selection
				 * is to be returned. */
    Tk_GetXSelProc *proc;	/* Procedure to call to process the
				 * selection, once it has been retrieved. */
    ClientData clientData;	/* Arbitrary value to pass to proc. */
{
    TkWindow *winPtr = (TkWindow *) tkwin;
    TkDisplay *dispPtr = winPtr->dispPtr;
    TkSelectionInfo *infoPtr;

    if (dispPtr->multipleAtom == None) {
	TkSelInit(tkwin);
    }

    /*
     * If the selection is owned by a window managed by this
     * process, then call the retrieval procedure directly,
     * rather than going through the X server (it's dangerous
     * to go through the X server in this case because it could
     * result in deadlock if an INCR-style selection results).
     */

    for (infoPtr = dispPtr->selectionInfoPtr; infoPtr != NULL;
	    infoPtr = infoPtr->nextPtr) {
	if (infoPtr->selection == selection)
	    break;
    }
    if (infoPtr != NULL) {
	register TkSelHandler *selPtr;
	int offset, result, count;
	long buffer[TK_SEL_WORDS_AT_ONCE+1];
	TkSelInProgress ip;

	for (selPtr = ((TkWindow *) infoPtr->owner)->selHandlerList;
		selPtr != NULL; selPtr = selPtr->nextPtr) {
	    if ((selPtr->target == target)
		    && (selPtr->selection == selection)) {
		break;
	    }
	}
	if (selPtr == NULL) {
	    Atom type  = XA_STRING;
            int format = 8;

	    count = TkSelDefaultSelection(infoPtr, target, buffer,
		    TK_SEL_BYTES_AT_ONCE, &type, &format);
	    if (count > TK_SEL_BYTES_AT_ONCE) {
		panic("selection handler returned too many bytes");
	    }
	    if (count < 0) {
		goto cantget;
	    }
	    result = (*proc)(clientData, interp, buffer, count, format, type, tkwin);
	} else {
            Atom type  = selPtr->format;
            int format = (type == XA_STRING) ? 8: 32;
	    offset = 0;
	    result = TCL_OK;
	    ip.selPtr = selPtr;
	    ip.nextPtr = pendingPtr;
	    pendingPtr = &ip;
	    while (1) {
		count = (selPtr->proc)(selPtr->clientData, offset, buffer,
			TK_SEL_BYTES_AT_ONCE, type, tkwin);
		if ((count < 0) || (ip.selPtr == NULL)) {
		    pendingPtr = ip.nextPtr;
		    goto cantget;
		}
		if (count > TK_SEL_BYTES_AT_ONCE) {
		    panic("selection handler returned too many bytes");
		}
		((char *) buffer)[count] = '\0';
		result = (*proc)(clientData, interp, buffer, count, format, type, tkwin);
		if ((result != TCL_OK) || (count < TK_SEL_BYTES_AT_ONCE)
			|| (ip.selPtr == NULL)) {
		    break;
		}
		offset += count;
	    }
	    pendingPtr = ip.nextPtr;
	}
	return result;
    }

    /*
     * The selection is owned by some other process.
     */

    return TkSelGetSelection(interp, tkwin, selection, target, proc,
	    clientData);

    cantget:
    Tcl_AppendResult(interp, Tk_GetAtomName(tkwin, selection),
	" selection doesn't exist or form \"", Tk_GetAtomName(tkwin, target),
	"\" not defined", (char *) NULL);
    return TCL_ERROR;

}

typedef struct CompatInfo
{
 Tk_GetSelProc *proc;	/* Procedure to call to process the
			 * selection, once it has been retrieved. */
 ClientData clientData;	/* Arbitrary value to pass to proc. */
} CompatInfo;

static int
CompatXSelProc(clientData,interp,portion,numItems,format,type,tkwin)
ClientData clientData;
Tcl_Interp *interp;
long *portion;
int numItems;
int format;
Atom type;
Tk_Window tkwin;
{CompatInfo *info = (CompatInfo *) clientData;
 if ((type == XA_STRING)) {
    if (format != 8) {
	sprintf(interp->result,
	    "bad format for string selection: wanted \"8\", got \"%d\"",
	    format);
	return TCL_ERROR;
    }
    portion[numItems] = '\0';
    return (*info->proc)(info->clientData, interp, (char *) portion);
 } else {
    char *string;
    int  result;
    if (format != 32) {
	sprintf(interp->result,
	    "bad format for selection: wanted \"32\", got \"%d\"",
	    format);
	return TCL_ERROR;
    }
    string = TkSelCvtFromX(portion, (int) numItems, type, tkwin);
    result = (*info->proc)(info->clientData, interp, string);
    ckfree(string);
    return result;
 }
}

int
Tk_GetSelection(interp, tkwin, selection, target, proc, clientData)
    Tcl_Interp *interp;		/* Interpreter to use for reporting
				 * errors. */
    Tk_Window tkwin;		/* Window on whose behalf to retrieve
				 * the selection (determines display
				 * from which to retrieve). */
    Atom selection;		/* Selection to retrieve. */
    Atom target;		/* Desired form in which selection
				 * is to be returned. */
    Tk_GetSelProc *proc;	/* Procedure to call to process the
				 * selection, once it has been retrieved. */
    ClientData clientData;	/* Arbitrary value to pass to proc. */
{
    CompatInfo cd;
    cd.clientData = clientData;
    cd.proc = proc;
    return Tk_GetXSelection(interp, tkwin, selection, target, CompatXSelProc, (ClientData) &cd);
}

static void
FreeHandler(clientData)
ClientData clientData;
{
 CompatHandler *cd = (CompatHandler *) clientData;
 if (cd->proc == HandleTclCommand)
  {
   CommandInfo *cmdInfoPtr = (CommandInfo *) cd->clientData;
   LangFreeCallback(cmdInfoPtr->command);
   ckfree((char *) cmdInfoPtr);
  }
 ckfree((char *) cd);
}

/*
 *--------------------------------------------------------------
 *
 * Tk_SelectionCmd --
 *
 *	This procedure is invoked to process the "selection" Tcl
 *	command.  See the user documentation for details on what
 *	it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

int
Tk_SelectionCmd(clientData, interp, argc, argv)
    ClientData clientData;	/* Main window associated with
				 * interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    Tk_Window tkwin = (Tk_Window) clientData;
    char *path = NULL;
    Atom selection;
    char *selName = NULL;
    int c, count;
    size_t length;
    Arg *argp;

    if (argc < 2) {
	sprintf(interp->result,
		"wrong # args: should be \"%.50s option ?arg arg ...?\"",
		argv[0]);
	return TCL_ERROR;
    }
    c = argv[1][0];
    length = strlen(argv[1]);
    if ((c == 'c') && (strncmp(argv[1], "clear", length) == 0)) {
	for (count = argc-2, argp = argv+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (*string != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing", (char *) NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') && (strncmp(string, "-displayof", length) == 0)) {
		path = LangString(argp[1]);
	    } else if ((c == 's')
		    && (strncmp(string, "-selection", length) == 0)) {
		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"", (char *) NULL);
		return TCL_ERROR;
	    }
	}
	if (count == 1) {
	    path = LangString(*argp);
	} else if (count > 1) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
		    " clear ?options?\"", (char *) NULL);
	    return TCL_ERROR;
	}
	if (path != NULL) {
	    tkwin = Tk_NameToWindow(interp, path, tkwin);
	}
	if (tkwin == NULL) {
	    return TCL_ERROR;
	}
	if (selName != NULL) {
	    selection = Tk_InternAtom(tkwin, selName);
	} else {
	    selection = XA_PRIMARY;
	}
	    
	Tk_ClearSelection(tkwin, selection);
	return TCL_OK;
    } else if ((c == 'e') && (strncmp(argv[1], "exists", length) == 0)) {
	Window win = None;
	for (count = argc-2, argp = argv+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (*string != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing", (char *) NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') && (strncmp(string, "-displayof", length) == 0)) {
		path = LangString(argp[1]);
	    } else if ((c == 's')
		    && (strncmp(string, "-selection", length) == 0)) {
		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"", (char *) NULL);
		return TCL_ERROR;
	    }
	}
	if (count == 1) {
	    path = LangString(*argp);
	} else if (count > 1) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
		    " clear ?options?\"", (char *) NULL);
	    return TCL_ERROR;
	}
	if (path != NULL) {
	    tkwin = Tk_NameToWindow(interp, path, tkwin);
	}
	if (tkwin == NULL) {
	    return TCL_ERROR;
	}
	if (selName != NULL) {
	    selection = Tk_InternAtom(tkwin, selName);
	} else {
	    selection = XA_PRIMARY;
	}
	win = XGetSelectionOwner(Tk_Display(tkwin), selection);
	if (win != None) {
	    TkWindow *winPtr = (TkWindow *) tkwin;
	    tkwin = Tk_IdToWindow(Tk_Display(tkwin), win);
	    if (tkwin != NULL && tkwin != winPtr->dispPtr->clipWindow) {
		Tcl_ArgResult(interp,LangWidgetArg(interp,tkwin));
	    } else {
		Tcl_IntResults(interp, 1, 0, win);    
	    }
        }
	return TCL_OK;
    } else if ((c == 'g') && (strncmp(argv[1], "get", length) == 0)) {
	Atom target;
	char *targetName = NULL;
	Tcl_DString selBytes;
	int result;
	
	for (count = argc-2, argp = argv+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing", (char *) NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') && (strncmp(string, "-displayof", length) == 0)) {
		path = LangString(argp[1]);
	    } else if ((c == 's')
		    && (strncmp(string, "-selection", length) == 0)) {
		selName = LangString(argp[1]);
	    } else if ((c == 't')
		    && (strncmp(string, "-type", length) == 0)) {
		targetName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"", (char *) NULL);
		return TCL_ERROR;
	    }
	}
	if (path != NULL) {
	    tkwin = Tk_NameToWindow(interp, path, tkwin);
	}
	if (tkwin == NULL) {
	    return TCL_ERROR;
	}
	if (selName != NULL) {
	    selection = Tk_InternAtom(tkwin, selName);
	} else {
	    selection = XA_PRIMARY;
	}
	if (count > 1) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
		    " get ?options?\"", (char *) NULL);
	    return TCL_ERROR;
	} else if (count == 1) {
	    target = Tk_InternAtom(tkwin, LangString(*argp));
	} else if (targetName != NULL) {
	    target = Tk_InternAtom(tkwin, targetName);
	} else {
	    target = XA_STRING;
	}

	Tcl_DStringInit(&selBytes);
	result = Tk_GetSelection(interp, tkwin, selection, target, SelGetProc,
		(ClientData) &selBytes);
	if (result == TCL_OK) {
	    Tcl_DStringResult(interp, &selBytes);
	} else {
	    Tcl_DStringFree(&selBytes);
	}
	return result;
    } else if ((c == 'h') && (strncmp(argv[1], "handle", length) == 0)) {
	Atom target, format;
	char *targetName = NULL;
	char *formatName = NULL;
	register CommandInfo *cmdInfoPtr;
	int cmdLength;
	
	for (count = argc-2, argp = argv+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing", (char *) NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'f') && (strncmp(string, "-format", length) == 0)) {
		formatName = LangString(argp[1]);
	    } else if ((c == 's')
		    && (strncmp(string, "-selection", length) == 0)) {
		selName = LangString(argp[1]);
	    } else if ((c == 't')
		    && (strncmp(string, "-type", length) == 0)) {
		targetName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"", (char *) NULL);
		return TCL_ERROR;
	    }
	}

	if ((count < 2) || (count > 4)) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
		    " handle ?options? window command\"", (char *) NULL);
	    return TCL_ERROR;
	}
	tkwin = Tk_NameToWindow(interp, LangString(*argp), tkwin);
	if (tkwin == NULL) {
	    return TCL_ERROR;
	}
	if (selName != NULL) {
	    selection = Tk_InternAtom(tkwin, selName);
	} else {
	    selection = XA_PRIMARY;
	}
	    
	if (count > 2) {
	    target = Tk_InternAtom(tkwin, LangString(argp[2]));
	} else if (targetName != NULL) {
	    target = Tk_InternAtom(tkwin, targetName);
	} else {
	    target = XA_STRING;
	}
	if (count > 3) {
	    format = Tk_InternAtom(tkwin, LangString(argp[3]));
	} else if (formatName != NULL) {
	    format = Tk_InternAtom(tkwin, formatName);
	} else {
	    format = XA_STRING;
	}
	cmdLength = strlen(LangString(argp[1]));
	if (cmdLength == 0) {
	    Tk_DeleteSelHandler(tkwin, selection, target);
	} else {
	    cmdInfoPtr = (CommandInfo *) ckalloc((unsigned) (
		    sizeof(CommandInfo)));
	    cmdInfoPtr->interp = interp;
	    cmdInfoPtr->command = LangMakeCallback(argp[1]);
	    Tk_CreateSelHandler(tkwin, selection, target, HandleTclCommand,
		    (ClientData) cmdInfoPtr, format);
	}
	return TCL_OK;
    } else if ((c == 'o') && (strncmp(argv[1], "own", length) == 0)) {
	register LostCommand *lostPtr;
	Arg script = NULL;
	int cmdLength;

	for (count = argc-2, argp = argv+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing", (char *) NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'c') && (strncmp(string, "-command", length) == 0)) {
		script = argp[1];
	    } else if ((c == 'd')
		    && (strncmp(string, "-displayof", length) == 0)) {
		path = LangString(argp[1]);
	    } else if ((c == 's')
		    && (strncmp(string, "-selection", length) == 0)) {
		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"", (char *) NULL);
		return TCL_ERROR;
	    }
	}

	if (count > 2) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
		    " own ?options? ?window?\"", (char *) NULL);
	    return TCL_ERROR;
	}
	if (selName != NULL) {
	    selection = Tk_InternAtom(tkwin, selName);
	} else {
	    selection = XA_PRIMARY;
	}
	if (count == 0) {
	    TkSelectionInfo *infoPtr;
	    TkWindow *winPtr;
	    if (path != NULL) {
		tkwin = Tk_NameToWindow(interp, path, tkwin);
	    }
	    if (tkwin == NULL) {
		return TCL_ERROR;
	    }
	    winPtr = (TkWindow *)tkwin;
	    for (infoPtr = winPtr->dispPtr->selectionInfoPtr; infoPtr != NULL;
		    infoPtr = infoPtr->nextPtr) {
		if (infoPtr->selection == selection)
		    break;
	    }

	    /*
	     * Ignore the internal clipboard window.
	     */

	    if ((infoPtr != NULL)
		    && (infoPtr->owner != winPtr->dispPtr->clipWindow)) {
		Tcl_ArgResult(interp,LangWidgetArg(interp,infoPtr->owner));
	    }
	    return TCL_OK;
	}
	tkwin = Tk_NameToWindow(interp, LangString(*argp), tkwin);
	if (tkwin == NULL) {
	    return TCL_ERROR;
	}
	if (count == 2) {
	    script = argp[1];
	}
	if (script == NULL) {
	    Tk_OwnSelection(tkwin, selection, (Tk_LostSelProc *) NULL,
		    (ClientData) NULL);
	    return TCL_OK;
	}
	lostPtr = (LostCommand *) ckalloc((unsigned) (sizeof(LostCommand)));
	lostPtr->interp = interp;
	lostPtr->command = LangMakeCallback(script);
	Tk_OwnSelection(tkwin, selection, LostSelection, (ClientData) lostPtr);
	return TCL_OK;
    } else {
	sprintf(interp->result,
		"bad option \"%.50s\": must be clear, get, handle, or own",
		argv[1]);
	return TCL_ERROR;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkSelDeadWindow --
 *
 *	This procedure is invoked just before a TkWindow is deleted.
 *	It performs selection-related cleanup.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Frees up memory associated with the selection.
 *
 *----------------------------------------------------------------------
 */

void
TkSelDeadWindow(winPtr)
    register TkWindow *winPtr;	/* Window that's being deleted. */
{
    register TkSelHandler *selPtr;
    register TkSelInProgress *ipPtr;
    TkSelectionInfo *infoPtr, *prevPtr, *nextPtr;

    /*
     * While deleting all the handlers, be careful to check whether
     * ConvertSelection or TkSelPropProc are about to process one of the
     * deleted handlers.
     */

    while (winPtr->selHandlerList != NULL) {
	selPtr = winPtr->selHandlerList;
	winPtr->selHandlerList = selPtr->nextPtr;
	for (ipPtr = pendingPtr; ipPtr != NULL; ipPtr = ipPtr->nextPtr) {
	    if (ipPtr->selPtr == selPtr) {
		ipPtr->selPtr = NULL;
	    }
	}
	if (selPtr->proc == HandleCompat) {
            FreeHandler(selPtr->clientData);
	}
	ckfree((char *) selPtr);
    }

    /*
     * Remove selections owned by window being deleted.
     */

    for (infoPtr = winPtr->dispPtr->selectionInfoPtr, prevPtr = NULL;
	     infoPtr != NULL; infoPtr = nextPtr) {
	nextPtr = infoPtr->nextPtr;
	if (infoPtr->owner == (Tk_Window) winPtr) {
	    if (infoPtr->clearProc == LostSelection) {
		ckfree((char *) infoPtr->clearData);
	    }
	    ckfree((char *) infoPtr);
	    infoPtr = prevPtr;
	    if (prevPtr == NULL) {
		winPtr->dispPtr->selectionInfoPtr = nextPtr;
	    } else {
		prevPtr->nextPtr = nextPtr;
	    }
	}
	prevPtr = infoPtr;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkSelInit --
 *
 *	Initialize selection-related information for a display.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Selection-related information is initialized.
 *
 *----------------------------------------------------------------------
 */

void
TkSelInit(tkwin)
    Tk_Window tkwin;		/* Window token (used to find
				 * display to initialize). */
{
    register TkDisplay *dispPtr = ((TkWindow *) tkwin)->dispPtr;

    /*
     * Fetch commonly-used atoms.
     */

    dispPtr->multipleAtom = Tk_InternAtom(tkwin, "MULTIPLE");
    dispPtr->incrAtom = Tk_InternAtom(tkwin, "INCR");
    dispPtr->targetsAtom = Tk_InternAtom(tkwin, "TARGETS");
    dispPtr->timestampAtom = Tk_InternAtom(tkwin, "TIMESTAMP");
    dispPtr->textAtom = Tk_InternAtom(tkwin, "TEXT");
    dispPtr->compoundTextAtom = Tk_InternAtom(tkwin, "COMPOUND_TEXT");
    dispPtr->applicationAtom = Tk_InternAtom(tkwin, "TK_APPLICATION");
    dispPtr->windowAtom = Tk_InternAtom(tkwin, "TK_WINDOW");
    dispPtr->clipboardAtom = Tk_InternAtom(tkwin, "CLIPBOARD");
}

/*
 *----------------------------------------------------------------------
 *
 * TkSelClearSelection --
 *
 *	This procedure is invoked to process a SelectionClear event.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Invokes the clear procedure for the window which lost the
 *	selection.
 *
 *----------------------------------------------------------------------
 */

void
TkSelClearSelection(tkwin, eventPtr)
    Tk_Window tkwin;		/* Window for which event was targeted. */
    register XEvent *eventPtr;	/* X SelectionClear event. */
{
    register TkWindow *winPtr = (TkWindow *) tkwin;
    TkDisplay *dispPtr = winPtr->dispPtr;
    TkSelectionInfo *infoPtr;
    TkSelectionInfo *prevPtr;

    /*
     * Invoke clear procedure for window that just lost the selection.  This
     * code is a bit tricky, because any callbacks due to selection changes
     * between windows managed by the process have already been made.  Thus,
     * ignore the event unless it refers to the window that's currently the
     * selection owner and the event was generated after the server saw the
     * SetSelectionOwner request.
     */

    for (infoPtr = dispPtr->selectionInfoPtr, prevPtr = NULL;
	 infoPtr != NULL; infoPtr = infoPtr->nextPtr) {
	if (infoPtr->selection == eventPtr->xselectionclear.selection) {
	    break;
	}
	prevPtr = infoPtr;
    }

    if (infoPtr != NULL && (infoPtr->owner == tkwin)
	    && (eventPtr->xselectionclear.serial >= infoPtr->serial)) {
	if (prevPtr == NULL) {
	    dispPtr->selectionInfoPtr = infoPtr->nextPtr;
	} else {
	    prevPtr->nextPtr = infoPtr->nextPtr;
	}

	/*
	 * Because of reentrancy problems, calling clearProc must be done
	 * after the infoPtr has been removed from the selectionInfoPtr
	 * list (clearProc could modify the list, e.g. by creating
	 * a new selection).
	 */

	if (infoPtr->clearProc != NULL) {
	    (*infoPtr->clearProc)(infoPtr->clearData);
	}
	ckfree((char *) infoPtr);
    }
}

/*
 *--------------------------------------------------------------
 *
 * SelGetProc --
 *
 *	This procedure is invoked to process pieces of the selection
 *	as they arrive during "selection get" commands.
 *
 * Results:
 *	Always returns TCL_OK.
 *
 * Side effects:
 *	Bytes get appended to the dynamic string pointed to by the
 *	clientData argument.
 *
 *--------------------------------------------------------------
 */

	/* ARGSUSED */
static int
SelGetProc(clientData, interp, portion)
    ClientData clientData;	/* Dynamic string holding partially
				 * assembled selection. */
    Tcl_Interp *interp;		/* Interpreter used for error
				 * reporting (not used). */
    char *portion;		/* New information to be appended. */
{
    Tcl_DStringAppend((Tcl_DString *) clientData, portion, -1);
    return TCL_OK;
}

/*
 * HandleTclCommand --
 *
 *	This procedure acts as selection handler for handlers created
 *	by the "selection handle" command.  It invokes a Tcl command to
 *	retrieve the selection.
 *
 * Results:
 *	The return value is a count of the number of bytes actually
 *	stored at buffer, or -1 if an error occurs while executing
 *	the Tcl command to retrieve the selection.
 *
 * Side effects:
 *	None except for things done by the Tcl command.
 *
 *----------------------------------------------------------------------
 */

static int
HandleTclCommand(clientData, offset, buffer, maxBytes)
    ClientData clientData;	/* Information about command to execute. */
    int offset;			/* Return selection bytes starting at this
				 * offset. */
    char *buffer;		/* Place to store converted selection. */
    int maxBytes;		/* Maximum # of bytes to store at buffer. */
{
    CommandInfo *cmdInfoPtr = (CommandInfo *) clientData;
    Tcl_Interp *interp = cmdInfoPtr->interp;

    /*
     * We must copy the interpreter pointer from CommandInfo because the
     * command could delete the handler, freeing the CommandInfo data before we
     * are done using it. We must also protect the interpreter from being
     * deleted too soo.
     */

    LangResultSave *oldResult = LangSaveResult(&interp);
    int length = -1;
    interp = cmdInfoPtr->interp;
    Tcl_Preserve((ClientData) interp);


    /*
     * Execute the command.  Be sure to restore the state of the
     * interpreter after executing the command.
     */

    if (LangDoCallback(interp, cmdInfoPtr->command, 1, 2, "%d %d", offset, maxBytes) == TCL_OK) {
	length = strlen(Tcl_GetResult(interp));
	if (length > maxBytes) {
	    length = maxBytes;
	}
	memcpy((VOID *) buffer, (VOID *) Tcl_GetResult(interp), (size_t) length);
	buffer[length] = '\0';
    } else {
	length = -1;
    }

    LangRestoreResult(&interp,oldResult);
    Tcl_Preserve((ClientData) interp);
    return length;
}
/*
 *----------------------------------------------------------------------
 *
 * TkSelDefaultSelection --
 *
 *	This procedure is called to generate selection information
 *	for a few standard targets such as TIMESTAMP and TARGETS.
 *	It is invoked only if no handler has been declared by the
 *	application.
 *
 * Results:
 *	If "target" is a standard target understood by this procedure,
 *	the selection is converted to that form and stored as a
 *	character string in buffer.  The type of the selection (e.g.
 *	STRING or ATOM) is stored in *typePtr, and the return value is
 *	a count of the # of non-NULL bytes at buffer.  If the target
 *	wasn't understood, or if there isn't enough space at buffer
 *	to hold the entire selection (no INCR-mode transfers for this
 *	stuff!), then -1 is returned.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int
TkSelDefaultSelection(infoPtr, target, lbuffer, maxBytes, typePtr, formatPtr)
    TkSelectionInfo *infoPtr;	/* Info about selection being retrieved. */
    Atom target;		/* Desired form of selection. */
    long *lbuffer;		/* Place to put selection characters. */
    int maxBytes;		/* Maximum # of bytes to store at buffer. */
    Atom *typePtr;		/* Store here the type of the selection,
				 * for use in converting to proper X format. */
    int  *formatPtr; 
{
    register TkWindow *winPtr = (TkWindow *) infoPtr->owner;
    TkDisplay *dispPtr = winPtr->dispPtr;
    char *buffer = (char *) lbuffer; 

    if (target == dispPtr->timestampAtom) {
	if (maxBytes < 20) {
	    return -1;
	}
        *((long *) buffer) = (long) infoPtr->time;
	*typePtr = XA_INTEGER;
        *formatPtr = 8*sizeof(long);
	return 1;
    }

    if (target == dispPtr->targetsAtom) {
	register TkSelHandler *selPtr;
        Atom *ap = (Atom *) buffer;

        if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
           return -1; 
        *ap++ = Tk_InternAtom((Tk_Window) winPtr,"MULTIPLE");
        if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
           return -1; 
        *ap++ = Tk_InternAtom((Tk_Window) winPtr,"TARGETS");
        if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
           return -1; 
        *ap++ = Tk_InternAtom((Tk_Window) winPtr,"TIMESTAMP");
        if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
           return -1; 
        *ap++ = Tk_InternAtom((Tk_Window) winPtr,"TK_APPLICATION");
        if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
           return -1; 
        *ap++ = Tk_InternAtom((Tk_Window) winPtr,"TK_WINDOW");

	for (selPtr = winPtr->selHandlerList; selPtr != NULL;
		selPtr = selPtr->nextPtr) {
	    if (selPtr->selection == infoPtr->selection) {
                if ((char *)ap >= buffer + maxBytes - sizeof(Atom))
                   return -1; 
		*ap++ = selPtr->target;
	    }
	}
	*typePtr = XA_ATOM;
        *formatPtr = 8*sizeof(Atom);
	return (ap - ((Atom *) buffer));
    }

    if (target == dispPtr->applicationAtom) {
	int length;
	char *name = winPtr->mainPtr->winPtr->nameUid;

	length = strlen(name);
	if (maxBytes <= length) {
	    return -1;
	}
	strcpy(buffer, name);
	*typePtr = XA_STRING;
        *formatPtr = 8; 
	return length;
    }

    if (target == dispPtr->windowAtom) {
	int length;
	char *name = winPtr->pathName;

	length = strlen(name);
	if (maxBytes <= length) {
	    return -1;
	}
	strcpy(buffer, name);
	*typePtr = XA_STRING;
        *formatPtr = 8; 
	return length;
    }

    return -1;
}

/*
 *----------------------------------------------------------------------
 *
 * LostSelection --
 *
 *	This procedure is invoked when a window has lost ownership of
 *	the selection and the ownership was claimed with the command
 *	"selection own".
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A Tcl script is executed;  it can do almost anything.
 *
 *----------------------------------------------------------------------
 */

static void
LostSelection(clientData)
    ClientData clientData;		/* Pointer to CommandInfo structure. */
{
    LostCommand *lostPtr = (LostCommand *) clientData;
    LangResultSave *oldResult = LangSaveResult(&lostPtr->interp);
    Tcl_FreeProc *oldFreeProc;
    Tcl_Interp *interp;

    interp = lostPtr->interp;
    Tcl_Preserve((ClientData) interp);
    
    /*
     * Execute the command.  Save the interpreter's result, if any, and
     * restore it after executing the command.
     */

    if (LangDoCallback(interp, lostPtr->command, 0, 0) != TCL_OK) {
        Tcl_AddErrorInfo(interp,"\n (Selection Lost proc)");
	Tcl_BackgroundError(interp);
    }
    LangRestoreResult(&interp,oldResult);

    Tcl_Release((ClientData) interp);
    
    /*
     * Free the storage for the command, since we're done with it now.
     */
    LangFreeCallback(lostPtr->command);
    ckfree((char *) lostPtr);
}


