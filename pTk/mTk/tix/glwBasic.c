/* 
 * glwBasic.c
 *
 *	This file access to the GLX extension running on SGI
 *	machines.
 */

#include "tkConfig.h"
#include "tkInt.h"
#include "patchlevel.h"
#include <gl/glws.h>

/* set_entry --
 *
 * Sets the entries on the GLXconfig array passed to glxGetConfig()
 */
static void set_entry (GLXconfig* ptr, int b, int m, int a)
{
    ptr->buffer = b;
    ptr->mode = m;
    ptr->arg = a;
}

/* This function tries to find out whether this display supports GLX extension
 *
 */
static int QueryGLXExtension(Display * dpy)
{
    const int UNKNOWN 	= 0;
    const int YES	= 1;
    const int NO	= 2;
    static found = UNKNOWN;
    char ** exts;
    int n, i;

    if (found == YES) {
	return 1;
    }
    else if (found == NO) {
	return 0;
    }

    if ((exts = XListExtensions(dpy, &n)) && n) {
	for (i=0; i<n; i++) {
	    if (exts[i] && (strcmp("GLX", exts[i])==0)) {
		found = YES;
		return 1;
	    }
	    if (exts[i] && (strncmp("SGI", exts[i], 3)==0)) {
		found = YES;
		return 1;
	    }
	}
    }

    found = NO;
    return 0;
}

/*  GLXSetWindowBuffer --
 *
 *
 *	Specify the buffer in which the TK window should be created.
 *
 *
 * %% Now only supports GLX_POPUP.
 *
 */
int GLXSetWindowBuffer(tkwin, buffer)
    Tk_Window    tkwin;
    int        	 buffer;
{
    GLXconfig 		params[50];
    GLXconfig	      * next;
    GLXconfig	      * retconfig;

    Colormap 		colormap;
    unsigned int	depth;

    Visual	      * visual;
    XVisualInfo	      * vis;
    XVisualInfo 	template;
    int 		nret;

    TkWindow	      * winPtr = (TkWindow*) tkwin;

    if (!QueryGLXExtension(Tk_Display(tkwin))) {
	return 0;
    }

    /* get original values */
    visual   = winPtr->visual;
    depth    = winPtr->depth;
    colormap = winPtr->atts.colormap;

    /* This builds an array in "params" that describes for GLXgetconfig(3G)
     * the type of GL drawing that will be done.
     */
    next = params;
    set_entry(next++, buffer, GLX_RGB, FALSE);
    set_entry(next++, buffer, GLX_DOUBLE, FALSE);
    if (buffer != GLX_NORMAL) {
	set_entry(next++, buffer, GLX_BUFSIZE,  GLX_NOCONFIG);
	set_entry(next++, buffer, GLX_ZSIZE,    GLX_NOCONFIG);
	set_entry(next++, buffer, GLX_ACSIZE,   GLX_NOCONFIG);
	set_entry(next++, buffer, GLX_STENSIZE, GLX_NOCONFIG);
    }

    /* The input to GLXgetconfig is null terminated */
    set_entry(next, 0, 0, 0); 

    /* Get configuration data for a window based on above parameters
     * First we have to find out which screen the parent window is on,
     * then we can call GXLgetconfig()
     */
    retconfig = GLXgetconfig(winPtr->display, winPtr->screenNum, params);
    if (retconfig == 0) {
	/* cannot find the info about the GL Overlay plane */
	return 0;
    }

    /* Scan through config info, pulling info needed to create a window
     * that supports the rendering mode.
     */
    for (next = retconfig; next->buffer; next++) {
	unsigned long buf   = next->buffer;
	unsigned long mode  = next->mode;
	unsigned long value = next->arg;
	switch (mode) {
	  case GLX_COLORMAP:
	    if (buf == buffer) {
		if (value == 0) {
		    return 0;
		}
		colormap = value;
	    }
	    break;
	  case GLX_VISUAL:
	    if (buf == buffer) {
		if (value == 0) {
		    return 0;
		}
		template.visualid = value;
		template.screen   = winPtr->screenNum;
		vis = XGetVisualInfo(winPtr->display, 
				     VisualScreenMask|VisualIDMask,
				     &template, &nret);
		if (vis) {
		    visual = vis->visual;
		} else {
		    return 0;
		}
	    }
	    break;
	  case GLX_BUFSIZE:
	    if (buf == buffer) {
		if (value == 0) {
		    return 0;
		}
		depth = (unsigned int) value;
	    }
	    break;
	}
    }

    fprintf(stderr, "depth = %d\n", depth);
    return Tk_SetWindowVisual(tkwin, visual, depth, colormap);
}
