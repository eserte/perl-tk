/*
 * tkConfig.h --
 *
 *	This file is included by all of the Tk C files.  It contains
 *	information that may be configuration-dependent, such as
 *	#includes for system include files and a few other things.
 *
 * Copyright (c) 1991-1993 The Regents of the University of California.
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that the
 * above copyright notice and the following two paragraphs appear in
 * all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * $Header: /home/auspex9/free-sw/tcl/mk4/RCS/tkConfig.h,v 1.2 1995/01/04 18:23:17 a904209 Exp a904209 $ SPRITE (Berkeley)
 */

#ifndef _TKCONFIG
#define _TKCONFIG

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

#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
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
#    include <sys/time.h>
#endif
#ifndef _TCL
#   include <tcl.h>
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

/*
 * Not all systems declare the errno variable in errno.h. so this
 * file does it explicitly.
 */

extern int errno;

/*
 * Define OPEN_MAX if it isn't already defined for this system.
 */

#ifndef OPEN_MAX
#   define OPEN_MAX 256
#endif

/*
 * The following macro defines the type of the mask arguments to
 * select:
 */

#ifdef NO_FD_SET
#   ifndef _AIX
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

/*
 * Define "NBBY" (number of bits per byte) if it's not already defined.
 */

#ifndef NBBY
#   define NBBY 8
#endif

/*
 * The following macro defines the number of fd_masks in an fd_set:
 */

#if !defined(howmany)
#   define howmany(x, y) (((x)+((y)-1))/(y))
#endif
#ifdef NFDBITS
#   define MASK_SIZE howmany(FD_SETSIZE, NFDBITS)
#else
#   define MASK_SIZE howmany(OPEN_MAX, NBBY*sizeof(fd_mask))
#endif

/*
 * Substitute Tcl's own versions for several system calls.  The
 * Tcl versions retry automatically if interrupted by signals.
 */

#define open(a,b,c) TclOpen(a,b,c)
#define read(a,b,c) TclRead(a,b,c)
#define waitpid(a,b,c) TclWaitpid(a,b,c)
#define write(a,b,c) TclWrite(a,b,c)
EXTERN int	TclOpen _ANSI_ARGS_((char *path, int oflag, mode_t mode));
EXTERN int	TclRead _ANSI_ARGS_((int fd, VOID *buf,
		    unsigned int numBytes));
EXTERN int	TclWaitpid _ANSI_ARGS_((pid_t pid, int *statPtr, int options));
EXTERN int	TclWrite _ANSI_ARGS_((int fd, VOID *buf,
		    unsigned int numBytes));

/*
 * Declarations for various library procedures that may not be declared
 * in any other header file.
 */

extern void		panic();

#if 0
#ifndef HAVE_SYS_SELECT_H
extern int		select _ANSI_ARGS_((int nfds, SELECT_MASK *readfds,
			    SELECT_MASK *writefds, SELECT_MASK *exceptfds,
			    struct timeval *timeout));
#endif
#endif

#endif /* _TKCONFIG */
