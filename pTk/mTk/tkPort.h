/*
 * tkPort.h --
 *
 *	This file is included by all of the Tk C files.  It contains
 *	information that may be configuration-dependent, such as
 *	#includes for system include files and a few other things.
 *
 * Copyright (c) 1991-1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * @(#) tkPort.h 1.6 95/08/28 09:33:16
 */

#ifndef _TKPORT
#define _TKPORT
#include "tkConfig.h"

/*
 * Macro to use instead of "void" for arguments that must have
 * type "void *" in ANSI C;  maps them to type "char *" in
 * non-ANSI systems.  This macro may be used in some of the include
 * files below, which is why it is defined here.
 */

#ifndef VOID
#   ifdef __STDC__
#       define VOID void
#   else
#       define VOID char
#   endif
#endif

#undef CONST
#ifdef NOCONST
#define CONST
#define const
#else
#define CONST const
#endif

/*
 * Definitions that allow this header file to be used either with or
 * without ANSI C features like function prototypes.
 */

#undef _ANSI_ARGS_
#if defined(USE_PROTO) || ((defined(__STDC__) || defined(SABER)) && !defined(NO_PROTOTYPE)) || defined(__cplusplus)
#   define _USING_PROTOTYPES_ 1
#   define _ANSI_ARGS_(x)	x
#   ifdef __cplusplus
#       define VARARGS (...)
#   else
#       define VARARGS ()
#   endif
#else
#   define _ANSI_ARGS_(x)	()
#endif

#ifdef __cplusplus
#   define EXTERN extern "C"
#else
#   define EXTERN extern
#endif
#define COREXT EXTERN 
#define MOVEXT EXTERN
/*
 * Miscellaneous declarations (to allow Tcl to be used stand-alone,
 * without the rest of Sprite).
 */

#ifndef _CLIENTDATA
#   ifndef NOVOID
    typedef void *ClientData;
#   else
    typedef int *ClientData;
#   endif 
#define _CLIENTDATA
#endif



#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#ifdef HAVE_LIMITS_H
#   include <limits.h>
#else
#   include "compat/limits.h"
#endif
#include <math.h>
#include <pwd.h>
#ifdef NO_STDLIB_H
#   include "compat/stdlib.h"
#else
#   include <stdlib.h>
#endif
#include <string.h>
#include <sys/types.h>
#include <sys/file.h>
#ifdef HAVE_SYS_SELECT_H
#   include <sys/select.h>
#endif
#include <sys/stat.h>
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_UNISTD_H
#   include <unistd.h>
#else
#   include "compat/unistd.h"
#endif
#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <X11/Xatom.h>
#include <X11/Xproto.h>
#include <X11/Xresource.h>
#include <X11/Xutil.h>

#if defined(XlibSpecificationRelease)
#define XFree_arg_t void
#else
#define XFree_arg_t char
#endif

/*
 * Not all systems declare the errno variable in errno.h. so this
 * file does it explicitly.
 */

extern int errno;

/*
 * The following macro defines the type of the mask arguments to
 * select:
 */

#ifdef NO_FD_SET
#   ifndef _AIX
	typedef long fd_mask;
#   endif
#else
#   ifdef __EMX__
typedef long fd_mask;
#   endif
#endif

#ifndef SELECT_MASK
#ifndef NO_FD_SET
#   define SELECT_MASK fd_set
#else
#   if defined(_IBMR2)
#	define SELECT_MASK void
#   else
#	define SELECT_MASK int
#   endif
#endif
#endif

#ifdef __EMX__
#   define strncasecmp strnicmp
#   define strcasecmp stricmp
#endif

/*
 * Define "NBBY" (number of bits per byte) if it's not already defined.
 */

#ifndef NBBY
#   define NBBY 8
#endif

/*
 * The following macro defines the number of fd_masks in an fd_set:
 */

#ifndef FD_SETSIZE
#   ifdef OPEN_MAX
#	define FD_SETSIZE OPEN_MAX
#   else
#	define FD_SETSIZE 256
#   endif
#endif
#if !defined(howmany)
#   define howmany(x, y) (((x)+((y)-1))/(y))
#endif
#ifndef NFDBITS
#   define NFDBITS NBBY*sizeof(fd_mask)
#endif
#define MASK_SIZE howmany(FD_SETSIZE, NFDBITS)

/*
 * The following macro checks to see whether there is buffered
 * input data available for a stdio FILE.  This has to be done
 * in different ways on different systems.  TK_FILE_GPTR and
 * TK_FILE_COUNT are #defined by autoconf.
 */

#ifdef TK_FILE_COUNT
#   define TK_READ_DATA_PENDING(f) ((f)->TK_FILE_COUNT > 0)
#else
#   ifdef TK_FILE_GPTR
#       define TK_READ_DATA_PENDING(f) ((f)->_gptr < (f)->_egptr)
#   else
#       ifdef TK_FILE_READ_PTR
#	    define TK_READ_DATA_PENDING(f) ((f)->_IO_read_ptr != (f)->_IO_read_end)
#	else
	    /*
	     * Don't know what to do for this system; whoever installs
	     * Tk will have to write a function TkReadDataPending to do
	     * the job.
	     */
	    EXTERN int TkReadDataPending _ANSI_ARGS_((FILE *f));
#           define TK_READ_DATA_PENDING(f) TkReadDataPending(f)
#	endif
#   endif
#endif

/*
 * Substitute Tcl's own versions for several system calls.  The
 * Tcl versions retry automatically if interrupted by signals.
 */

#define open(a,b,c) TclOpen(a,b,c)
#define read(a,b,c) TclRead(a,b,c)
#define write(a,b,c) TclWrite(a,b,c)
#undef calloc
#define calloc(n,s) TclCalloc(n,s)

#ifdef TIMEOFDAY_NO_TZ
#define Tk_timeofday(x) gettimeofday(x)
COREXT int gettimeofday _ANSI_ARGS_((struct timeval *tp));
#else
#ifdef TIMEOFDAY_TZ
#define Tk_timeofday(x) gettimeofday(x, (struct timezone *) 0)
COREXT int gettimeofday _ANSI_ARGS_((struct timeval *tp ,struct timezone *tzp));
#else
#define Tk_timeofday(x) gettimeofday(x, (void *) 0)
#ifdef TIMEOFDAY_DOTS
COREXT int gettimeofday _ANSI_ARGS_((struct timeval *tp, ...));
#else
COREXT int gettimeofday _ANSI_ARGS_((struct timeval *tp, void *));
#endif
#endif
#endif

#ifdef USE_BCOPY
COREXT void bcopy _ANSI_ARGS_((const void *src,void *dst,int count));
#ifndef memmove
#define memmove(dst,src,count) bcopy(src,dst,count)
#endif
#endif

/*
 * Declarations for various library procedures that may not be declared
 * in any other header file.
 */

COREXT void		panic();

#ifndef NULL
#define NULL 0
#endif

#endif /* _TKPORT */
