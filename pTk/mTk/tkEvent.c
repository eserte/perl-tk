/* 
 * tkEvent.c --
 *
 *	This file provides basic event-managing facilities, whereby
 *	procedure callbacks may be attached to certain events.  It
 *	also contains the command procedures for the commands "after"
 *	and "fileevent", plus abridged versions of "tkwait" and
 *	"update", for use with Tk_EventInit.
 *
 * Copyright (c) 1990-1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

static char sccsid[] = "@(#) tkEvent.c 1.97 95/06/21 15:16:33";

#include "tkPort.h"
#include "tkInt.h"
#include <errno.h>

/*
 * For each timer callback that's pending, there is one record
 * of the following type, chained together in a list sorted by
 * time (earliest event first).
 */

typedef struct TimerEvent {
    struct timeval time;	/* When timer is to fire. */
    void (*proc)  _ANSI_ARGS_((ClientData clientData));
				/* Procedure to call. */
    ClientData clientData;	/* Argument to pass to proc. */
    Tk_TimerToken token;	/* Identifies event so it can be
				 * deleted. */
    struct TimerEvent *nextPtr;	/* Next event in queue, or NULL for
				 * end of queue. */
} TimerEvent;

static TimerEvent *firstTimerHandlerPtr;
				/* First event in queue. */

/*
 * The information below is used to provide read, write, and
 * exception masks to select during calls to Tk_DoOneEvent.
 */

static fd_mask ready[3*MASK_SIZE];
				/* Masks passed to select and modified
				 * by kernel to indicate which files are
				 * actually ready. */
static fd_mask check[3*MASK_SIZE];
				/* Temporary set of masks, built up during
				 * Tk_DoOneEvent, that reflects what files
				 * we should wait for in the next select
				 * (doesn't include things that we've been
				 * asked to ignore in this call). */
static int numFds = 0;		/* Number of valid bits in mask
				 * arrays (this value is passed
				 * to select). */

/*
 * For each file registered in a call to Tk_CreateFileHandler,
 * and for each display that's currently active, there is one
 * record of the following type.  All of these records are
 * chained together into a single list.
 */

typedef struct FileHandler {
    int fd;			/* POSIX file descriptor for file. */
    fd_mask *readPtr;		/* Pointer to word in ready array
				 * for this file's read mask bit. */
    fd_mask *writePtr;		/* Same for write mask bit. */
    fd_mask *exceptPtr;		/* Same for except mask bit. */
    fd_mask *checkReadPtr;	/* Pointer to word in check array for
				 * this file's read mask bit. */
    fd_mask *checkWritePtr;	/* Same for write mask bit. */
    fd_mask *checkExceptPtr;	/* Same for except mask bit. */
    fd_mask bitSelect;		/* Value to AND with *readPtr etc. to
				 * select just this file's bit. */
    int mask;			/* Mask of desired events: TK_READABLE, etc. */
    Tk_FileProc *proc;		/* Procedure to call, in the style of
				 * Tk_CreateFileHandler.  This is NULL
				 * if the handler was created by
				 * Tk_CreateFileHandler2. */
    Tk_FileProc2 *proc2;	/* Procedure to call, in the style of
				 * Tk_CreateFileHandler2.  NULL means that
				 * the handler was created by
				 * Tk_CreateFileHandler. */
    ClientData clientData;	/* Argument to pass to proc. */
    struct FileHandler *nextPtr;/* Next in list of all files we
				 * care about (NULL for end of
				 * list). */
} FileHandler;

static FileHandler *firstFileHandlerPtr;
				/* List of all file events. */

/*
 * There is one of the following structures for each of the
 * handlers declared in a call to Tk_DoWhenIdle.  All of the
 * currently-active handlers are linked together into a list.
 */

typedef struct IdleHandler {
    void (*proc)  _ANSI_ARGS_((ClientData clientData));
				/* Procedure to call. */
    ClientData clientData;	/* Value to pass to proc. */
    int generation;		/* Used to distinguish older handlers from
				 * recently-created ones. */
    struct IdleHandler *nextPtr;/* Next in list of active handlers. */
} IdleHandler;

static IdleHandler *idleList = NULL;
				/* First in list of all idle handlers. */
static IdleHandler *lastIdlePtr = NULL;
				/* Last in list (or NULL for empty list). */
static int idleGeneration = 0;	/* Used to fill in the "generation" fields
				 * of IdleHandler structures.  Increments
				 * each time Tk_DoOneEvent starts calling
				 * idle handlers, so that all old handlers
				 * can be called without calling any of the
				 * new ones created by old ones. */

/*
 * The following procedure provides a secret hook for tkXEvent.c so that
 * it can handle delayed mouse motion events at the right time.
 */

void (*tkDelayedEventProc) _ANSI_ARGS_((void)) = NULL;

/*
 * One of the following structures exists for each file with a handler
 * created by the "fileevent" command.  Several of the fields are
 * two-element arrays, in which the first element is used for read
 * events and the second for write events.
 */

typedef struct FileEvent {
    FILE *f;				/* Stdio handle for file. */
    Tcl_Interp *interps[2];		/* Interpreters in which to execute
					 * scripts.  NULL means no handler
					 * for event. */
    LangCallback *scripts[2];		/* Scripts to evaluate in response to
					 * events (malloc'ed).  NULL means no
					 * handler for event. */
    struct FileEvent *nextPtr;		/* Next in list of all file events
					 * currently defined. */
} FileEvent;

static FileEvent *firstFileEventPtr = NULL;
					/* First in list of all existing
					 * file events. */

/*
 * The data structure below is used by the "after" command to remember
 * the command to be executed later.
 */

typedef struct AfterInfo {
    Tcl_Interp *interp;		/* Interpreter in which to execute command. */
    LangCallback *command;	/* Command to execute.  Malloc'ed, so must
				 * be freed when structure is deallocated. */
    int id;			/* Integer identifier for command;  used to
				 * cancel it. */
    Tk_TimerToken token;	/* Used to cancel the "after" command.  NULL
				 * means that the command is run as an
				 * idle handler rather than as a timer
				 * handler. */
    struct AfterInfo *nextPtr;	/* Next in list of all "after" commands for
				 * the application. */
} AfterInfo;

static AfterInfo *firstAfterPtr = NULL;
				/* First in list of all pending "after"
				 * commands. */

/*
 * The data structure below is used to report background errors.  One
 * such structure is allocated for each error;  it holds information
 * about the interpreter and the error until tkerror can be invoked
 * later as an idle handler.
 */

typedef struct BgError {
    Tcl_Interp *interp;		/* Interpreter in which error occurred.  NULL
				 * means this error report has been cancelled
				 * (a previous report generated a break). */
    char *errorMsg;		/* The error message (interp->result when
				 * the error occurred).  Malloc-ed. */
    char *errorInfo;		/* Value of the errorInfo variable
				 * (malloc-ed). */
    char *errorCode;		/* Value of the errorCode variable
				 * (malloc-ed). */
    struct BgError *nextPtr;	/* Next in list of all pending error
				 * reports. */
} BgError;

static BgError *firstBgPtr = NULL;
				/* First in list of all background errors
				 * waiting to be processed (NULL if none). */
static BgError *lastBgPtr = NULL;
				/* First in list of all background errors
				 * waiting to be processed (NULL if none). */

/*
 * Prototypes for procedures referenced only in this file:
 */

static void		AfterProc _ANSI_ARGS_((ClientData clientData));
static void		DeleteFileEvent _ANSI_ARGS_((FILE *f));
static int		FileEventProc _ANSI_ARGS_((ClientData clientData,
			    int mask, int flags));
static void		FreeAfterPtr _ANSI_ARGS_((AfterInfo *afterPtr));
static void		HandleBgErrors _ANSI_ARGS_((ClientData clientData));
static int		TkwaitCmd2 _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, char **argv));
static int		UpdateCmd2 _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, char **argv));
static char *		WaitVariableProc2 _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, Var name1, char *name2,
			    int flags));
static void		CheckFileHandlers _ANSI_ARGS_((void));


/*
 *--------------------------------------------------------------
 *
 * Tk_CreateFileHandler --
 *
 *	Arrange for a given procedure to be invoked whenever
 *	a given file becomes readable or writable.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	From now on, whenever the I/O channel given by fd becomes
 *	ready in the way indicated by mask, proc will be invoked.
 *	See the manual entry for details on the calling sequence
 *	to proc.  If fd is already registered then the old mask
 *	and proc and clientData values will be replaced with
 *	new ones.
 *
 *--------------------------------------------------------------
 */

void
Tk_CreateFileHandler(fd, mask, proc, clientData)
    int fd;			/* Integer identifier for stream. */
    int mask;			/* OR'ed combination of TK_READABLE,
				 * TK_WRITABLE, and TK_EXCEPTION:
				 * indicates conditions under which
				 * proc should be called.  TK_IS_DISPLAY
				 * indicates that this is a display and that
				 * clientData is the (Display *) for it,
				 * and that events should be handled
				 * automatically.*/
    Tk_FileProc *proc;		/* Procedure to call for each
				 * selected event. */
    ClientData clientData;	/* Arbitrary data to pass to proc. */
{
    register FileHandler *filePtr;
    int index;

    if (fd >= OPEN_MAX) {
	panic("Tk_CreatefileHandler can't handle file id %d", fd);
    }

    /*
     * Make sure the file isn't already registered.  Create a
     * new record in the normal case where there's no existing
     * record.
     */

    for (filePtr = firstFileHandlerPtr; filePtr != NULL;
	    filePtr = filePtr->nextPtr) {
	if (filePtr->fd == fd) {
	    break;
	}
    }
    index = fd/(NBBY*sizeof(fd_mask));
    if (filePtr == NULL) {
	filePtr = (FileHandler *) ckalloc(sizeof(FileHandler));
	filePtr->fd = fd;
	filePtr->readPtr = &ready[index];
	filePtr->writePtr = &ready[index+MASK_SIZE];
	filePtr->exceptPtr = &ready[index+2*MASK_SIZE];
	filePtr->checkReadPtr = &check[index];
	filePtr->checkWritePtr = &check[index+MASK_SIZE];
	filePtr->checkExceptPtr = &check[index+2*MASK_SIZE];
	filePtr->bitSelect = 1 << (fd%(NBBY*sizeof(fd_mask)));
	filePtr->nextPtr = firstFileHandlerPtr;
	firstFileHandlerPtr = filePtr;
    }

    /*
     * The remainder of the initialization below is done
     * regardless of whether or not this is a new record
     * or a modification of an old one.
     */

    filePtr->mask = mask;
    filePtr->proc = proc;
    filePtr->proc2 = NULL;
    filePtr->clientData = clientData;

    if (numFds <= fd) {
	numFds = fd+1;
    }
}

/*
 *--------------------------------------------------------------
 *
 * Tk_CreateFileHandler2 --
 *
 *	Arrange for a given procedure to be invoked during the
 *	event loop to handle a particular file.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	In each pass through Tk_DoOneEvent, proc will be invoked to
 *	decide whether fd is "ready" and take appropriate action if
 *	it is.  See the manual entry for details on the calling
 *	sequence to proc.  If a handler for fd has already been
 *	registered then it is superseded by the new one.
 *
 *--------------------------------------------------------------
 */

void
Tk_CreateFileHandler2(fd, proc, clientData)
    int fd;			/* Integer identifier for stream. */
    Tk_FileProc2 *proc;		/* Procedure to call from the event
				 * dispatcher. */
    ClientData clientData;	/* Arbitrary data to pass to proc. */
{
    register FileHandler *filePtr;

    /*
     * Let Tk_CreateFileHandler do all of the work of setting up
     * the handler, then just modify things a bit after it returns.
     */

    Tk_CreateFileHandler(fd, 0, (Tk_FileProc *) NULL, clientData);
    for (filePtr = firstFileHandlerPtr; filePtr->fd != fd;
	    filePtr = filePtr->nextPtr) {
	/* Empty loop body. */
    }
    filePtr->proc = NULL;
    filePtr->proc2 = proc;
}

/*
 *--------------------------------------------------------------
 *
 * Tk_DeleteFileHandler --
 *
 *	Cancel a previously-arranged callback arrangement for
 *	a file.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	If a callback was previously registered on fd, remove it.
 *
 *--------------------------------------------------------------
 */

void
Tk_DeleteFileHandler(fd)
    int fd;			/* Stream id for which to remove
				 * callback procedure. */
{
    register FileHandler *filePtr;
    FileHandler *prevPtr;

    /*
     * Find the entry for the given file (and return if there
     * isn't one).
     */

    for (prevPtr = NULL, filePtr = firstFileHandlerPtr; ;
	    prevPtr = filePtr, filePtr = filePtr->nextPtr) {
	if (filePtr == NULL) {
	    return;
	}
	if (filePtr->fd == fd) {
	    break;
	}
    }

    /*
     * Clean up information in the callback record.
     */

    if (prevPtr == NULL) {
	firstFileHandlerPtr = filePtr->nextPtr;
    } else {
	prevPtr->nextPtr = filePtr->nextPtr;
    }
    ckfree((char *) filePtr);

    /*
     * Recompute numFds.
     */

    numFds = 0;
    for (filePtr = firstFileHandlerPtr; filePtr != NULL;
	    filePtr = filePtr->nextPtr) {
	if (numFds <= filePtr->fd) {
	    numFds = filePtr->fd+1;
	}
    }
}

/*
 *--------------------------------------------------------------
 *
 * CheckFileHandlers --
 *
 *	Scan through list fstat()'ing fd's to check for bad ones
 *	deleting any which cannot be fstat'ed
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	If a callback was previously registered on fd, remove it.
 *
 *--------------------------------------------------------------
 */

static void
CheckFileHandlers()
{
    register FileHandler *filePtr;
    FileHandler **prevPtr = &firstFileHandlerPtr;
    struct stat info;
    int fd = -1;

    while ((filePtr = *prevPtr)) {
	if (fstat(fd = filePtr->fd,&info) != 0) {
            *prevPtr = filePtr->nextPtr;
	    ckfree((char *) filePtr);
	    break;
	} 
	prevPtr = &(filePtr->nextPtr);
    }

    /*
     * Recompute numFds.
     */

    numFds = 0;
    for (filePtr = firstFileHandlerPtr; filePtr != NULL;
	    filePtr = filePtr->nextPtr) {
	if (numFds <= filePtr->fd) {
	    numFds = filePtr->fd+1;
	}
    }

    if (fd >= 0)
     LangBadFile(fd);
}

/*
 *--------------------------------------------------------------
 *
 * Tk_CreateTimerHandler --
 *
 *	Arrange for a given procedure to be invoked at a particular
 *	time in the future.
 *
 * Results:
 *	The return value is a token for the timer event, which
 *	may be used to delete the event before it fires.
 *
 * Side effects:
 *	When milliseconds have elapsed, proc will be invoked
 *	exactly once.
 *
 *--------------------------------------------------------------
 */

Tk_TimerToken
Tk_CreateTimerHandler(milliseconds, proc, clientData)
    int milliseconds;		/* How many milliseconds to wait
				 * before invoking proc. */
    Tk_TimerProc *proc;		/* Procedure to invoke. */
    ClientData clientData;	/* Arbitrary data to pass to proc. */
{
    register TimerEvent *timerPtr, *tPtr2, *prevPtr;
    static int id = 0;

    timerPtr = (TimerEvent *) ckalloc(sizeof(TimerEvent));

    /*
     * Compute when the event should fire.
     */

    (void) gettimeofday(&timerPtr->time, (struct timezone *) NULL);
    timerPtr->time.tv_sec += milliseconds/1000;
    timerPtr->time.tv_usec += (milliseconds%1000)*1000;
    if (timerPtr->time.tv_usec >= 1000000) {
	timerPtr->time.tv_usec -= 1000000;
	timerPtr->time.tv_sec += 1;
    }

    /*
     * Fill in other fields for the event.
     */

    timerPtr->proc = proc;
    timerPtr->clientData = clientData;
    id++;
    timerPtr->token = (Tk_TimerToken) id;

    /*
     * Add the event to the queue in the correct position
     * (ordered by event firing time).
     */

    for (tPtr2 = firstTimerHandlerPtr, prevPtr = NULL; tPtr2 != NULL;
	    prevPtr = tPtr2, tPtr2 = tPtr2->nextPtr) {
	if ((tPtr2->time.tv_sec > timerPtr->time.tv_sec)
		|| ((tPtr2->time.tv_sec == timerPtr->time.tv_sec)
		&& (tPtr2->time.tv_usec > timerPtr->time.tv_usec))) {
	    break;
	}
    }
    if (prevPtr == NULL) {
	timerPtr->nextPtr = firstTimerHandlerPtr;
	firstTimerHandlerPtr = timerPtr;
    } else {
	timerPtr->nextPtr = prevPtr->nextPtr;
	prevPtr->nextPtr = timerPtr;
    }
    return timerPtr->token;
}

/*
 *--------------------------------------------------------------
 *
 * Tk_DeleteTimerHandler --
 *
 *	Delete a previously-registered timer handler.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Destroy the timer callback identified by TimerToken,
 *	so that its associated procedure will not be called.
 *	If the callback has already fired, or if the given
 *	token doesn't exist, then nothing happens.
 *
 *--------------------------------------------------------------
 */

void
Tk_DeleteTimerHandler(token)
    Tk_TimerToken token;	/* Result previously returned by
				 * Tk_DeleteTimerHandler. */
{
    register TimerEvent *timerPtr, *prevPtr;

    for (timerPtr = firstTimerHandlerPtr, prevPtr = NULL; timerPtr != NULL;
	    prevPtr = timerPtr, timerPtr = timerPtr->nextPtr) {
	if (timerPtr->token != token) {
	    continue;
	}
	if (prevPtr == NULL) {
	    firstTimerHandlerPtr = timerPtr->nextPtr;
	} else {
	    prevPtr->nextPtr = timerPtr->nextPtr;
	}
	ckfree((char *) timerPtr);
	return;
    }
}

/*
 *--------------------------------------------------------------
 *
 * Tk_DoWhenIdle --
 *
 *	Arrange for proc to be invoked the next time the
 *	system is idle (i.e., just before the next time
 *	that Tk_DoOneEvent would have to wait for something
 *	to happen).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Proc will eventually be called, with clientData
 *	as argument.  See the manual entry for details.
 *
 *--------------------------------------------------------------
 */

void
Tk_DoWhenIdle(proc, clientData)
    Tk_IdleProc *proc;		/* Procedure to invoke. */
    ClientData clientData;	/* Arbitrary value to pass to proc. */
{
    register IdleHandler *idlePtr;

    idlePtr = (IdleHandler *) ckalloc(sizeof(IdleHandler));
    idlePtr->proc = proc;
    idlePtr->clientData = clientData;
    idlePtr->generation = idleGeneration;
    idlePtr->nextPtr = NULL;
    if (lastIdlePtr == NULL) {
	idleList = idlePtr;
    } else {
	lastIdlePtr->nextPtr = idlePtr;
    }
    lastIdlePtr = idlePtr;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_CancelIdleCall --
 *
 *	If there are any when-idle calls requested to a given procedure
 *	with given clientData, cancel all of them.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	If the proc/clientData combination were on the when-idle list,
 *	they are removed so that they will never be called.
 *
 *----------------------------------------------------------------------
 */

void
Tk_CancelIdleCall(proc, clientData)
    Tk_IdleProc *proc;		/* Procedure that was previously registered. */
    ClientData clientData;	/* Arbitrary value to pass to proc. */
{
    register IdleHandler *idlePtr, *prevPtr;
    IdleHandler *nextPtr;

    for (prevPtr = NULL, idlePtr = idleList; idlePtr != NULL;
	    prevPtr = idlePtr, idlePtr = idlePtr->nextPtr) {
	while ((idlePtr->proc == proc)
		&& (idlePtr->clientData == clientData)) {
	    nextPtr = idlePtr->nextPtr;
	    ckfree((char *) idlePtr);
	    idlePtr = nextPtr;
	    if (prevPtr == NULL) {
		idleList = idlePtr;
	    } else {
		prevPtr->nextPtr = idlePtr;
	    }
	    if (idlePtr == NULL) {
		lastIdlePtr = prevPtr;
		return;
	    }
	}
    }
}

/*
 *--------------------------------------------------------------
 *
 * Tk_DoOneEvent --
 *
 *	Process a single event of some sort.  If there's no
 *	work to do, wait for an event to occur, then process
 *	it.
 *
 * Results:
 *	The return value is 1 if the procedure actually found
 *	an event to process.  If no event was found then 0 is
 *	returned.
 *
 * Side effects:
 *	May delay execution of process while waiting for an
 *	X event, X error, file-ready event, or timer event.
 *	The handling of the event could cause additional
 *	side effects.  Collapses sequences of mouse-motion
 *	events for the same window into a single event by
 *	delaying motion event processing.
 *
 *--------------------------------------------------------------
 */

int
Tk_DoOneEvent(flags)
    int flags;			/* Miscellaneous flag values:  may be any
				 * combination of TK_DONT_WAIT, TK_X_EVENTS,
				 * TK_FILE_EVENTS, TK_TIMER_EVENTS, and
				 * TK_IDLE_EVENTS. */
{
    register FileHandler *filePtr;
    struct timeval curTime, timeout, *timeoutPtr;
    int numFound, mask, anyFilesToWaitFor;

    if ((flags & TK_ALL_EVENTS) == 0) {
	flags |= TK_ALL_EVENTS;
    }

    /*
     * Phase One: see if there's a ready file that was left over
     * from before (i.e don't do a select, just check the bits from
     * the last select).
     */

    checkFiles:

    if (LangEventHook(flags))
        return 1;

    memset((VOID *) check, 0, 3*MASK_SIZE*sizeof(fd_mask));
    anyFilesToWaitFor = 0;
    for (filePtr = firstFileHandlerPtr; filePtr != NULL;
	    filePtr = filePtr->nextPtr) {
	mask = 0;
	if (*filePtr->readPtr & filePtr->bitSelect) {
	    mask |= TK_READABLE;
	    *filePtr->readPtr &= ~filePtr->bitSelect;
	}
	if (*filePtr->writePtr & filePtr->bitSelect) {
	    mask |= TK_WRITABLE;
	    *filePtr->writePtr &= ~filePtr->bitSelect;
	}
	if (*filePtr->exceptPtr & filePtr->bitSelect) {
	    mask |= TK_EXCEPTION;
	    *filePtr->exceptPtr &= ~filePtr->bitSelect;
	}
	if (filePtr->proc2 != NULL) {
	    /*
	     * Handler created by Tk_CreateFileHandler2.
	     */

	    mask = (*filePtr->proc2)(filePtr->clientData, mask, flags);
	    if (mask == TK_FILE_HANDLED) {
		return 1;
	    }
	} else {
	    /*
	     * Handler created by Tk_CreateFileHandler.
	     */

	    if (!(flags & TK_FILE_EVENTS)) {
		continue;
	    }
	    if (mask != 0) {
		(*filePtr->proc)(filePtr->clientData, mask);
		return 1;
	    }
	    mask = filePtr->mask;
	}
	if (mask != 0) {
	    anyFilesToWaitFor = 1;
	    if (mask & TK_READABLE) {
		*filePtr->checkReadPtr |= filePtr->bitSelect;
	    }
	    if (mask & TK_WRITABLE) {
		*filePtr->checkWritePtr |= filePtr->bitSelect;
	    }
	    if (mask & TK_EXCEPTION) {
		*filePtr->checkExceptPtr |= filePtr->bitSelect;
	    }
	}
    }

    /*
     * Phase Two: get the current time and see if any timer
     * events are ready to fire.  If so, fire one and return.
     */

    checkTime:
    if ((firstTimerHandlerPtr != NULL) && (flags & TK_TIMER_EVENTS)) {
	register TimerEvent *timerPtr = firstTimerHandlerPtr;

	(void) gettimeofday(&curTime, (struct timezone *) NULL);
	if ((timerPtr->time.tv_sec < curTime.tv_sec)
		|| ((timerPtr->time.tv_sec == curTime.tv_sec)
		&&  (timerPtr->time.tv_usec < curTime.tv_usec))) {
	    firstTimerHandlerPtr = timerPtr->nextPtr;
	    (*timerPtr->proc)(timerPtr->clientData);
	    ckfree((char *) timerPtr);
	    return 1;
	}
    }

    /*
     * Phase Three: if there are DoWhenIdle requests pending (or
     * if we're not allowed to block), then do a select with an
     * instantaneous timeout.  If a ready file is found, then go
     * back to process it.
     */

    if (((idleList != NULL) && (flags & TK_IDLE_EVENTS))
	    || (flags & TK_DONT_WAIT)) {
	if (flags & (TK_X_EVENTS|TK_FILE_EVENTS)) {
	    memcpy((VOID *) ready, (VOID *) check,
		    3*MASK_SIZE*sizeof(fd_mask));
	    timeout.tv_sec = timeout.tv_usec = 0;
	    numFound = select(numFds, (SELECT_MASK *) &ready[0],
		    (SELECT_MASK *) &ready[MASK_SIZE],
		    (SELECT_MASK *) &ready[2*MASK_SIZE], &timeout);
	    if (numFound <= 0) {
		/*
		 * Some systems don't clear the masks after an error, so
		 * we have to do it here.
		 */

		memset((VOID *) ready, 0, 3*MASK_SIZE*sizeof(fd_mask));
	    }
	    if ((numFound > 0) || ((numFound == -1) && (errno == EINTR))) {
		goto checkFiles;
	    }
	}
    }

    /*
     * Phase Four: if there is a delayed motion event then call a procedure
     * to handle it.  Do it now, before calling any DoWhenIdle handlers,
     * since the goal of idle handlers is to delay until after all pending
     * events have been processed.
     *
     * The particular implementation of this (a procedure variable shared
     * with tkXEvent.c) is a bit kludgy, but it allows this file to be used
     * separately without any of the rest of Tk.
     */

    if ((tkDelayedEventProc != NULL) && (flags & TK_X_EVENTS)) {
	(*tkDelayedEventProc)();
	return 1;
    }

    /*
     * Phase Five:  process all pending DoWhenIdle requests.
     */

    if ((idleList != NULL) && (flags & TK_IDLE_EVENTS)) {
	register IdleHandler *idlePtr;
	int oldGeneration;

	oldGeneration = idleList->generation;
	idleGeneration++;

	/*
	 * The code below is trickier than it may look, for the following
	 * reasons:
	 *
	 * 1. New handlers can get added to the list while the current
	 *    one is being processed.  If new ones get added, we don't
	 *    want to process them during this pass through the list (want
	 *    to check for other work to do first).  This is implemented
	 *    using the generation number in the handler:  new handlers
	 *    will have a different generation than any of the ones currently
	 *    on the list.
	 * 2. The handler can call Tk_DoOneEvent, so we have to remove
	 *    the hander from the list before calling it. Otherwise an
	 *    infinite loop could result.
	 * 3. Tk_CancelIdleCall can be called to remove an element from
	 *    the list while a handler is executing, so the list could
	 *    change structure during the call.
	 */

	for (idlePtr = idleList;
		((idlePtr != NULL) && (idlePtr->generation == oldGeneration));
		idlePtr = idleList) {
	    idleList = idlePtr->nextPtr;
	    if (idleList == NULL) {
		lastIdlePtr = NULL;
	    }
	    (*idlePtr->proc)(idlePtr->clientData);
	    ckfree((char *) idlePtr);
	}
	return 1;
    }

    /*
     * Phase Six: do a select to wait for either one of the
     * files to become ready or for the first timer event to
     * fire.  Then go back to process the event.
     */

    if ((flags & TK_DONT_WAIT)
	    || !(flags & (TK_TIMER_EVENTS|TK_FILE_EVENTS|TK_X_EVENTS))) {
	return 0;
    }
    if ((firstTimerHandlerPtr == NULL) || !(flags & TK_TIMER_EVENTS)) {
	timeoutPtr = NULL;
    } else {
	timeoutPtr = &timeout;
	timeout.tv_sec = firstTimerHandlerPtr->time.tv_sec - curTime.tv_sec;
	timeout.tv_usec = firstTimerHandlerPtr->time.tv_usec - curTime.tv_usec;
	if (timeout.tv_usec < 0) {
	    timeout.tv_sec -= 1;
	    timeout.tv_usec += 1000000;
	}
    }
    if ((timeoutPtr == NULL) && !anyFilesToWaitFor) {
	return 0;
    }
    memcpy((VOID *) ready, (VOID *) check, 3*MASK_SIZE*sizeof(fd_mask));
    numFound = select(numFds, (SELECT_MASK *) &ready[0],
	    (SELECT_MASK *) &ready[MASK_SIZE],
	    (SELECT_MASK *) &ready[2*MASK_SIZE], timeoutPtr);
    if (numFound == -1) {
	/*
	 * Some systems don't clear the masks after an error, so
	 * we have to do it here.
	 */

	memset((VOID *) ready, 0, 3*MASK_SIZE*sizeof(fd_mask));
        if (errno == EBADF) 
            CheckFileHandlers(); 
    }
    if (numFound == 0) {
	goto checkTime;
    }
    goto checkFiles;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_Sleep --
 *
 *	Delay execution for the specified number of milliseconds.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Time passes.
 *
 *----------------------------------------------------------------------
 */

void
Tk_Sleep(ms)
    int ms;			/* Number of milliseconds to sleep. */
{
    static struct timeval delay;

    delay.tv_sec = ms/1000;
    delay.tv_usec = (ms%1000)*1000;
    (void) select(0, (SELECT_MASK *) 0, (SELECT_MASK *) 0,
	    (SELECT_MASK *) 0, &delay);
}

#if 0
/*
 *----------------------------------------------------------------------
 *
 * Tk_BackgroundError --
 *
 *	This procedure is invoked to handle errors that occur in Tcl
 *	commands that are invoked in "background" (e.g. from event or
 *	timer bindings).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The command "tkerror" is invoked later as an idle handler to
 *	process the error, passing it the error message.  If that fails,
 *	then an error message is output on stderr.
 *
 *----------------------------------------------------------------------
 */

void
Tk_BackgroundError(interp)
    Tcl_Interp *interp;		/* Interpreter in which an error has
				 * occurred. */
{
    BgError *errPtr;
    char *varValue;

    /*
     * The Tcl_AddErrorInfo call below (with an empty string) ensures that
     * errorInfo gets properly set.  It's needed in cases where the error
     * came from a utility procedure like Tcl_GetVar instead of Tcl_Eval;
     * in these cases errorInfo still won't have been set when this
     * procedure is called.
     */

    Tcl_AddErrorInfo(interp, "");
    errPtr = (BgError *) ckalloc(sizeof(BgError));
    errPtr->interp = interp;
    errPtr->errorMsg = (char *) ckalloc((unsigned) (strlen(interp->result)
	    + 1));
    strcpy(errPtr->errorMsg, interp->result);
    varValue = Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY);
    if (varValue == NULL) {
	varValue = errPtr->errorMsg;
    }
    errPtr->errorInfo = (char *) ckalloc((unsigned) (strlen(varValue) + 1));
    strcpy(errPtr->errorInfo, varValue);
    varValue = Tcl_GetVar(interp, "errorCode", TCL_GLOBAL_ONLY);
    if (varValue == NULL) {
	varValue = "";
    }
    errPtr->errorCode = (char *) ckalloc((unsigned) (strlen(varValue) + 1));
    strcpy(errPtr->errorCode, varValue);
    errPtr->nextPtr = NULL;
    if (firstBgPtr == NULL) {
	firstBgPtr = errPtr;
	Tk_DoWhenIdle(HandleBgErrors, (ClientData) NULL);
    } else {
	lastBgPtr->nextPtr = errPtr;
    }
    lastBgPtr = errPtr;
    Tcl_ResetResult(interp);
}

/*
 *----------------------------------------------------------------------
 *
 * HandleBgErrors --
 *
 *	This procedure is invoked as an idle handler to process all of
 *	the accumulated background errors.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Depends on what actions "tkerror" takes for the errors.
 *
 *----------------------------------------------------------------------
 */

static void
HandleBgErrors(clientData)
    ClientData clientData;		/* Not used. */
{
    Tcl_Interp *interp;
    char *command;
    char *argv[2];
    int code;
    BgError *errPtr;

    while (firstBgPtr != NULL) {
	interp = firstBgPtr->interp;
	if (interp == NULL) {
	    goto doneWithReport;
	}

	/*
	 * Restore important state variables to what they were at
	 * the time the error occurred.
	 */

	Tcl_SetVar(interp, "errorInfo", firstBgPtr->errorInfo,
		TCL_GLOBAL_ONLY);
	Tcl_SetVar(interp, "errorCode", firstBgPtr->errorCode,
		TCL_GLOBAL_ONLY);

	/*
	 * Create and invoke the tkerror command.
	 */

	argv[0] = "tkerror";
	argv[1] = firstBgPtr->errorMsg;
	command = Tcl_Merge(2, argv);
	Tcl_AllowExceptions(interp);
	code = Tcl_GlobalEval(interp, command);
	ckfree(command);
	if (code == TCL_ERROR) {
	    if (strcmp(interp->result, "\"tkerror\" is an invalid command name or ambiguous abbreviation") == 0) {
		fprintf(stderr, "%s\n", firstBgPtr->errorInfo);
	    } else {
		fprintf(stderr, "tkerror failed to handle background error.\n");
		fprintf(stderr, "    Original error: %s\n",
			firstBgPtr->errorMsg);
		fprintf(stderr, "    Error in tkerror: %s\n", interp->result);
	    }
	} else if (code == TCL_BREAK) {
	    /*
	     * Break means cancel any remaining error reports for this
	     * interpreter.
	     */

	    for (errPtr = firstBgPtr; errPtr != NULL;
		    errPtr = errPtr->nextPtr) {
		if (errPtr->interp == interp) {
		    errPtr->interp = NULL;
		}
	    }
	}

	/*
	 * Discard the command and the information about the error report.
	 */

	doneWithReport:
	ckfree(firstBgPtr->errorMsg);
	ckfree(firstBgPtr->errorInfo);
	ckfree(firstBgPtr->errorCode);
	errPtr = firstBgPtr->nextPtr;
	ckfree((char *) firstBgPtr);
	firstBgPtr = errPtr;
    }
    lastBgPtr = NULL;
}

#endif

/*
 *----------------------------------------------------------------------
 *
 * Tk_AfterCmd --
 *
 *	This procedure is invoked to process the "after" Tcl command.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
int
Tk_AfterCmd(clientData, interp, argc, argv)
    ClientData clientData;	/* Main window associated with
				 * interpreter.  Not used.*/
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    /*
     * The variable below is used to generate unique identifiers for
     * after commands.  This id can wrap around, which can potentially
     * cause problems.  However, there are not likely to be problems
     * in practice, because after commands can only be requested to
     * about a month in the future, and wrap-around is unlikely to
     * occur in less than about 1-10 years.  Thus it's unlikely that
     * any old ids will still be around when wrap-around occurs.
     */

    static int nextId = 1;
    int ms, id;
    AfterInfo *afterPtr;

    if (argc < 2) {
	Tcl_AppendResult(interp, "wrong # args: should be \"",
		argv[0], " milliseconds ?command? ?arg arg ...?\" or \"",
		argv[0], " cancel id|command\"", (char *) NULL);
	return TCL_ERROR;
    }

    if (isdigit(UCHAR(argv[1][0]))) {
	if (Tcl_GetInt(interp, argv[1], &ms) != TCL_OK) {
	    return TCL_ERROR;
	}
	if (ms < 0) {
	    ms = 0;
	}
	if (argc == 2) {
	    Tk_Sleep(ms);
	    return TCL_OK;
	}
	afterPtr = (AfterInfo *) ckalloc((unsigned) (sizeof(AfterInfo)));
	afterPtr->interp = interp;
	if (argc == 3) {
	    afterPtr->command = LangMakeCallback(args[2]);
	} else {
	    afterPtr->command = LangMakeCallback(Tcl_Merge(argc-2, argv+2));
	}
	afterPtr->id = nextId;
	nextId += 1;
	afterPtr->token = Tk_CreateTimerHandler(ms, AfterProc,
		(ClientData) afterPtr);
	afterPtr->nextPtr = firstAfterPtr;
	firstAfterPtr = afterPtr;
	sprintf(interp->result, "after#%d", afterPtr->id);
    } else if (strncmp(argv[1], "cancel", strlen(argv[1])) == 0) {
	Arg arg;

	if (argc < 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    argv[0], " cancel id|command\"", (char *) NULL);
	    return TCL_ERROR;
	}
	if (argc == 3) {
	    arg = args[2];
	} else {
	    arg = Tcl_Concat(argc-2, args+2);
	}
	if (strncmp(LangString(arg), "after#", 6) == 0) {
            Arg tmp = LangStringArg(LangString(arg)+6); 
	    if (Tcl_GetInt(interp, tmp, &id) != TCL_OK) {
                LangFreeArg(tmp,TCL_DYNAMIC);
		return TCL_ERROR;
	    }
            LangFreeArg(tmp,TCL_DYNAMIC);
	    for (afterPtr = firstAfterPtr; afterPtr != NULL;
		    afterPtr = afterPtr->nextPtr) {
		if (afterPtr->id == id) {
		    break;
		}
	    }
	} else {
	    for (afterPtr = firstAfterPtr; afterPtr != NULL;
		    afterPtr = afterPtr->nextPtr) {
		if (LangCmpCallback(afterPtr->command, arg)) {
		    break;
		}
	    }
	}
	if (arg != args[2]) {
	    LangFreeArg(arg, TCL_DYNAMIC);
	}
	if (afterPtr != NULL) {
	    if (afterPtr->token != NULL) {
		Tk_DeleteTimerHandler(afterPtr->token);
	    } else {
		Tk_CancelIdleCall(AfterProc, (ClientData) afterPtr);
	    }
	    FreeAfterPtr(afterPtr);
	}
    } else if (strncmp(argv[1], "idle", strlen(argv[1])) == 0) {
	if (argc < 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    argv[0], " idle script script ...\"", (char *) NULL);
	    return TCL_ERROR;
	}
	afterPtr = (AfterInfo *) ckalloc((unsigned) (sizeof(AfterInfo)));
	afterPtr->interp = interp;
	if (argc == 3) {
	    afterPtr->command = LangMakeCallback(args[2]);
	} else {
	    afterPtr->command = LangMakeCallback(Tcl_Merge(argc-2, argv+2));
	}
	afterPtr->id = nextId;
	nextId += 1;
	afterPtr->token = NULL;
	afterPtr->nextPtr = firstAfterPtr;
	firstAfterPtr = afterPtr;
	Tk_DoWhenIdle(AfterProc, (ClientData) afterPtr);
	sprintf(interp->result, "after#%d", afterPtr->id);
    } else {
	Tcl_AppendResult(interp, "bad argument \"", argv[1],
		"\": must be cancel, idle, or a number", (char *) NULL);
	return TCL_ERROR;
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * AfterProc --
 *
 *	Timer callback to execute commands registered with the
 *	"after" command.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Executes whatever command was specified.  If the command
 *	returns an error, then the command "tkerror" is invoked
 *	to process the error;  if tkerror fails then information
 *	about the error is output on stderr.
 *
 *----------------------------------------------------------------------
 */

static void
AfterProc(clientData)
    ClientData clientData;	/* Describes command to execute. */
{
    AfterInfo *afterPtr = (AfterInfo *) clientData;
    AfterInfo *prevPtr;
    int result;

    /*
     * First remove the callback from our list of callbacks;  otherwise
     * someone could delete the callback while it's being executed, which
     * could cause a core dump.
     */

    if (firstAfterPtr == afterPtr) {
	firstAfterPtr = afterPtr->nextPtr;
    } else {
	for (prevPtr = firstAfterPtr; prevPtr->nextPtr != afterPtr;
		prevPtr = prevPtr->nextPtr) {
	    /* Empty loop body. */
	}
	prevPtr->nextPtr = afterPtr->nextPtr;
    }

    /*
     * Execute the callback.
     */

    result = LangDoCallback(afterPtr->interp, afterPtr->command, 0, 0);
    if (result != TCL_OK) {
	Tcl_AddErrorInfo(afterPtr->interp, "\n    (\"after\" script)");
	Tk_BackgroundError(afterPtr->interp);
    }

    /*
     * Free the memory for the callback.
     */

    LangFreeCallback(afterPtr->command);
    ckfree((char *) afterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * FreeAfterPtr --
 *
 *	This procedure removes an "after" command from the list of
 *	those that are pending and frees its resources.  This procedure
 *	does *not* cancel the timer handler;  if that's needed, the
 *	caller must do it.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The memory associated with afterPtr is released.
 *
 *----------------------------------------------------------------------
 */

static void
FreeAfterPtr(afterPtr)
    AfterInfo *afterPtr;		/* Command to be deleted. */
{
    AfterInfo *prevPtr;
    if (firstAfterPtr == afterPtr) {
	firstAfterPtr = afterPtr->nextPtr;
    } else {
	for (prevPtr = firstAfterPtr; prevPtr->nextPtr != afterPtr;
		prevPtr = prevPtr->nextPtr) {
	    /* Empty loop body. */
	}
	prevPtr->nextPtr = afterPtr->nextPtr;
    }
    LangFreeCallback(afterPtr->command);
    ckfree((char *) afterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_FileeventCmd --
 *
 *	This procedure is invoked to process the "fileevent" Tcl
 *	command. See the user documentation for details on what it does.
 *	This command is based on Mark Diekhans' "addinput" command.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
int
Tk_FileeventCmd(clientData, interp, argc, argv)
    ClientData clientData;	/* Main window associated with interpreter.
				 * Not used.*/
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    FILE *f;
    int index, fd, c;
    size_t length;
    FileEvent *fevPtr, *prevPtr;

    /*
     * Parse arguments.
     */

    if ((argc != 3) && (argc != 4)) {
	Tcl_AppendResult(interp, "wrong # args: must be \"", argv[0],
		" fileId event ?script?", (char *) NULL);
	return TCL_ERROR;
    }
    c = argv[2][0];
    length = strlen(argv[2]);
    if ((c == 'r') && (strncmp(argv[2], "readable", length) == 0)) {
	index = 0;
    } else if ((c == 'w') && (strncmp(argv[2], "writable", length) == 0)) {
	index = 1;
    } else {
	Tcl_AppendResult(interp, "bad event name \"", argv[2],
		"\": must be readable or writable", (char *) NULL);
	return TCL_ERROR;
    }
    if (Tcl_GetOpenFile(interp, args[1], index, 1, &f) != TCL_OK) {
	return TCL_ERROR;
    }
    fd = fileno(f);

    /*
     * Locate an existing file handler for this file, if one exists,
     * and make a new one if none currently exists.
     */

    for (fevPtr = firstFileEventPtr; ; fevPtr = fevPtr->nextPtr) {
	if (fevPtr == NULL) {
	    if ((argc == 3) || (argv[3][0] == 0)) {
		return TCL_OK;
	    }
	    fevPtr = (FileEvent *) ckalloc(sizeof(FileEvent));
	    fevPtr->f = f;
	    fevPtr->interps[0] = NULL;
	    fevPtr->interps[1] = NULL;
	    fevPtr->scripts[0] = NULL;
	    fevPtr->scripts[1] = NULL;
	    fevPtr->nextPtr = firstFileEventPtr;
	    firstFileEventPtr = fevPtr;
	    Tk_CreateFileHandler2(fileno(f), FileEventProc,
		    (ClientData) fevPtr);
	    LangCloseHandler(interp,args[1],f,DeleteFileEvent);
	    break;
	}
	if (fevPtr->f == f) {
	    break;
	}
    }

    /*
     * If we're just supposed to return the current script, do so.
     */

    if (argc == 3) {
	if (fevPtr->scripts[index] != NULL) {
            Tcl_ArgResult(interp, LangCallbackArg(fevPtr->scripts[index]));
	}
	return TCL_OK;
    }

    /*
     * If we're supposed to delete the event handler, do so.
     */

    if (argv[3][0] == 0) {
	if (fevPtr->scripts[index] != NULL) {
	    fevPtr->interps[index] = NULL;
            LangFreeCallback(fevPtr->scripts[index]);
	    fevPtr->scripts[index] = NULL;
	}
	if ((fevPtr->scripts[0] == NULL) && (fevPtr->scripts[1] == NULL)) {
	    if (firstFileEventPtr == fevPtr) {
		firstFileEventPtr = fevPtr->nextPtr;
	    } else {
		for (prevPtr = firstFileEventPtr; prevPtr->nextPtr != fevPtr;
			prevPtr = prevPtr->nextPtr) {
		    /* Empty loop body. */
		}
		prevPtr->nextPtr = fevPtr->nextPtr;
	    }
	    Tk_DeleteFileHandler(fileno(fevPtr->f));
	    ckfree((char *) fevPtr);
	}
	return TCL_OK;
    }

    /*
     * This is a new handler being created.  Save its script.
     */

    fevPtr->interps[index] = interp;
    if (fevPtr->scripts[index] != NULL) {
        LangFreeCallback(fevPtr->scripts[index]);
    }
    fevPtr->scripts[index] = LangMakeCallback(args[3]);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * FileEventProc --
 *
 *	This procedure is invoked by Tk's event loop to deal with file
 *	event bindings created by the "fileevent" command.
 *
 * Results:
 *	The return value is TK_FILE_HANDLED if the file was ready and
 *	a script was invoked to handle it.  Otherwise an OR-ed combination
 *	of TK_READABLE and TK_WRITABLE is returned, indicating the events
 *	that should be checked in future calls to select.
 *
 * Side effects:
 *	Whatever the event script does.
 *
 *----------------------------------------------------------------------
 */

static int
FileEventProc(clientData, mask, flags)
    ClientData clientData;	/* Pointer to FileEvent structure for file. */
    int mask;			/* OR-ed combination of the bits TK_READABLE,
				 * TK_WRITABLE, and TK_EXCEPTION, indicating
				 * current state of file. */
    int flags;			/* Flag bits passed to Tk_DoOneEvent;
				 * contains bits such as TK_DONT_WAIT,
				 * TK_X_EVENTS, Tk_FILE_EVENTS, etc. */
{
    FileEvent *fevPtr = (FileEvent *) clientData;
    Tcl_DString script;
    Tcl_Interp *interp;
    FILE *f;
    int code, checkMask;

    if (!(flags & TK_FILE_EVENTS)) {
	return 0;
    }

    /*
     * The code here is a little tricky, because the script for an
     * event could delete the event handler.  Thus, after we call
     * Tcl_GlobalEval we can't use fevPtr anymore.  We also have to
     * copy the script to make sure that it doesn't get freed while
     * being evaluated.
     */

    checkMask = 0;
    f = fevPtr->f;
    if (fevPtr->scripts[1] != NULL) {
	if (mask & TK_WRITABLE) {
	    interp = fevPtr->interps[1];
	    code = LangDoCallback(interp,fevPtr->scripts[1],0,0);
	    if (code != TCL_OK) {
		goto error;
	    }
	    return TK_FILE_HANDLED;
	} else {
	    checkMask |= TK_WRITABLE;
	}
    }
    if (fevPtr->scripts[0] != NULL) {
	if ((mask & TK_READABLE) || TK_READ_DATA_PENDING(f)) {
	    interp = fevPtr->interps[0];
            code = LangDoCallback(interp,fevPtr->scripts[0],0,0);
	    if (code != TCL_OK) {
		goto error;
	    }
	    return TK_FILE_HANDLED;
	} else {
	    checkMask |= TK_READABLE;
	}
    }
    return checkMask;

    /*
     * An error occurred in the script, so we have to call
     * Tk_BackgroundError.  However, it's possible that the file ready
     * condition didn't get cleared for the file, so we could end
     * up in an infinite loop if we're not careful.  To be safe,
     * delete the event handler.
     */

    error:
    DeleteFileEvent(f);
    Tcl_AddErrorInfo(interp,
	    "\n    (script bound to file event - binding deleted)");
    Tk_BackgroundError(interp);
    return TK_FILE_HANDLED;
}

/*
 *----------------------------------------------------------------------
 *
 * DeleteFileEvent --
 *
 *	This procedure is invoked to delete all file event handlers
 *	for a file.  For example, this is necessary if a file is closed,
 *	or if an error occurs in a handler for a file.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The file event handler is removed, so it will never be invoked
 *	again.
 *
 *----------------------------------------------------------------------
 */

static void
DeleteFileEvent(f)
    FILE *f;			/* Stdio structure describing open file. */
{
    register FileEvent *fevPtr;
    FileEvent *prevPtr;

    /*
     * See if there exists a file handler for the given file.
     */

    for (prevPtr = NULL, fevPtr = firstFileEventPtr; ;
	    prevPtr = fevPtr, fevPtr = fevPtr->nextPtr) {
	if (fevPtr == NULL) {
	    return;
	}
	if (fevPtr->f == f) {
	    break;
	}
    }

    /*
     * Unlink it from the list, then free it.
     */

    if (prevPtr == NULL) {
	firstFileEventPtr = fevPtr->nextPtr;
    } else {
	prevPtr->nextPtr = fevPtr->nextPtr;
    }
    Tk_DeleteFileHandler(fileno(fevPtr->f));
    if (fevPtr->scripts[0] != NULL) {
        LangFreeCallback(fevPtr->scripts[0]);
    }
    if (fevPtr->scripts[1] != NULL) {
        LangFreeCallback(fevPtr->scripts[1]);
    }
    ckfree((char *) fevPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * TkEventCleanupProc --
 *
 *	This procedure is invoked whenever an interpreter is deleted.
 *	It deletes any file events and after commands that refer to
 *	that interpreter.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	File event handlers and after commands are removed.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
void
TkEventCleanupProc(clientData, interp)
    ClientData clientData;	/* Not used. */
    Tcl_Interp *interp;		/* Interpreter that is being deleted. */
{
    FileEvent *fevPtr, *prevPtr, *nextPtr;
    AfterInfo *afterPtr, *prevAfterPtr, *nextAfterPtr;
    int i;

    prevPtr = NULL;
    fevPtr = firstFileEventPtr;
    while (fevPtr != NULL) {
	for (i = 0; i < 2; i++) {
	    if (fevPtr->interps[i] == interp) {
		fevPtr->interps[i] = NULL;
                LangFreeCallback(fevPtr->scripts[i]);
		fevPtr->scripts[i] = NULL;
	    }
	}
	if ((fevPtr->scripts[0] != NULL) || (fevPtr->scripts[1] != NULL)) {
	    prevPtr = fevPtr;
	    fevPtr = fevPtr->nextPtr;
	    continue;
	}
	nextPtr = fevPtr->nextPtr;
	if (prevPtr == NULL) {
	    firstFileEventPtr = nextPtr;
	} else {
	    prevPtr->nextPtr = nextPtr;
	}
	Tk_DeleteFileHandler(fileno(fevPtr->f));
	ckfree((char *) fevPtr);
	fevPtr = nextPtr;
    }

    prevAfterPtr = NULL;
    afterPtr = firstAfterPtr;
    while (afterPtr != NULL) {
	if (afterPtr->interp != interp) {
	    prevAfterPtr = afterPtr;
	    afterPtr = afterPtr->nextPtr;
	    continue;
	}
	nextAfterPtr = afterPtr->nextPtr;
	if (prevAfterPtr == NULL) {
	    firstAfterPtr = nextAfterPtr;
	} else {
	    prevAfterPtr->nextPtr = nextAfterPtr;
	}
	if (afterPtr->token != NULL) {
	    Tk_DeleteTimerHandler(afterPtr->token);
	} else {
	    Tk_CancelIdleCall(AfterProc, (ClientData) afterPtr);
	}
	LangFreeCallback(afterPtr->command);
	ckfree((char *) afterPtr);
	afterPtr = nextAfterPtr;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkwaitCmd2 --
 *
 *	This procedure is invoked to process the "tkwait" Tcl command.
 *	See the user documentation for details on what it does.  This
 *	is a modified version of tkwait with only the "variable"
 *	option, suitable for use in stand-alone mode without the rest
 *	of Tk.  It's only used when Tk_EventInit has been called.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
TkwaitCmd2(clientData, interp, argc, argv)
    ClientData clientData;	/* Not used. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    int c, done;
    size_t length;

    if (argc != 3) {
	Tcl_AppendResult(interp, "wrong # args: should be \"",
		argv[0], " variable name\"", (char *) NULL);
	return TCL_ERROR;
    }
    c = argv[1][0];
    length = strlen(argv[1]);
    if ((c == 'v') && (strncmp(argv[1], "variable", length) == 0)
	    && (length >= 2)) {
        Var variable;
        if (LangSaveVar(interp, args[2], &variable, TK_CONFIG_SCALARVAR) != TCL_OK)
	    return TCL_ERROR;
	if (Tcl_TraceVar(interp, variable,
		TCL_GLOBAL_ONLY|TCL_TRACE_WRITES|TCL_TRACE_UNSETS,
		WaitVariableProc2, (ClientData) &done) != TCL_OK)
	    return TCL_ERROR;
	done = 0;
	while (!done) {
	    Tk_DoOneEvent(0);
	}
	Tcl_UntraceVar(interp, variable,
		TCL_GLOBAL_ONLY|TCL_TRACE_WRITES|TCL_TRACE_UNSETS,
		WaitVariableProc2, (ClientData) &done);
        LangFreeVar(variable);
    } else {
	Tcl_AppendResult(interp, "bad option \"", argv[1],
		"\": must be variable", (char *) NULL);
	return TCL_ERROR;
    }

    /*
     * Clear out the interpreter's result, since it may have been set
     * by event handlers.
     */

    Tcl_ResetResult(interp);
    return TCL_OK;
}

	/* ARGSUSED */
static char *
WaitVariableProc2(clientData, interp, name1, name2, flags)
    ClientData clientData;	/* Pointer to integer to set to 1. */
    Tcl_Interp *interp;		/* Interpreter containing variable. */
    Var name1;			/* Name of variable. */
    char *name2;		/* Second part of variable name. */
    int flags;			/* Information about what happened. */
{
    int *donePtr = (int *) clientData;

    *donePtr = 1;
    return (char *) NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * UpdateCmd2 --
 *
 *	This procedure is invoked to process the "update" Tcl command.
 *	See the user documentation for details on what it does.  This
 *	is a modified version of the command that doesn't deal with
 *	windows, suitable for use in stand-alone mode without the rest
 *	of Tk.  It's only used when Tk_EventInit has been called.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
UpdateCmd2(clientData, interp, argc, argv)
    ClientData clientData;	/* Not used. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    int flags;

    if (argc == 1) {
	flags = TK_DONT_WAIT|TK_FILE_EVENTS|TK_TIMER_EVENTS|TK_IDLE_EVENTS;
    } else if (argc == 2) {
	if (strncmp(argv[1], "idletasks", strlen(argv[1])) != 0) {
	    Tcl_AppendResult(interp, "bad argument \"", argv[1],
		    "\": must be idletasks", (char *) NULL);
	    return TCL_ERROR;
	}
	flags = TK_IDLE_EVENTS;
    } else {
	Tcl_AppendResult(interp, "wrong # args: should be \"",
		argv[0], " ?idletasks?\"", (char *) NULL);
	return TCL_ERROR;
    }

    /*
     * Handle all pending events.
     */

    while (Tk_DoOneEvent(flags) != 0) {
	/* Empty loop body */
    }

    /*
     * Must clear the interpreter's result because event handlers could
     * have executed commands.
     */

    Tcl_ResetResult(interp);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_EventInit --
 *
 *	This procedure is invoked from Tcl_AppInit if the Tk event stuff
 *	is being used by itself (without the rest of Tk) in an application.
 *	It creates the "after" and "fileevent" commands.
 *
 * Results:
 *	Always returns TCL_OK.
 *
 * Side effects:
 *	New commands get added to interp.
 *
 *----------------------------------------------------------------------
 */

int
Tk_EventInit(interp)
    Tcl_Interp *interp;		/* Interpreter in which to set up
				 * event-handling. */
{
    Tcl_CreateCommand(interp, "after", Tk_AfterCmd, (ClientData) NULL,
	    (void (*)()) NULL);
    Tcl_CreateCommand(interp, "fileevent", Tk_FileeventCmd, (ClientData) NULL,
	    (void (*)()) NULL);
    Tcl_CreateCommand(interp, "tkwait", TkwaitCmd2, (ClientData) NULL,
	    (void (*)()) NULL);
    Tcl_CreateCommand(interp, "update", UpdateCmd2, (ClientData) NULL,
	    (void (*)()) NULL);
    Tcl_CallWhenDeleted(interp, TkEventCleanupProc, (ClientData) NULL);
    return TCL_OK;
}


