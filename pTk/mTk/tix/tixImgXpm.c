/* 
 * tkImgXpm.c --
 *
 *	This procedure implements images of type "pixmap" for Tix.
 *	This file is adapted from the Tk 4.0 source file tkImgBmap.c
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" of the TK distribution for information
 * on usage and redistribution of the original tkImgBmap.c file, and for 
 * a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tkInt.h"
#include "tkPort.h"
#include "xpm.h"

/*
 * The following data structure represents the master for a pixmap
 * image:
 */

typedef struct PixmapMaster {
    Tk_ImageMaster tkMaster;	/* Tk's token for image master.  NULL means
				 * the image is being deleted. */
    Tcl_Interp *interp;		/* Interpreter for application that is
				 * using image. */
    Tcl_Command imageCmd;	/* Token for image command (used to delete
				 * it when the image goes away).  NULL means
				 * the image command has already been
				 * deleted. */
    char *fileString;		/* Value of -file option (malloc'ed).
				 * valid only if the -file option is specified
				 */
    char *dataString;		/* Value of -data option (malloc'ed).
				 * valid only if the -data option is specified
				 */
				/* First in list of all instances associated
				 * with this master. */
    Tk_Uid id;			/* ID's for XPM data already compiled
				 * in the tixwish binary */
    XpmImage * xpmImage;	/* Data comprising pixmap (suitable for
				 * input to XCreatePixmapFromData).   May
				 * be NULL if no data.  Malloc'ed.
				 */
    XpmInfo xpmInfo;
    struct PixmapInstance *instancePtr;
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
    Pixmap pixmap;		/* The pixmap to display. */
    Pixmap mask;		/* Mask: only display pixmap pixels where
				 * there are 1's here. */
    GC gc;			/* Graphics context for displaying pixmap.
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

static int		ImgXpmCreate _ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, int argc, char **argv,
			    Tk_ImageType *typePtr, Tk_ImageMaster master,
			    ClientData *clientDataPtr));
static ClientData	ImgXpmGet _ANSI_ARGS_((Tk_Window tkwin,
			    ClientData clientData));
static void		ImgXpmDisplay _ANSI_ARGS_((ClientData clientData,
			    Display *display, Drawable drawable, 
			    int imageX, int imageY, int width, int height,
			    int drawableX, int drawableY));
static void		ImgXpmFree _ANSI_ARGS_((ClientData clientData,
			    Display *display));
static void		ImgXpmDelete _ANSI_ARGS_((ClientData clientData));

Tk_ImageType tixPixmapImageType = {
    "pixmap",			/* name */
    ImgXpmCreate,		/* createProc */
    ImgXpmGet,			/* getProc */
    ImgXpmDisplay,		/* displayProc */
    ImgXpmFree,			/* freeProc */
    ImgXpmDelete,		/* deleteProc */
    (Tk_ImageType *) NULL	/* nextPtr */
};

/*
 * Information used for parsing configuration specs:
 */

static Tk_ConfigSpec configSpecs[] = {
#if 0
    {TK_CONFIG_UID, "-background", (char *) NULL, (char *) NULL,
	"", Tk_Offset(PixmapMaster, bgUid), 0},
#endif
    {TK_CONFIG_STRING, "-data", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, dataString), TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-file", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, fileString), TK_CONFIG_NULL_OK},
#if 0
    {TK_CONFIG_UID, "-foreground", (char *) NULL, (char *) NULL,
	"#000000", Tk_Offset(PixmapMaster, fgUid), 0},
#endif

    {TK_CONFIG_UID, "-id", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, id), TK_CONFIG_NULL_OK},

#if 0
    {TK_CONFIG_STRING, "-maskdata", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, maskDataString),
	TK_CONFIG_NULL_OK},
    {TK_CONFIG_STRING, "-maskfile", (char *) NULL, (char *) NULL,
	(char *) NULL, Tk_Offset(PixmapMaster, maskFileString),
	TK_CONFIG_NULL_OK},
#endif
    {TK_CONFIG_END, (char *) NULL, (char *) NULL, (char *) NULL,
	(char *) NULL, 0, 0}
};

/*
 * Prototypes for procedures used only locally in this file:
 */

static char *		ErrorCode _ANSI_ARGS_((int code));
static int		GetXpmData _ANSI_ARGS_((Tcl_Interp *interp,
			    PixmapMaster *masterPtr));
static int		ImgXpmCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, int argc, char **argv));
static void		ImgXpmCmdDeletedProc _ANSI_ARGS_((
			    ClientData clientData));
static void		ImgXpmConfigureInstance _ANSI_ARGS_((
			    PixmapInstance *instancePtr));
static int		ImgXpmConfigureMaster _ANSI_ARGS_((
			    PixmapMaster *masterPtr, int argc, char **argv,
			    int flags));

static Tcl_HashTable xpmTable;
static int xpmTableInited = 0;


/*
 *----------------------------------------------------------------------
 *
 * ImgXpmCreate --
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
ImgXpmCreate(interp, name, argc, argv, typePtr, master, clientDataPtr)
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
    masterPtr->imageCmd = Tcl_CreateCommand(interp, name, ImgXpmCmd,
	    (ClientData) masterPtr, ImgXpmCmdDeletedProc);

    masterPtr->fileString = NULL;
    masterPtr->dataString = NULL;
    masterPtr->id = NULL;
    masterPtr->instancePtr = NULL;
    masterPtr->xpmImage = NULL;

    if (ImgXpmConfigureMaster(masterPtr, argc, argv, 0) != TCL_OK) {
	ImgXpmDelete((ClientData) masterPtr);
	return TCL_ERROR;
    }
    *clientDataPtr = (ClientData) masterPtr;
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmConfigureMaster --
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
ImgXpmConfigureMaster(masterPtr, argc, argv, flags)
    PixmapMaster *masterPtr;	/* Pointer to data structure describing
				 * overall pixmap image to (reconfigure). */
    int argc;			/* Number of entries in argv. */
    char **argv;		/* Pairs of configuration options for image. */
    int flags;			/* Flags to pass to Tk_ConfigureWidget,
				 * such as TK_CONFIG_ARGV_ONLY. */
{
    PixmapInstance *instancePtr;

    if (Tk_ConfigureWidget(masterPtr->interp, Tk_MainWindow(masterPtr->interp),
	    configSpecs, argc, argv, (char *) masterPtr, flags)
	    != TCL_OK) {
	return TCL_ERROR;
    }

    /*
     * Parse the pixmap and/or mask to create binary data.  Make sure that
     * the pixmap and mask have the same dimensions.
     */
    if (masterPtr->xpmImage != NULL) {
	ckfree((char*)masterPtr->xpmImage);
	masterPtr->xpmImage = NULL;
    }

    if (masterPtr->id != NULL ||
	masterPtr->dataString != NULL ||
	masterPtr->fileString != NULL) {
	if (GetXpmData(masterPtr->interp, masterPtr) != TCL_OK) {
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
	ImgXpmConfigureInstance(instancePtr);
    }

    if (masterPtr->xpmImage) {
	Tk_ImageChanged(masterPtr->tkMaster, 0, 0,
	    masterPtr->xpmImage->width, masterPtr->xpmImage->height,
	    masterPtr->xpmImage->width, masterPtr->xpmImage->height);
    } else {
	Tk_ImageChanged(masterPtr->tkMaster, 0, 0, 0, 0, 0, 0);
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmConfigureInstance --
 *
 *	This procedure is called to create displaying information for
 *	a pixmap image instance based on the configuration information
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
ImgXpmConfigureInstance(instancePtr)
    PixmapInstance *instancePtr;	/* Instance to reconfigure. */
{
    PixmapMaster *masterPtr = instancePtr->masterPtr;

#ifdef IOI_DEBUG
    TkWindow * winPtr = instancePtr->tkwin;
#endif

    int xpmCode;
    XGCValues gcValues;
    GC gc;
    unsigned int mask;
    XpmAttributes xpm_attributes;

    if (instancePtr->pixmap != None) {
	XFreePixmap(Tk_Display(instancePtr->tkwin), instancePtr->pixmap);
	instancePtr->pixmap = None;
    }
    if (instancePtr->mask != None) {
	XFreePixmap(Tk_Display(instancePtr->tkwin), instancePtr->mask);
	instancePtr->mask = None;
    }

    if (masterPtr->xpmImage != NULL) {
	if (Tk_WindowId(instancePtr->tkwin) == None) {
	    Tk_MakeWindowExist(instancePtr->tkwin);
	}

	xpm_attributes.visual	 = Tk_Visual(instancePtr->tkwin);
	xpm_attributes.colormap	 = Tk_Colormap(instancePtr->tkwin);
	xpm_attributes.depth	 = Tk_Depth(instancePtr->tkwin);
	xpm_attributes.closeness = 65535;	/* To prevent running out of
						 * colors, Suggested by 
						 * canedo@taec.ENET.dec.com.
						 */
	xpm_attributes.valuemask = 
	  XpmCloseness|XpmVisual|XpmColormap|XpmDepth;
	
	if ((xpmCode = XpmCreatePixmapFromXpmImage(
		Tk_Display(instancePtr->tkwin),
		Tk_WindowId(instancePtr->tkwin),
		masterPtr->xpmImage,
		&instancePtr->pixmap, &instancePtr->mask,
		&xpm_attributes)) != BitmapSuccess) {

	    XpmFreeAttributes(&xpm_attributes);
	    instancePtr->pixmap = None;
	    instancePtr->mask = None;
	    goto error;
	}
	XpmFreeAttributes(&xpm_attributes);
    }

    if (masterPtr->xpmImage != NULL) {
	mask = GCGraphicsExposures|GCClipMask;
	gcValues.graphics_exposures = False;
	gcValues.clip_mask = instancePtr->mask;

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

    Tcl_AddErrorInfo(masterPtr->interp, "\n error code: \"");
    Tcl_AddErrorInfo(masterPtr->interp, ErrorCode(xpmCode));
    Tcl_AddErrorInfo(masterPtr->interp, "\"");
    Tcl_AddErrorInfo(masterPtr->interp, "\n    (while configuring image \"");
    Tcl_AddErrorInfo(masterPtr->interp, Tk_NameOfImage(masterPtr->tkMaster));
    Tcl_AddErrorInfo(masterPtr->interp, "\")");
    Tk_BackgroundError(masterPtr->interp);
}

/*
 *----------------------------------------------------------------------
 *
 * GetXpmData --
 *
 *	Given a file name or ASCII string, this procedure parses the
 *	file or string contents to produce binary data for a pixmap.
 *
 * Results:
 *	If the pixmap description was parsed successfully then the
 *	return value is an XpmImage image data structure that contains all
 *	necessary information about the Pixmap image.
 *
 * Side effects:
 *	When succeeds, an XpmImage structure is created if 
 *
 *----------------------------------------------------------------------
 */
static int
GetXpmData(interp, masterPtr)
    Tcl_Interp *interp;			/* For reporting errors. */
    PixmapMaster *masterPtr;
{
    int code, xpmCode;
    XpmImage * xpmImage = (XpmImage*)ckalloc(sizeof(XpmImage));
    char * fileName;
    char tmpFileName[256];

    if (masterPtr->id != NULL) {
	Tcl_HashEntry * hashPtr;
	char ** data;

	if (xpmTableInited == 0) {
	    hashPtr = NULL;
	} else {
	    hashPtr = Tcl_FindHashEntry(&xpmTable, (char*)masterPtr->id);
	}

	if (hashPtr == NULL) {
	    Tcl_AppendResult(interp, "unknown pixmap ID \"", masterPtr->id,
		"\"",
		NULL);
	    code = TCL_ERROR;
	    goto done;
	} else {
	    data = (char**)Tcl_GetHashValue(hashPtr);

	    if ((xpmCode=XpmCreateXpmImageFromData(data, xpmImage,
		&masterPtr->xpmInfo)) == BitmapSuccess) {
		code = TCL_OK;
	    } else {
		Tcl_AppendResult(interp, "internal error, ",
		    "cannot create XpmImage from -id \"", masterPtr->id,
		    "\", error code \"", ErrorCode(xpmCode), "\"", NULL);
		code = TCL_ERROR;
	    }
	    goto done;
	}
    }

    if (masterPtr->dataString != NULL) {
	int pid;
	FILE * f;
	pid = getpid();

	sprintf(tmpFileName, "/tmp/tix-pixmap-%d", pid);
	if ((f = fopen(tmpFileName, "w+")) != NULL) {
	    fprintf(f, "%s", masterPtr->dataString);
	    fileName = tmpFileName;
	    fclose(f);
	}
    } else {
	fileName = masterPtr->fileString;
    }

    if ((xpmCode=XpmReadFileToXpmImage(fileName, xpmImage,&masterPtr->xpmInfo))
	== BitmapSuccess) {

	code = TCL_OK;
    } else {
	Tcl_AppendResult(interp, "internal error, ",
	    "cannot read XPM image, error code \"", 
	     ErrorCode(xpmCode), "\"", NULL);

	code = TCL_ERROR;
    }

    if (fileName == tmpFileName) {
	unlink(tmpFileName);
    }

  done:

    if (code == TCL_ERROR) {
	ckfree((char*)xpmImage);
    } else {
	masterPtr->xpmImage = xpmImage;
    }

    return code;
}

/*
 *--------------------------------------------------------------
 *
 * ImgXpmCmd --
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
ImgXpmCmd(clientData, interp, argc, argv)
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
	    code = ImgXpmConfigureMaster(masterPtr, argc-2, argv+2,
		    TK_CONFIG_ARGV_ONLY);
	}
	return code;
    }

/* error */

    Tcl_AppendResult(interp, "bad option \"", argv[1],
	"\": must be cget or configure", (char *) NULL);
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmGet --
 *
 *	This procedure is called for each use of a pixmap image in a
 *	widget.
 *
 * Results:
 *	The return value is a token for the instance, which is passed
 *	back to us in calls to ImgXpmDisplay and ImgXpmFree.
 *
 * Side effects:
 *	A data structure is set up for the instance (or, an existing
 *	instance is re-used for the new one).
 *
 *----------------------------------------------------------------------
 */

static ClientData
ImgXpmGet(tkwin, masterData)
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
    instancePtr->pixmap = None;
    instancePtr->mask = None;
    instancePtr->gc = None;
    instancePtr->nextPtr = masterPtr->instancePtr;
    masterPtr->instancePtr = instancePtr;
    ImgXpmConfigureInstance(instancePtr);

    /*
     * If this is the first instance, must set the size of the image.
     */
    if (instancePtr->nextPtr == NULL) {
	if (masterPtr->xpmImage) {
	    Tk_ImageChanged(masterPtr->tkMaster, 0, 0,
	        masterPtr->xpmImage->width, masterPtr->xpmImage->height,
	        masterPtr->xpmImage->width, masterPtr->xpmImage->height);
	} else {
	    Tk_ImageChanged(masterPtr->tkMaster, 0, 0, 0, 0, 0, 0);
	}
    }

    return (ClientData) instancePtr;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmDisplay --
 *
 *	This procedure is invoked to draw a pixmap image.
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
ImgXpmDisplay(clientData, display, drawable, imageX, imageY, width,
	height, drawableX, drawableY)
    ClientData clientData;	/* Pointer to PixmapInstance structure for
				 * for instance to be displayed. */
    Display *display;		/* Display on which to draw image. */
    Drawable drawable;		/* Pixmap or window in which to draw image. */
    int imageX, imageY;		/* Upper-left corner of region within image
				 * to draw. */
    int width, height;		/* Dimensions of region within image to draw.*/
    int drawableX, drawableY;	/* Coordinates within drawable that
				 * correspond to imageX and imageY. */
{
    PixmapInstance *instancePtr = (PixmapInstance *) clientData;

    /*
     * If there's no graphics context, it means that an error occurred
     * while creating the image instance so it can't be displayed.
     */

    if (instancePtr->gc == None) {
	return;
    }

    /*
     * We always use masking: modify the mask origin within
     * the graphics context to line up with the image's origin.
     * Then draw the image and reset the clip origin, if there's
     * a mask.
     */

    XSetClipOrigin(display, instancePtr->gc, drawableX - imageX,
	drawableY - imageY);
    XCopyArea(display, instancePtr->pixmap, drawable, instancePtr->gc,
	imageX, imageY, (unsigned) width, (unsigned) height,
	drawableX, drawableY);
    XSetClipOrigin(display, instancePtr->gc, 0, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmFree --
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
ImgXpmFree(clientData, display)
    ClientData clientData;	/* Pointer to PixmapInstance structure for
				 * for instance to be displayed. */
    Display *display;		/* Display containing window that used image.*/
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

#if 0
    if (instancePtr->fg != NULL) {
	Tk_FreeColor(instancePtr->fg);
    }
    if (instancePtr->bg != NULL) {
	Tk_FreeColor(instancePtr->bg);
    }
#endif
    if (instancePtr->pixmap != None) {
	XFreePixmap(display, instancePtr->pixmap);
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
 * ImgXpmDelete --
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
ImgXpmDelete(masterData)
    ClientData masterData;	/* Pointer to PixmapMaster structure for
				 * image.  Must not have any more instances. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) masterData;

    if (masterPtr->instancePtr != NULL) {
	panic("tried to delete pixmap image when instances still exist");
    }
    masterPtr->tkMaster = NULL;
    if (masterPtr->imageCmd != NULL) {
	Tcl_DeleteCommand(masterPtr->interp,
		Tcl_GetCommandName(masterPtr->interp, masterPtr->imageCmd));
    }
    if (masterPtr->xpmImage != NULL) {
	ckfree((char*)masterPtr->xpmImage);
    }
    Tk_FreeOptions(configSpecs, (char *) masterPtr, (Display *) NULL, 0);
    ckfree((char *) masterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgXpmCmdDeletedProc --
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
ImgXpmCmdDeletedProc(clientData)
    ClientData clientData;	/* Pointer to PixmapMaster structure for
				 * image. */
{
    PixmapMaster *masterPtr = (PixmapMaster *) clientData;

    masterPtr->imageCmd = NULL;
    if (masterPtr->tkMaster != NULL) {
	Tk_DeleteImage(masterPtr->interp, Tk_NameOfImage(masterPtr->tkMaster));
    }
}

static char *
ErrorCode(code)
   int code;
{
    switch (code) {
      case XpmColorError:
	return "XpmColorError";

      case XpmSuccess:      
 	return "XpmSuccess";      

      case XpmOpenFailed:
 	return "XpmOpenFailed";

      case XpmFileInvalid:
 	return "XpmFileInvalid"; 

      case XpmNoMemory:    
 	return "XpmNoMemory";    

      case XpmColorFailed: 
 	return "XpmColorFailed";

      default:
	return "unknown error";
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tix_DefinePixmap
 *
 *	Define an XPM data structure with an unique name
 *
 * Results:
 *	None.
 *
 * Side effects:
 *
 *----------------------------------------------------------------------
 */
int
Tix_DefinePixmap(interp, name, data)
    Tcl_Interp * interp;
    Tk_Uid name;		/* Name to use for bitmap.  Must not already
				 * be defined as a bitmap. */
    char **data;
{
    int new;
    Tcl_HashEntry *hshPtr;

    if (!xpmTableInited) {
	xpmTableInited = 1;
	Tcl_InitHashTable(&xpmTable, TCL_ONE_WORD_KEYS);
    }

    hshPtr = Tcl_CreateHashEntry(&xpmTable, name, &new);
    if (!new) {
        Tcl_AppendResult(interp, "bitmap \"", name,
		"\" is already defined", (char *) NULL);
	return TCL_ERROR;
    }
    Tcl_SetHashValue(hshPtr, (char*)data);
    return TCL_OK;
}
