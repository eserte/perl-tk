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
 */

static char sccsid[] = "@(#) tkSelect.c 1.48 95/08/21 10:49:09";

#include "tkPort.h"
#include "tkInt.h"

/*
 * When a selection is owned by a window on a given display, one of the
 * following structures is present on a list of current selections in the
 * display structure.  The structure is used to record the current owner of
 * a selection for use in later retrieval requests.  There is a list of
 * such structures because a display can have multiple different selections
 * active at the same time.
 */

typedef struct TkSelectionInfo {
    Atom selection;		/* Selection name, e.g. XA_PRIMARY. */
    Tk_Window owner;		/* Current owner of this selection. */
    int serial;			/* Serial number of last XSelectionSetOwner
				 * request made to server for this
				 * selection (used to filter out redundant
				 * SelectionClear events). */
    Time time;			/* Timestamp used to acquire selection. */
    Tk_LostSelProc *clearProc;	/* Procedure to call when owner loses
				 * selection. */
    ClientData clearData;	/* Info to pass to clearProc. */
    struct TkSelectionInfo *nextPtr;
				/* Next in list of current selections on
                                 * this display.  NULL means end of list */
} TkSelectionInfo;

/*
 * One of the following structures exists for each selection handler
 * created for a window by calling Tk_CreateSelHandler.  The handlers
 * are linked in a list rooted in the TkWindow structure.
 */

typedef struct TkSelHandler {
    Atom selection;		/* Selection name, e.g. XA_PRIMARY */
    Atom target;		/* Target type for selection
				 * conversion, such as TARGETS or
				 * STRING. */
    Atom format;		/* Format in which selection
				 * info will be returned, such
				 * as STRING or ATOM. */
    Tk_XSelectionProc *proc;	/* Procedure to generate selection
				 * in this format. */
    ClientData clientData;	/* Argument to pass to proc. */
    int size;			/* Size of units returned by proc
				 * (8 for STRING, 32 for almost
				 * anything else). */
    struct TkSelHandler *nextPtr;
				/* Next selection handler associated
				 * with same window (NULL for end of
				 * list). */
} TkSelHandler;

/*
 * When the selection is being retrieved, one of the following
 * structures is present on a list of pending selection retrievals.
 * The structure is used to communicate between the background
 * procedure that requests the selection and the foreground
 * event handler that processes the events in which the selection
 * is returned.  There is a list of such structures so that there
 * can be multiple simultaneous selection retrievals (e.g. on
 * different displays).
 */

typedef struct RetrievalInfo {
    Tcl_Interp *interp;		/* Interpreter for error reporting. */
    TkWindow *winPtr;		/* Window used as requestor for
				 * selection. */
    Atom selection;		/* Selection being requested. */
    Atom property;		/* Property where selection will appear. */
    Atom target;		/* Desired form for selection. */
    Tk_GetXSelProc *proc; 	/* Procedure to call to handle pieces
				 * of selection. */
    ClientData clientData;	/* Argument for proc. */
    int result;			/* Initially -1.  Set to a Tcl
				 * return value once the selection
				 * has been retrieved. */
    Tk_TimerToken timeout;	/* Token for current timeout procedure. */
    int idleTime;		/* Number of seconds that have gone by
				 * without hearing anything from the
				 * selection owner. */
    struct RetrievalInfo *nextPtr;
				/* Next in list of all pending
				 * selection retrievals.  NULL means
				 * end of list. */
} RetrievalInfo;

static RetrievalInfo *pendingRetrievals = NULL;
				/* List of all retrievals currently
				 * being waited for. */

/*
 * When handling INCR-style selection retrievals, the selection owner
 * uses the following data structure to communicate between the
 * ConvertSelection procedure and TkSelPropProc.
 */

typedef struct IncrInfo {
    TkWindow *winPtr;		/* Window that owns selection. */
    Atom selection;		/* Selection that is being retrieved. */
    Atom *multAtoms;		/* Information about conversions to
				 * perform:  one or more pairs of
				 * (target, property).  This either
				 * points to a retrieved  property (for
				 * MULTIPLE retrievals) or to a static
				 * array. */
    unsigned long numConversions;
				/* Number of entries in offsets (same as
				 * # of pairs in multAtoms). */
    int *offsets;		/* One entry for each pair in
				 * multAtoms;  -1 means all data has
				 * been transferred for this
				 * conversion.  -2 means only the
				 * final zero-length transfer still
				 * has to be done.  Otherwise it is the
				 * offset of the next chunk of data
				 * to transfer.  This array is malloc-ed. */
    int numIncrs;		/* Number of entries in offsets that
				 * aren't -1 (i.e. # of INCR-mode transfers
				 * not yet completed). */
    Tk_TimerToken timeout;	/* Token for timer procedure. */
    int idleTime;		/* Number of seconds since we heard
				 * anything from the selection
				 * requestor. */
    Window reqWindow;		/* Requestor's window id. */
    Time time;			/* Timestamp corresponding to
				 * selection at beginning of request;
				 * used to abort transfer if selection
				 * changes. */
    struct IncrInfo *nextPtr;	/* Next in list of all INCR-style
				 * retrievals currently pending. */
} IncrInfo;

static IncrInfo *pendingIncrs = NULL;
				/* List of all incr structures
				 * currently active. */

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
 * It is possible for a Tk_SelectionProc to delete the handler that it
 * represents.  If this happens, the code that is retrieving the selection
 * needs to know about it so it doesn't use the now-defunct handler
 * structure.  One structure of the following form is created for each
 * retrieval in progress, so that the retriever can find out if its
 * handler is deleted.  All of the pending retrievals (if there are more
 * than one) are linked into a list.
 */

typedef struct InProgress {
    TkSelHandler *selPtr;	/* Handler being executed.  If this handler
				 * is deleted, the field is set to NULL. */
    struct InProgress *nextPtr; /* Next higher nested search. */
#if 0
    TkWindow *winPtr;		 /* Window for selection.  Gets set to None if
				  * window is deleted while selection is being
				  * handled. */
#endif
} InProgress;

static InProgress *pendingPtr = NULL;
				/* Topmost search in progress, or
				 * NULL if none. */

/*
 * Chunk size for retrieving selection.  It's defined both in
 * words and in bytes;  the word size is used to allocate
 * buffer space that's guaranteed to be word-aligned and that
 * has an extra character for the terminating NULL.
 */

#define TK_SEL_BYTES_AT_ONCE 4000
#define TK_SEL_WORDS_AT_ONCE 1001

/*
 * Largest property that we'll accept when sending or receiving the
 * selection:
 */

#define MAX_PROP_WORDS 100000

/*
 * Forward declarations for procedures defined in this file:
 */

static void		ConvertSelection _ANSI_ARGS_((TkWindow *winPtr,
			    XSelectionRequestEvent *eventPtr));
static int		DefaultSelection _ANSI_ARGS_((
			    TkSelectionInfo *infoPtr, Atom target,
			    long *buffer, int maxBytes, Atom *typePtr, int *formatPtr));
static int		HandleTclCommand _ANSI_ARGS_((ClientData clientData,
			    int offset, char *buffer, int maxBytes));
static void		IncrTimeoutProc _ANSI_ARGS_((ClientData clientData));
static void		LostSelection _ANSI_ARGS_((ClientData clientData));
static char *		SelCvtFromX _ANSI_ARGS_((long *propPtr, int numValues,
			    Atom type, Tk_Window tkwin));
static int		SelectionSize _ANSI_ARGS_((TkSelHandler *selPtr,Tk_Window tkwin));
static int		SelCvtToX _ANSI_ARGS_((long *buffer, char *string, Atom type,
			    Tk_Window tkwin, int maxBytes));
static int		SelGetProc _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, char *portion));
static void		SelRcvIncrProc _ANSI_ARGS_((ClientData clientData,
			    XEvent *eventPtr));
static void		SelTimeoutProc _ANSI_ARGS_((ClientData clientData));
static void		FreeHandler _ANSI_ARGS_((ClientData clientData));
static int		HandleCompat _ANSI_ARGS_((ClientData clientData,
			    int offset, long *buffer, int maxBytes, 
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
   return SelCvtToX(Xbuffer, buffer, type, tkwin, maxBytes);
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
    register InProgress *ipPtr;

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
	infoPtr->owner = tkwin;
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
 *	then an error message is left in Tcl_GetResult(interp).
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
 *	TCL_ERROR and leave an error message in Tcl_GetResult(interp); the
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
    RetrievalInfo retr;
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
	long buffer[TK_SEL_WORDS_AT_ONCE];
	InProgress ip;

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

	    count = DefaultSelection(infoPtr, target, buffer,
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
     * The selection is owned by some other process.  To
     * retrieve it, first record information about the retrieval
     * in progress.  Use an internal window as the requestor.
     */

    retr.interp = interp;
    if (dispPtr->clipWindow == NULL) {
	int result;

	result = TkClipInit(interp, dispPtr);
	if (result != TCL_OK) {
	    return result;
	}
    }
    retr.winPtr = (TkWindow *) dispPtr->clipWindow;
    retr.selection = selection;
    retr.property = selection;
    retr.target = target;
    retr.proc = proc;
    retr.clientData = clientData;
    retr.result = -1;
    retr.idleTime = 0;
    retr.nextPtr = pendingRetrievals;
    pendingRetrievals = &retr;

    /*
     * Initiate the request for the selection.  Note:  can't use
     * TkCurrentTime for the time.  If we do, and this application hasn't
     * received any X events in a long time, the current time will be way
     * in the past and could even predate the time when the selection was
     * made;  if this happens, the request will be rejected.
     */

    XConvertSelection(winPtr->display, retr.selection, retr.target,
	    retr.property, retr.winPtr->window, CurrentTime);

    /*
     * Enter a loop processing X events until the selection
     * has been retrieved and processed.  If no response is
     * received within a few seconds, then timeout.
     */

    retr.timeout = Tk_CreateTimerHandler(1000, SelTimeoutProc,
	    (ClientData) &retr);
    while (retr.result == -1) {
	Tk_DoOneEvent(0);
    }
    Tk_DeleteTimerHandler(retr.timeout);

    /*
     * Unregister the information about the selection retrieval
     * in progress.
     */

    if (pendingRetrievals == &retr) {
	pendingRetrievals = retr.nextPtr;
    } else {
	RetrievalInfo *retrPtr;

	for (retrPtr = pendingRetrievals; retrPtr != NULL;
		retrPtr = retrPtr->nextPtr) {
	    if (retrPtr->nextPtr == &retr) {
		retrPtr->nextPtr = retr.nextPtr;
		break;
	    }
	}
    }
    return retr.result;

    cantget:
    Tcl_AppendResult(interp, Tk_GetAtomName(tkwin, selection),
	" selection doesn't exist or form \"", Tk_GetAtomName(tkwin, target),
	"\" not defined",          NULL);
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
	Tcl_SprintfResult(interp,
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
	Tcl_SprintfResult(interp,
	    "bad format for selection: wanted \"32\", got \"%d\"",
	    format);
	return TCL_ERROR;
    }
    string = SelCvtFromX(portion, (int) numItems, type, tkwin);
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
Tk_SelectionCmd(clientData, interp, argc, args)
    ClientData clientData;	/* Main window associated with
				 * interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Arg *args;		/* Argument strings. */
{
    Tk_Window tkwin = (Tk_Window) clientData;
    char *path = NULL;
    Atom selection;
    char *selName = NULL;
    int c, count;
    size_t length;
    Arg *argp;

    if (argc < 2) {
	Tcl_SprintfResult(interp,
		"wrong # args: should be \"%.50s option ?arg arg ...?\"",
		LangString(args[0]));
	return TCL_ERROR;
    }
    c = LangString(args[1])[0];
    length = strlen(LangString(args[1]));
    if ((c == 'c') && (strncmp(LangString(args[1]), "clear", length) == 0)) {
	for (count = argc-2, argp = args+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (*string != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing",          NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') &&  LangCmpOpt("-displayof",string,length) == 0 ) {
		path = LangString(argp[1]);
	    } else if ((c == 's') &&  LangCmpOpt("-selection",string,length) == 0 ) {

		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"",          NULL);
		return TCL_ERROR;
	    }
	}
	if (count == 1) {
	    path = LangString(*argp);
	} else if (count > 1) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", LangString(args[0]),
		    " clear ?options?\"",          NULL);
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
    } else if ((c == 'e') && (strncmp(LangString(args[1]), "exists", length) == 0)) {
	Window win = None;
	for (count = argc-2, argp = args+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (*string != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing",          NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') &&  LangCmpOpt("-displayof",string,length) == 0 ) {
		path = LangString(argp[1]);
	    } else if ((c == 's') &&  LangCmpOpt("-selection",string,length) == 0 ) {

		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"",          NULL);
		return TCL_ERROR;
	    }
	}
	if (count == 1) {
	    path = LangString(*argp);
	} else if (count > 1) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", LangString(args[0]),
		    " clear ?options?\"",          NULL);
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
    } else if ((c == 'g') && (strncmp(LangString(args[1]), "get", length) == 0)) {
	Atom target;
	char *targetName = NULL;
	Tcl_DString selBytes;
	int result;
	
	for (count = argc-2, argp = args+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing",          NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'd') &&  LangCmpOpt("-displayof",string,length) == 0 ) {
		path = LangString(argp[1]);
	    } else if ((c == 's') &&  LangCmpOpt("-selection",string,length) == 0 ) {

		selName = LangString(argp[1]);
	    } else if ((c == 't') &&  LangCmpOpt("-type",string,length) == 0 ) {

		targetName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"",          NULL);
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
	    Tcl_AppendResult(interp, "wrong # args: should be \"", LangString(args[0]),
		    " get ?options?\"",          NULL);
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
    } else if ((c == 'h') && (strncmp(LangString(args[1]), "handle", length) == 0)) {
	Atom target, format;
	char *targetName = NULL;
	char *formatName = NULL;
	register CommandInfo *cmdInfoPtr;
	int cmdLength;
	
	for (count = argc-2, argp = args+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing",          NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'f') &&  LangCmpOpt("-format",string,length) == 0 ) {
		formatName = LangString(argp[1]);
	    } else if ((c == 's') &&  LangCmpOpt("-selection",string,length) == 0 ) {

		selName = LangString(argp[1]);
	    } else if ((c == 't') &&  LangCmpOpt("-type",string,length) == 0 ) {

		targetName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"",          NULL);
		return TCL_ERROR;
	    }
	}

	if ((count < 2) || (count > 4)) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", LangString(args[0]),
		    " handle ?options? window command\"",          NULL);
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
    } else if ((c == 'o') && (strncmp(LangString(args[1]), "own", length) == 0)) {
	register LostCommand *lostPtr;
	Arg script = NULL;
	int cmdLength;

	for (count = argc-2, argp = args+2; count > 0; count -= 2, argp += 2) {
            char *string = LangString(argp[0]);
	    if (string[0] != '-') {
		break;
	    }
	    if (count < 2) {
		Tcl_AppendResult(interp, "value for \"", string,
			"\" missing",          NULL);
		return TCL_ERROR;
	    }
	    c = string[1];
	    length = strlen(string);
	    if ((c == 'c') &&  LangCmpOpt("-command",string,length) == 0 ) {
		script = argp[1];
	    } else if ((c == 'd') &&  LangCmpOpt("-displayof",string,length) == 0 ) {

		path = LangString(argp[1]);
	    } else if ((c == 's') &&  LangCmpOpt("-selection",string,length) == 0 ) {

		selName = LangString(argp[1]);
	    } else {
		Tcl_AppendResult(interp, "unknown option \"", string,
			"\"",          NULL);
		return TCL_ERROR;
	    }
	}

	if (count > 2) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", LangString(args[0]),
		    " own ?options? ?window?\"",          NULL);
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
	Tcl_SprintfResult(interp,
		"bad option \"%.50s\":  must be clear, get, handle, or own",
		LangString(args[1]));
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
    register InProgress *ipPtr;
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
 *--------------------------------------------------------------
 *
 * TkSelEventProc --
 *
 *	This procedure is invoked whenever a selection-related
 *	event occurs.  It does the lion's share of the work
 *	in implementing the selection protocol.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Lots:  depends on the type of event.
 *
 *--------------------------------------------------------------
 */

void
TkSelEventProc(tkwin, eventPtr)
    Tk_Window tkwin;		/* Window for which event was
				 * targeted. */
    register XEvent *eventPtr;	/* X event:  either SelectionClear,
				 * SelectionRequest, or
				 * SelectionNotify. */
{
    register TkWindow *winPtr = (TkWindow *) tkwin;
    TkDisplay *dispPtr = winPtr->dispPtr;

    /*
     * Case #1: SelectionClear events.  Invoke clear procedure
     * for window that just lost the selection.  This code is a
     * bit tricky, because any callbacks due to selection changes
     * between windows managed by the process have already been
     * made.  Thus, ignore the event unless it refers to the
     * window that's currently the selection owner and the event
     * was generated after the server saw the SetSelectionOwner
     * request.
     */

    if (eventPtr->type == SelectionClear) {
	TkSelectionInfo *infoPtr;
	TkSelectionInfo *prevPtr;
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
	return;
    }

    /*
     * Case #2: SelectionNotify events.  Call the relevant procedure
     * to handle the incoming selection.
     */

    if (eventPtr->type == SelectionNotify) {
	register RetrievalInfo *retrPtr;
	long *propInfo;
	Atom type;
	int format, result;
	unsigned long numItems, bytesAfter;

	for (retrPtr = pendingRetrievals; ; retrPtr = retrPtr->nextPtr) {
	    if (retrPtr == NULL) {
		return;
	    }
	    if ((retrPtr->winPtr == winPtr)
		    && (retrPtr->selection == eventPtr->xselection.selection)
		    && (retrPtr->target == eventPtr->xselection.target)
		    && (retrPtr->result == -1)) {
		if (retrPtr->property == eventPtr->xselection.property) {
		    break;
		}
		if (eventPtr->xselection.property == None) {
		    Tcl_SetResult(retrPtr->interp,          NULL, TCL_STATIC);
		    Tcl_AppendResult(retrPtr->interp,
			    Tk_GetAtomName(tkwin, retrPtr->selection),
			    " selection doesn't exist or form \"",
			    Tk_GetAtomName(tkwin, retrPtr->target),
			    "\" not defined",          NULL);
		    retrPtr->result = TCL_ERROR;
		    return;
		}
	    }
	}

	propInfo = NULL;
	result = XGetWindowProperty(eventPtr->xselection.display,
		eventPtr->xselection.requestor, retrPtr->property,
		0, MAX_PROP_WORDS, False, (Atom) AnyPropertyType,
		&type, &format, &numItems, &bytesAfter,
		(unsigned char **) &propInfo);
	if ((result != Success) || (type == None)) {
	    return;
	}
	if (bytesAfter != 0) {
	    Tcl_SetResult(retrPtr->interp, "selection property too large", TCL_STATIC);

	    retrPtr->result = TCL_ERROR;
	    XFree((char *) propInfo);
	    return;
	}
	if ((type == XA_STRING) || (type == dispPtr->textAtom)
		|| (type == dispPtr->compoundTextAtom)) {
	    retrPtr->result = (*retrPtr->proc)(retrPtr->clientData,
		    retrPtr->interp, propInfo, (int) numItems, format, XA_STRING, (Tk_Window) winPtr);
	} else if (type == dispPtr->incrAtom) {

	    /*
	     * It's a !?#@!?!! INCR-style reception.  Arrange to receive
	     * the selection in pieces, using the ICCCM protocol, then
	     * hang around until either the selection is all here or a
	     * timeout occurs.
	     */

	    retrPtr->idleTime = 0;
	    Tk_CreateEventHandler(tkwin, PropertyChangeMask, SelRcvIncrProc,
		    (ClientData) retrPtr);
	    XDeleteProperty(Tk_Display(tkwin), Tk_WindowId(tkwin),
		    retrPtr->property);
	    while (retrPtr->result == -1) {
		Tk_DoOneEvent(0);
	    }
	    Tk_DeleteEventHandler(tkwin, PropertyChangeMask, SelRcvIncrProc,
		    (ClientData) retrPtr);
	} else {
	    retrPtr->result = (*retrPtr->proc)(retrPtr->clientData,
		    retrPtr->interp, propInfo, (int) numItems, format, type, (Tk_Window) winPtr);
	}
	XFree((char *) propInfo);
	return;
    }

    /*
     * Case #3: SelectionRequest events.  Call ConvertSelection to
     * do the dirty work.
     */

    if (eventPtr->type == SelectionRequest) {
	ConvertSelection(winPtr, &eventPtr->xselectionrequest);
	return;
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
 *----------------------------------------------------------------------
 *
 * SelCvtToX --
 *
 *	Given a selection represented as a string (the normal Tcl form),
 *	convert it to the ICCCM-mandated format for X, depending on
 *	the type argument.  This procedure and SelCvtFromX are inverses.
 *
 * Results:
 *	The return value is a malloc'ed buffer holding a value
 *	equivalent to "string", but formatted as for "type".  It is
 *	the caller's responsibility to free the string when done with
 *	it.  The word at *numLongsPtr is filled in with the number of
 *	32-bit words returned in the result.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
SelCvtToX(propPtr, string, type, tkwin, maxBytes)
    long *propPtr;
    char *string;		/* String representation of selection. */
    Atom type;			/* Atom specifying the X format that is
				 * desired for the selection.  Should not
				 * be XA_STRING (if so, don't bother calling
				 * this procedure at all). */
    Tk_Window tkwin;		/* Window that governs atom conversion. */
    int maxBytes;		/* Number of 32-bit words contained in the
				 * result. */
{
    register char *p;
    char *field;
    int numFields;
    int bytes;
    long *longPtr;
#define MAX_ATOM_NAME_LENGTH 100
    char atomName[MAX_ATOM_NAME_LENGTH+1];

    /*
     * The string is assumed to consist of fields separated by spaces.
     * The property gets generated by converting each field to an
     * integer number, in one of two ways:
     * 1. If type is XA_ATOM, convert each field to its corresponding
     *	  atom.
     * 2. If type is anything else, convert each field from an ASCII number
     *    to a 32-bit binary number.
     */

    numFields = 1;
    for (p = string; *p != 0; p++) {
	if (isspace(UCHAR(*p))) {
	    numFields++;
	}
    }
    /*
     * Convert the fields one-by-one.
     */

    for (longPtr = propPtr, bytes = 0, p = string; bytes < maxBytes
	    ; bytes += sizeof(long), longPtr++) {
	while (isspace(UCHAR(*p))) {
	    p++;
	}
	if (*p == 0) {
	    break;
	}
	field = p;
	while ((*p != 0) && !isspace(UCHAR(*p))) {
	    p++;
	}
	if (type == XA_ATOM) {
	    int length;

	    length = p - field;
	    if (length > MAX_ATOM_NAME_LENGTH) {
		length = MAX_ATOM_NAME_LENGTH;
	    }
	    strncpy(atomName, field, (unsigned) length);
	    atomName[length] = 0;
	    *longPtr = (long) Tk_InternAtom(tkwin, atomName);
	} else {
	    char *dummy;

	    *longPtr = strtol(field, &dummy, 0);
	}
    }
    return bytes / sizeof(long);
}

/*
 *----------------------------------------------------------------------
 *
 * SelCvtFromX --
 *
 *	Given an X property value, formatted as a collection of 32-bit
 *	values according to "type" and the ICCCM conventions, convert
 *	the value to a string suitable for manipulation by Tcl.  This
 *	procedure is the inverse of SelCvtToX.
 *
 * Results:
 *	The return value is the string equivalent of "property".  It is
 *	malloc-ed and should be freed by the caller when no longer
 *	needed.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static char *
SelCvtFromX(propPtr, numValues, type, tkwin)
    register long *propPtr;	/* Property value from X. */
    int numValues;		/* Number of 32-bit values in property. */
    Atom type;			/* Type of property  Should not be
				 * XA_STRING (if so, don't bother calling
				 * this procedure at all). */
    Tk_Window tkwin;		/* Window to use for atom conversion. */
{
    char *result;
    int resultSpace, curSize, fieldSize;
    char *atomName;

    /*
     * Convert each long in the property to a string value, which is
     * either the name of an atom (if type is XA_ATOM) or a hexadecimal
     * string.  Make an initial guess about the size of the result, but
     * be prepared to enlarge the result if necessary.
     */

    resultSpace = 12*numValues+1;
    curSize = 0;
    atomName = "";	/* Not needed, but eliminates compiler warning. */
    result = (char *) ckalloc((unsigned) resultSpace);
    *result  = '\0';
    for ( ; numValues > 0; propPtr++, numValues--) {
	if (type == XA_ATOM) {
	    atomName = Tk_GetAtomName(tkwin, (Atom) *propPtr);
	    fieldSize = strlen(atomName) + 1;
	} else {
	    fieldSize = 12;
	}
	if (curSize+fieldSize >= resultSpace) {
	    char *newResult;

	    resultSpace *= 2;
	    if (curSize+fieldSize >= resultSpace) {
		resultSpace = curSize + fieldSize + 1;
	    }
	    newResult = (char *) ckalloc((unsigned) resultSpace);
	    strncpy(newResult, result, (unsigned) curSize);
	    ckfree(result);
	    result = newResult;
	}
	if (curSize != 0) {
	    result[curSize] = ' ';
	    curSize++;
	}
	if (type == XA_ATOM) {
	    strcpy(result+curSize, atomName);
	} else {
	    sprintf(result+curSize, "0x%x", (unsigned int) *propPtr);
	}
	curSize += strlen(result+curSize);
    }
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 * ConvertSelection --
 *
 *	This procedure is invoked to handle SelectionRequest events.
 *	It responds to the requests, obeying the ICCCM protocols.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Properties are created for the selection requestor, and a
 *	SelectionNotify event is generated for the selection
 *	requestor.  In the event of long selections, this procedure
 *	implements INCR-mode transfers, using the ICCCM protocol.
 *
 *----------------------------------------------------------------------
 */

static void
ConvertSelection(winPtr, eventPtr)
    TkWindow *winPtr;			/* Window that received the
					 * conversion request;  may not be
					 * selection's current owner, be we
					 * set it to the current owner. */
    register XSelectionRequestEvent *eventPtr;
					/* Event describing request. */
{
    XSelectionEvent reply;		/* Used to notify requestor that
					 * selection info is ready. */
    int multiple;			/* Non-zero means a MULTIPLE request
					 * is being handled. */
    IncrInfo incr;			/* State of selection conversion. */
    Atom singleInfo[2];			/* incr.multAtoms points here except
					 * for multiple conversions. */
    int i;
    Tk_ErrorHandler errorHandler;
    TkSelectionInfo *infoPtr;
    InProgress ip;

    errorHandler = Tk_CreateErrorHandler(eventPtr->display, -1, -1,-1,
	    (int (*)()) NULL, (ClientData) NULL);

    /*
     * Initialize the reply event.
     */

    reply.type = SelectionNotify;
    reply.serial = 0;
    reply.send_event = True;
    reply.display = eventPtr->display;
    reply.requestor = eventPtr->requestor;
    reply.selection = eventPtr->selection;
    reply.target = eventPtr->target;
    reply.property = eventPtr->property;
    if (reply.property == None) {
	reply.property = reply.target;
    }
    reply.time = eventPtr->time;

    for (infoPtr = winPtr->dispPtr->selectionInfoPtr; infoPtr != NULL;
	    infoPtr = infoPtr->nextPtr) {
	if (infoPtr->selection == eventPtr->selection)
	    break;
    }
    if (infoPtr == NULL) {
	goto refuse;
    }
    winPtr = (TkWindow *) infoPtr->owner;

    /*
     * Figure out which kind(s) of conversion to perform.  If handling
     * a MULTIPLE conversion, then read the property describing which
     * conversions to perform.
     */

    incr.winPtr = winPtr;
    incr.selection = eventPtr->selection;
    if (eventPtr->target != winPtr->dispPtr->multipleAtom) {
	multiple = 0;
	singleInfo[0] = reply.target;
	singleInfo[1] = reply.property;
	incr.multAtoms = singleInfo;
	incr.numConversions = 1;
    } else {
	Atom type;
	int format, result;
	unsigned long bytesAfter;

	multiple = 1;
	incr.multAtoms = NULL;
	if (eventPtr->property == None) {
	    goto refuse;
	}
	result = XGetWindowProperty(eventPtr->display,
		eventPtr->requestor, eventPtr->property,
		0, MAX_PROP_WORDS, False, XA_ATOM,
		&type, &format, &incr.numConversions, &bytesAfter,
		(unsigned char **) &incr.multAtoms);
	if ((result != Success) || (bytesAfter != 0) || (format != 32)
		|| (type == None)) {
	    if (incr.multAtoms != NULL) {
		XFree((char *) incr.multAtoms);
	    }
	    goto refuse;
	}
	incr.numConversions /= 2;		/* Two atoms per conversion. */
    }

    /*
     * Loop through all of the requested conversions, and either return
     * the entire converted selection, if it can be returned in a single
     * bunch, or return INCR information only (the actual selection will
     * be returned below).
     */

    incr.offsets = (int *) ckalloc((unsigned)
	    (incr.numConversions*sizeof(int)));
    incr.numIncrs = 0;
    for (i = 0; i < incr.numConversions; i++) {
	Atom target, property, type = XA_STRING;
	long buffer[TK_SEL_WORDS_AT_ONCE];
	register TkSelHandler *selPtr;
	int numItems, format = 8;
	char *propPtr;

	target = incr.multAtoms[2*i];
	property = incr.multAtoms[2*i + 1];
	incr.offsets[i] = -1;

	for (selPtr = winPtr->selHandlerList; selPtr != NULL;
		selPtr = selPtr->nextPtr) {
	    if ((selPtr->target == target)
		    && (selPtr->selection == eventPtr->selection)) {
		break;
	    }
	}

	if (selPtr == NULL) {
	    /*
	     * Nobody seems to know about this kind of request.  If
	     * it's of a sort that we can handle without any help, do
	     * it.  Otherwise mark the request as an errror.
	     */

	    numItems = DefaultSelection(infoPtr, target, buffer,
		    TK_SEL_BYTES_AT_ONCE, &type, &format);
	    if (numItems < 0) {
		incr.multAtoms[2*i + 1] = None;
		continue;
	    }
	} else {
	    ip.selPtr = selPtr;
	    ip.nextPtr = pendingPtr;
	    pendingPtr = &ip;
	    type = selPtr->format;
	    format = (type == XA_STRING) ? 8: 32;
	    numItems = (*selPtr->proc)(selPtr->clientData, 0,
		    buffer, TK_SEL_BYTES_AT_ONCE, type, (Tk_Window) winPtr);
	    pendingPtr = ip.nextPtr;
	    if ((ip.selPtr == NULL) || (numItems < 0)) {
		incr.multAtoms[2*i + 1] = None;
		continue;
	    }
	    if (numItems > TK_SEL_BYTES_AT_ONCE) {
		panic("selection handler returned too many bytes");
	    }
	    ((char *) buffer)[numItems] = '\0';
	}

	/*
	 * Got the selection;  store it back on the requestor's property.
	 */

	if (numItems == TK_SEL_BYTES_AT_ONCE) {
	    /*
	     * Selection is too big to send at once;  start an
	     * INCR-mode transfer.
	     */

	    incr.numIncrs++;
	    type = winPtr->dispPtr->incrAtom;
	    buffer[0] = SelectionSize(selPtr, (Tk_Window) winPtr);
	    if (buffer[0] == 0) {
		incr.multAtoms[2*i + 1] = None;
		continue;
	    }
	    numItems = 1;
	    propPtr = (char *) buffer;
	    format = 32;
	    incr.offsets[i] = 0;
	} else {
	    propPtr = (char *) buffer;
	}
	XChangeProperty(reply.display, reply.requestor,
		property, type, format, PropModeReplace,
		(unsigned char *) propPtr, numItems);
	if (propPtr != (char *) buffer) {
	    ckfree(propPtr);
	}
    }

    /*
     * Send an event back to the requestor to indicate that the
     * first stage of conversion is complete (everything is done
     * except for long conversions that have to be done in INCR
     * mode).
     */

    if (incr.numIncrs > 0) {
	XSelectInput(reply.display, reply.requestor, PropertyChangeMask);
	incr.timeout = Tk_CreateTimerHandler(1000, IncrTimeoutProc,
	    (ClientData) &incr);
	incr.idleTime = 0;
	incr.reqWindow = reply.requestor;
	incr.time = infoPtr->time;
	incr.nextPtr = pendingIncrs;
	pendingIncrs = &incr;
    }
    if (multiple) {
	XChangeProperty(reply.display, reply.requestor, reply.property,
		XA_ATOM, 32, PropModeReplace,
		(unsigned char *) incr.multAtoms,
		(int) incr.numConversions*2);
    } else {

	/*
	 * Not a MULTIPLE request.  The first property in "multAtoms"
	 * got set to None if there was an error in conversion.
	 */

	reply.property = incr.multAtoms[1];
    }
    XSendEvent(reply.display, reply.requestor, False, 0, (XEvent *) &reply);
    Tk_DeleteErrorHandler(errorHandler);

    /*
     * Handle any remaining INCR-mode transfers.  This all happens
     * in callbacks to TkSelPropProc, so just wait until the number
     * of uncompleted INCR transfers drops to zero.
     */

    if (incr.numIncrs > 0) {
	IncrInfo *incrPtr2;

	while (incr.numIncrs > 0) {
	    Tk_DoOneEvent(0);
	}
	Tk_DeleteTimerHandler(incr.timeout);
	errorHandler = Tk_CreateErrorHandler(winPtr->display,
		-1, -1,-1, (int (*)()) NULL, (ClientData) NULL);
	XSelectInput(reply.display, reply.requestor, 0L);
	Tk_DeleteErrorHandler(errorHandler);
	if (pendingIncrs == &incr) {
	    pendingIncrs = incr.nextPtr;
	} else {
	    for (incrPtr2 = pendingIncrs; incrPtr2 != NULL;
		    incrPtr2 = incrPtr2->nextPtr) {
		if (incrPtr2->nextPtr == &incr) {
		    incrPtr2->nextPtr = incr.nextPtr;
		    break;
		}
	    }
	}
    }

    /*
     * All done.  Cleanup and return.
     */

    ckfree((char *) incr.offsets);
    if (multiple) {
	XFree((char *) incr.multAtoms);
    }
    return;

    /*
     * An error occurred.  Send back a refusal message.
     */

    refuse:
    reply.property = None;
    XSendEvent(reply.display, reply.requestor, False, 0, (XEvent *) &reply);
    Tk_DeleteErrorHandler(errorHandler);
    return;
}

/*
 *----------------------------------------------------------------------
 *
 * SelRcvIncrProc --
 *
 *	This procedure handles the INCR protocol on the receiving
 *	side.  It is invoked in response to property changes on
 *	the requestor's window (which hopefully are because a new
 *	chunk of the selection arrived).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	If a new piece of selection has arrived, a procedure is
 *	invoked to deal with that piece.  When the whole selection
 *	is here, a flag is left for the higher-level procedure that
 *	initiated the selection retrieval.
 *
 *----------------------------------------------------------------------
 */

static void
SelRcvIncrProc(clientData, eventPtr)
    ClientData clientData;		/* Information about retrieval. */
    register XEvent *eventPtr;		/* X PropertyChange event. */
{
    register RetrievalInfo *retrPtr = (RetrievalInfo *) clientData;
    long *propInfo;
    Atom type = XA_STRING;
    int format = 8, result;
    unsigned long numItems, bytesAfter;

    if ((eventPtr->xproperty.atom != retrPtr->property)
	    || (eventPtr->xproperty.state != PropertyNewValue)
	    || (retrPtr->result != -1)) {
	return;
    }
    propInfo = NULL;
    result = XGetWindowProperty(eventPtr->xproperty.display,
	    eventPtr->xproperty.window, retrPtr->property, 0, MAX_PROP_WORDS,
	    True, (Atom) AnyPropertyType, &type, &format, &numItems,
	    &bytesAfter, (unsigned char **) &propInfo);
    if ((result != Success) || (type == None)) {
	return;
    }
    if (bytesAfter != 0) {
	Tcl_SetResult(retrPtr->interp, "selection property too large", TCL_STATIC);

	retrPtr->result = TCL_ERROR;
	goto done;
    }
    if (numItems == 0) {
	retrPtr->result = TCL_OK;
    } else if ((type == XA_STRING)
	    || (type == retrPtr->winPtr->dispPtr->textAtom)
	    || (type == retrPtr->winPtr->dispPtr->compoundTextAtom)) {
	if (format != 8) {
	    Tcl_SetResult(retrPtr->interp,          NULL, TCL_STATIC);
	    sprintf(Tcl_GetResult(retrPtr->interp),
		"bad format for string selection: wanted \"8\", got \"%d\"",
		format);
	    retrPtr->result = TCL_ERROR;
	    goto done;
	}
	result = (*retrPtr->proc)(retrPtr->clientData, retrPtr->interp,
		propInfo, (int) numItems, format, XA_STRING, (Tk_Window) retrPtr->winPtr);
	if (result != TCL_OK) {
	    retrPtr->result = result;
	}
    } else {
	result = (*retrPtr->proc)(retrPtr->clientData, retrPtr->interp,
		propInfo, (int) numItems, format, type, (Tk_Window) retrPtr->winPtr);
	if (result != TCL_OK) {
	    retrPtr->result = result;
	}
    }

    done:
    XFree((char *) propInfo);
    retrPtr->idleTime = 0;
}

/*
 *----------------------------------------------------------------------
 *
 * TkSelPropProc --
 *
 *	This procedure is invoked when property-change events
 *	occur on windows not known to the toolkit.  Its function
 *	is to implement the sending side of the INCR selection
 *	retrieval protocol when the selection requestor deletes
 *	the property containing a part of the selection.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	If the property that is receiving the selection was just
 *	deleted, then a new piece of the selection is fetched and
 *	placed in the property, until eventually there's no more
 *	selection to fetch.
 *
 *----------------------------------------------------------------------
 */

void
TkSelPropProc(eventPtr)
    register XEvent *eventPtr;		/* X PropertyChange event. */
{
    register IncrInfo *incrPtr;
    int i, format = 8;
    Atom target, formatType = None;
    register TkSelHandler *selPtr;
    long buffer[TK_SEL_WORDS_AT_ONCE];
    int numItems;
    char *propPtr;
    Tk_ErrorHandler errorHandler;

    /*
     * See if this event announces the deletion of a property being
     * used for an INCR transfer.  If so, then add the next chunk of
     * data to the property.
     */

    if (eventPtr->xproperty.state != PropertyDelete) {
	return;
    }
    for (incrPtr = pendingIncrs; incrPtr != NULL;
	    incrPtr = incrPtr->nextPtr) {
	if (incrPtr->reqWindow != eventPtr->xproperty.window) {
	    continue;
	}
	for (i = 0; i < incrPtr->numConversions; i++) {
	    if ((eventPtr->xproperty.atom != incrPtr->multAtoms[2*i + 1])
		    || (incrPtr->offsets[i] == -1)){
		continue;
	    }
	    target = incrPtr->multAtoms[2*i];
	    incrPtr->idleTime = 0;
	    for (selPtr = incrPtr->winPtr->selHandlerList; ;
		    selPtr = selPtr->nextPtr) {
		if (selPtr == NULL) {
		    incrPtr->multAtoms[2*i + 1] = None;
		    incrPtr->offsets[i] = -1;
		    incrPtr->numIncrs --;
		    return;
		}
		if ((selPtr->target == target)
			&& (selPtr->selection == incrPtr->selection)) {
		    formatType = selPtr->format;
		    if (incrPtr->offsets[i] == -2) {
			numItems = 0;
			((char *) buffer)[0] = 0;
		    } else {
			InProgress ip;
			ip.selPtr = selPtr;
			ip.nextPtr = pendingPtr;
			pendingPtr = &ip;
                        format = (formatType == XA_STRING) ? 8: 32;
			numItems = (*selPtr->proc)(selPtr->clientData,
				incrPtr->offsets[i], buffer,
				TK_SEL_BYTES_AT_ONCE, formatType, (Tk_Window) incrPtr->winPtr);
			pendingPtr = ip.nextPtr;
			if (ip.selPtr == NULL) {
			    /*
			     * The selection handler deleted itself.
			     */
			    return;
			}
			if (numItems > TK_SEL_BYTES_AT_ONCE*8/format) {
			    panic("selection handler returned too many bytes");
			} else {
			    if (numItems < 0) {
				numItems = 0;
			    }
			}
			((char *) buffer)[numItems*format/8] = '\0';
		    }
		    if (numItems < TK_SEL_BYTES_AT_ONCE*8/format) {
			if (numItems <= 0) {
			    incrPtr->offsets[i] = -1;
			    incrPtr->numIncrs--;
			} else {
			    incrPtr->offsets[i] = -2;
			}
		    } else {
			incrPtr->offsets[i] += numItems;
		    }
                    propPtr = (char *) buffer;
		    errorHandler = Tk_CreateErrorHandler(
			    eventPtr->xproperty.display, -1, -1, -1,
			    (int (*)()) NULL, (ClientData) NULL);
		    XChangeProperty(eventPtr->xproperty.display,
			    eventPtr->xproperty.window,
			    eventPtr->xproperty.atom, formatType,
			    format, PropModeReplace,
			    (unsigned char *) propPtr, numItems);
		    Tk_DeleteErrorHandler(errorHandler);
		    if (propPtr != (char *) buffer) {
			ckfree(propPtr);
		    }
		    return;
		}
	    }
	}
    }
}

/*
 *----------------------------------------------------------------------
 *
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
     * are done using it.
     */

    LangResultSave *oldResult = LangSaveResult(&interp);

    int length = -1;

    /*
     * Execute the command.  Be sure to restore the state of the
     * interpreter after executing the command.
     */

    if (LangDoCallback(cmdInfoPtr->interp, cmdInfoPtr->command, 1, 2, "%d %d", offset, maxBytes) == TCL_OK) {
	length = strlen(Tcl_GetResult(cmdInfoPtr->interp));
	if (length > maxBytes) {
	    length = maxBytes;
	}
	memcpy((VOID *) buffer, (VOID *) Tcl_GetResult(cmdInfoPtr->interp), (size_t) length);
	buffer[length] = '\0';
    } else {
	length = -1;
    }

    LangRestoreResult(&interp,oldResult);
    return length;
}

/*
 *----------------------------------------------------------------------
 *
 * SelTimeoutProc --
 *
 *	This procedure is invoked once every second while waiting for
 *	the selection to be returned.  After a while it gives up and
 *	aborts the selection retrieval.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A new timer callback is created to call us again in another
 *	second, unless time has expired, in which case an error is
 *	recorded for the retrieval.
 *
 *----------------------------------------------------------------------
 */

static void
SelTimeoutProc(clientData)
    ClientData clientData;		/* Information about retrieval
					 * in progress. */
{
    register RetrievalInfo *retrPtr = (RetrievalInfo *) clientData;

    /*
     * Make sure that the retrieval is still in progress.  Then
     * see how long it's been since any sort of response was received
     * from the other side.
     */

    if (retrPtr->result != -1) {
	return;
    }
    retrPtr->idleTime++;
    if (retrPtr->idleTime >= 5) {

	/*
	 * Use a careful procedure to store the error message, because
	 * the result could already be partially filled in with a partial
	 * selection return.
	 */

	Tcl_SetResult(retrPtr->interp, "selection owner didn't respond", TCL_STATIC);

	retrPtr->result = TCL_ERROR;
    } else {
	retrPtr->timeout = Tk_CreateTimerHandler(1000, SelTimeoutProc,
	    (ClientData) retrPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * IncrTimeoutProc --
 *
 *	This procedure is invoked once a second while sending the
 *	selection to a requestor in INCR mode.  After a while it
 *	gives up and aborts the selection operation.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A new timeout gets registered so that this procedure gets
 *	called again in another second, unless too many seconds
 *	have elapsed, in which case incrPtr is marked as "all done".
 *
 *----------------------------------------------------------------------
 */

static void
IncrTimeoutProc(clientData)
    ClientData clientData;		/* Information about INCR-mode
					 * selection retrieval for which
					 * we are selection owner. */
{
    register IncrInfo *incrPtr = (IncrInfo *) clientData;

    incrPtr->idleTime++;
    if (incrPtr->idleTime >= 5) {
	incrPtr->numIncrs = 0;
    } else {
	incrPtr->timeout = Tk_CreateTimerHandler(1000, IncrTimeoutProc,
		(ClientData) incrPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * DefaultSelection --
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

static int
DefaultSelection(infoPtr, target, lbuffer, maxBytes, typePtr, formatPtr)
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

    /*
     * Execute the command.  Save the interpreter's result, if any, and
     * restore it after executing the command.
     */

    if (LangDoCallback(lostPtr->interp, lostPtr->command, 0, 0) != TCL_OK) {
        Tcl_AddErrorInfo(lostPtr->interp,"\n (Selection Lost proc)");
	Tk_BackgroundError(lostPtr->interp);
    }
    LangRestoreResult(&lostPtr->interp,oldResult);
 
    /*
     * Free the storage for the command, since we're done with it now.
     */
    LangFreeCallback(lostPtr->command);
    ckfree((char *) lostPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * SelectionSize --
 *
 *	This procedure is called when the selection is too large to
 *	send in a single buffer;  it computes the total length of
 *	the selection in bytes.
 *
 * Results:
 *	The return value is the number of bytes in the selection
 *	given by selPtr.
 *
 * Side effects:
 *	The selection is retrieved from its current owner (this is
 *	the only way to compute its size).
 *
 *----------------------------------------------------------------------
 */

static int
SelectionSize(selPtr,tkwin)
    TkSelHandler *selPtr;	/* Information about how to retrieve
				 * the selection whose size is wanted. */
    Tk_Window tkwin;
{
    long buffer[TK_SEL_WORDS_AT_ONCE];
    int size, chunkSize;
    InProgress ip;

    size = TK_SEL_BYTES_AT_ONCE;
    ip.selPtr = selPtr;
    ip.nextPtr = pendingPtr;
    pendingPtr = &ip;
    do {
	chunkSize = (*selPtr->proc)(selPtr->clientData, size,
			buffer, TK_SEL_BYTES_AT_ONCE, XA_STRING, tkwin);
	if (ip.selPtr == NULL) {
	    size = 0;
	    break;
	}
	size += chunkSize;
    } while (chunkSize == TK_SEL_BYTES_AT_ONCE);
    pendingPtr = ip.nextPtr;
    return size;
}
