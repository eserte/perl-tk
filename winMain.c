/* 
 * winMain.c --
 *
 *	Main entry point for wish and other Tk-based applications.
 *
 * Copyright (c) 1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) winMain.c 1.28 96/07/23 16:58:12
 */
#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef WIN32_LEAN_AND_MEAN
#include <malloc.h>
#include <locale.h>
#include <stdlib.h>

#include <stdio.h>

#if 0
#include <win32io.h>
extern __declspec(dllimport) WIN32_IOSUBSYSTEM	win32stdio;
#endif
extern int RunPerl(int argc, char **argv, char **env, void *iosubsystem);


/*
 * The following declarations refer to internal Tk routines.  These
 * interfaces are available for use, but are not supported.
 */

#if 0
EXTERN void		TkConsoleCreate _ANSI_ARGS_((void));
EXTERN int		TkConsoleInit _ANSI_ARGS_((Tcl_Interp *interp));
#endif

/*
 * Forward declarations for procedures defined later in this file:
 */

/*
 *----------------------------------------------------------------------
 *
 * WinMain --
 *
 *	Main entry point from Windows.
 *
 * Results:
 *	Returns false if initialization fails, otherwise it never
 *	returns. 
 *
 * Side effects:
 *	Just about anything, since from here we call arbitrary Tcl code.
 *
 *----------------------------------------------------------------------
 */

int APIENTRY
WinMain(hInstance, hPrevInstance, lpszCmdLine, nCmdShow)
    HINSTANCE hInstance;
    HINSTANCE hPrevInstance;
    LPSTR lpszCmdLine;
    int nCmdShow;
{
    char **argv, **argvlist, *p;
    int argc, size, i;
    char buffer[MAX_PATH];

    /*
     * Increase the application queue size from default value of 8.
     * At the default value, cross application SendMessage of WM_KILLFOCUS
     * will fail because the handler will not be able to do a PostMessage!
     * This is only needed for Windows 3.x, since NT dynamically expands
     * the queue.
     */
    SetMessageQueue(64);

#if 0
    /*
     * Create the console channels and install them as the standard
     * channels.  All I/O will be discarded until TkConsoleInit is
     * called to attach the console to a text widget.
     */

    TkConsoleCreate();
#endif

    /*
     * Precompute an overly pessimistic guess at the number of arguments
     * in the command line by counting non-space spans.  Note that we
     * have to allow room for the executable name and the trailing NULL
     * argument.
     */

    for (size = 3, p = lpszCmdLine; *p != '\0'; p++) {
	if (isspace(*p)) {
	    size++;
	    while (isspace(*p)) {
		p++;
	    }
	    if (*p == '\0') {
		break;
	    }
	}
    }
    argvlist = (char **) malloc((unsigned) (size * sizeof(char *)));
    argv = argvlist;

    /*
     * Parse the Windows command line string.  If an argument begins with a
     * double quote, then spaces are considered part of the argument until the
     * next double quote.  The argument terminates at the second quote.  Note
     * that this is different from the usual Unix semantics.
     */

    for (i = 1, p = lpszCmdLine; *p != '\0'; i++) {
	while (isspace(*p)) {
	    p++;
	}
	if (*p == '\0') {
	    break;
	}
	if (*p == '"') {
	    p++;
	    argv[i] = p;
	    while ((*p != '\0') && (*p != '"')) {
		p++;
	    }
	} else {
	    argv[i] = p;
	    while (*p != '\0' && !isspace(*p)) {
		p++;
	    }
	}
	if (*p != '\0') {
	    *p = '\0';
	    p++;
	}
    }
    argv[i] = NULL;
    argc = i;

    /*
     * Since Windows programs don't get passed the command name as the
     * first argument, we need to fetch it explicitly.
     */

    GetModuleFileName(NULL, buffer, sizeof(buffer));
    argv[0] = buffer;

    return (RunPerl(argc, argv, _environ, NULL));
}

#endif
