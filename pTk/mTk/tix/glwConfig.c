/* glwConfig.c --
 *   
 *	(1) Resource converters for GLW customed configureation options.
 *
 */

#include <tk.h>
#include <tix.h>

/*----------------------------------------------------------------------
 *
 *		 The GLW Customed Config Options
 *
 *----------------------------------------------------------------------
 */

static int   OverlayBorderParseProc _ANSI_ARGS_((ClientData clientData,
		Tcl_Interp *interp, Tk_Window tkwin, char *value,
		char *widRec, int offset));

static char *OverlayBorderPrintProc _ANSI_ARGS_((
		ClientData clientData, Tk_Window tkwin, char *widRec,
		int offset, Tcl_FreeProc **freeProcPtr));

static int   OverlayColorParseProc _ANSI_ARGS_((ClientData clientData,
		Tcl_Interp *interp, Tk_Window tkwin, char *value,
		char *widRec, int offset));

static char *OverlayColorPrintProc _ANSI_ARGS_((
		ClientData clientData, Tk_Window tkwin, char *widRec,
		int offset, Tcl_FreeProc **freeProcPtr));


Tk_CustomOption tixConfigOverlayBorder = {
    OverlayBorderParseProc, OverlayBorderPrintProc, 0,
};

Tk_CustomOption tixConfigOverlayColor = {
    OverlayColorParseProc, OverlayColorPrintProc, 0,
};


/*----------------------------------------------------------------------
 *			Overlay Border
 *----------------------------------------------------------------------
 */

/*
 *  OverlayBorderParseProc --
 *
 *	Parse a color name and creates a Tk_3DBorder structure that
 * can be used in the SGI popup plane.
 *
 * ---->Currently the color name is ignored.
 *
 */
static int OverlayBorderParseProc(clientData, interp, tkwin,
				  value, widRec,offset)
    ClientData clientData;
    Tcl_Interp *interp;
    Tk_Window tkwin;
    char *value;
    char *widRec;
    int offset;
{
    Tk_3DBorder new, old;
    Tk_3DBorder *ptr = (Tk_3DBorder *)(widRec + offset);

    if (value == NULL) {
	new = NULL;
    } else {
 	new = Tk_GetSGIOverlayBorder(interp, tkwin, (Colormap) None, value);
	if (new == NULL) {
	    return TCL_ERROR;
	}
    }

#if 0
    /* %% Now we just allow one (fixed) border color in the overlay plane
     * so it makes no sense to free the border. BTW, calling Tk_Free3DBorder()
     * on an overlay border may not be safe.
     */
    old = *((Tk_3DBorder *) ptr);
    if (old != NULL) {
	Tk_Free3DBorder(old);
    }

#endif

    *((Tk_3DBorder *) ptr) = new;
    return TCL_OK;
}


static char *OverlayBorderPrintProc(clientData, tkwin, widRec,
				    offset, freeProcPtr)
    ClientData clientData;
    Tk_Window tkwin;
    char *widRec;
    int offset;
    Tcl_FreeProc **freeProcPtr;
{
    Tk_3DBorder border = *((Tk_3DBorder *) (widRec+offset));

    if (border != NULL) {
	return Tk_NameOf3DBorder(border);
    } else {
	return 0;
    }
}

/*----------------------------------------------------------------------
 *			Overlay Color
 *----------------------------------------------------------------------
 */

/*
 *  OverlayColorParseProc --
 *
 *	Parse a color name and creates a XColor structure that
 * can be used in the SGI popup plane.
 *
 * ---->Currently the color name is ignored.
 *
 */
static int OverlayColorParseProc(clientData, interp, tkwin,
				 value, widRec,offset)
    ClientData clientData;
    Tcl_Interp *interp;
    Tk_Window tkwin;
    char *value;
    char *widRec;
    int offset;
{
    /* Don't need to free colors */
    XColor  * newPtr;
    XColor ** ptr = (XColor **)(widRec + offset);

    if (value == NULL) {
	newPtr = NULL;
    } else {
	newPtr = Tk_SGIOverlayColor(1);
	if (newPtr == NULL) {
	    return TCL_ERROR;
	}
    }
    *ptr = newPtr;

    return TCL_OK;
}

static char *OverlayColorPrintProc(clientData, tkwin, widRec,
				   offset, freeProcPtr)
    ClientData clientData;
    Tk_Window tkwin;
    char *widRec;
    int offset;
    Tcl_FreeProc **freeProcPtr;
{
    XColor *colorPtr = *((XColor **)(widRec+offset));

    if (colorPtr != NULL) {
	return Tk_NameOfColor(colorPtr);
    } else {
	return 0;
    }
}
