/*
  Copyright (c) 1995 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include <tkGlue.def>

#include <pTk/tkPort.h>
#include <pTk/tkInt.h>
#include <pTk/tkImgPhoto.h>
#include <pTk/tkImgPhoto.m>
#include <pTk/tkVMacro.h>
#include <tkGlue.h>
#include <tkGlue.m>

#undef memcpy

/*
 * The format record for the Window file format:
 */

static int      FileMatchWindow _ANSI_ARGS_((Tcl_Channel chan, Arg fileName,
		    char *formatString, int *widthPtr, int *heightPtr));
static int      FileReadWindow  _ANSI_ARGS_((Tcl_Interp *interp,
		    Tcl_Channel chan, Arg fileName, char *formatString,
		    Tk_PhotoHandle imageHandle, int destX, int destY,
		    int width, int height, int srcX, int srcY));
static int	StringMatchWindow _ANSI_ARGS_(( Tcl_Obj *dataObj,
		    char *formatString, int *widthPtr, int *heightPtr));
static int	StringReadWindow _ANSI_ARGS_((Tcl_Interp *interp, Tcl_Obj *dataObj,
		    char *formatString, Tk_PhotoHandle imageHandle,
		    int destX, int destY, int width, int height,
		    int srcX, int srcY));

Tk_PhotoImageFormat tkImgFmtWindow = {
	"Window",			/* name */
	FileMatchWindow,   /* fileMatchProc */
	StringMatchWindow, /* stringMatchProc */
	FileReadWindow,    /* fileReadProc */
	StringReadWindow,  /* stringReadProc */
	NULL,           /* fileWriteProc */
	NULL,           /* stringWriteProc */
};          

static int
FileMatchWindow(chan, fileName, formatString, widthPtr, heightPtr)
    Tcl_Channel chan;		/* The image file, open for reading. */
    Arg fileName;		/* The name of the image file. */
    char *formatString;		/* User-specified format string, or NULL. */
    int *widthPtr, *heightPtr;	/* The dimensions of the image are
				 * returned here if the file is a valid
				 * raw Window file. */
{
	return TCL_ERROR;
}


static int
FileReadWindow(interp, chan, fileName, formatString, imageHandle, destX, destY,
	width, height, srcX, srcY)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    Tcl_Channel chan;		/* The image file, open for reading. */
    Arg fileName;		/* The name of the image file. */
    char *formatString;		/* User-specified format string, or NULL. */
    Tk_PhotoHandle imageHandle;	/* The photo image to write into. */
    int destX, destY;		/* Coordinates of top-left pixel in
				 * photo image to be written to. */
    int width, height;		/* Dimensions of block of photo image to
				 * be written to. */
    int srcX, srcY;		/* Coordinates of top-left pixel to be used
				 * in image being read. */
{    
 return TCL_ERROR;
}                   
 
static int
DataToWin(Tcl_Obj *sv, Display **dpy, Window *win)
{  
 *win = None;
 if (SvROK(sv) && SvTYPE(SvRV(sv)) == SVt_PVAV)
  {                   
   AV *av = (AV *) SvRV(sv);
   SV **svp = av_fetch(av, 0, 0);
   Tk_Window tkwin = NULL;
   if (!svp || !(tkwin = SVtoWindow(*svp)))
    return 0;
   *dpy = Tk_Display(tkwin);
   if (av_len(av) == 2)
    {
     Window root = RootWindowOfScreen(Tk_Screen(tkwin));
     int x = 0;
     int y = 0;
     svp = av_fetch(av,1,0);
     if (svp)
      x = SvIV(*svp);
     svp = av_fetch(av,2,0);
     if (svp)
      y = SvIV(*svp);      
     return XTranslateCoordinates(*dpy, root, root, x, y, &x, &y, win);
    }
   else if (av_len(av) == 1)
    {          
     svp = av_fetch(av,1,0);
     if (svp && SvIOK(*svp))
      {
       *win = (Window) SvIV(*svp);
       return 1; 
      }
    }
   return 0;
  }
 else
  {
   Tk_Window tkwin = SVtoWindow(sv);
   if (tkwin)
    {
     *dpy = Tk_Display(tkwin);
     *win = Tk_WindowId(tkwin);
     return 1;
    }
  }
 return 0;
}

static int
StringMatchWindow(dataObj, formatString, widthPtr, heightPtr)
    Tcl_Obj *dataObj;		/* the object containing the image data */
    char *formatString;		/* the image format string */
    int *widthPtr;		/* where to put the string width */
    int *heightPtr;		/* where to put the string height */
{                              
 Display *dpy = NULL;
 Window  win = None;
 if (DataToWin(dataObj,&dpy,&win))
  {
   XWindowAttributes attr;
   XGetWindowAttributes(dpy, win, &attr);
   *widthPtr  = attr.width;
   *heightPtr = attr.height;
   return 1;
  }
 return 0;
}                                                       

static int
StringReadWindow(interp,dataObj,formatString,imageHandle,
	destX, destY, width, height, srcX, srcY)
    Tcl_Interp *interp;		/* interpreter for reporting errors in */
    Tcl_Obj *dataObj;		/* object containing the image */
    char *formatString;		/* format string if any */
    Tk_PhotoHandle imageHandle;	/* the image to write this data into */
    int destX, destY;		/* The rectangular region of the  */
    int  width, height;		/*   image to copy */
    int srcX, srcY;
{    
 Display *dpy = NULL;
 Window  win = None;
 int x;
 int y;
 unsigned char *p;
 Tk_PhotoImageBlock block;
 if (DataToWin(dataObj,&dpy,&win))
  {
   XWindowAttributes attr;
   XImage *img;
   XColor color;
   Tcl_HashTable ctable;
   XGetWindowAttributes(dpy, win, &attr);
   Tcl_InitHashTable(&ctable, TCL_ONE_WORD_KEYS);   
   if (srcX+width > attr.width)
    {
     width = attr.width - srcX;
    }
   if (srcY+height > attr.height)
    {
     height = attr.height - srcY;
    }
   if (width <= 0 || height <= 0)
    {
     return TCL_ERROR;
    }
   img = XGetImage(dpy, win, srcX, srcY, width, height, 
                   (unsigned long) -1, XYPixmap);
   
   Tk_PhotoGetImage(imageHandle, &block);
   block.offset[3] = (block.pixelSize > 3) ? 3 : 0;
   block.width = width;            
   block.pitch = block.pixelSize * width;
   block.height = height;          
   block.pixelPtr = (unsigned char *) 
                         ckalloc((unsigned) block.pixelSize * width * height);
   p = block.pixelPtr;             
   for (y = 0; y < height; y++)    
    {                              
     for (x = 0; x < width; x++)   
      {                      
       unsigned char *p = block.pixelPtr+(y*block.pitch)+(x*block.pixelSize);
       Tcl_HashEntry *he;
       int new = 0;
       ClientData cd = 0;
       color.pixel = (*img->f.get_pixel)(img, srcX+x, srcY+y);              
       he = Tcl_CreateHashEntry(&ctable,(char *) color.pixel, &new);
       if (new)
        {
         XQueryColor(dpy, attr.colormap, &color);
         p[0] = color.red   >> 8;         
         p[1] = color.green >> 8;        
         p[2] = color.blue  >> 8;                   
         if (block.pixelSize > 3)    
          p[3] = 255;                
         Copy(p,&cd,block.pixelSize,unsigned char);
         Tcl_SetHashValue(he, cd); 
        }
       else
        {
         cd = Tcl_GetHashValue(he);
         Copy(&cd, p, block.pixelSize,unsigned char); 
        }
      }                            
    }                              
   Tk_PhotoExpand(imageHandle, destX + width, destY + height);
   Tk_PhotoPutBlock(imageHandle, &block, destX, destY, width, height);
   Tcl_DeleteHashTable(&ctable);
   (*img->f.destroy_image)(img);
   ckfree((char *) block.pixelPtr);
  }
 else
  {   
   croak("Cannot get Mainwindow");
  }
 return TCL_OK;
}


DECLARE_VTABLES;
TkimgphotoVtab *TkimgphotoVptr;

MODULE = Tk::WinPhoto	PACKAGE = Tk::WinPhoto

PROTOTYPES: DISABLE

BOOT:
 {
  IMPORT_VTABLES;
  TkimgphotoVptr  =   (TkimgphotoVtab *) SvIV(FindTkVarName("TkimgphotoVtab",5));    \
  Tk_CreatePhotoImageFormat(&tkImgFmtWindow);
 }
