/*
  Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include <patchlevel.h>

#include "tkGlue.def"

static STRLEN na; /* Quick and dirty fix */

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "pTk/tkXrm.h"
#include "pTk/default.h"

#if defined(__WIN32__) && !defined(__EMX__)
#  include "pTk/tkWinInt.h"
#endif

#include "tkGlue.h"

#ifdef NEED_PRELOAD
#ifdef I_DLFCN
#include <dlfcn.h>	/* the dynamic linker include file for Sunos/Solaris */
#else
#include <nlist.h>
#include <link.h>
#endif
#define NeedPreload() 1
#else

#define NeedPreload() 0
#endif

#define Tk_tainting() (PL_tainting)
#define Tk_tainted(sv) ((sv) ? SvTAINTED(sv) : PL_tainted)

static void
DebugHook(SV *sv)
{

}

#define pTk_exit(status) Tcl_Exit(status)

#define XEvent_DESTROY(obj)

#define Tk_XRaiseWindow(w) XRaiseWindow(Tk_Display(w),Tk_WindowId(w))

#define Const_DONT_WAIT()     (TCL_DONT_WAIT)
#define Const_WINDOW_EVENTS() (TCL_WINDOW_EVENTS)
#define Const_FILE_EVENTS()   (TCL_FILE_EVENTS)
#define Const_TIMER_EVENTS()  (TCL_TIMER_EVENTS)
#define Const_IDLE_EVENTS()   (TCL_IDLE_EVENTS)
#define Const_ALL_EVENTS()    (TCL_ALL_EVENTS)

#ifndef SELECT_FG
/* Should really depend on color/mono */
#define SELECT_FG BLACK
#endif

#define Const_NORMAL_BG()     (NORMAL_BG)
#define Const_ACTIVE_BG()     (ACTIVE_BG)
#define Const_SELECT_BG()     (SELECT_BG)
#define Const_SELECT_FG()     (SELECT_FG)
#define Const_TROUGH()        (TROUGH)
#define Const_INDICATOR()     (INDICATOR)
#define Const_DISABLED()      (DISABLED)
#define Const_BLACK()         (BLACK)
#define Const_WHITE()         (WHITE)

static XFontStruct * TkwinFont _((Tk_Window tkwin, Tk_Uid name));

static void pTk_DefineBitmap _((Tk_Window tkwin, char *name,
                               int width, int height, SV *source));

static void
pTk_DefineBitmap (tkwin, name, width, height, source)
Tk_Window tkwin;
char *name;
int width;
int height;
SV *source;
{
 Tcl_Interp *interp;
 if (TkToWidget(tkwin,&interp) && interp)
  {STRLEN len;
   unsigned char *data = (unsigned char *) SvPV(source, len);
   STRLEN byte_line = (width + 7) / 8;
   if (len == height * byte_line)
    {
     Tcl_ResetResult(interp);
     if (Tk_DefineBitmap(interp, Tk_GetUid(name), data, width, height) != TCL_OK)
      croak(Tcl_GetResult(interp));
    }
   else
    {
     croak("Data wrong size for %dx%d bitmap",width,height);
    }
  }
 else
  {
   croak("Invalid widget");
  }
}

#define pTk_Synchronize(win,flag) \
   XSynchronize(Tk_Display(win), flag)

static IV
PointToWindow(Tk_Window tkwin, int x, int y, Window dest)
{
 Display *dpy = Tk_Display(tkwin);
 Window root = RootWindowOfScreen(Tk_Screen(tkwin));
 Window win;
 if (dest == None)
  dest = root;
 if (!XTranslateCoordinates(dpy, root, dest, x, y, &x, &y, &win))
  {
   win = None;
  }
 return (IV) win;
}


MODULE = Tk	PACKAGE = Tk	PREFIX = Const_
PROTOTYPES: ENABLE

char *
Const_BLACK()

char *
Const_WHITE()

char *
Const_NORMAL_BG()

char *
Const_ACTIVE_BG()

char *
Const_SELECT_BG()

char *
Const_SELECT_FG()

char *
Const_TROUGH()

char *
Const_INDICATOR()

char *
Const_DISABLED()


IV
Const_DONT_WAIT()

IV
Const_WINDOW_EVENTS()

IV
Const_FILE_EVENTS()

IV
Const_TIMER_EVENTS()

IV
Const_IDLE_EVENTS()

IV
Const_ALL_EVENTS()

MODULE = Tk	PACKAGE = Tk::Xrm	PREFIX = Xrm_
PROTOTYPES: DISABLE

void
Xrm_import(class,...)
char *	class

MODULE = Tk	PACKAGE = XEvent	PREFIX = XEvent_

void
XEvent_Info(obj,s)
EventAndKeySym *	obj
char *	s
CODE:
{
 ST(0) = XEvent_Info(obj,s);
}

void
XEvent_DESTROY(obj)
SV *	obj

MODULE = Tk	PACKAGE = Tk::MainWindow	PREFIX = pTk_

PROTOTYPES: DISABLE

void
pTk_Synchronize(win,flag = True)
Tk_Window	win
int		flag

int
Count(self)
SV *	self
CODE:
 {
  ST(0) = sv_2mortal(newSViv(Tk_GetNumMainWindows()));
 }


MODULE = Tk	PACKAGE = Tk::Callback	PREFIX = Callback_

void
new(package,what)
char *	package
SV *	what
CODE:
 {
  ST(0) = sv_2mortal(sv_bless(LangMakeCallback(what),gv_stashpv(package, TRUE)));
 }

void
Substitute(cb,src,dst)
SV *	cb
SV *	src
SV *	dst
CODE:
{
 if (!SvROK(cb))
  croak("callback is not a reference");
 cb = SvRV(cb);
 if (!SvROK(src))
  croak("src is not a reference");
 src = SvRV(src);
 if (!SvROK(dst))
  croak("dst is not a reference");

 if (SvTYPE(cb) == SVt_PVAV)
  {
   AV *av = newAV();
   int n = av_len((AV *) cb);
   int i;
   int match = 0;
   for (i=0; i <= n; i++)
    {
     SV **svp = av_fetch((AV *) cb,i,0);
     if (svp)
      {
       if (SvROK(*svp) && SvRV(*svp) == src)
        {
         av_store(av, i, SvREFCNT_inc(dst));
         match++;
        }
       else
        {
         av_store(av, i, SvREFCNT_inc(*svp));
        }
      }
    }
   if (match)
    {
     ST(0) = sv_2mortal(sv_bless(MakeReference((SV *) av),SvSTASH(cb)));
    }
   else
    {
     SvREFCNT_dec(av);
    }
  }
}

MODULE = Tk	PACKAGE = Tk	PREFIX = Tk

int
NeedPreload()

void
Preload(filename)
    char *		filename
    CODE:
#ifdef NEED_PRELOAD
    void *h = dlopen(filename, RTLD_LAZY|RTLD_GLOBAL) ;
    if (!h)
     croak("Cannot load %s",filename);
#endif

double
timeofday()
CODE:
{
 Tcl_Time t;
 TclpGetTime(&t);
 RETVAL = t.sec + (double) t.usec/1e6;
}
OUTPUT:
 RETVAL

TkWindow *
TkGetFocusWin(win)
TkWindow *	win

void
TkGetPointerCoords(win)
Tk_Window	win
PPCODE:
 {
  int x, y;
  TkGetPointerCoords(win, &x, &y);
  PUSHs(sv_2mortal(newSViv(x)));
  PUSHs(sv_2mortal(newSViv(y)));
 }

MODULE = Tk	PACKAGE = Tk	PREFIX = pTk_

void
pTk_exit(status = 0)
int	status

MODULE = Tk	PACKAGE = Tk	PREFIX = Tk_

void
Tk_CheckHash(widget)
SV *	widget
CODE:
 {
  Tk_CheckHash(widget,NULL);
 }

void
Debug(widget,string)
SV *	widget;
char *	string
CODE:
 {
  LangDumpVec(string,1,&SvRV(widget));
 }

void
WidgetMethod(widget,name,...)
SV *	widget;
SV *	name;
CODE:
 {
  Lang_CmdInfo *info = WindowCommand(widget, NULL, 1);
  XSRETURN(Call_Tk(info, items, &ST(0)));
 }

void
OldEnterMethods(package,file,...)
char *	package
char *	file
CODE:
 {int i;
  char buf[80];  /* FIXME Size of buffer */
  for (i=2; i < items; i++)
   {
    STRLEN len;
    SV *method = newSVsv(ST(i));
    CV *cv;
    sprintf(buf, "%s::%s", package, SvPV(method,len));
    cv = newXS(buf, XStoWidget, file);
    CvXSUBANY(cv).any_ptr = method;
   }
 }

IV
GetFILE(arg,w)
SV *	arg
int	w
CODE:
 {
  IO *io = sv_2io(arg);
  RETVAL = -1;
  if (io)
   {
    PerlIO *f = (w) ? IoOFP(io) : IoIFP(io);
    if (f)
     {
      RETVAL = PerlIO_fileno(f);
     }
   }
 }
OUTPUT:
 RETVAL

MODULE = Tk	PACKAGE = Tk::Widget	PREFIX = pTk_

IV
PointToWindow(tkwin,x,y,parent = None)
Tk_Window	tkwin
int		x
int		y
IV		parent

void
WindowXY(tkwin,src = None, dst = None)
Tk_Window	tkwin
IV		src
IV		dst
PPCODE:
{
 Display *dpy = Tk_Display(tkwin);
 Window root = RootWindowOfScreen(Tk_Screen(tkwin));
 int x = 0;
 int y = 0;
 if (src == None)
  src = Tk_WindowId(tkwin);
 if (dst == None)
  dst = root;
 XTranslateCoordinates(dpy, src, dst, 0, 0, &x, &y, &root);
 XPUSHs(sv_2mortal(newSViv(x)));
 XPUSHs(sv_2mortal(newSViv(y)));
}

void
pTk_DefineBitmap (win, name, width, height, source)
Tk_Window	win;
char *	name;
int	width;
int	height;
SV *	source;

void
pTk_GetBitmap(tkwin, name)
Tk_Window	tkwin;
char *	name;
PPCODE:
 {
  Tcl_Interp *interp;
  Pixmap pixmap;
  if (TkToWidget(tkwin,&interp) && interp)
   {
    pixmap = Tk_GetBitmap(interp, tkwin, name);
    if (pixmap == None)
     PUSHs(&PL_sv_undef);
    else
     PUSHs(sv_2mortal(newSViv((IV)pixmap)));
   }
  else
   {
    croak("Invalid widget");
   }
 }


MODULE = Tk	PACKAGE = Tk::Widget	PREFIX = Tk_

void
UnmanageGeometry(win)
Tk_Window	win
CODE:
 {
  Tk_ManageGeometry(win, NULL, NULL);
 }

void
DisableButtonEvents(win)
Tk_Window	win
CODE:
 {
  Tk_Attributes(win)->event_mask
    &= ~(ButtonPressMask | ButtonReleaseMask | ButtonMotionMask);
  Tk_ChangeWindowAttributes(win, CWEventMask, Tk_Attributes(win));
 }


int
SendClientMessage(win,type,xid,format,data)
Tk_Window	win
char *		type
IV		xid
IV		format
SV *		data
CODE:
 {
  XClientMessageEvent cM;
  STRLEN len;
  char *s = SvPV(data,len);
  if (len > sizeof(cM.data))
   len = sizeof(cM.data);
  cM.type = ClientMessage;
  cM.serial  = 0;
  cM.send_event = 0;
  cM.display = Tk_Display(win);
  cM.window = xid;
  cM.message_type = Tk_InternAtom(win,type);
  cM.format = format;
  memmove(cM.data.b,s,len);
  if ((RETVAL = XSendEvent(cM.display, cM.window, False, NoEventMask, (XEvent *) & cM)))
   {
    /* XSync may be overkill - but need XFlush ... */
    XSync(cM.display, False);
   }
  else
   {
    croak("XSendEvent failed");
   }
 }
OUTPUT:
  RETVAL

void
XSync(win,flush)
Tk_Window	win
int		flush
CODE:
 {
  XSync(Tk_Display(win),flush);
 }

void
Tk_GetRootCoords(win)
Tk_Window	win
PPCODE:
 {
  int x, y;
  Tk_GetRootCoords(win, &x, &y);
  PUSHs(sv_2mortal(newSViv(x)));
  PUSHs(sv_2mortal(newSViv(y)));
 }

void
Tk_GetVRootGeometry(win)
Tk_Window	win
PPCODE:
 {
  int x, y;
  int width, height;
  Tk_GetVRootGeometry(win, &x, &y, &width, &height);
  PUSHs(sv_2mortal(newSViv(x)));
  PUSHs(sv_2mortal(newSViv(y)));
  PUSHs(sv_2mortal(newSViv(width)));
  PUSHs(sv_2mortal(newSViv(height)));
 }

Colormap
Tk_Colormap(win)
Tk_Window	win

Display *
Tk_Display(win)
Tk_Window	win

int
Tk_ScreenNumber(win)
Tk_Window	win

Screen *
Tk_Screen(win)
Tk_Window	win

Visual *
Tk_Visual(win)
Tk_Window	win

Window
Tk_WindowId(win)
Tk_Window	win

int
Tk_X(win)
Tk_Window	win

int
Tk_Y(win)
Tk_Window	win

int
Tk_ReqWidth(win)
Tk_Window	win

int
Tk_ReqHeight(win)
Tk_Window	win

int
Tk_Width(win)
Tk_Window	win

int
Tk_Height(win)
Tk_Window	win

int
Tk_IsMapped(win)
Tk_Window	win

int
Tk_Depth(win)
Tk_Window	win

int
Tk_InternalBorderWidth(win)
Tk_Window	win

int
Tk_IsTopLevel(win)
Tk_Window	win

char *
Tk_Name(win)
Tk_Window	win

char *
Tk_PathName(win)
Tk_Window	win

char *
Tk_Class(win)
Tk_Window	win

void
Tk_MakeWindowExist(win)
Tk_Window	win

void
Tk_SetClass(win,class)
Tk_Window	win
char *		class

void
Tk_MoveWindow(win,x,y)
Tk_Window	win
int		x
int		y

void
Tk_XRaiseWindow(win)
Tk_Window	win

void
Tk_MoveToplevelWindow(win,x,y)
Tk_Window	win
int		x
int		y

void
Tk_MoveResizeWindow(win,x,y,width,height)
Tk_Window	win
int		x
int		y
int		width
int		height

void
Tk_ResizeWindow(win,width,height)
Tk_Window	win
int		width
int		height

void
Tk_GeometryRequest(win,width,height)
Tk_Window	win
int		width
int		height

void
Tk_MaintainGeometry(slave,master,x,y,width,height)
Tk_Window	slave
Tk_Window	master
int		x
int		y
int		width
int		height

void
Tk_SetGrid(win,reqWidth,reqHeight,gridWidth,gridHeight)
Tk_Window	win
int		reqWidth
int		reqHeight
int		gridWidth
int		gridHeight


void
Tk_UnmaintainGeometry(slave,master)
Tk_Window	slave
Tk_Window	master

void
Tk_MapWindow(win)
Tk_Window	win

void
Tk_UnmapWindow(win)
Tk_Window	win

void
Tk_UnsetGrid(win)
Tk_Window	win

void
Tk_AddOption(win,name,value,priority)
Tk_Window	win
char *	name
char *	value
int	priority

char *
Tk_GetAtomName(win,atom)
Tk_Window	win
Atom		atom

void
Tk_ClearSelection(win,selection)
Tk_Window	win
Atom		selection

char *
Tk_DisplayName(win)
Tk_Window	win

char *
Tk_GetOption(win,name,class)
Tk_Window	win
char *	name
char *	class

IV
Tk_InternAtom(win,name)
Tk_Window	win
char *		name

void
Tk_Ungrab(win)
Tk_Window	win

char *
Tk_SetAppName(win,name)
Tk_Window	win
char *		name

int
IsWidget(win)
SV *	win
CODE:
 {
  if (!SvROK(win) || SvTYPE(SvRV(win)) != SVt_PVHV)
   RETVAL = 0;
  else
   {
    Lang_CmdInfo *info = WindowCommand(win,NULL,0);
    RETVAL = (info && info->tkwin);
   }
 }
OUTPUT:
 RETVAL

int
Tk_Grab(win,global)
SV *	win
int	global
CODE:
 {
  Lang_CmdInfo *info = WindowCommand(win,NULL,3);
  RETVAL = Tk_Grab(info->interp,info->tkwin,global);
 }

SV *
Widget(win,path)
SV *	win
char *	path
CODE:
 {
  Lang_CmdInfo *info = WindowCommand(win,NULL,1);
  ST(0) = sv_mortalcopy(WidgetRef(info->interp,path));
 }

Tk_Window
Containing(win,X,Y)
Tk_Window	win
int	X
int	Y
CODE:
 {
  RETVAL = Tk_CoordsToWindow(X, Y, win);
 }
OUTPUT:
  RETVAL

Tk_Window
Tk_Parent(win)
Tk_Window	win

SV *
MainWindow(interp)
Tcl_Interp *	interp
CODE:
 {
  RETVAL = SvREFCNT_inc(WidgetRef(interp,"."));
 }
OUTPUT:
 RETVAL

MODULE = Tk	PACKAGE = Tk	PREFIX = Tcl_

void
Tcl_AddErrorInfo(interp,message)
Tcl_Interp *	interp
char *		message

void
Tcl_BackgroundError(interp)
Tcl_Interp *	interp

void
Fail(interp,message)
Tcl_Interp *	interp
char *		message
CODE:
 {
  Tcl_SetResult(interp,message,TCL_VOLATILE);
  Tcl_BackgroundError(interp);
 }

int
Tcl_DoOneEvent(...)
CODE:
 {
  int flags = 0;
  if (items)
   {int i;
    for (i=0; i < items; i++)
     {
      SV *sv = ST(i);
      if (SvIOK(sv) || looks_like_number(sv))
       flags |= SvIV(sv);
      else if (!sv_isobject(sv))
       {STRLEN l;
        char *s = SvPV(sv,l);
        if (strcmp(s,BASEEXT))
         {
          /* string to integer lookup here */
          croak("Usage [$object->]DoOneEvent([flags]) got '%s'\n",s);
         }
       }
     }
   }
  RETVAL = Tcl_DoOneEvent(flags);
 }
OUTPUT:
  RETVAL

MODULE = Tk	PACKAGE = Tk::Font	PREFIX = Font_

void
Font_DESTROY(sv)
SV *	sv

MODULE = Tk	PACKAGE = Tk::Font	PREFIX = Tk_

int
Tk_PostscriptFontName(tkfont,name)
Tk_Font	tkfont
SV *	&name
OUTPUT:
	name


MODULE = Tk	PACKAGE = Tk	PREFIX = Tk_

void
abort()

int
Tk_tainting()

int
Tk_tainted(sv = NULL)
SV *	sv

void
DebugHook(arg)
SV *	arg

void
ClearErrorInfo(win)
SV *	win

BOOT:
 {
#ifdef WIN32
  /* Force inclusion of DllMain() */
  TkWin32DllPresent();
#endif
  Boot_Glue();
 }

