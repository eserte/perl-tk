/*
  Copyright (c) 1995 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "tkGlue.h"
#include "leak_util.h"

Tk_Window mainWindow = NULL;

MODULE = Tk	PACKAGE = MainWindow

int
Count(self)
SV *	self
CODE:
 {
  ST(0) = sv_2mortal(newSViv(tk_NumMainWindows));
 }


SV *
CreateMainWindow(name, Class, ...)
	char *		name
	char *		Class
    CODE:
       {
        Tcl_Interp *interp = Tcl_CreateInterp(); 
        char *display = NULL;
        int  sync     = 0; 
        RETVAL = &sv_undef; 
        
        if (items > 3)
         display = (char *)SvPV(ST(2),na);

        if (items > 4)
          sync = (int)SvIV(ST(3));

        if ((mainWindow = Tk_CreateMainWindow(interp, display, name, Class)))
         {
          if (sync)
           XSynchronize(Tk_Display(mainWindow), True);

          RETVAL = SvREFCNT_inc(TkToWidget(mainWindow,NULL));
         }
        else 
         croak(Tcl_GetResult(interp));
       }
    OUTPUT:
        RETVAL

MODULE = Tk	PACKAGE = Leak

IV
NoteSV(obj)
hash_ptr *	obj = NO_INIT
CODE:
 {
  RETVAL = note_used(&obj);
 }
OUTPUT:
 obj
 RETVAL

IV
CheckSV(obj)
hash_ptr *	obj
CODE:
 {
  RETVAL = check_used(&obj);
 }
OUTPUT:
 RETVAL

MODULE = Tk	PACKAGE = Tk::Callback

void
new(package,what)
char *	package
SV *	what
CODE:
 {
  ST(0) = sv_bless(LangMakeCallback(what),gv_stashpv(package, TRUE));
 }

void 
DESTROY(object)
SV *	object
CODE:
 {
  XSRETURN_UNDEF;
 }

MODULE = Tk	PACKAGE = Tk	PREFIX = Tk

TkWindow *
TkGetFocus(win)
TkWindow *	win

void
TkGetPointerCoords(win)
Tk_Window	win
PPCODE:
 {
  int x, y;
  TkGetPointerCoords(win, &x, &y);
  if (items < 2)
   {
    EXTEND(sp,2-items);
   }
  ST(0) = sv_2mortal(newSViv(x));
  ST(1) = sv_2mortal(newSViv(y));
  XSRETURN(2);
 }

MODULE = Tk	PACKAGE = Tk	PREFIX = Tk_

void
EnterMethods(package,file,...)
char *	package
char *	file
CODE:
 {int i;
  char buf[80];
  for (i=2; i < items; i++)
   {
    SV *method = newSVsv(ST(i));
    CV *cv;                        
    sprintf(buf, "%s::%s", package, SvPV(method,na));
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
    FILE *f = (w) ? IoOFP(io) : IoIFP(io);
    if (f)          
     {              
      RETVAL = fileno(f);
     }              
   }
 }
OUTPUT:
 RETVAL

void
Tk_MainLoop(class = "Tk")
char *	class
CODE:
 Tk_MainLoop(); 

int
Tk_DoOneEvent(...)
CODE:
 {
  int flags = 0;
  if (items)
   {int i;
    for (i=0; i < items; i++)
     {
      SV *sv = ST(i);
      if (SvIOK(sv))
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
  RETVAL = Tk_DoOneEvent(flags);
 }
OUTPUT:
  RETVAL


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

void
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
  if (XSendEvent(cM.display, cM.window, False, NoEventMask, (XEvent *) & cM))
   {
    /* XSync may be overkill - but need XFlush ... */
    XSync(cM.display, False);
    XSRETURN_YES;
   }
  croak("XSendEvent failed");
  XSRETURN_NO;
 }

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
  if (items < 2)
   {
    EXTEND(sp, 2 - items);
   }
  ST(0) = sv_2mortal(newSViv(x));
  ST(1) = sv_2mortal(newSViv(y));
  XSRETURN(2);
 }

void
Tk_GetVRootGeometry(win)
Tk_Window	win
PPCODE:
 {
  int x, y;
  int width, height;
  Tk_GetVRootGeometry(win, &x, &y, &width, &height);
  if (items < 4)
   {
    EXTEND(sp, 4 - items);
   }
  ST(0) = sv_2mortal(newSViv(x));
  ST(1) = sv_2mortal(newSViv(y));
  ST(2) = sv_2mortal(newSViv(width));
  ST(3) = sv_2mortal(newSViv(height));
  XSRETURN(4);
 } 

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
    Lang_CmdInfo *info = WindowCommand(win,NULL);
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
  Lang_CmdInfo *info = WindowCommand(win,NULL);
  RETVAL = Tk_Grab(info->interp,info->tkwin,global);
 }

SV *
Widget(win,path)
SV *	win
char *	path
CODE:
 {
  Lang_CmdInfo *info = WindowCommand(win,NULL);
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
MainWindow(win)
	SV *	win
    CODE:
     {
      RETVAL = SvREFCNT_inc(WidgetRef(WindowCommand(win,NULL)->interp,".")); 
     }
    OUTPUT:
     RETVAL

MODULE = Tk	PACKAGE = Tk	PREFIX = Tk_

void
AddErrorInfo(win,message)
SV *	win
char *	message
CODE:
 {
  Tcl_AddErrorInfo(WindowCommand(win,NULL)->interp,message);
 }

void
ClearErrorInfo(win)
SV *	win


BOOT:
 {
  Boot_Glue();
 } 

