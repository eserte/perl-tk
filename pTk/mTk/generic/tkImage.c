/*
 * tkImage.c --
 *
 *	This module implements the image protocol, which allows lots
 *	of different kinds of images to be used in lots of different
 *	widgets.
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * Copyright (c) 1994-1996 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: tkImage.c,v 1.2 1998/09/14 18:23:12 stanton Exp $
 */

#include "tkInt.h"
#include "tkPort.h"

/*
 * bltList.h --
 *
 * Copyright 1993-1996 by AT&T Bell Laboratories.
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for any purpose and without fee is hereby
 * granted, provided that the above copyright notice appear in all
 * copies and that both that the copyright notice and warranty
 * disclaimer appear in supporting documentation, and that the
 * names of AT&T Bell Laboratories any of their entities not be used
 * in advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission.
 *
 * AT&T disclaims all warranties with regard to this software, including
 * all implied warranties of merchantability and fitness.  In no event
 * shall AT&T be liable for any special, indirect or consequential
 * damages or any damages whatsoever resulting from loss of use, data
 * or profits, whether in an action of contract, negligence or other
 * tortuous action, arising out of or in connection with the use or
 * performance of this software.
 *
 */
#ifndef _BLT_LIST_H
#define _BLT_LIST_H

struct Blt_List;
/*
 * A Blt_ListItem is the container structure for the Blt_List.
 */
typedef struct Blt_ListItem {
    struct Blt_ListItem *prevPtr;	/* Link to the previous item */
    struct Blt_ListItem *nextPtr;	/* Link to the next item */
    Tk_Uid keyPtr;		/* Pointer to the (character string) key */
    ClientData clientData;	/* Pointer to the data object */
    struct Blt_List *listPtr;
} Blt_ListItem;

/*
 * A Blt_List is a doubly chained list structure.
 */
typedef struct Blt_List {
    Blt_ListItem *headPtr;	/* Pointer to first element in list */
    Blt_ListItem *tailPtr;	/* Pointer to last element in list */
    int numEntries;		/* Number of elements in list */
    int type;			/* Type of keys in list */
} Blt_List;

static void Blt_InitList _ANSI_ARGS_((Blt_List *listPtr, int type));
static Blt_ListItem *Blt_NewItem _ANSI_ARGS_((char *key));
static void Blt_LinkAfter _ANSI_ARGS_((Blt_List *listPtr,
	Blt_ListItem *itemPtr, Blt_ListItem *afterPtr));
static void Blt_FreeItem _ANSI_ARGS_((Blt_ListItem *itemPtr));
static void TileChangedProc _ANSI_ARGS_((ClientData clientData,
	int x, int y, int width, int height, int imageWidth,
	int imageHeight));

#define Blt_FirstListItem(listPtr)	((listPtr)->headPtr)
#define Blt_NextItem(itemPtr) 		((itemPtr)->nextPtr)
#define Blt_GetItemValue(itemPtr)  	((itemPtr)->clientData)
#define Blt_SetItemValue(itemPtr, valuePtr) \
	((itemPtr)->clientData = (ClientData)(valuePtr))

#endif /* _BLT_LIST_H */

/*
 * Each call to Tk_GetImage returns a pointer to one of the following
 * structures, which is used as a token by clients (widgets) that
 * display images.
 */

typedef struct Image {
    Tk_Window tkwin;		/* Window passed to Tk_GetImage (needed to
				 * "re-get" the image later if the manager
				 * changes). */
    Display *display;		/* Display for tkwin.  Needed because when
				 * the image is eventually freed tkwin may
				 * not exist anymore. */
    struct ImageMaster *masterPtr;
				/* Master for this image (identifiers image
				 * manager, for example). */
    ClientData instanceData;
				/* One word argument to pass to image manager
				 * when dealing with this image instance. */
    Tk_ImageChangedProc *changeProc;
				/* Code in widget to call when image changes
				 * in a way that affects redisplay. */
    ClientData widgetClientData;
				/* Argument to pass to changeProc. */
    struct Image *nextPtr;	/* Next in list of all image instances
				 * associated with the same name. */

} Image;

/*
 * For each image master there is one of the following structures,
 * which represents a name in the image table and all of the images
 * instantiated from it.  Entries in mainPtr->imageTable point to
 * these structures.
 */

typedef struct ImageMaster {
    Tk_ImageType *typePtr;	/* Information about image type.  NULL means
				 * that no image manager owns this image:  the
				 * image was deleted. */
    ClientData masterData;	/* One-word argument to pass to image mgr
				 * when dealing with the master, as opposed
				 * to instances. */
    int width, height;		/* Last known dimensions for image. */
    Tcl_HashTable *tablePtr;	/* Pointer to hash table containing image
				 * (the imageTable field in some TkMainInfo
				 * structure). */
    Tcl_HashEntry *hPtr;	/* Hash entry in mainPtr->imageTable for
				 * this structure (used to delete the hash
				 * entry). */
    Image *instancePtr;		/* Pointer to first in list of instances
				 * derived from this name. */
} ImageMaster;

/*
 * The following variable points to the first in a list of all known
 * image types.
 */

static Tk_ImageType *imageTypeList = NULL;

/*
 * Prototypes for local procedures:
 */

static void	DeleteImage _ANSI_ARGS_((ImageMaster *masterPtr));


/*
 *----------------------------------------------------------------------
 *
 * Tk_CreateImageType --
 *
 *	This procedure is invoked by an image manager to tell Tk about
 *	a new kind of image and the procedures that manage the new type.
 *	The procedure is typically invoked during Tcl_AppInit.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The new image type is entered into a table used in the "image
 *	create" command.
 *
 *----------------------------------------------------------------------
 */

void
Tk_CreateImageType(typePtr)
    Tk_ImageType *typePtr;	/* Structure describing the type.  All of
				 * the fields except "nextPtr" must be filled
				 * in by caller.  Must not have been passed
				 * to Tk_CreateImageType previously. */
{
    typePtr->nextPtr = imageTypeList;
    imageTypeList = typePtr;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_ImageObjCmd --
 *
 *	This procedure is invoked to process the "image" Tcl command.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

int
Tk_ImageObjCmd(clientData, interp, argc, objv)
    ClientData clientData;	/* Main window associated with interpreter. */
    Tcl_Interp *interp;		/* Current interpreter. */
    int argc;			/* Number of arguments. */
    Tcl_Obj *CONST objv[];	/* Argument strings. */
{
    TkWindow *winPtr = (TkWindow *) clientData;
    int c, i, new, firstOption;
    size_t length;
    Tk_ImageType *typePtr;
    ImageMaster *masterPtr;
    Image *imagePtr;
    Tcl_HashEntry *hPtr;
    Tcl_HashSearch search;
    char idString[30], *name;
    static int id = 0;
    static char **strv = NULL;

    if (argc < 2) {
	Tcl_WrongNumArgs(interp, 1, objv, "option ?arg arg ...?");
	return TCL_ERROR;
    }
    if (strv) {
	ckfree((char *) strv);
    }
    strv = (char **) ckalloc((argc+1) * sizeof(char *));
    strv[argc] = NULL;
    for (i = 0; i < argc; i++) {
	strv[i]=Tcl_GetStringFromObj(objv[i], (int *) NULL);
    }
    c = strv[1][0];
    length = strlen(strv[1]);
    if ((c == 'c') && (strncmp(strv[1], "create", length) == 0)) {
	if (argc < 3) {
	    Tcl_WrongNumArgs(interp, 2, objv, "type ?name? ?options?");
	    return TCL_ERROR;
	}
	c = strv[2][0];

	/*
	 * Look up the image type.
	 */

	for (typePtr = imageTypeList; typePtr != NULL;
		typePtr = typePtr->nextPtr) {
	    if ((c == typePtr->name[0])
		    && (strcmp(strv[2], typePtr->name) == 0)) {
		break;
	    }
	}
	if (typePtr == NULL) {
	    Tcl_AppendResult(interp, "image type \"", strv[2],
		    "\" doesn't exist", (char *) NULL);
	    return TCL_ERROR;
	}

	/*
	 * Figure out a name to use for the new image.
	 */

	if ((argc == 3) || (strv[3][0] == '-')) {
	    id++;
	    sprintf(idString, "image%d", id);
	    name = idString;
	    firstOption = 3;
	} else {
	    name = strv[3];
	    firstOption = 4;
	}

	/*
	 * Create the data structure for the new image.
	 */

	hPtr = Tcl_CreateHashEntry(&winPtr->mainPtr->imageTable, name, &new);
	if (new) {
	    masterPtr = (ImageMaster *) ckalloc(sizeof(ImageMaster));
	    masterPtr->typePtr = NULL;
	    masterPtr->masterData = NULL;
	    masterPtr->width = masterPtr->height = 1;
	    masterPtr->tablePtr = &winPtr->mainPtr->imageTable;
	    masterPtr->hPtr = hPtr;
	    masterPtr->instancePtr = NULL;
	    Tcl_SetHashValue(hPtr, masterPtr);
	} else {
	    /*
	     * An image already exists by this name.  Disconnect the
	     * instances from the master.
	     */

	    masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	    if (masterPtr->typePtr != NULL) {
		for (imagePtr = masterPtr->instancePtr; imagePtr != NULL;
			imagePtr = imagePtr->nextPtr) {
		   (*masterPtr->typePtr->freeProc)(
			   imagePtr->instanceData, imagePtr->display);
		   if (imagePtr->changeProc != NULL) {
		     (*imagePtr->changeProc)(imagePtr->widgetClientData, 0, 0,
			masterPtr->width, masterPtr->height, masterPtr->width,
			masterPtr->height);
		   }
		}
		(*masterPtr->typePtr->deleteProc)(masterPtr->masterData);
		masterPtr->typePtr = NULL;
	    }
	}

	/*
	 * Call the image type manager so that it can perform its own
	 * initialization, then re-"get" for any existing instances of
	 * the image.
	 */

	if ((*typePtr->createProc)(interp, name, argc-firstOption,
		(Tcl_Obj **)(objv+firstOption), typePtr, (Tk_ImageMaster) masterPtr,
		&masterPtr->masterData) != TCL_OK) {
	    DeleteImage(masterPtr);
	    return TCL_ERROR;
	}
	masterPtr->typePtr = typePtr;
	for (imagePtr = masterPtr->instancePtr; imagePtr != NULL;
		imagePtr = imagePtr->nextPtr) {
	   imagePtr->instanceData = (*typePtr->getProc)(
		   imagePtr->tkwin, masterPtr->masterData);
	   if (imagePtr->changeProc != NULL) {
	      (*imagePtr->changeProc)(imagePtr->widgetClientData, 0, 0,
		masterPtr->width, masterPtr->height, masterPtr->width,
		masterPtr->height);
	   }
	}
        Tcl_SetObjResult(interp, LangObjectObj( interp, Tcl_GetHashKey(&winPtr->mainPtr->imageTable, hPtr)));
    } else if ((c == 'd') && (strncmp(strv[1], "delete", length) == 0)) {
	for (i = 2; i < argc; i++) {
	    hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, strv[i]);
	    if (hPtr == NULL) {
	    Tcl_AppendResult(interp, "image \"", strv[i],
		    "\" doesn't exist", (char *) NULL);
		return TCL_ERROR;
	    }
	    masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	    DeleteImage(masterPtr);
	}
    } else if ((c == 'h') && (strncmp(strv[1], "height", length) == 0)) {
	if (argc != 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", strv[0],
		    " height name\"", (char *) NULL);
	    return TCL_ERROR;
	}
	hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, strv[2]);
	if (hPtr == NULL) {
	    Tcl_AppendResult(interp, "image \"", strv[2],
		    "\" doesn't exist", (char *) NULL);
	    return TCL_ERROR;
	}
	masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	Tcl_SetIntObj(Tcl_GetObjResult(interp), masterPtr->height);
    } else if ((c == 'n') && (strncmp(strv[1], "names", length) == 0)) {
	if (argc != 2) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", strv[0],
		    " names\"", (char *) NULL);
	    return TCL_ERROR;
	}
	for (hPtr = Tcl_FirstHashEntry(&winPtr->mainPtr->imageTable, &search);
		hPtr != NULL; hPtr = Tcl_NextHashEntry(&search)) {
	    Tcl_ListObjAppendElement(interp, Tcl_GetObjResult(interp),
			LangObjectObj(interp,Tcl_GetHashKey(&winPtr->mainPtr->imageTable, hPtr)));
	}
    } else if ((c == 't') && (strcmp(strv[1], "type") == 0)) {
	if (argc != 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", strv[0],
		    " type name\"", (char *) NULL);
	    return TCL_ERROR;
	}
	hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, strv[2]);
	if (hPtr == NULL) {
	    Tcl_AppendResult(interp, "image \"", strv[2],
		    "\" doesn't exist", (char *) NULL);
	    return TCL_ERROR;
	}
	masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	if (masterPtr->typePtr != NULL) {
	    Tcl_AppendResult(interp, masterPtr->typePtr->name, (char *) NULL);
	}
    } else if ((c == 't') && (strcmp(strv[1], "types") == 0)) {
	if (argc != 2) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", strv[0],
		    " types\"", (char *) NULL);
	    return TCL_ERROR;
	}
	for (typePtr = imageTypeList; typePtr != NULL;
		typePtr = typePtr->nextPtr) {
	    Tcl_AppendElement(interp, typePtr->name);
	}
    } else if ((c == 'w') && (strncmp(strv[1], "width", length) == 0)) {
	if (argc != 3) {
	    Tcl_AppendResult(interp, "wrong # args: should be \"", strv[0],
		    " width name\"", (char *) NULL);
	    return TCL_ERROR;
	}
	hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, strv[2]);
	if (hPtr == NULL) {
	    Tcl_AppendResult(interp, "image \"", strv[2],
		    "\" doesn't exist", (char *) NULL);
	    return TCL_ERROR;
	}
	masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	Tcl_SetIntObj(Tcl_GetObjResult(interp), masterPtr->width);
    } else {
	Tcl_AppendResult(interp, "bad option \"", strv[1],
		"\": must be create, delete, height, names, type, types,",
		" or width", (char *) NULL);
	return TCL_ERROR;
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_ImageChanged --
 *
 *	This procedure is called by an image manager whenever something
 *	has happened that requires the image to be redrawn (some of its
 *	pixels have changed, or its size has changed).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Any widgets that display the image are notified so that they
 *	can redisplay themselves as appropriate.
 *
 *----------------------------------------------------------------------
 */

void
Tk_ImageChanged(imageMaster, x, y, width, height, imageWidth,
	imageHeight)
    Tk_ImageMaster imageMaster;	/* Image that needs redisplay. */
    int x, y;			/* Coordinates of upper-left pixel of
				 * region of image that needs to be
				 * redrawn. */
    int width, height;		/* Dimensions (in pixels) of region of
				 * image to redraw.  If either dimension
				 * is zero then the image doesn't need to
				 * be redrawn (perhaps all that happened is
				 * that its size changed). */
    int imageWidth, imageHeight;/* New dimensions of image. */
{
    ImageMaster *masterPtr = (ImageMaster *) imageMaster;
    Image *imagePtr;

    masterPtr->width = imageWidth;
    masterPtr->height = imageHeight;
    for (imagePtr = masterPtr->instancePtr; imagePtr != NULL;
	    imagePtr = imagePtr->nextPtr) {
	if (imagePtr->changeProc != NULL) {
	  (*imagePtr->changeProc)(imagePtr->widgetClientData, x, y,
	    width, height, imageWidth, imageHeight);
	}
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_NameOfImage --
 *
 *	Given a token for an image master, this procedure returns
 *	the name of the image.
 *
 * Results:
 *	The return value is the string name for imageMaster.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

char *
Tk_NameOfImage(imageMaster)
    Tk_ImageMaster imageMaster;		/* Token for image. */
{
    ImageMaster *masterPtr = (ImageMaster *) imageMaster;

    if (imageMaster == NULL) {
	return "";
    }
    return Tcl_GetHashKey(masterPtr->tablePtr, masterPtr->hPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetImage --
 *
 *	This procedure is invoked by a widget when it wants to use
 *	a particular image in a particular window.
 *
 * Results:
 *	The return value is a token for the image.  If there is no image
 *	by the given name, then NULL is returned and an error message is
 *	left in interp->result.
 *
 * Side effects:
 *	Tk records the fact that the widget is using the image, and
 *	it will invoke changeProc later if the widget needs redisplay
 *	(i.e. its size changes or some of its pixels change).  The
 *	caller must eventually invoke Tk_FreeImage when it no longer
 *	needs the image.
 *
 *----------------------------------------------------------------------
 */

Tk_Image
Tk_GetImage(interp, tkwin, name, changeProc, clientData)
    Tcl_Interp *interp;		/* Place to leave error message if image
				 * can't be found. */
    Tk_Window tkwin;		/* Token for window in which image will
				 * be used. */
    char *name;			/* Name of desired image. */
    Tk_ImageChangedProc *changeProc;
				/* Procedure to invoke when redisplay is
				 * needed because image's pixels or size
				 * changed. */
    ClientData clientData;	/* One-word argument to pass to damageProc. */
{
    Tcl_HashEntry *hPtr;
    ImageMaster *masterPtr;
    Image *imagePtr;

    hPtr = Tcl_FindHashEntry(&((TkWindow *) tkwin)->mainPtr->imageTable, name);
    if (hPtr == NULL) {
	goto noSuchImage;
    }
    masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
    if (masterPtr->typePtr == NULL) {
	goto noSuchImage;
    }
    imagePtr = (Image *) ckalloc(sizeof(Image));
    imagePtr->tkwin = tkwin;
    imagePtr->display = Tk_Display(tkwin);
    imagePtr->masterPtr = masterPtr;
    imagePtr->instanceData =
	    (*masterPtr->typePtr->getProc)(tkwin, masterPtr->masterData);
    imagePtr->changeProc = changeProc;
    imagePtr->widgetClientData = clientData;
    imagePtr->nextPtr = masterPtr->instancePtr;
    masterPtr->instancePtr = imagePtr;
    return (Tk_Image) imagePtr;

    noSuchImage:
    Tcl_AppendResult(interp, "image \"", name, "\" doesn't exist",
	    (char *) NULL);
    return NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_FreeImage --
 *
 *	This procedure is invoked by a widget when it no longer needs
 *	an image acquired by a previous call to Tk_GetImage.  For each
 *	call to Tk_GetImage there must be exactly one call to Tk_FreeImage.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The association between the image and the widget is removed.
 *
 *----------------------------------------------------------------------
 */

void
Tk_FreeImage(image)
    Tk_Image image;		/* Token for image that is no longer
				 * needed by a widget. */
{
    Image *imagePtr = (Image *) image;
    ImageMaster *masterPtr = imagePtr->masterPtr;
    Image *prevPtr;

    /*
     * Clean up the particular instance.
     */

    if (masterPtr->typePtr != NULL) {
	(*masterPtr->typePtr->freeProc)(imagePtr->instanceData,
		imagePtr->display);
    }
    prevPtr = masterPtr->instancePtr;
    if (prevPtr == imagePtr) {
	masterPtr->instancePtr = imagePtr->nextPtr;
    } else {
	while (prevPtr->nextPtr != imagePtr) {
	    prevPtr = prevPtr->nextPtr;
	}
	prevPtr->nextPtr = imagePtr->nextPtr;
    }
    ckfree((char *) imagePtr);

    /*
     * If there are no more instances left for the master, and if the
     * master image has been deleted, then delete the master too.
     */

    if ((masterPtr->typePtr == NULL) && (masterPtr->instancePtr == NULL)) {
        if (masterPtr->hPtr != NULL) {
	    Tcl_DeleteHashEntry(masterPtr->hPtr);
        }
	ckfree((char *) masterPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_PostscriptImage --
 *
 *	This procedure is called by widgets that contain images in order
 *	to redisplay an image on the screen or an off-screen pixmap.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image's manager is notified, and it redraws the desired
 *	portion of the image before returning.
 *
 *----------------------------------------------------------------------
 */

int
Tk_PostscriptImage(image, interp, tkwin, psinfo, x, y, width, height, prepass)
    Tk_Image image;		/* Token for image to redisplay. */
    Tcl_Interp *interp;
    Tk_Window tkwin;
    Tk_PostscriptInfo psinfo;	/* postscript info */
    int x, y;			/* Upper-left pixel of region in image that
				 * needs to be redisplayed. */
    int width, height;		/* Dimensions of region to redraw. */
    int prepass;
{
    int result;
    XImage *ximage;
    Pixmap pmap;
    GC newGC;
    XGCValues gcValues;

/*    Image *imagePtr = (Image *) image;

    if (imagePtr->masterPtr->typePtr->postscriptProc != NULL) {
	return imagePtr->masterPtr->typePtr->postscriptProc(
		(ClientData) ((Image *)image)->masterPtr, interp, tkwin, psinfo,
		x, y, width, height, prepass);
    }*/

    if (prepass) {
	return TCL_OK;
    }

    /*
     * Create a Pixmap, tell the image to redraw itself there, and then
     * generate an XImage from the Pixmap.  We can then read pixel
     * values out of the XImage.
     */

    pmap = Tk_GetPixmap(Tk_Display(tkwin), Tk_WindowId(tkwin),
                        width, height, Tk_Depth(tkwin));

    gcValues.foreground = WhitePixelOfScreen(Tk_Screen(tkwin));
    newGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
    if (newGC != None) {
	XFillRectangle(Tk_Display(tkwin), pmap, newGC,
		0, 0, width, height);
	Tk_FreeGC(Tk_Display(tkwin), newGC);
    }

    Tk_RedrawImage(image, x, y, width, height, pmap, 0, 0);

    ximage = XGetImage(Tk_Display(tkwin), pmap, 0, 0, width, height,
                       AllPlanes, ZPixmap);

    Tk_FreePixmap(Tk_Display(tkwin), pmap);

    if (ximage == NULL) {
	/* The XGetImage() function is apparently not
	 * implemented on this system. Just ignore it.
	 */
	return TCL_OK;
    }
    result = TkPostscriptImage(interp, tkwin, psinfo, ximage, x, y,
	    width, height);

    XDestroyImage(ximage);
    return result;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_RedrawImage --
 *
 *	This procedure is called by widgets that contain images in order
 *	to redisplay an image on the screen or an off-screen pixmap.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image's manager is notified, and it redraws the desired
 *	portion of the image before returning.
 *
 *----------------------------------------------------------------------
 */

void
Tk_RedrawImage(image, imageX, imageY, width, height, drawable,
	drawableX, drawableY)
    Tk_Image image;		/* Token for image to redisplay. */
    int imageX, imageY;		/* Upper-left pixel of region in image that
				 * needs to be redisplayed. */
    int width, height;		/* Dimensions of region to redraw. */
    Drawable drawable;		/* Drawable in which to display image
				 * (window or pixmap).  If this is a pixmap,
				 * it must have the same depth as the window
				 * used in the Tk_GetImage call for the
				 * image. */
    int drawableX, drawableY;	/* Coordinates in drawable that correspond
				 * to imageX and imageY. */
{
    Image *imagePtr = (Image *) image;

    if (imagePtr->masterPtr->typePtr == NULL) {
	/*
	 * No master for image, so nothing to display.
	 */

	return;
    }

    /*
     * Clip the redraw area to the area of the image.
     */

    if (imageX < 0) {
	width += imageX;
	drawableX -= imageX;
	imageX = 0;
    }
    if (imageY < 0) {
	height += imageY;
	drawableY -= imageY;
	imageY = 0;
    }
    if ((imageX + width) > imagePtr->masterPtr->width) {
	width = imagePtr->masterPtr->width - imageX;
    }
    if ((imageY + height) > imagePtr->masterPtr->height) {
	height = imagePtr->masterPtr->height - imageY;
    }
    (*imagePtr->masterPtr->typePtr->displayProc)(
	    imagePtr->instanceData, imagePtr->display, drawable,
	    imageX, imageY, width, height, drawableX, drawableY);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_SizeOfImage --
 *
 *	This procedure returns the current dimensions of an image.
 *
 * Results:
 *	The width and height of the image are returned in *widthPtr
 *	and *heightPtr.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

void
Tk_SizeOfImage(image, widthPtr, heightPtr)
    Tk_Image image;		/* Token for image whose size is wanted. */
    int *widthPtr;		/* Return width of image here. */
    int *heightPtr;		/* Return height of image here. */
{
    Image *imagePtr = (Image *) image;

    *widthPtr = imagePtr->masterPtr->width;
    *heightPtr = imagePtr->masterPtr->height;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_DeleteImage --
 *
 *	Given the name of an image, this procedure destroys the
 *	image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image is destroyed; existing instances will display as
 *	blank areas.  If no such image exists then the procedure does
 *	nothing.
 *
 *----------------------------------------------------------------------
 */

void
Tk_DeleteImage(interp, name)
    Tcl_Interp *interp;		/* Interpreter in which the image was
				 * created. */
    char *name;			/* Name of image. */
{
    Tcl_HashEntry *hPtr;
    TkWindow *winPtr;

    winPtr = (TkWindow *) Tk_MainWindow(interp);
    if (winPtr == NULL) {
	return;
    }
    hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, name);
    if (hPtr == NULL) {
	return;
    }
    DeleteImage((ImageMaster *) Tcl_GetHashValue(hPtr));
}

/*
 *----------------------------------------------------------------------
 *
 * DeleteImage --
 *
 *	This procedure is responsible for deleting an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The connection is dropped between instances of this image and
 *	an image master.  Image instances will redisplay themselves
 *	as empty areas, but existing instances will not be deleted.
 *
 *----------------------------------------------------------------------
 */

static void
DeleteImage(masterPtr)
    ImageMaster *masterPtr;	/* Pointer to main data structure for image. */
{
    Image *imagePtr;
    Tk_ImageType *typePtr;

    typePtr = masterPtr->typePtr;
    masterPtr->typePtr = NULL;
    if (typePtr != NULL) {
	for (imagePtr = masterPtr->instancePtr; imagePtr != NULL;
		imagePtr = imagePtr->nextPtr) {
	   (*typePtr->freeProc)(imagePtr->instanceData,
		   imagePtr->display);
	   (*imagePtr->changeProc)(imagePtr->widgetClientData, 0, 0,
		    masterPtr->width, masterPtr->height, masterPtr->width,
		    masterPtr->height);
	}
	(*typePtr->deleteProc)(masterPtr->masterData);
    }
    if (masterPtr->instancePtr == NULL) {
        if (masterPtr->hPtr != NULL) {
	    Tcl_DeleteHashEntry(masterPtr->hPtr);
	    masterPtr->hPtr = NULL;
        }
	ckfree((char *) masterPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkDeleteAllImages --
 *
 *	This procedure is called when an application is deleted.  It
 *	calls back all of the managers for all images so that they
 *	can cleanup, then it deletes all of Tk's internal information
 *	about images.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	All information for all images gets deleted.
 *
 *----------------------------------------------------------------------
 */

void
TkDeleteAllImages(mainPtr)
    TkMainInfo *mainPtr;	/* Structure describing application that is
				 * going away. */
{
    Tcl_HashSearch search;
    Tcl_HashEntry *hPtr;
    ImageMaster *masterPtr;

    for (hPtr = Tcl_FirstHashEntry(&mainPtr->imageTable, &search);
	    hPtr != NULL; hPtr = Tcl_NextHashEntry(&search)) {
	masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
	DeleteImage(masterPtr);
    }
    Tcl_DeleteHashTable(&mainPtr->imageTable);
}

/*
 * bltTile.c --
 *
 *	This module implements a utility to convert images into
 *	tiles.
 *
 * Copyright 1995-1996 by AT&T Bell Laboratories.
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for any purpose and without fee is hereby
 * granted, provided that the above copyright notice appear in all
 * copies and that both that the copyright notice and warranty
 * disclaimer appear in supporting documentation, and that the
 * names of AT&T Bell Laboratories any of their entities not be used
 * in advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission.
 *
 * AT&T disclaims all warranties with regard to this software, including
 * all implied warranties of merchantability and fitness.  In no event
 * shall AT&T be liable for any special, indirect or consequential
 * damages or any damages whatsoever resulting from loss of use, data
 * or profits, whether in an action of contract, negligence or other
 * tortuous action, arising out of or in connection with the use or
 * performance of this software.
 *
 */

#define TILE_MAGIC ((unsigned int) 0x46170277)

static Tcl_HashTable tileTable;
static int initialized = 0;

typedef struct {
    Tk_Uid nameId;		/* Identifier of image from which the
				 * tile was generated. */
    Display *display;		/* Display where pixmap was created */
    int depth;			/* Depth of pixmap */
    int screenNum;		/* Screen number of pixmap */

    Pixmap pixmap;		/* Pixmap generated from image */
    Tk_Image image;		/* Token of image */
    int width, height;		/* Dimensions of the tile. */

    Blt_List clients;		/* List of clients sharing this tile */

} TileMaster;

typedef struct {
    Tk_Uid nameId;		/* Identifier of image from which the
				 * tile was generated. */
    Display *display;
} TileKey;


typedef struct {
    unsigned int magic;
    Tk_TileChangedProc *changeProc;
				/* If non-NULL, routine to
				 * call to when tile image changes. */
    ClientData clientData;	/* Data to pass to when calling the above
				 * routine */
    Tk_Item *canvasItem;	/* item pointer (only used for Canvas) */
    TileMaster *masterPtr;	/* Pointer to actual tile information */
    Blt_ListItem *itemPtr;	/* Pointer to client entry in the master's
				 * client list.  Used to delete the client */
} Tile;

/*
 *----------------------------------------------------------------------
 *
 * TileChangedProc
 *
 *	It would be better if Tk checked for NULL proc pointers.
 *
 * Results:
 *	None.
 *
 *----------------------------------------------------------------------
 */
/* ARGSUSED */
static void
TileChangedProc(clientData, x, y, width, height, imageWidth, imageHeight)
    ClientData clientData;
    int x, y, width, height;	/* Not used */
    int imageWidth, imageHeight;
{
    TileMaster *masterPtr = (TileMaster *)clientData;
    Tile *tilePtr;
    Blt_ListItem *itemPtr;

    if (((Image *) masterPtr->image)->masterPtr->typePtr == NULL) {
	if (masterPtr->pixmap != None) {
	    Tk_FreePixmap(masterPtr->display, masterPtr->pixmap);
	}
	masterPtr->pixmap = None;
    } else {
/*	GC newGC;
	XGCValues gcValues;*/
	/*
	 * If the size of the current image differs from the current pixmap,
	 * destroy the pixmap and create a new one of the proper size
	 */
	if ((masterPtr->width != imageWidth) ||
	    (masterPtr->height != imageHeight)) {
	    Pixmap pixmap;
	    Window root;
	
	    if (masterPtr->pixmap != None) {
		Tk_FreePixmap(masterPtr->display, masterPtr->pixmap);
	    }
	    root = RootWindow(masterPtr->display, masterPtr->screenNum);
	    pixmap = Tk_GetPixmap(masterPtr->display, root, imageWidth,
		imageHeight, masterPtr->depth);
	    masterPtr->width = imageWidth;
	    masterPtr->height = imageHeight;
	    masterPtr->pixmap = pixmap;
	}
/*	gcValues.foreground = WhitePixelOfScreen(Tk_Screen(tkwin));
	newGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
	if (newGC != None) {
	    XFillRectangle(masterPtr->display, masterPtr->pixmap, newGC,
		    0, 0, imageWidth, imageHeight);
	    Tk_FreeGC(masterPtr->display, newGC);
	}*/
	Tk_RedrawImage(masterPtr->image, 0, 0, imageWidth, imageHeight,
	    masterPtr->pixmap, 0, 0);
    }
    /*
     * Now call back each of the tile clients to notify them that the
     * pixmap has changed.
     */
    for (itemPtr = Blt_FirstListItem(&(masterPtr->clients)); itemPtr != NULL;
	itemPtr = Blt_NextItem(itemPtr)) {
	tilePtr = (Tile *)Blt_GetItemValue(itemPtr);
	if (tilePtr->changeProc != NULL) {
	    (*tilePtr->changeProc) (tilePtr->clientData, (Tk_Tile)tilePtr,
		    tilePtr->canvasItem);
	}
    }
}


static void
InitTables()
{
    Tcl_InitHashTable(&tileTable, sizeof(TileKey) / sizeof(int));
    initialized = 1;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetTile
 *
 *	Convert the named image into a tile.
 *
 * Results:
 *	If the image is valid, a new tile is returned.  If the name
 *	does not represent a proper image, an error message is left in
 *	interp->result.
 *
 * Side Effects:
 *	Memory and X resources are allocated.  Bookkeeping is
 *	maintained on the tile (i.e. width, height, and name).
 *
 *----------------------------------------------------------------------
 */
Tk_Tile
Tk_GetTile(interp, tkwin, imageName)
    Tcl_Interp *interp;		/* Interpreter to report results back to */
    Tk_Window tkwin;		/* Window on the same display as tile */
    CONST char *imageName;	/* Name of image */
{
    Tcl_HashEntry *hPtr;
    Blt_ListItem *itemPtr;
    Tile *tilePtr;
    int isNew;
    TileKey key;
    TileMaster *masterPtr;

    if ((imageName == NULL) || (*imageName == '\0')) {
	return (Tk_Tile) NULL;
    }
    if (!initialized) {
	InitTables();
    }
    tilePtr = (Tile *)ckalloc(sizeof(Tile));
    memset(tilePtr, 0, sizeof(Tile));
    if (tilePtr == NULL) {
	panic("can't allocate Tile client structure");
    }
    /* Initialize client information (Remember to set the itemPtr) */
    tilePtr->magic = TILE_MAGIC;

    /* Find (or create) the master entry for the tile */
    key.nameId = Tk_GetUid((char *) imageName);
    key.display = Tk_Display(tkwin);
    hPtr = Tcl_CreateHashEntry(&tileTable, (char *)&key, &isNew);

    if (isNew) {
	Tk_Image image;
	int width, height;
	Pixmap pixmap;
	Window root;
	GC newGC;
	XGCValues gcValues;

	masterPtr = (TileMaster *)ckalloc(sizeof(TileMaster));
	if (masterPtr == NULL) {
	    panic("can't allocate Tile master structure");
	}

	/*
	 * Initialize the (master) bookkeeping on the tile.
	 */
	masterPtr->nameId = key.nameId;
	masterPtr->depth = Tk_Depth(tkwin);
	masterPtr->screenNum = Tk_ScreenNumber(tkwin);
	masterPtr->display = Tk_Display(tkwin);

	/*
	 * Get the image. Funnel all change notifications to a single routine.
	 */
	image = Tk_GetImage(interp, tkwin, (char *) imageName, TileChangedProc,
	    (ClientData)masterPtr);
	if (image == NULL) {
	    Tcl_DeleteHashEntry(hPtr);
	    ckfree((char *)masterPtr);
	    ckfree((char *)tilePtr);
	    return NULL;
	}

	/*
	 * Create a pixmap the same size and draw the image into it.
	 */
	Tk_SizeOfImage(image, &width, &height);
	root = RootWindow(masterPtr->display, masterPtr->screenNum);
	pixmap = Tk_GetPixmap(masterPtr->display, root, width, height,
	    masterPtr->depth);
	gcValues.foreground = WhitePixelOfScreen(Tk_Screen(tkwin));
	newGC = Tk_GetGC(tkwin, GCForeground, &gcValues);
	if (newGC != None) {
	    XFillRectangle(Tk_Display(tkwin), pixmap, newGC,
		    0, 0, width, height);
	    Tk_FreeGC(Tk_Display(tkwin), newGC);
	}
	Tk_RedrawImage(image, 0, 0, width, height, pixmap, 0, 0);

	masterPtr->width = width;
	masterPtr->height = height;
	masterPtr->pixmap = pixmap;
	masterPtr->image = image;
	Blt_InitList(&(masterPtr->clients), TCL_ONE_WORD_KEYS);
	Tcl_SetHashValue(hPtr, (ClientData)masterPtr);
    } else {
	masterPtr = (TileMaster *)Tcl_GetHashValue(hPtr);
    }
    itemPtr = Blt_NewItem(key.nameId);
    Blt_SetItemValue(itemPtr, (ClientData)tilePtr);
    Blt_LinkAfter(&(masterPtr->clients), itemPtr, (Blt_ListItem *)NULL);
    tilePtr->itemPtr = itemPtr;
    tilePtr->masterPtr = masterPtr;
    return (Tk_Tile)tilePtr;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_FreeTile
 *
 *	Release the resources associated with the tile.
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Memory and X resources are freed.  Bookkeeping information
 *	about the tile (i.e. width, height, and name) is discarded.
 *
 *----------------------------------------------------------------------
 */
void
Tk_FreeTile(tile)
    Tk_Tile tile;		/* Tile to be deleted */
{
    Tile *tilePtr = (Tile *)tile;
    TileMaster *masterPtr;

    if (!initialized) {
	InitTables();
    }
    if ((tilePtr == NULL) || (tilePtr->magic != TILE_MAGIC)) {
	return;			/* No tile */
    }
    masterPtr = tilePtr->masterPtr;

    /* Remove the client from the master tile's list */
    if (tilePtr->itemPtr != NULL) {
	Blt_FreeItem(tilePtr->itemPtr);
    }
    ckfree((char *) tilePtr);

    /*
     * If there are no more clients of the tile, then remove the
     * pixmap, image, and the master record.
     */
    if ((masterPtr != NULL) && (masterPtr->clients.numEntries == 0)) {
	Tcl_HashEntry *hPtr;
	TileKey key;

	key.nameId = masterPtr->nameId;
	key.display = masterPtr->display;
	hPtr = Tcl_FindHashEntry(&tileTable, (char *)&key);
	if (hPtr != NULL) {
	    Tcl_DeleteHashEntry(hPtr);
	}
	if (masterPtr->pixmap != None) {
	    Tk_FreePixmap(masterPtr->display, masterPtr->pixmap);
	}
	Tk_FreeImage(masterPtr->image);
	ckfree((char *)masterPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_NameOfTile
 *
 *	Returns the name of the image from which the tile was
 *	generated.
 *
 * Results:
 *	The name of the image is returned.  The name is not unique.
 *	Many tiles may use the same image.
 *
 *----------------------------------------------------------------------
 */
char *
Tk_NameOfTile(tile)
    Tk_Tile tile;		/* Tile to query */
{
    Tile *tilePtr = (Tile *)tile;

    if (tilePtr == NULL) {
	return "";
    }
    if (tilePtr->magic != TILE_MAGIC) {
	return "not a tile";
    }
    if ((tilePtr->masterPtr == NULL) || (tilePtr->masterPtr->nameId == NULL)) {
	return "";
    }
    return (tilePtr->masterPtr->nameId);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_PixmapOfTile
 *
 *	Returns the pixmap of the tile.
 *
 * Results:
 *	The X pixmap used as the tile is returned.
 *
 *----------------------------------------------------------------------
 */
Pixmap
Tk_PixmapOfTile(tile)
    Tk_Tile tile;		/* Tile to query */
{
    Tile *tilePtr = (Tile *)tile;

    if ((tilePtr == NULL) || (tilePtr->magic != TILE_MAGIC) ||
	    (tilePtr->masterPtr == NULL)) {
	return None;
    }
    return (tilePtr->masterPtr->pixmap);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_SizeOfTile
 *
 *	Returns the width and height of the tile.
 *
 * Results:
 *	The width and height of the tile are returned.
 *
 *----------------------------------------------------------------------
 */
void
Tk_SizeOfTile(tile, widthPtr, heightPtr)
    Tk_Tile tile;		/* Tile to query */
    int *widthPtr, *heightPtr;	/* Returned dimensions of the tile (out) */
{
    Tile *tilePtr = (Tile *)tile;

    if ((tilePtr == NULL) || (tilePtr->magic != TILE_MAGIC) ||
	    (tilePtr->masterPtr == NULL)) {
	*widthPtr = *heightPtr = 0;
	return;			/* No tile given */
    }
    *widthPtr = tilePtr->masterPtr->width;
    *heightPtr = tilePtr->masterPtr->height;
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_SetTileChangedProc
 *
 *	Sets the routine to called when an image changes.  If
 *	*changeProc* is NULL, no callback will be performed.
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	The designated routine will be called the next time the
 *	image associated with the tile changes.
 *
 *----------------------------------------------------------------------
 */
void
Tk_SetTileChangedProc(tile, changeProc, clientData, itemPtr)
    Tk_Tile tile;		/* Tile to query */
    Tk_TileChangedProc *changeProc;
    ClientData clientData;
    Tk_Item *itemPtr;
{
    Tile *tilePtr = (Tile *)tile;

    if ((tilePtr != NULL) && (tilePtr->magic == TILE_MAGIC)) {
	tilePtr->changeProc = changeProc;
	tilePtr->clientData = clientData;
	tilePtr->canvasItem = itemPtr;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_SetTileOrigin --
 *
 *	Set the pattern origin of the tile to a common point (i.e. the
 *	origin (0,0) of the top level window) so that tiles from two
 *	different widgets will match up.  This done by setting the
 *	GCTileStipOrigin field is set to the translated origin of the
 *	toplevel window in the hierarchy.
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	The GCTileStipOrigin is reset in the GC.  This will cause the
 *	tile origin to change when the GC is used for drawing.
 *
 *----------------------------------------------------------------------
 */
/*ARGSUSED*/
void
Tk_SetTileOrigin(tkwin, gc, x, y)
    Tk_Window tkwin;
    GC gc;
    int x, y;
{
    while (!Tk_IsTopLevel(tkwin)) {
	x -= Tk_X(tkwin) + Tk_Changes(tkwin)->border_width;
	y -= Tk_Y(tkwin) + Tk_Changes(tkwin)->border_width;
	tkwin = Tk_Parent(tkwin);
    }
    XSetTSOrigin(Tk_Display(tkwin), gc, x, y);
}

/*
 * bltList.c --
 *
 *	Generic linked list management routines.
 *
 * Copyright 1991-1996 by AT&T Bell Laboratories.
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for any purpose and without fee is hereby
 * granted, provided that the above copyright notice appear in all
 * copies and that both that the copyright notice and warranty
 * disclaimer appear in supporting documentation, and that the
 * names of AT&T Bell Laboratories any of their entities not be used
 * in advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission.
 *
 * AT&T disclaims all warranties with regard to this software, including
 * all implied warranties of merchantability and fitness.  In no event
 * shall AT&T be liable for any special, indirect or consequential
 * damages or any damages whatsoever resulting from loss of use, data
 * or profits, whether in an action of contract, negligence or other
 * tortuous action, arising out of or in connection with the use or
 * performance of this software.
 *
 */

/*
 *----------------------------------------------------------------------
 *
 * Blt_InitList --
 *
 *	Initialized a linked list.
 *
 * Results:
 *	None.
 *
 *----------------------------------------------------------------------
 */
static void
Blt_InitList(listPtr, type)
    Blt_List *listPtr;
    int type;
{

    listPtr->numEntries = 0;
    listPtr->headPtr = listPtr->tailPtr = (Blt_ListItem *)NULL;
    listPtr->type = type;
}

/*
 *----------------------------------------------------------------------
 *
 * Blt_NewItem --
 *
 *	Creates a list entry holder.  This routine does not insert
 *	the entry into the list, nor does it no attempt to maintain
 *	consistency of the keys.  For example, more than one entry
 *	may use the same key.
 *
 * Results:
 *	The return value is the pointer to the newly created entry.
 *
 * Side Effects:
 *	The key is not copied, only the Uid is kept.  It is assumed
 *	this key will not change in the life of the entry.
 *
 *----------------------------------------------------------------------
 */
static Blt_ListItem *
Blt_NewItem(key)
    char *key;			/* Unique key to reference object */
{
    register Blt_ListItem *iPtr;

    iPtr = (Blt_ListItem *)ckalloc(sizeof(Blt_ListItem));
    if (iPtr == (Blt_ListItem *)NULL) {
	panic("can't allocate list item structure");
    }
    iPtr->keyPtr = key;
    iPtr->clientData = (ClientData)NULL;
    iPtr->nextPtr = iPtr->prevPtr = (Blt_ListItem *)NULL;
    iPtr->listPtr = (Blt_List *)NULL;
    return (iPtr);
}
/*
 *----------------------------------------------------------------------
 *
 * Blt_LinkAfter --
 *
 *	Inserts an entry following a given entry.
 *
 * Results:
 *	None.
 *
 *----------------------------------------------------------------------
 */
static void
Blt_LinkAfter(listPtr, iPtr, afterPtr)
    Blt_List *listPtr;
    Blt_ListItem *iPtr;
    Blt_ListItem *afterPtr;
{
    /*
     * If the list keys are strings, change the key to a Tk_Uid
     */
    if (listPtr->type == TCL_STRING_KEYS) {
	iPtr->keyPtr = Tk_GetUid(iPtr->keyPtr);
    }
    if (listPtr->headPtr == (Blt_ListItem *)NULL) {
	listPtr->tailPtr = listPtr->headPtr = iPtr;
    } else {
	if (afterPtr == (Blt_ListItem *)NULL) {
	    afterPtr = listPtr->tailPtr;
	}
	iPtr->nextPtr = afterPtr->nextPtr;
	iPtr->prevPtr = afterPtr;
	if (afterPtr == listPtr->tailPtr) {
	    listPtr->tailPtr = iPtr;
	} else {
	    afterPtr->nextPtr->prevPtr = iPtr;
	}
	afterPtr->nextPtr = iPtr;
    }
    iPtr->listPtr = listPtr;
    listPtr->numEntries++;
}

/*
 *----------------------------------------------------------------------
 *
 * Blt_FreeItem --
 *
 *	Frees an entry from the given list.
 *
 * Results:
 *	None.
 *
 *----------------------------------------------------------------------
 */
static void
Blt_FreeItem(iPtr)
    Blt_ListItem *iPtr;
{
    Blt_List *listPtr;

    listPtr = iPtr->listPtr;
    if (listPtr != NULL) {
	if (listPtr->headPtr == iPtr) {
	    listPtr->headPtr = iPtr->nextPtr;
	}
	if (listPtr->tailPtr == iPtr) {
	    listPtr->tailPtr = iPtr->prevPtr;
	}
	if (iPtr->nextPtr != NULL) {
	    iPtr->nextPtr->prevPtr = iPtr->prevPtr;
	}
	if (iPtr->prevPtr != NULL) {
	    iPtr->prevPtr->nextPtr = iPtr->nextPtr;
	}
	iPtr->listPtr = NULL;
	listPtr->numEntries--;
    }
    ckfree((char *) iPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetImageMasterData --
 *
 *	Given the name of an image, this procedure returns the type
 *	of the image and the clientData associated with its master.
 *
 * Results:
 *	If there is no image by the given name, then NULL is returned
 *	and a NULL value is stored at *typePtrPtr.  Otherwise the return
 *	value is the clientData returned by the createProc when the
 *	image was created and a pointer to the type structure for the
 *	image is stored at *typePtrPtr.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

ClientData
Tk_GetImageMasterData(interp, name, typePtrPtr)
    Tcl_Interp *interp;		/* Interpreter in which the image was
				 * created. */
    char *name;			/* Name of image. */
    Tk_ImageType **typePtrPtr;	/* Points to location to fill in with
				 * pointer to type information for image. */
{
    Tcl_HashEntry *hPtr;
    TkWindow *winPtr;
    ImageMaster *masterPtr;

    winPtr = (TkWindow *) Tk_MainWindow(interp);
    hPtr = Tcl_FindHashEntry(&winPtr->mainPtr->imageTable, name);
    if (hPtr == NULL) {
	*typePtrPtr = NULL;
	return NULL;
    }
    masterPtr = (ImageMaster *) Tcl_GetHashValue(hPtr);
    *typePtrPtr = masterPtr->typePtr;
    return masterPtr->masterData;
}
