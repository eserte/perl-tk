/* 
 * tclUtil.c --
 *
 *	This file contains utility procedures that are used by many Tcl
 *	commands.
 *
 * Copyright (c) 1987-1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef lint
static char sccsid[] = "@(#) tclUtil.c 1.100 94/12/17 16:14:41";
#endif

#include "tkPort.h"
#include "Lang.h"

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringInit --
 *
 *	Initializes a dynamic string, discarding any previous contents
 *	of the string (Tcl_DStringFree should have been called already
 *	if the dynamic string was previously in use).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The dynamic string is initialized to be empty.
 *
 *----------------------------------------------------------------------
 */

void
Tcl_DStringInit(dsPtr)
    register Tcl_DString *dsPtr;	/* Pointer to structure for
					 * dynamic string. */
{
    dsPtr->string = dsPtr->staticSpace;
    dsPtr->length = 0;
    dsPtr->spaceAvl = TCL_DSTRING_STATIC_SIZE;
    dsPtr->staticSpace[0] = 0;
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringAppend --
 *
 *	Append more characters to the current value of a dynamic string.
 *
 * Results:
 *	The return value is a pointer to the dynamic string's new value.
 *
 * Side effects:
 *	Length bytes from string (or all of string if length is less
 *	than zero) are added to the current value of the string.  Memory
 *	gets reallocated if needed to accomodate the string's new size.
 *
 *----------------------------------------------------------------------
 */

char *
Tcl_DStringAppend(dsPtr, string, length)
    register Tcl_DString *dsPtr;	/* Structure describing dynamic
					 * string. */
    char *string;			/* String to append.  If length is
					 * -1 then this must be
					 * null-terminated. */
    int length;				/* Number of characters from string
					 * to append.  If < 0, then append all
					 * of string, up to null at end. */
{
    int newSize;
    char *newString, *dst, *end;

    if (length < 0) {
	length = strlen(string);
    }
    newSize = length + dsPtr->length;

    /*
     * Allocate a larger buffer for the string if the current one isn't
     * large enough.  Allocate extra space in the new buffer so that there
     * will be room to grow before we have to allocate again.
     */

    if (newSize >= dsPtr->spaceAvl) {
	dsPtr->spaceAvl = newSize*2;
	newString = (char *) ckalloc((unsigned) dsPtr->spaceAvl);
	memcpy((VOID *)newString, (VOID *) dsPtr->string, dsPtr->length);
	if (dsPtr->string != dsPtr->staticSpace) {
	    ckfree(dsPtr->string);
	}
	dsPtr->string = newString;
    }

    /*
     * Copy the new string into the buffer at the end of the old
     * one.
     */

    for (dst = dsPtr->string + dsPtr->length, end = string+length;
	    string < end; string++, dst++) {
	*dst = *string;
    }
    *dst = 0;
    dsPtr->length += length;
    return dsPtr->string;
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringSetLength --
 *
 *	Change the length of a dynamic string.  This can cause the
 *	string to either grow or shrink, depending on the value of
 *	length.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The length of dsPtr is changed to length and a null byte is
 *	stored at that position in the string.  If length is larger
 *	than the space allocated for dsPtr, then a panic occurs.
 *
 *----------------------------------------------------------------------
 */

void
Tcl_DStringSetLength(dsPtr, length)
    register Tcl_DString *dsPtr;	/* Structure describing dynamic
					 * string. */
    int length;				/* New length for dynamic string. */
{
    if (length < 0) {
	length = 0;
    }
    if (length >= dsPtr->spaceAvl) {
	char *newString;

	dsPtr->spaceAvl = length+1;
	newString = (char *) ckalloc((unsigned) dsPtr->spaceAvl);

	/*
	 * SPECIAL NOTE: must use memcpy, not strcpy, to copy the string
	 * to a larger buffer, since there may be embedded NULLs in the
	 * string in some cases.
	 */

	memcpy((VOID *) newString, (VOID *) dsPtr->string, dsPtr->length);
	if (dsPtr->string != dsPtr->staticSpace) {
	    ckfree(dsPtr->string);
	}
	dsPtr->string = newString;
    }
    dsPtr->length = length;
    dsPtr->string[length] = 0;
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringFree --
 *
 *	Frees up any memory allocated for the dynamic string and
 *	reinitializes the string to an empty state.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The previous contents of the dynamic string are lost, and
 *	the new value is an empty string.
 *
 *----------------------------------------------------------------------
 */

void
Tcl_DStringFree(dsPtr)
    register Tcl_DString *dsPtr;	/* Structure describing dynamic
					 * string. */
{
    if (dsPtr->string != dsPtr->staticSpace) {
	ckfree(dsPtr->string);
    }
    dsPtr->string = dsPtr->staticSpace;
    dsPtr->length = 0;
    dsPtr->spaceAvl = TCL_DSTRING_STATIC_SIZE;
    dsPtr->staticSpace[0] = 0;
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringResult --
 *
 *	This procedure moves the value of a dynamic string into an
 *	interpreter as its result.  The string itself is reinitialized
 *	to an empty string.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The string is "moved" to interp's result, and any existing
 *	result for interp is freed up.  DsPtr is reinitialized to
 *	an empty string.
 *
 *----------------------------------------------------------------------
 */

void
Tcl_DStringResult(interp, dsPtr)
    Tcl_Interp *interp;			/* Interpreter whose result is to be
					 * reset. */
    Tcl_DString *dsPtr;			/* Dynamic string that is to become
					 * the result of interp. */
{
    Tcl_ResetResult(interp);
    Tcl_SetResult(interp, dsPtr->string, TCL_VOLATILE);
    Tcl_DStringFree(dsPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_DStringGetResult --
 *
 *	This procedure moves the result of an interpreter into a
 *	dynamic string.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The interpreter's result is cleared, and the previous contents
 *	of dsPtr are freed.
 *
 *----------------------------------------------------------------------
 */

void
Tcl_DStringGetResult(interp, dsPtr)
    Tcl_Interp *interp;			/* Interpreter whose result is to be
					 * reset. */
    Tcl_DString *dsPtr;			/* Dynamic string that is to become
					 * the result of interp. */
{
    char *s = Tcl_GetResult(interp);
    Tcl_DStringFree(dsPtr);
    Tcl_DStringAppend(dsPtr,s, strlen(s));
    Tcl_ResetResult(interp);
}

void *
TclCalloc(n,s)
    size_t n;
    size_t s;
{
    size_t need = s*n;
    void *p     = malloc(need);
    if (p) {
	memset(p, 0, need);
    } 
    return p;
}
