/* 
 * tkImgPmap.c --
 *
 *	This procedure implements images of type "pixmap" for Tk. The only
 *      portable file format for this kind of colorfull pixel data is
 *	the XPM file format (my greetings to Arnaud Le Hors!)
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * Derived from tkImgBmap.c as a template by Harald Albrecht
 * (albrecht@igpm.rwth-aachen.de)
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

/* Sorry -- no sccsid here, I'm doing it the traditional way round... */
/* Last update: 95/02/22                                              */

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tkVMacro.h"
#include "xpm/xpm.h"

/*
 * The following data structure represents the master for a pixmap
 * image:
 */

typedef struct PixmapMaster {
    Tk_ImageMaster tkMaster;	/* Tk's token for image master. */
    Tcl_Interp *interp;		/* Interpreter for application that is
				 * using image. */
    Tcl_Command imageCmd;	/* Token for image command (used to delete
				 * it when the image goes away).  NULL means
				 * the image command has already been
				 * deleted. */
    int width, height;		/* Dimensions of image. */
    char *data;			/* Data comprising xpm pixmap.  May
				 * be NULL if no data.  Malloc'ed. */
    Tk_Uid bgUid;		/* Value of -background option (malloc'ed). */
    char *fileString;		/* Value of -file option (malloc'ed). */
    char *dataString;		/* Value of -data option (malloc'ed). */
    struct PixmapInstance *instancePtr;
				/* First in list of all instances associated
				 * with this master. */
} PixmapMaster;

/*
 * The following data structure represents all of the instances of an
 * image that lie within a particular window:
 */

typedef struct PixmapInstance {
    int refCount;		/* Number of instances that share this
				 * data structure. */
    PixmapMaster *masterPtr;	/* Pointer to master for image. */
    Tk_Window tkwin;		/* Window in which the instances will be
				 * displayed. */
    XColor *bg;			/* Background color for displaying image. */
    Pixmap bitmap;		/* The bitmap to display. */
    Pixmap mask;		/* Mask: only display bitmap pixels where
				 * there are 1's here. */
    GC gc;			/* Graphics context for displaying bitmap.
				 * None means there was an error while
				 * setting up the instance, so it cannot
				 * be displayed. */
    struct PixmapInstance *nextPtr;
				/* Next in list of all instance structures
				 * associated with masterPtr (NULL means
				 * end of list). */
} PixmapInstance;

/*
 * The type record for pixmap images:
 */

static int		ImgPmapCreate _ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, int argc, char **argv,
			    Tk_ImageType *typePtr, Tk_ImageMaster master,
			    ClientData *clientDataPtr));
static ClientData	ImgPmapGet _ANSI_ARGS_((Tk_Window tkwin,
			    ClientData clientData));
static void		ImgPmapDisplay _ANSI_ARGS_((ClientData clientData,
			    Display *display, Drawable drawable, 
			    int imageX, int imageY, int width,
			    int height, int drawableX,
			    int drawableY));
static void		ImgPmapFree _ANSI_ARGS_((ClientData clientData,
			    Display *display));
static void		ImgPmapDelete _ANSI_ARGS_((ClientData clientData));

Tk_ImageType tkPixmapImageType = {
    "pixmap",			/* name */
    ImgPmapCreate,		/* createProc */
    ImgPmapGet,			/* getProc */
    ImgPmapDisplay,		/* displayProc */
    ImgPmapFree,		/* freeProc */
    ImgPmapDelete,		/* deleteProc */
    (Tk_ImageType *) NULL	/* nextPtr */
};

/*
 * Information used for parsing configuration specs:
 */

static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_UID, "-background", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, bgUid), TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-data", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, dataString), TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-file", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, fileString), TK_CONFIG_NULL_OK},
    {TK_CONFIG_END, (char *) NULL, (char *) NULL, (char *) NULL,
	(char *) NULL, 0, 0}
};

/*
 * Prototypes for procedures used only locally in this file:
 */

static char *		GetPixmapData _ANSI_ARGS_((Tcl_Interp *interp,
			    char *string, char *fileName,
			    int *widthPtr, int *heightPtr));
static int		ImgPmapCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, char **argv));
static void		ImgPmapCmdDeletedProc _ANSI_ARGS_((
			    ClientData clientData));
static void		ImgPmapConfigureInstance _ANSI_ARGS_((
			    PixmapInstance *instancePtr));
static int		ImgPmapConfigureMaster _ANSI_ARGS_((
			    PixmapMaster *masterPtr, int argc, char **argv,
			    int flags));

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapCreate --
 *
 *	This procedure is called by the Tk image code to create "test"
 *	images.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	The data structure for a new image is allocated.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
ImgPmapCreate(interp, name, argc, argv, typePtr, master, clientDataPtr)
    Tcl_Interp *interp;		/* Interpreter for application containing
				 * image. */
    char *name;			/* Name to use for image. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings for options (doesn't
				 * include image name or type). */
    Tk_ImageType *typePtr;	/* Pointer to our type record (not used). */
    Tk_ImageMaster master;	/* Token for image, to be used by us in
				 * later callbacks. */
    ClientData *clientDataPtr;	/* Store manager's token for image here;
				 * it will be returned in later callbacks. */
{
    PixmapMaster *masterPtr;

    masterPtr = (PixmapMaster *) ckalloc(sizeof(PixmapMaster));
    masterPtr->tkMaster = master;
    masterPtr->interp = interp;
    masterPtr->imageCmd = Lang_CreateImage(interp, name, ImgPmapCmd,
	    (ClientData) masterPtr, ImgPmapCmdDeletedProc, typePtr);
    masterPtr->width = masterPtr->height = 0;
    masterPtr->data = NULL;
    masterPtr->bgUid = NULL;
    masterPtr->fileString = NULL;
    masterPtr->dataString = NULL;
    masterPtr->instancePtr = NULL;
    if (ImgPmapConfigureMaster(masterPtr, argc, argv, 0) != TCL_OK) {
	ImgPmapDelete((ClientData) masterPtr);
	return TCL_ERROR;
    }
    *clientDataPtr = (ClientData) masterPtr;
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapConfigureMaster --
 *
 *	This procedure is called when a pixmap image is created or
 *	reconfigured.  It process configuration options and resets
 *	any instances of the image.
 *
 * Results:
 *	A standard Tcl return value.  If TCL_ERROR is returned then
 *	an error message is left in masterPtr->interp->result.
 *
 * Side effects:
 *	Existing instances of the image will be redisplayed to match
 *	the new configuration options.
 *
 *----------------------------------------------------------------------
 */

static int
ImgPmapConfigureMaster(masterPtr, argc, argv, flags)
    PixmapMaster *masterPtr;	/* Pointer to data structure describing
				 * overall bitmap image to (reconfigure). */
    int argc;			/* Number of entries in argv. */
    char **argv;		/* Pairs of configuration options for image. */
    int flags;			/* Flags to pass to Tk_ConfigureWidget,
				 * such as TK_CONFIG_ARGV_ONLY. */
{
    PixmapInstance *instancePtr;

    if (Tk_ConfigureWidget(masterPtr->interp, Tk_MainWindow(masterPtr->interp),
	    configSpecs, argc, argv, (char *) masterPtr, flags) != TCL_OK) {
	return TCL_ERROR;
    }

    /*
     * Parse the bitmap and/or mask to create binary data.  Make sure that
     * the bitmap and mask have the same dimensions.
     */

    if (masterPtr->data != NULL) {
	ckfree(masterPtr->data);
	masterPtr->data = NULL;
    }
    if ((masterPtr->fileString != NULL) || (masterPtr->dataString != NULL)) {
	masterPtr->data = GetPixmapData(masterPtr->interp,
		masterPtr->dataString, masterPtr->fileString,
		&masterPtr->width, &masterPtr->height);
	if (masterPtr->data == NULL) {
	    return TCL_ERROR;
	}
    }

    /*
     * Cycle through all of the instances of this image, regenerating
     * the information for each instance.  Then force the image to be
     * redisplayed everywhere that it is used.
     */

    for (instancePtr = masterPtr->instancePtr; instancePtr != NULL;
	    instancePtr = instancePtr->nextPtr) {
	ImgPmapConfigureInstance(instancePtr);
    }
    Tk_ImageChanged(masterPtr->tkMaster, 0, 0, masterPtr->width,
	    masterPtr->height, masterPtr->width, masterPtr->height);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapConfigureInstance --
 *
 *	This procedure is called to create displaying information for
 *	a bitmap image instance based on the configuration information
 *	in the master.  It is invoked both when new instances are
 *	created and when the master is reconfigured.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Generates errors via Tk_BackgroundError if there are problems
 *	in setting up the instance.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPmapConfigureInstance(instancePtr)
    PixmapInstance *instancePtr;	/* Instance to reconfigure. */
{
    PixmapMaster *masterPtr = instancePtr->masterPtr;
    XColor *colorPtr;
    XGCValues gcValues;
    GC gc;
    unsigned int mask;
    int xpmError;
    XpmAttributes xpmAttr;
    static XpmColorSymbol xpmTransparentColor[1] = {{ NULL, "none", 0 }};

    /*
     * For each of the options in masterPtr, translate the string
     * form into an internal form appropriate for instancePtr.
     */

    if ( masterPtr->bgUid != NULL ) {
        colorPtr = Tk_GetColor(masterPtr->interp, instancePtr->tkwin,
		               masterPtr->bgUid);
    	if (colorPtr == NULL) {
	    goto error;
    	}
    	if (instancePtr->bg != NULL) {
	    Tk_FreeColor(instancePtr->bg);
    	}
    	instancePtr->bg = colorPtr;
    } else {
        instancePtr->bg = NULL;
    }

    if (instancePtr->bitmap != None) {
	XFreePixmap(Tk_Display(instancePtr->tkwin), instancePtr->bitmap);
	instancePtr->bitmap = None;
    }
    if (instancePtr->mask != None) {
    	XFreePixmap(Tk_Display(instancePtr->tkwin), instancePtr->mask);
    	instancePtr->mask = None;
    }
    
    if (masterPtr->data != NULL) {
	xpmAttr.valuemask    = XpmCloseness | XpmDepth;
	if ( instancePtr->bg != NULL ) {
	    xpmAttr.valuemask            |= XpmColorSymbols;
            xpmTransparentColor[0].pixel  = instancePtr->bg->pixel;
	    xpmAttr.colorsymbols          = xpmTransparentColor;
	    xpmAttr.numsymbols            = 1;
	}
	xpmAttr.closeness    = 65535;
	xpmAttr.depth        = DisplayPlanes(Tk_Display(instancePtr->tkwin),
	                           Tk_ScreenNumber(instancePtr->tkwin));
	xpmError = XpmCreatePixmapFromBuffer(
		Tk_Display(instancePtr->tkwin),
		RootWindowOfScreen(Tk_Screen(instancePtr->tkwin)),
		masterPtr->data,
		&(instancePtr->bitmap),
		instancePtr->bg == NULL ? &(instancePtr->mask) : NULL,
		&xpmAttr);
	if ( xpmError != XpmSuccess ) {
	    XpmFreeAttributes(&xpmAttr);
	    instancePtr->bitmap = None;
	    goto error;
	}
	XpmFreeAttributes(&xpmAttr);
    }

    if (masterPtr->data != NULL) {
	mask = GCGraphicsExposures;
	gcValues.graphics_exposures = False;
        if ( instancePtr->bg != NULL ) {
	    gcValues.background = instancePtr->bg->pixel;
	    mask |= GCBackground;
	}
	if (instancePtr->mask != None) {
	    gcValues.clip_mask = instancePtr->mask;
	    mask |= GCClipMask;
	}
	gc = Tk_GetGC(instancePtr->tkwin, mask, &gcValues);
    } else {
	gc = None;
    }
    if (instancePtr->gc != None) {
	Tk_FreeGC(Tk_Display(instancePtr->tkwin), instancePtr->gc);
    }
    instancePtr->gc = gc;
    return;

  error:
    /*
     * An error occurred: clear the graphics context in the instance to
     * make it clear that this instance cannot be displayed.  Then report
     * the error.
     */

    if (instancePtr->gc != None) {
	Tk_FreeGC(Tk_Display(instancePtr->tkwin), instancePtr->gc);
    }
    instancePtr->gc = None;
    Tcl_AddErrorInfo(masterPtr->interp, "\n    (while configuring image \"");
    Tcl_AddErrorInfo(masterPtr->interp, Tk_NameOfImage(masterPtr->tkMaster));
    Tcl_AddErrorInfo(masterPtr->interp, "\")");
    Tk_BackgroundError(masterPtr->interp);
}

/*
 *----------------------------------------------------------------------
 *
 * GetPixmapData --
 *
 *	Given a file name or ASCII string, this procedure parses the
 *	file or string contents to produce binary data for a bitmap.
 *
 * Results:
 *	If the bitmap description was parsed successfully then the
 *	return value is a malloc-ed array containing the bitmap data.
 *	The dimensions of the data are stored in *widthPtr and *heightPtr.
 *	If an error occurred, NULL is returned and an error message is
 *	left in interp->result.
 *
 * Side effects:
 *	A bitmap is created.
 *
 *----------------------------------------------------------------------
 */

static char *
GetPixmapData(interp, string, fileName, widthPtr, heightPtr)
    Tcl_Interp *interp;			/* For reporting errors. */
    char *string;			/* String describing bitmap.  May
					 * be NULL. */
    char *fileName;			/* Name of file containing bitmap
					 * description.  Used only if string
					 * is NULL.  Must not be NULL if
					 * string is NULL. */
    int *widthPtr, *heightPtr;		/* Dimensions of pixmap get returned
					 * here. */
{
    FILE        *f;
    int         numBytes;
    XpmImage    image;
    char        *data = NULL;
    Tcl_DString fName;
    char        *ExpandedFileName;

    if ( string == NULL ) {
        ExpandedFileName = Tcl_TildeSubst(interp, fileName, &fName);
	f = fopen(ExpandedFileName, "r");
	Tcl_DStringFree(&fName);
	if ( f == NULL ) {
	    Tcl_AppendResult(interp, "couldn't read pixmap file \"",
		    fileName, "\": ", Tcl_PosixError(interp), (char *) NULL);
	    return NULL;
	}
	fseek(f, 0, SEEK_END);
	numBytes = ftell(f) + 1;
	fseek(f, 0, SEEK_SET);
	data = (char *) ckalloc((unsigned) numBytes);
	if ( data != NULL ) {
	    fread(data, 1, numBytes, f);
	}
	fclose(f);
    } else {
	data = ckalloc((unsigned) strlen(string) + 1);
	if ( data != NULL ) {
	    strcpy(data, string);
	}
    }

    if ( data == NULL ) {
        Tcl_AppendResult(interp, "out of memory while reading XPM pixmap",
                                 (char *) NULL);
        goto errorCleanup;
    }

    if ( XpmCreateXpmImageFromBuffer(data, &image, NULL) != XpmSuccess ) {
        Tcl_AppendResult(interp, "error reading XPM pixmap",
                                 (char *) NULL);
        goto errorCleanup;
    }
    *widthPtr = image.width; *heightPtr = image.height;
    XpmFreeXpmImage(&image);
    return data;

    errorCleanup:
    if (data != NULL) {
	ckfree(data);
    }
    return NULL;
}

/*
 *--------------------------------------------------------------
 *
 * ImgPmapCmd --
 *
 *	This procedure is invoked to process the Tcl command
 *	that corresponds to an image managed by this module.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

static int
ImgPmapCmd(clientData, interp, argc, argv)
    ClientData clientData;	/* Information about button widget. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    char **argv;		/* Argument strings. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) clientData;
    int c, code;
    size_t length;

    if (argc < 2) {
	sprintf(interp->result,
		"wrong # args: should be \"%.50s option ?arg arg ...?\"",
		argv[0]);
	return TCL_ERROR;
    }
    c = argv[1][0];
    length = strlen(argv[1]);
    if ((c == 'c') && (strncmp(argv[1], "cget", length) == 0)
	    && (length >= 2)) {
	if (argc != 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"",
		    argv[0], " cget option\"",
		    (char *) NULL);
	    return TCL_ERROR;
	}
	return Tk_ConfigureValue(interp, Tk_MainWindow(interp), configSpecs,
		(char *) masterPtr, argv[2], 0);
    } else if ((c == 'c') && (strncmp(argv[1], "configure", length) == 0)
	    && (length >= 2)) {
	if (argc == 2) {
	    code = Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
		    configSpecs, (char *) masterPtr, (char *) NULL, 0);
	} else if (argc == 3) {
	    code = Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
		    configSpecs, (char *) masterPtr, argv[2], 0);
	} else {
	    code = ImgPmapConfigureMaster(masterPtr, argc-2, argv+2,
		    TK_CONFIG_ARGV_ONLY);
	}
	return code;
    } else {
	Tcl_AppendResult(interp, "bad option \"", argv[1],
		"\": must be cget or configure", (char *) NULL);
	return TCL_ERROR;
    }
    /* return TCL_OK;  */ 
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapGet --
 *
 *	This procedure is called for each use of a bitmap image in a
 *	widget.
 *
 * Results:
 *	The return value is a token for the instance, which is passed
 *	back to us in calls to ImgPmapDisplay and ImgPmapFree.
 *
 * Side effects:
 *	A data structure is set up for the instance (or, an existing
 *	instance is re-used for the new one).
 *
 *----------------------------------------------------------------------
 */

static ClientData
ImgPmapGet(tkwin, masterData)
    Tk_Window tkwin;		/* Window in which the instance will be
				 * used. */
    ClientData masterData;	/* Pointer to our master structure for the
				 * image. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) masterData;
    PixmapInstance *instancePtr;

    /*
     * See if there is already an instance for this window.  If so
     * then just re-use it.
     */

    for (instancePtr = masterPtr->instancePtr; instancePtr != NULL;
	    instancePtr = instancePtr->nextPtr) {
	if (instancePtr->tkwin == tkwin) {
	    instancePtr->refCount++;
	    return (ClientData) instancePtr;
	}
    }

    /*
     * The image isn't already in use in this window.  Make a new
     * instance of the image.
     */

    instancePtr = (PixmapInstance *) ckalloc(sizeof(PixmapInstance));
    instancePtr->refCount = 1;
    instancePtr->masterPtr = masterPtr;
    instancePtr->tkwin = tkwin;
    instancePtr->bg = NULL;
    instancePtr->bitmap = None;
    instancePtr->mask = None;
    instancePtr->gc = None;
    instancePtr->nextPtr = masterPtr->instancePtr;
    masterPtr->instancePtr = instancePtr;
    ImgPmapConfigureInstance(instancePtr);

    /*
     * If this is the first instance, must set the size of the image.
     */

    if (instancePtr->nextPtr == NULL) {
	Tk_ImageChanged(masterPtr->tkMaster, 0, 0, 0, 0, masterPtr->width,
		masterPtr->height);
    }

    return (ClientData) instancePtr;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapDisplay --
 *
 *	This procedure is invoked to draw a bitmap image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A portion of the image gets rendered in a pixmap or window.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPmapDisplay(clientData, display, drawable, imageX, imageY, width,
	height, drawableX, drawableY)
    ClientData clientData;	/* Pointer to PixmapInstance structure for
				 * for instance to be displayed. */
    Display *display;		/* Display on which to draw image. */
    Drawable drawable;		/* Pixmap or window in which to draw image. */
    int imageX, imageY;		/* Upper-left corner of region within image
				 * to draw. */
    int width, height;		/* Dimensions of region within image to draw. */
    int drawableX, drawableY;	/* Coordinates within drawable that
				 * correspond to imageX and imageY. */
{
    PixmapInstance *instancePtr = (PixmapInstance *) clientData;
    int masking;

    /*
     * If there's no graphics context, it means that an error occurred
     * while creating the image instance so it can't be displayed.
     */

    if (instancePtr->gc == None) {
	return;
    }

    /*
     * If masking is in effect, must modify the mask origin within
     * the graphics context to line up with the image's origin.
     * Then draw the image and reset the clip origin, if there's
     * a mask.
     */

    masking = (instancePtr->mask != None) || (instancePtr->bg == NULL);
    if (masking) {
	XSetClipOrigin(display, instancePtr->gc, drawableX - imageX,
		drawableY - imageY);
    }
    XCopyArea(display, instancePtr->bitmap, drawable, instancePtr->gc,
	      imageX, imageY, width, height, drawableX, drawableY);
    if (instancePtr->mask != None) {
	XSetClipOrigin(display, instancePtr->gc, 0, 0);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapFree --
 *
 *	This procedure is called when a widget ceases to use a
 *	particular instance of an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Internal data structures get cleaned up.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPmapFree(clientData, display)
    ClientData clientData;	/* Pointer to PixmapInstance structure for
				 * for instance to be displayed. */
    Display *display;		/* Display containing window that used image. */
{
    PixmapInstance *instancePtr = (PixmapInstance *) clientData;
    PixmapInstance *prevPtr;

    instancePtr->refCount--;
    if (instancePtr->refCount > 0) {
	return;
    }

    /*
     * There are no more uses of the image within this widget.  Free
     * the instance structure.
     */

    if (instancePtr->bg != NULL) {
	Tk_FreeColor(instancePtr->bg);
    }
    if (instancePtr->bitmap != None) {
	XFreePixmap(display, instancePtr->bitmap);
    }
    if (instancePtr->mask != None) {
	XFreePixmap(display, instancePtr->mask);
    }
    if (instancePtr->gc != None) {
	Tk_FreeGC(display, instancePtr->gc);
    }
    if (instancePtr->masterPtr->instancePtr == instancePtr) {
	instancePtr->masterPtr->instancePtr = instancePtr->nextPtr;
    } else {
	for (prevPtr = instancePtr->masterPtr->instancePtr;
		prevPtr->nextPtr != instancePtr; prevPtr = prevPtr->nextPtr) {
	    /* Empty loop body */
	}
	prevPtr->nextPtr = instancePtr->nextPtr;
    }
    ckfree((char *) instancePtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapDelete --
 *
 *	This procedure is called by the image code to delete the
 *	master structure for an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Resources associated with the image get freed.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPmapDelete(masterData)
    ClientData masterData;	/* Pointer to PixmapMaster structure for
				 * image.  Must not have any more instances. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) masterData;

    if (masterPtr->instancePtr != NULL) {
	panic("tried to delete bitmap image when instances still exist");
    }
    masterPtr->tkMaster = NULL;
    if (masterPtr->imageCmd != NULL) {
 	Tcl_DeleteCommand(masterPtr->interp,
 		Tcl_GetCommandName(masterPtr->interp, masterPtr->imageCmd));
    }
    if (masterPtr->data != NULL) {
	ckfree(masterPtr->data);
    }
    Tk_FreeOptions(configSpecs, (char *) masterPtr, (Display *) NULL, 0);
    ckfree((char *) masterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPmapCmdDeletedProc --
 *
 *	This procedure is invoked when the image command for an image
 *	is deleted.  It deletes the image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image is deleted.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPmapCmdDeletedProc(clientData)
    ClientData clientData;	/* Pointer to BitmapMaster structure for
				 * image. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) clientData;

    masterPtr->imageCmd = NULL;
    if (masterPtr->tkMaster != NULL) {
	Tk_DeleteImage(masterPtr->interp, Tk_NameOfImage(masterPtr->tkMaster));
    }
}
