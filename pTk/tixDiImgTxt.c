/*
 * tixDiImgTxt.c --
 *
 *	This file implements one of the "Display Items" in the Tix library :
 *	Image-text display items.
 *
 */

#include "tkPort.h"
#include "tkInt.h"
#include "tixInt.h"
#include "default.h"

#define DEF_IMAGETEXT_BITMAP	 ""
#define DEF_IMAGETEXT_IMAGE	 ""
#define DEF_IMAGETEXT_TYPE	 "imagetext"
#define DEF_IMAGETEXT_SHOWIMAGE  "1"
#define DEF_IMAGETEXT_SHOWTEXT   "1"
#define DEF_IMAGETEXT_STYLE	 ""
#define DEF_IMAGETEXT_TEXT	 ""
#define DEF_IMAGETEXT_UNDERLINE  "-1"

static Tk_ConfigSpec imageTextConfigSpecs[] = {

    {TK_CONFIG_BITMAP, "-bitmap", "bitmap", "Bitmap",
       DEF_IMAGETEXT_BITMAP, Tk_Offset(TixImageText, bitmap),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_STRING, "-image", "image", "Image",
       DEF_IMAGETEXT_IMAGE, Tk_Offset(TixImageText, imageString),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_CUSTOM, "-itemtype", "itemType", "ItemType", 
       DEF_IMAGETEXT_TYPE, Tk_Offset(TixImageText, diTypePtr),
       0, &tixConfigItemType},

    {TK_CONFIG_INT, "-showimage", "showImage", "ShowImage",
        DEF_IMAGETEXT_SHOWIMAGE, Tk_Offset(TixImageText, showImage), 0},

    {TK_CONFIG_INT, "-showtext", "showText", "ShowText",
        DEF_IMAGETEXT_SHOWTEXT, Tk_Offset(TixImageText, showText), 0},

    {TK_CONFIG_CUSTOM, "-style", "imageTextStyle", "ImageTextStyle",
       DEF_IMAGETEXT_STYLE, Tk_Offset(TixImageText, stylePtr),
       TK_CONFIG_NULL_OK, &tixConfigItemStyle},

    {TK_CONFIG_STRING, "-text", "text", "Text",
       DEF_IMAGETEXT_TEXT, Tk_Offset(TixImageText, text),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_INT, "-underline", "underline", "Underline",
       DEF_IMAGETEXT_UNDERLINE, Tk_Offset(TixImageText, underline), 0},

    {TK_CONFIG_END,          NULL,          NULL,          NULL,
                NULL, 0, 0}
};

/*----------------------------------------------------------------------
 *
 * 		Configuration options for Text Styles
 *
 *----------------------------------------------------------------------
 */


#define SELECTED_BG SELECT_BG 
#define DISABLED_BG DISABLED  

#define DEF_IMAGETEXTSTYLE_NORMAL_FG_COLOR	BLACK
#define DEF_IMAGETEXTSTYLE_NORMAL_FG_MONO	BLACK
#define DEF_IMAGETEXTSTYLE_NORMAL_BG_COLOR	NORMAL_BG
#define DEF_IMAGETEXTSTYLE_NORMAL_BG_MONO	WHITE

#define DEF_IMAGETEXTSTYLE_ACTIVE_FG_COLOR	BLACK
#define DEF_IMAGETEXTSTYLE_ACTIVE_FG_MONO	WHITE
#define DEF_IMAGETEXTSTYLE_ACTIVE_BG_COLOR	ACTIVE_BG
#define DEF_IMAGETEXTSTYLE_ACTIVE_BG_MONO	BLACK

#define DEF_IMAGETEXTSTYLE_SELECTED_FG_COLOR	BLACK
#define DEF_IMAGETEXTSTYLE_SELECTED_FG_MONO	WHITE
#define DEF_IMAGETEXTSTYLE_SELECTED_BG_COLOR	SELECTED_BG
#define DEF_IMAGETEXTSTYLE_SELECTED_BG_MONO	BLACK

#define DEF_IMAGETEXTSTYLE_DISABLED_FG_COLOR	BLACK
#define DEF_IMAGETEXTSTYLE_DISABLED_FG_MONO	BLACK
#define DEF_IMAGETEXTSTYLE_DISABLED_BG_COLOR	DISABLED_BG
#define DEF_IMAGETEXTSTYLE_DISABLED_BG_MONO	WHITE

#define DEF_IMAGETEXTSTYLE_FONT  "-Adobe-Helvetica-Bold-R-Normal--*-120-*"
#define DEF_IMAGETEXTSTYLE_GAP	 	"4"
#define DEF_IMAGETEXTSTYLE_PADX	 	"2"
#define DEF_IMAGETEXTSTYLE_PADY	 	"2"
#define DEF_IMAGETEXTSTYLE_JUSTIFY	"left"
#define DEF_IMAGETEXTSTYLE_WLENGTH	"0"
#define DEF_IMAGETEXTSTYLE_ANCHOR 	"w"


static Tk_ConfigSpec imageTextStyleConfigSpecs[] = {
    {TK_CONFIG_ANCHOR, "-anchor", "anchor", "Anchor",
       DEF_IMAGETEXTSTYLE_ANCHOR, Tk_Offset(TixImageTextStyle, anchor), 0},

    {TK_CONFIG_SYNONYM, "-bg", "background",          NULL,
                NULL, 0, 0},
    {TK_CONFIG_SYNONYM, "-fg", "foreground",          NULL,
                NULL, 0, 0},
 
    {TK_CONFIG_FONT, "-font", "font", "Font",
       DEF_IMAGETEXTSTYLE_FONT, Tk_Offset(TixImageTextStyle, fontPtr), 0},

    {TK_CONFIG_PIXELS, "-gap", "gap", "Gap",
       DEF_IMAGETEXTSTYLE_GAP, Tk_Offset(TixImageTextStyle, gap), 0},

    {TK_CONFIG_JUSTIFY, "-justify", "justify", "Justyfy",
       DEF_IMAGETEXTSTYLE_JUSTIFY, Tk_Offset(TixImageTextStyle, justify),
       TK_CONFIG_NULL_OK},

    {TK_CONFIG_PIXELS, "-padx", "padX", "Pad",
       DEF_IMAGETEXTSTYLE_PADX, Tk_Offset(TixImageTextStyle, pad[0]), 0},

    {TK_CONFIG_PIXELS, "-pady", "padY", "Pad",
       DEF_IMAGETEXTSTYLE_PADY, Tk_Offset(TixImageTextStyle, pad[1]), 0},

    {TK_CONFIG_PIXELS, "-wraplength", "wrapLength", "WrapLength",
       DEF_IMAGETEXTSTYLE_WLENGTH, Tk_Offset(TixImageTextStyle, wrapLength),
       0},

/* The following is automatically generated */
	{TK_CONFIG_COLOR,"-background","background","Background",
	DEF_IMAGETEXTSTYLE_NORMAL_BG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_NORMAL].bg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-background","background","Background",
	DEF_IMAGETEXTSTYLE_NORMAL_BG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_NORMAL].bg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-foreground","foreground","Foreground",
	DEF_IMAGETEXTSTYLE_NORMAL_FG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_NORMAL].fg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-foreground","foreground","Foreground",
	DEF_IMAGETEXTSTYLE_NORMAL_FG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_NORMAL].fg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-activebackground","activeBackground","ActiveBackground",
	DEF_IMAGETEXTSTYLE_ACTIVE_BG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_ACTIVE].bg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-activebackground","activeBackground","ActiveBackground",
	DEF_IMAGETEXTSTYLE_ACTIVE_BG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_ACTIVE].bg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-activeforeground","activeForeground","ActiveForeground",
	DEF_IMAGETEXTSTYLE_ACTIVE_FG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_ACTIVE].fg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-activeforeground","activeForeground","ActiveForeground",
	DEF_IMAGETEXTSTYLE_ACTIVE_FG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_ACTIVE].fg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-selectbackground","selectBackground","SelectBackground",
	DEF_IMAGETEXTSTYLE_SELECTED_BG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_SELECTED].bg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-selectbackground","selectBackground","SelectBackground",
	DEF_IMAGETEXTSTYLE_SELECTED_BG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_SELECTED].bg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-selectforeground","selectForeground","SelectForeground",
	DEF_IMAGETEXTSTYLE_SELECTED_FG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_SELECTED].fg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-selectforeground","selectForeground","SelectForeground",
	DEF_IMAGETEXTSTYLE_SELECTED_FG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_SELECTED].fg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-disabledbackground","disabledBackground","DisabledBackground",
	DEF_IMAGETEXTSTYLE_DISABLED_BG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_DISABLED].bg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-disabledbackground","disabledBackground","DisabledBackground",
	DEF_IMAGETEXTSTYLE_DISABLED_BG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_DISABLED].bg),
	TK_CONFIG_MONO_ONLY},
	{TK_CONFIG_COLOR,"-disabledforeground","disabledForeground","DisabledForeground",
	DEF_IMAGETEXTSTYLE_DISABLED_FG_COLOR,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_DISABLED].fg),
	TK_CONFIG_COLOR_ONLY},
	{TK_CONFIG_COLOR,"-disabledforeground","disabledForeground","DisabledForeground",
	DEF_IMAGETEXTSTYLE_DISABLED_FG_MONO,
	Tk_Offset(TixImageTextStyle,colors[TIX_DITEM_DISABLED].fg),
	TK_CONFIG_MONO_ONLY},

    {TK_CONFIG_END,          NULL,          NULL,          NULL,
                NULL, 0, 0}
};

/*----------------------------------------------------------------------
 * Forward declarations for procedures defined later in this file:
 *----------------------------------------------------------------------
 */
static void		ImageProc _ANSI_ARGS_((ClientData clientData,
			    int x, int y, int width, int height,
			    int imgWidth, int imgHeight));
static void		Tix_ImageTextCalculateSize  _ANSI_ARGS_((
			    Tix_DItem * iPtr));
static int 		Tix_ImageTextConfigure _ANSI_ARGS_((
			    Tix_DItem * iPtr, int argc, Arg *args,
			    int flags));
static Tix_DItem * 	Tix_ImageTextCreate _ANSI_ARGS_((
			    Tix_DispData * ddPtr, Tix_DItemInfo * diTypePtr));
static void		Tix_ImageTextDisplay  _ANSI_ARGS_((
			    Pixmap pixmap, GC gc, Tix_DItem * iPtr,
			    int x, int y, int width, int height, int flag));
static void		Tix_ImageTextFree  _ANSI_ARGS_((
			    Tix_DItem * iPtr));
static void		Tix_ImageTextLostStyle  _ANSI_ARGS_((
			    Tix_DItem * iPtr));
static void 		Tix_ImageTextStyleChanged  _ANSI_ARGS_((
			    Tix_DItem * iPtr));
static int 		Tix_ImageTextStyleConfigure _ANSI_ARGS_((
			    Tix_DItemStyle* style, int argc, Arg *args,
			    int flags));
static Tix_DItemStyle *	Tix_ImageTextStyleCreate _ANSI_ARGS_((
			    Tcl_Interp *interp, Tk_Window tkwin,
			    Tix_DItemInfo * diTypePtr, char * name));
static void		Tix_ImageTextStyleFree _ANSI_ARGS_((
			    Tix_DItemStyle* style));
static void 		Tix_ImageTextStyleSetTemplate _ANSI_ARGS_((
			    Tix_DItemStyle* style,
			    Tix_StyleTemplate * tmplPtr));

Tix_DItemInfo tix_ImageTextType = {
    "imagetext",			/* type */
    TIX_DITEM_IMAGETEXT,
    Tix_ImageTextCreate,		/* createProc */
    Tix_ImageTextConfigure,
    Tix_ImageTextCalculateSize,
    Tix_ImageTextDisplay,
    Tix_ImageTextFree,
    Tix_ImageTextStyleChanged,
    Tix_ImageTextLostStyle,

    Tix_ImageTextStyleCreate,
    Tix_ImageTextStyleConfigure,
    Tix_ImageTextStyleFree,
    Tix_ImageTextStyleSetTemplate,

    imageTextConfigSpecs,
    imageTextStyleConfigSpecs,
    NULL,				/*next */
};


/*----------------------------------------------------------------------
 * Tix_ImageText --
 *
 *
 *----------------------------------------------------------------------
 */
static Tix_DItem * Tix_ImageTextCreate(ddPtr, diTypePtr)
    Tix_DispData * ddPtr;
    Tix_DItemInfo * diTypePtr;
{
    TixImageText * itPtr;

    itPtr = (TixImageText*) ckalloc(sizeof(TixImageText));

    itPtr->diTypePtr	= diTypePtr;
    itPtr->ddPtr 	= ddPtr;
    itPtr->stylePtr     = NULL;
    itPtr->clientData	= 0;
    itPtr->size[0]	= 0;
    itPtr->size[1]	= 0;

    itPtr->bitmap	= None;
    itPtr->bitmapW	= 0;
    itPtr->bitmapH	= 0;

    itPtr->imageString	= NULL;
    itPtr->image	= NULL;
    itPtr->imageW	= 0;
    itPtr->imageH	= 0;

    itPtr->numChars	= 0;
    itPtr->text		= NULL;
    itPtr->textW	= 0;
    itPtr->textH	= 0;
    itPtr->underline 	= -1;

    itPtr->showImage	= 1;
    itPtr->showText	= 1;

    return (Tix_DItem *)itPtr;
}

static void Tix_ImageTextFree(iPtr)
    Tix_DItem * iPtr;
{
    TixImageText * itPtr = (TixImageText *) iPtr;

    if (itPtr->image) {
	Tk_FreeImage(itPtr->image);
    }
    if (itPtr->stylePtr) {
	TixDItemStyleFree(iPtr, (Tix_DItemStyle*)itPtr->stylePtr);
    }

    Tk_FreeOptions(imageTextConfigSpecs, (char *)itPtr,
	itPtr->ddPtr->display, 0);
    ckfree((char*)itPtr);
}

static int Tix_ImageTextConfigure(iPtr, argc, args, flags)
    Tix_DItem * iPtr;
    int argc;
    Arg *args;
    int flags;
{
    TixImageText * itPtr = (TixImageText *) iPtr;
    TixImageTextStyle * oldStyle = itPtr->stylePtr;

    if (Tk_ConfigureWidget(itPtr->ddPtr->interp, itPtr->ddPtr->tkwin,
	imageTextConfigSpecs,
	argc, args, (char *)itPtr, flags) != TCL_OK) {
	return TCL_ERROR;
    }
    if (itPtr->stylePtr == NULL) {
	itPtr->stylePtr = (TixImageTextStyle*)TixGetDefaultDItemStyle(
	    itPtr->ddPtr, &tix_ImageTextType, iPtr, NULL);
    }

    /*
     * Free the old images for the widget, if there were any.
     */
    if (itPtr->image != NULL) {
	Tk_FreeImage(itPtr->image);
	itPtr->image = NULL;
    }

    if (itPtr->imageString != NULL) {
	itPtr->image = Tk_GetImage(itPtr->ddPtr->interp, itPtr->ddPtr->tkwin,
	    itPtr->imageString, ImageProc, (ClientData) itPtr);
	if (itPtr->image == NULL) {
	    return TCL_ERROR;
	}
    }

    if (oldStyle != NULL && itPtr->stylePtr != oldStyle) {
	Tix_ImageTextStyleChanged(iPtr);
    }
    else {
	Tix_ImageTextCalculateSize((Tix_DItem*)itPtr);
    }

    return TCL_OK;
}

static void Tix_ImageTextDisplay(pixmap, gc, iPtr, x, y, width, height, flags)
    Pixmap pixmap;
    GC gc;
    Tix_DItem * iPtr;
    int x;
    int y;
    int width;
    int height;
    int flags;
{
    TixImageText *itPtr = (TixImageText *)iPtr;
    GC foreGC, backGC;

    TixGetColorDItemGC(iPtr, &backGC, &foreGC, flags);
    TixDItemGetAnchor(itPtr->stylePtr->anchor, x, y, width, height,
	itPtr->size[0], itPtr->size[1], &x, &y);

    if (backGC != None) {
	/* Draw the background */
	XFillRectangle(itPtr->ddPtr->display, pixmap,
	    backGC, x, y, width, height);
    }

    if (itPtr->image != NULL) {
	int bitY;

	bitY = itPtr->size[1] - itPtr->imageH - 2*itPtr->stylePtr->pad[1];

	if (bitY > 0) {
	    bitY = bitY / 2;
	} else {
	    bitY = 0;
	}
	Tk_RedrawImage(itPtr->image, 0, 0, itPtr->imageW, itPtr->imageH,
	    pixmap,
	    x + itPtr->stylePtr->pad[0],
	    y + itPtr->stylePtr->pad[1] + bitY);

	x += itPtr->imageW + itPtr->stylePtr->gap;
    }
    else if (itPtr->bitmap != None && foreGC != None) {
	int bitY;

	bitY = itPtr->size[1] - itPtr->bitmapH - 2*itPtr->stylePtr->pad[1];
	if (bitY > 0) {
	    bitY = bitY / 2;
	} else {
	    bitY = 0;
	}

	if (itPtr->showImage) {
	    XSetClipOrigin(itPtr->ddPtr->display, foreGC, x, y);
	    XCopyPlane(itPtr->ddPtr->display, itPtr->bitmap, pixmap, foreGC,
		0, 0,
	    	itPtr->bitmapW, itPtr->bitmapH,
	    	x + itPtr->stylePtr->pad[0],
	    	y + itPtr->stylePtr->pad[1] + bitY,
	    	1);
	    XSetClipOrigin(itPtr->ddPtr->display, foreGC, 0, 0);
	}
	x += itPtr->bitmapW + itPtr->stylePtr->gap;
    }

    if (itPtr->text && itPtr->showText && foreGC != None) {
	int textY;
	
	textY = itPtr->size[1] - itPtr->textH - 2*itPtr->stylePtr->pad[1];
	if (textY > 0) {
	    textY = textY / 2;
	} else {
	    textY = 0;
	}
	
	TkDisplayText(itPtr->ddPtr->display, pixmap, itPtr->stylePtr->fontPtr,
       	    itPtr->text, itPtr->numChars,
	    x + itPtr->stylePtr->pad[0],
	    y + itPtr->stylePtr->pad[1] + textY,
	    itPtr->textW,
	    itPtr->stylePtr->justify,
	    itPtr->underline,
	    foreGC);
    }
}

static void Tix_ImageTextCalculateSize(iPtr)
    Tix_DItem * iPtr;
{
    TixImageText *itPtr = (TixImageText *)iPtr;

    itPtr->size[0] = 0;
    itPtr->size[1] = 0;

    if (itPtr->image != NULL) {
	Tk_SizeOfImage(itPtr->image, &itPtr->imageW, &itPtr->imageH);

	itPtr->size[0] = itPtr->imageW + itPtr->stylePtr->gap;
	itPtr->size[1] = itPtr->imageH;
    }
    else if (itPtr->bitmap != None) {
	Tk_SizeOfBitmap(itPtr->ddPtr->display, itPtr->bitmap, &itPtr->bitmapW,
	        &itPtr->bitmapH);

	itPtr->size[0] = itPtr->bitmapW + itPtr->stylePtr->gap;
	itPtr->size[1] = itPtr->bitmapH;
    }

    if (itPtr->text) {
	itPtr->numChars = strlen(itPtr->text);
	TkComputeTextGeometry(itPtr->stylePtr->fontPtr, itPtr->text,
		itPtr->numChars, itPtr->stylePtr->wrapLength,
		&itPtr->textW, &itPtr->textH);

	itPtr->size[0] += itPtr->textW;
	
	if (itPtr->textH > itPtr->size[1]) {
	    itPtr->size[1] = itPtr->textH;
	}
    }

    itPtr->size[0] += 2*itPtr->stylePtr->pad[0];
    itPtr->size[1] += 2*itPtr->stylePtr->pad[1];
}

static void Tix_ImageTextStyleChanged(iPtr)
    Tix_DItem * iPtr;
{
    TixImageText *itPtr = (TixImageText *)iPtr;

    if (itPtr->stylePtr == NULL) {
	/* Maybe we haven't set the style to default style yet */
	return;
    }
    Tix_ImageTextCalculateSize(iPtr);
    if (itPtr->ddPtr->sizeChangedProc != NULL) {
	itPtr->ddPtr->sizeChangedProc(iPtr);
    }
}
static void Tix_ImageTextLostStyle(iPtr)
    Tix_DItem * iPtr;
{
    TixImageText *itPtr = (TixImageText *)iPtr;

    itPtr->stylePtr = (TixImageTextStyle*)TixGetDefaultDItemStyle(
	itPtr->ddPtr, &tix_ImageTextType, iPtr, NULL);

    Tix_ImageTextStyleChanged(iPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImageProc --
 *
 *	This procedure is invoked by the image code whenever the manager
 *	for an image does something that affects the size of contents
 *	of an image displayed in this widget.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Arranges for the HList to get redisplayed.
 *
 *----------------------------------------------------------------------
 */
static void
ImageProc(clientData, x, y, width, height, imgWidth, imgHeight)
    ClientData clientData;		/* Pointer to widget record. */
    int x, y;				/* Upper left pixel (within image)
					 * that must be redisplayed. */
    int width, height;			/* Dimensions of area to redisplay
					 * (may be <= 0). */
    int imgWidth, imgHeight;		/* New dimensions of image. */
{
    TixImageText *itPtr = (TixImageText *)clientData;

    Tix_ImageTextCalculateSize((Tix_DItem *)itPtr);
    if (itPtr->ddPtr->sizeChangedProc != NULL) {
	itPtr->ddPtr->sizeChangedProc((Tix_DItem *)itPtr);
    }
}

/*----------------------------------------------------------------------
 *
 *
 *  			Display styles
 *
 *
 *----------------------------------------------------------------------
 */
static Tix_DItemStyle *
Tix_ImageTextStyleCreate(interp, tkwin, diTypePtr, name)
    Tcl_Interp * interp;
    Tk_Window tkwin;
    char * name;
    Tix_DItemInfo * diTypePtr;
{
    int i;
    TixImageTextStyle * stylePtr =
      (TixImageTextStyle *)ckalloc(sizeof(TixImageTextStyle));

    stylePtr->fontPtr 	 = NULL;
    stylePtr->gap 	 = 0;
    stylePtr->justify 	 = TK_JUSTIFY_LEFT;
    stylePtr->wrapLength = 0;

    for (i=0; i<4; i++) {
	stylePtr->colors[i].bg = NULL;
	stylePtr->colors[i].fg = NULL;
	stylePtr->colors[i].backGC = None;
	stylePtr->colors[i].foreGC = NULL;
    }

    return (Tix_DItemStyle *)stylePtr;
}

static int
Tix_ImageTextStyleConfigure(style, argc, args, flags)
    Tix_DItemStyle *style;
    int argc;
    Arg *args;
    int flags;
{
    TixImageTextStyle * stylePtr = (TixImageTextStyle *)style;
    XGCValues gcValues;
    GC newGC;
    int i, isNew;

    if (stylePtr->fontPtr == NULL) {
	isNew = 1;
    } else {
	isNew = 0;
    }

    if (!(flags &TIX_DONT_CALL_CONFIG)) {
	if (Tk_ConfigureWidget(stylePtr->interp, stylePtr->tkwin,
	    imageTextStyleConfigSpecs,
	    argc, args, (char *)stylePtr, flags) != TCL_OK) {
	    return TCL_ERROR;
	}
    }

    gcValues.font = stylePtr->fontPtr->fid;
    gcValues.graphics_exposures = False;

    for (i=0; i<4; i++) {
	/* Foreground */
	gcValues.background = stylePtr->colors[i].bg->pixel;
	gcValues.foreground = stylePtr->colors[i].fg->pixel;
	newGC = Tk_GetGC(stylePtr->tkwin,
	    GCFont|GCForeground|GCBackground|GCGraphicsExposures, &gcValues);

	if (stylePtr->colors[i].foreGC != None) {
	    Tk_FreeGC(Tk_Display(stylePtr->tkwin),
		stylePtr->colors[i].foreGC);
	}
	stylePtr->colors[i].foreGC = newGC;

	/* Background */
	gcValues.foreground = stylePtr->colors[i].bg->pixel;
	newGC = Tk_GetGC(stylePtr->tkwin,
	    GCFont|GCForeground|GCGraphicsExposures, &gcValues);

	if (stylePtr->colors[i].backGC != None) {
	    Tk_FreeGC(Tk_Display(stylePtr->tkwin),
		stylePtr->colors[i].backGC);
	}
	stylePtr->colors[i].backGC = newGC;
    }

    if (!isNew) {
	TixDItemStyleChanged(stylePtr->diTypePtr, (Tix_DItemStyle *)stylePtr);
    }

    return TCL_OK;
}

static void Tix_ImageTextStyleFree(style)
    Tix_DItemStyle *style;
{
    TixImageTextStyle * stylePtr = (TixImageTextStyle *)style;
    int i;

    for (i=0; i<4; i++) {
	if (stylePtr->colors[i].backGC != None) {
	    Tk_FreeGC(Tk_Display(stylePtr->tkwin), stylePtr->colors[i].backGC);
	}
	if (stylePtr->colors[i].foreGC != None) {
	    Tk_FreeGC(Tk_Display(stylePtr->tkwin), stylePtr->colors[i].foreGC);
	}
    }

    Tk_FreeOptions(imageTextStyleConfigSpecs, (char *)stylePtr,
	Tk_Display(stylePtr->tkwin), 0);
    ckfree((char *)stylePtr);
}

static int bg_flags [4] = {
    TIX_DITEM_NORMAL_BG,
    TIX_DITEM_ACTIVE_BG,
    TIX_DITEM_SELECTED_BG,
    TIX_DITEM_DISABLED_BG
};
static int fg_flags [4] = {
    TIX_DITEM_NORMAL_FG,
    TIX_DITEM_ACTIVE_FG,
    TIX_DITEM_SELECTED_FG,
    TIX_DITEM_DISABLED_FG
};

static void
Tix_ImageTextStyleSetTemplate(style, tmplPtr)
    Tix_DItemStyle* style;
    Tix_StyleTemplate * tmplPtr;
{
    TixImageTextStyle * stylePtr = (TixImageTextStyle *)style;
    int i;

    if (tmplPtr->flags & TIX_DITEM_FONT) {
	if (stylePtr->fontPtr != NULL) {
	    Tk_FreeFontStruct(stylePtr->fontPtr);
	}
	stylePtr->fontPtr = Tk_GetFontStruct(
  	    stylePtr->interp, stylePtr->tkwin,
	    Tk_NameOfFontStruct(tmplPtr->fontPtr));
    }
    if (tmplPtr->flags & TIX_DITEM_PADX) {
	stylePtr->pad[0] = tmplPtr->pad[0];
    }
    if (tmplPtr->flags & TIX_DITEM_PADY) {
	stylePtr->pad[1] = tmplPtr->pad[1];
    }

    for (i=0; i<4; i++) {
	if (tmplPtr->flags & bg_flags[i]) {
	    if (stylePtr->colors[i].bg != NULL) {
		Tk_FreeColor(stylePtr->colors[i].bg);
	    }
	    stylePtr->colors[i].bg = Tk_GetColor(
  	    	stylePtr->interp, stylePtr->tkwin,
		Tk_NameOfColor(tmplPtr->colors[i].bg));
	}
    }
    for (i=0; i<4; i++) {
	if (tmplPtr->flags & fg_flags[i]) {
	    if (stylePtr->colors[i].fg != NULL) {
		Tk_FreeColor(stylePtr->colors[i].fg);
	    }
	    stylePtr->colors[i].fg = Tk_GetColor(
  	    	stylePtr->interp, stylePtr->tkwin,
		Tk_NameOfColor(tmplPtr->colors[i].fg));
	}
    }

    Tix_ImageTextStyleConfigure(style, 0, 0, TIX_DONT_CALL_CONFIG);
}
