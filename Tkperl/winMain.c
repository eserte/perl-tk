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
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef WIN32_LEAN_AND_MEAN
#include <locale.h>
#include <stdlib.h>

#include <stdio.h>

extern int RunPerl(int argc, char **argv, char **env, void *iosubsystem);


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

int
main(int argc, char *argv[], char *env[])
{
#ifndef WIN32
    return (RunPerl(argc, argv, env, NULL));
#else
    fprintf(stderr, "Error: RunPerl() is unimplemented on this platform\n");
    fflush(stderr);
    abort();
    return 1;
#endif
}

int APIENTRY
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, 
        LPSTR lpszCmdLine, int nCmdShow)
{
    char **argv, **argvlist, *p;
    int argc, size, i;
    char buffer[MAX_PATH];

    char text[1024];

    lpszCmdLine = GetCommandLine();

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

    return (main(argc, argv, _environ));
}


#else /* WIN32 */
/* Allow UNIX to build 'guiperl' if tried, by faking 
 * a degnerate static-linked extension
 */


#ifdef __cplusplus
extern "C"
#endif

XS(boot_Tk__Tkperl)
{
 dXSARGS;
 ST(0) = &sv_yes;
 XSRETURN(1);
}

#endif /* WIN32 */
