/* 
 * tkWinImage.c --
 *
 *	This file contains routines for manipulation full-color images.
 *
 * Copyright (c) 1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tkWinImage.c 1.5 96/10/11 14:59:04
 */

#include "tkWinInt.h"

static int		ImgDestroy  _ANSI_ARGS_((XImage * image));
static int		ImgPutPixel _ANSI_ARGS_((XImage *image, int x, int y,
			    unsigned long pixel));
static unsigned long	ImgGetPixel _ANSI_ARGS_((XImage *image, int x, int y));
static XImage *		ImgSubImage _ANSI_ARGS_((XImage *image, int x, int y, 
			    unsigned int width, unsigned int height));
static int		ImgAddPixel _ANSI_ARGS_((XImage *image, long pixel));

static int
ImgAddPixel(image, pixel)
XImage *image;
long pixel;
{
 return 0;
}

static unsigned long
ImgGetPixel(image, x, y)
XImage *image;
int x;
int y;
{
 return 0;
}

static XImage *
ImgSubImage(image, x, y, width, height)
XImage *image;
int x;
int y;
unsigned int width;
unsigned int height;
{
 return NULL;
}


/*
 *----------------------------------------------------------------------
 *
 * PutPixel --
 *
 *	Set a single pixel in an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
ImgPutPixel(image, x, y, pixel)
    XImage *image;
    int x, y;
    unsigned long pixel;
{
    char *destPtr = &(image->data[(y * image->bytes_per_line)
    	+ (x * (image->bits_per_pixel >> 3))]);
    switch  (image->bits_per_pixel) {
	case 32:
	    destPtr[3] = 0;
	case 24:
	    destPtr[0] = GetBValue(pixel);
	    destPtr[1] = GetGValue(pixel);
	    destPtr[2] = GetRValue(pixel);
	    break;
	case 16:
	    destPtr[1] = (char) pixel>>8;
	case 8:
	    destPtr[0] = (char) pixel;
	    break;
	case 1: {
	    int offset = x%8;
	    if (pixel) {
		destPtr[0] |= 1<< offset;
	    } else {
		destPtr[0] & 0<< offset;
	    }
	}
	break;
    }
    return 0;
}

static int
ImgDestroy(image)
XImage *image;
{
    if (image) {
	ckfree(image);
    }
    return 0;
}

/*
 *----------------------------------------------------------------------
 *
 * XCreateImage --
 *
 *	Allocates storage for a new XImage.
 *
 * Results:
 *	Returns a newly allocated XImage.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

XImage *
XCreateImage(display, visual, depth, format, offset, data, width, height,
	bitmap_pad, bytes_per_line)
    Display* display;
    Visual* visual;
    unsigned int depth;
    int format;
    int offset;
    char* data;
    unsigned int width;
    unsigned int height;
    int bitmap_pad;
    int bytes_per_line;
{
    XImage* imagePtr = (XImage *) ckalloc(sizeof(XImage));
    imagePtr->width = width;
    imagePtr->height = height;
    imagePtr->xoffset = offset;
    imagePtr->format = format;
    imagePtr->data = data;
    imagePtr->byte_order = LSBFirst;
    imagePtr->bitmap_unit = 32;
    imagePtr->bitmap_bit_order = LSBFirst;
    imagePtr->bitmap_pad = bitmap_pad;
    imagePtr->depth = depth;

    /*
     * Round to the nearest word boundary.
     */
    
    imagePtr->bytes_per_line = bytes_per_line ? bytes_per_line
 	: ((depth * width + 31) >> 3) & ~3;

    imagePtr->bits_per_pixel = depth;
    imagePtr->red_mask = visual->red_mask;
    imagePtr->green_mask = visual->green_mask;
    imagePtr->blue_mask = visual->blue_mask;
    imagePtr->f.create_image = NULL;
    imagePtr->f.destroy_image = ImgDestroy;
    imagePtr->f.put_pixel = ImgPutPixel;
    imagePtr->f.get_pixel = ImgGetPixel;
    imagePtr->f.sub_image = ImgSubImage;
    imagePtr->f.add_pixel = ImgAddPixel;
    
    return imagePtr;
}
