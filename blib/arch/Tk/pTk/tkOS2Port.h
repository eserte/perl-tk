/*
 * tkOS2Port.h --
 *
 *	This header file handles porting issues that occur because of
 *	differences between OS/2 and Unix. It should be the only
 *	file that contains #ifdefs to handle different flavors of OS.
 *
 * Copyright (c) 1996-1997 Illya Vaes
 * Copyright (c) 1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _OS2PORT
#define _OS2PORT

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <limits.h>
#include <fcntl.h>
#include <io.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <sys/time.h>

#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>

#define strncasecmp strnicmp

#define NBBY 8

#define OPEN_MAX 32

#ifndef howmany
#   define howmany(x, y) (((x)+((y)-1))/(y))
#endif
#ifndef NFDBITS
#   define NFDBITS NBBY*sizeof(fd_mask)
#endif
#define MASK_SIZE howmany(FD_SETSIZE, NFDBITS)

/*
 * The following define causes Tk to use its internal keysym hash table
 */

#define REDO_KEYSYM_LOOKUP

/* Newer stuff: */
#define TkGetNativeProlog(interp) TkGetProlog(interp)
#define TkFreeWindowId(dispPtr,w)
#define TkInitXId(dispPtr)

/*
 * The following macro checks to see whether there is buffered
 * input data available for a stdio FILE.
 */

#ifdef __EMX__
#    define TK_READ_DATA_PENDING(f) ((f)->rcount > 0)
#elif __BORLANDC__
#    define TK_READ_DATA_PENDING(f) ((f)->level > 0)
#elif __IBMC__
#    define TK_READ_DATA_PENDING(f) ((f)->_count > 0)
#endif /* __EMX__ */

/*
 * The following stubs implement various X calls that don't do anything
 * under Windows.
 */

#define XFlush(display)
#define XFree(data) {if ((data) != NULL) ckfree((char *) (data));}
#define XGrabServer(display)
#define XNoOp(display) {display->request++;}
#define XUngrabServer(display)
#define XSynchronize(display, bool) {display->request++;}
#define XSync(display, bool) {display->request++;}
#define XVisualIDFromVisual(visual) (visual->visualid)

#define XPutImage(display, dr, gc, i, a, b, c, d, e, f) \
      TkPutImage(NULL, 0, display, dr, gc, i, a, b, c, d, e, f)
#define XDefaultVisual(display, screen) ((screen)->root_visual)
#define XDefaultScreen(display) ((display)->screens)
#define XDefaultColormap(display, screen) ((screen)->cmap)
#define XDefaultDepth(display, screen) ((screen)->root_depth)

#ifndef __EMX__

/*
 * Define timezone for gettimeofday.
 */
struct timezone {
    int tz_minuteswest;
    int tz_dsttime;
};
extern int gettimeofday(struct timeval *, struct timezone *);

#endif /* __EMX__ */


/* Various stubs added from Unix and Windows variants. */

/*
 * These calls implement native bitmaps which are not supported under
 * UNIX.  The macros eliminate the calls.
 */

#define TkpDefineNativeBitmaps()
#define TkpCreateNativeBitmap(display, source) None
#define TkpGetNativeAppBitmap(display, name, w, h) None

/*
 * These functions do nothing under Unix, so we just eliminate calls to them.
 */

#define TkpDestroyButton(butPtr) {}

/*
 * This macro stores a representation of the window handle in a string.
 */

#define TkpPrintWindowId(buf,w) \
	sprintf((buf), "0x%x", (unsigned int) (w))
	    
/*
 * TkpScanWindowId is just an alias for Tcl_GetInt on Unix.
 */

#define TkpScanWindowId(i,s,wp) \
	Tcl_GetInt((i),(s),(wp))
	    
/*
 * The following stubs implement various calls that don't do anything
 * under Windows.
 */

#define TkpSync(display)

#endif /* _OS2PORT */
