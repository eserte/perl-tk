#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "../tkGlue.def"

#include "tkPort.h"
#include "tkInt.h"
#include "tkVMacro.h"
#include "../tkGlue.h"
#include "../tkGlue.m"

DECLARE_VTABLES;

/* A few sample routines to get at Xlib via perl 
   Will eventaually be extended to the point where
   simple pTk widgets can be *implemented* in perl

   Main stumbling block is a clean way of filling in 
   a GC.

   The XDraw*() functions may be a bit messy, but 
   should be okay via CODE: bodies and variable number 
   of args and/or passing in array refs
*/


static IV
SvGCIVOBJ(class,sv)
char *class;
SV *sv;
{
 if (sv_isa(sv, class)) 
  return SvIV((SV*)SvRV(sv));
 else
  croak("Not of type %s",class);
 return 0;
}

#define SvGCint(x)           SvIV(x)
#define SvGCBool(x)          SvIV(x)
#define SvGCunsigned_long(x) SvIV(x)
#define SvGCPixmap(x)        (Pixmap) SvGCIVOBJ("Pixmap",x)
#define SvGCFont(x)          (Font)   SvGCIVOBJ("Font",x)

#define GCField(name,bit,field,func) \
 if (!strcmp(key,name)) {            \
  values->field = func(value);       \
  valuemask |= bit;                  \
 } else                              

unsigned long 
GCSetValue(valuemask,values,key,value)
unsigned long valuemask;
XGCValues *values;
char *key;
SV *value;
{
#include "GC.def"
 croak("Setting GC %s not implemented",key);
 return valuemask;
}


MODULE = Tk::Xlib	PACKAGE = ScreenPtr

int
WidthOfScreen(s)
Screen *	s

int
WidthMMOfScreen(s)
Screen *	s

int
HeightOfScreen(s)
Screen *	s

int
HeightMMOfScreen(s)
Screen *	s

GC
DefaultGCOfScreen(s)
Screen *	s

unsigned long
BlackPixelOfScreen(s)
Screen *	s

unsigned long
WhitePixelOfScreen(s)
Screen *	s

MODULE = Tk::Xlib	PACKAGE = DisplayPtr

Font
XLoadFont(dpy,name)
Display *	dpy
char *		name

void
XDrawRectangle(dpy,win,gc,x,y,width,height)
Display *	dpy
Window		win
GC		gc
int		x
int		y
int		width
int		height

void
XDrawString(dpy,win,gc,x,y,string)
Display *	dpy
Window		win
GC		gc
int		x
int		y
SV *		string
CODE:
 {
  if (SvOK(string))
   {STRLEN len;
    char *s = SvPV(string,len);
    if (s && len)
     {
      XDrawString(dpy,win,gc,x,y,s,len);
     }
   }
 }

Window
RootWindow(dpy,scr)
Display *	dpy
int		scr

char *
DisplayString(dpy)
Display *	dpy

int
DefaultScreen(dpy)
Display *	dpy

Screen *
ScreenOfDisplay(dpy,scr)
Display *	dpy
int		scr

GC
DefaultGC(dpy,scr)
Display *	dpy
int		scr

MODULE = Tk::Xlib	PACKAGE = GC	PREFIX = XSet

static GC
GC::new(dpy,win,...)
Display *	dpy
Window		win
CODE:
  {unsigned long valuemask = 0;
   XGCValues values;
   int i;
   for (i=3; i < items; i += 2)
    {char *key = SvPV(ST(i),na);
     if (i+1 < items)
      valuemask = GCSetValue(valuemask,&values,key,ST(i+1));
     else
      croak("No value for %s",key);
    }
   RETVAL = XCreateGC(dpy,win,valuemask,&values);
  }
OUTPUT:
  RETVAL

void
XSetForeground(dpy,gc,val)
Display *	dpy
GC		gc
unsigned long	val 

BOOT:
 {
  IMPORT_VTABLES;
 }

