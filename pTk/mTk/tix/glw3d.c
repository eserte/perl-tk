/* Ioi notes:
 *
 * (1) Now just use the "Black color of screen" for black line. Later
 *     Will make this color configurable
 *
 */

#include "tkConfig.h"
#include "tk.h"
#include "tk3dP.h"
#include "tix.h"
#include "tixGLW.h"

/*
 *--------------------------------------------------------------
 *
 * Tk_GetSGIOverlayBorder --
 *
 *	Create a data structure for displaying a 3-D border.
 *
 * Results:
 *	The return value is a token for a data structure
 *	describing a 3-D border.  This token may be passed
 *	to Tk_Draw3DRectangle and Tk_Free3DBorder.  If an
 *	error prevented the border from being created then
 *	NULL is returned and an error message will be left
 *	in interp->result.
 *
 * Side effects:
 *	Data structures, graphics contexts, etc. are allocated.
 *	It is the caller's responsibility to eventually call
 *	Tk_Free3DBorder to release the resources.
 *
 *--------------------------------------------------------------
 */
Tk_3DBorder
Tk_GetSGIOverlayBorder(interp, tkwin, colormap, colorName)
    Tcl_Interp *interp;		/* Place to store an error message. */
    Tk_Window tkwin;		/* Token for window in which
				 * border will be drawn. */
    Colormap colormap;		/* not used */
    Tk_Uid colorName;		/* not used */
{
    BorderKey key;
    Tcl_HashEntry *hashPtr;
    register Border *borderPtr;
    int new;
    unsigned long light, dark;
    XGCValues gcValues;
    unsigned long mask;

    if (!initialized_3d) {
	BorderInit();
    }

    /*
     * First, check to see if there's already a border that will work
     * for this request.
     */
    key.colorName = "hacked";
    key.colormap  = colormap;
    key.screen    = Tk_Screen(tkwin);

    hashPtr = Tcl_CreateHashEntry(&borderTable, (char *) &key, &new);

    if (!new) {
	borderPtr = (Border *) Tcl_GetHashValue(hashPtr);
	borderPtr->refCount++;
    } else {
	/*
	 * No satisfactory border exists yet.  Initialize a new one.
	 */
    	borderPtr = (Border *) ckalloc(sizeof(Border));
	borderPtr->display = Tk_Display(tkwin);
	borderPtr->refCount = 1;
	borderPtr->bgColorPtr = NULL;
	borderPtr->blackColorPtr = NULL;
	borderPtr->lightColorPtr = NULL;
	borderPtr->light2ColorPtr = NULL;
	borderPtr->darkColorPtr = NULL;
	borderPtr->dark2ColorPtr = NULL;
	borderPtr->shadow = None;
	borderPtr->lightGC = None;
	borderPtr->light2GC = None;
	borderPtr->darkGC = None;
	borderPtr->dark2GC = None;
	borderPtr->bgGC = None;
	borderPtr->blackGC = None;
	borderPtr->hashPtr = hashPtr;
	Tcl_SetHashValue(hashPtr, borderPtr);

	borderPtr->bgColorPtr    = Tk_SGIOverlayColor(2);
	borderPtr->lightColorPtr = Tk_SGIOverlayColor(0);	/* white*/
	borderPtr->darkColorPtr  = Tk_SGIOverlayColor(1);	/* black*/
	light = borderPtr->lightColorPtr->pixel;
	dark = borderPtr->darkColorPtr->pixel;

	gcValues.foreground = light;
	gcValues.background = dark;
	mask = GCForeground|GCBackground;
	if (borderPtr->shadow != None) {
	    gcValues.stipple = borderPtr->shadow;
	    gcValues.fill_style = FillOpaqueStippled;
	    mask |= GCStipple|GCFillStyle;
	}
	borderPtr->lightGC = Tk_GetGC(tkwin, mask, &gcValues);
	gcValues.foreground = dark;
	gcValues.background = light;
	borderPtr->darkGC = Tk_GetGC(tkwin, GCForeground|GCBackground,
	    &gcValues);
	gcValues.foreground = borderPtr->bgColorPtr->pixel;
	borderPtr->bgGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
    }

    return (Tk_3DBorder) borderPtr;
}
