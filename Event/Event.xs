/*
  Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "tkGlue.def"


#define TCL_EVENT_IMPLEMENT
#include "pTk/Lang.h"
#include "pTk/tkEvent.h"
#include "pTk/tkEvent.m"

void
LangDebug(char *fmt,...)
{
 va_list ap;
 va_start(ap,fmt);
 vfprintf(stderr,fmt,ap);
 va_end(ap);
}

void
#ifdef STANDARD_C
Tcl_Panic(char *fmt,...)
#else
/*VARARGS0 */
Tcl_Panic(fmt, va_alist)
char *fmt;
va_dcl
#endif
{
 va_list ap;
#ifdef I_STDARG
 va_start(ap, fmt);
#else
 va_start(ap);
#endif
 PerlIO_flush(PerlIO_stderr());
 PerlIO_vprintf(PerlIO_stderr(), fmt, ap);
 PerlIO_putc(PerlIO_stderr(),'\n');
 va_end(ap);
 croak("Tcl_Panic");
}

char *
Tcl_Alloc(unsigned int size)
{
 char *p;
 if ((int) size < 0)
  abort();
 Newz(603, p, size, char);
 return p;
}

void
Tcl_Free(char *p)
{
 Safefree(p);
}

void
LangExit(value)
int value;
{
 my_exit((unsigned) value);
}

long
Lang_OSHandle(fd)
int fd;
{
#ifdef WIN32
 return win32_get_osfhandle(fd);
#else
 return fd;
#endif
}

static SV *
FindVarName(varName,flags)
char *varName;
int flags;
{
 STRLEN len;
 SV *name = newSVpv("Tk",2);
 SV *sv;
 sv_catpv(name,"::");
 sv_catpv(name,varName);
 sv = perl_get_sv(SvPV(name,len),flags);
 SvREFCNT_dec(name);
 return sv;
}

static void
install_vtab(name, table, size)
char *name;
void *table;
size_t size;
{
 if (table)
  {
   typedef int (*fptr)_((void));
   fptr *q = table;
   unsigned i;
   sv_setiv(FindVarName(name,GV_ADD|GV_ADDMULTI),(IV) table);
   if (size % sizeof(fptr))
    {
     warn("%s is strange size %d",name,size);
    }
   size /= sizeof(void *);
   for (i=0; i < size; i++)
    {
     if (!q[i])
      warn("%s slot %d is NULL",name,i);
    }
  }
 else
  {
   croak("%s pointer is NULL",name);
  }
}

static void SetupProc _ANSI_ARGS_((ClientData clientData, int flags));
static void CheckProc _ANSI_ARGS_((ClientData clientData, int flags));
static int EventProc  _ANSI_ARGS_((Tcl_Event *evPtr, int flags));

typedef struct PerlIOHandler
 {
  struct PerlIOHandler *nextPtr;  /* Next in list of all files we care about. */
  SV *handle;
  IO *io;
  LangCallback *readHandler;
  LangCallback *writeHandler;
  LangCallback *exceptionHandler;
  int mask;                       /* Mask of desired events: TCL_READABLE etc. */
  int readyMask;                  /* Mask of events that have been seen since the
                                     * last time file handlers were invoked for
                                     * this file. */
  int pending;
 } PerlIOHandler;

typedef struct PerlIOEvent
 {
  Tcl_Event header;               /* Information that is standard for all events. */
  IO *io;                         /* PerlIO descriptor that is ready. */
 } PerlIOEvent;


static int initialized = 0;

static PerlIOHandler *firstPerlIOHandler;

static void PerlIOEventInit(void);

static void
PerlIOFileProc(ClientData clientData, int mask)
{
 PerlIOHandler *filePtr = (PerlIOHandler *) clientData;
 filePtr->readyMask |= mask;
}

SV *
PerlIO_handle(filePtr)
PerlIOHandler *filePtr;
{
 filePtr->io = sv_2io(filePtr->handle);
 return (filePtr->io) ? newRV((SV *) filePtr->io) : &PL_sv_undef;
}


void
PerlIO_watch(PerlIOHandler *filePtr, int mask)
{
 PerlIO *ip = IoIFP(filePtr->io);
 PerlIO *op = IoOFP(filePtr->io);
 int ifd    = (ip) ? PerlIO_fileno(ip) : -1;
 int ofd    = (op) ? PerlIO_fileno(op) : -1;
 int bits   = TCL_READABLE|TCL_EXCEPTION;
 if (ifd == ofd)
  bits |= TCL_WRITABLE;
 while (1)
  {
   int newmask  = mask & bits;
   if ((filePtr->mask & bits) != newmask)
    {
     if (filePtr->mask & bits && ifd >= 0)
      {
       Tcl_DeleteFileHandler(ifd);
      }
     if (newmask && ifd >= 0)
      {
       Tcl_CreateFileHandler(ifd, newmask, PerlIOFileProc, (ClientData) filePtr );
      }
     filePtr->mask = (filePtr->mask & ~bits) | newmask;
    }
   if (ifd == ofd || ofd < 0)
    break;
   bits = TCL_WRITABLE;
   ifd  = ofd;
  }
}

int
PerlIO_writable(filePtr)
PerlIOHandler *filePtr;
{
 if (!filePtr->mask & TCL_WRITABLE)
  {
   PerlIO_watch(filePtr,filePtr->mask | TCL_WRITABLE);
  }
 if (!(filePtr->readyMask & TCL_WRITABLE))
  {
   PerlIO *io = IoOFP(filePtr->io);
   if (io)
    {
     if (PerlIO_has_cntptr(io) && PerlIO_get_cnt(io) > 0)
      {
       filePtr->readyMask |= TCL_WRITABLE;
      }
    }
  }
 return filePtr->readyMask & TCL_WRITABLE;
}

int
PerlIO_readable(filePtr)
PerlIOHandler *filePtr;
{
 if (!filePtr->mask & TCL_READABLE)
  {
   PerlIO_watch(filePtr,filePtr->mask | TCL_READABLE);
  }
 if (!(filePtr->readyMask & TCL_READABLE))
  {
   PerlIO *io = IoIFP(filePtr->io);
   if (io)
    {
     if (PerlIO_has_cntptr(io) && PerlIO_get_cnt(io) > 0)
      {
       filePtr->readyMask |= TCL_READABLE;
      }
    }
  }
 return filePtr->readyMask & TCL_READABLE;
}

int
PerlIO_exception(filePtr)
PerlIOHandler *filePtr;
{
 return filePtr->readyMask & TCL_EXCEPTION;
}


static void
PerlIOSetupProc(ClientData data, int flags)
{
 static Tcl_Time blockTime = {0, 0};
 if (flags & TCL_FILE_EVENTS)
  {
   PerlIOHandler *filePtr = firstPerlIOHandler;
   while (filePtr != NULL)
    {
     if ((filePtr->mask & TCL_READABLE) && PerlIO_readable(filePtr) && filePtr->readHandler)
      Tcl_SetMaxBlockTime(&blockTime);
     if ((filePtr->mask & TCL_WRITABLE) && PerlIO_writable(filePtr) && filePtr->writeHandler)
      Tcl_SetMaxBlockTime(&blockTime);
     filePtr = filePtr->nextPtr;
    }
  }
}

static int
PerlIOEventProc(evPtr, flags)
Tcl_Event *evPtr;                 /* Event to service. */
int flags;                        /* Flags that indicate what events to
                                     * handle, such as TCL_FILE_EVENTS. */
{
 if (flags & TCL_FILE_EVENTS)
  {
   PerlIOEvent *fileEvPtr = (PerlIOEvent *) evPtr;
   PerlIOHandler *filePtr = firstPerlIOHandler;
   int mask;
   dTHR;
   /*
    * Search through the file handlers to find the one whose handle matches
    * the event.  We do this rather than keeping a pointer to the file
    * handler directly in the event, so that the handler can be deleted
    * while the event is queued without leaving a dangling pointer.
    */

   while (filePtr != NULL)
    {
     if (filePtr->io == fileEvPtr->io)
      {

       /*
        * The code is tricky for two reasons:
        * 1. The file handler's desired events could have changed
        *    since the time when the event was queued, so AND the
        *    ready mask with the desired mask.
        * 2. The file could have been closed and re-opened since
        *    the time when the event was queued.  This is why the
        *    ready mask is stored in the file handler rather than
        *    the queued event:  it will be zeroed when a new
        *    file handler is created for the newly opened file.
        */

       mask = filePtr->readyMask & filePtr->mask;
       filePtr->readyMask = 0;
       filePtr->pending = 0;
       if ((mask & TCL_READABLE) && filePtr->readHandler)
        {
         SV *sv = filePtr->readHandler;
         ENTER;
         SAVETMPS;
         LangPushCallbackArgs(&sv);
         LangCallCallback(sv,G_DISCARD);
         FREETMPS;
         LEAVE;
        }
       if ((mask & TCL_WRITABLE) && filePtr->writeHandler)
        {
         SV *sv = filePtr->writeHandler;
         ENTER;
         SAVETMPS;
         LangPushCallbackArgs(&sv);
         LangCallCallback(sv,G_DISCARD);
         FREETMPS;
         LEAVE;
        }
       if ((mask & TCL_EXCEPTION) && filePtr->exceptionHandler)
        {
         SV *sv = filePtr->exceptionHandler;
         ENTER;
         SAVETMPS;
         LangPushCallbackArgs(&sv);
         LangCallCallback(sv,G_DISCARD);
         FREETMPS;
         LEAVE;
        }
       break;
      }
     filePtr = filePtr->nextPtr;
    }
   return 1;
  }
 return 0;
}

static void
PerlIOCheckProc(data, flags)
ClientData data;                  /* Not used. */
int flags;                        /* Event flags as passed to Tcl_DoOneEvent. */
{
 if (flags & TCL_FILE_EVENTS)
  {
   PerlIOEvent *fileEvPtr;
   PerlIOHandler *filePtr = firstPerlIOHandler;
   while (filePtr)
    {
     if (filePtr->readyMask && !filePtr->pending)
      {
       fileEvPtr = (PerlIOEvent *) ckalloc(sizeof(PerlIOEvent));
       fileEvPtr->io = filePtr->io;
       Tcl_QueueProcEvent(PerlIOEventProc, (Tcl_Event *) fileEvPtr, TCL_QUEUE_TAIL);
       filePtr->pending = 1;
      }
     filePtr = filePtr->nextPtr;
    }
  }
}

static void
PerlIOExitHandler(ClientData clientData)
{
 Tcl_DeleteEventSource(PerlIOSetupProc, PerlIOCheckProc, NULL);
 initialized = 0;
}

static void
PerlIOEventInit(void)
{
 initialized = 1;
 firstPerlIOHandler = NULL;
 Tcl_CreateEventSource(PerlIOSetupProc, PerlIOCheckProc, NULL);
 Tcl_CreateExitHandler(PerlIOExitHandler, NULL);
}

PerlIOHandler *
SVtoPerlIOHandler(sv)
SV *sv;
{
 if (sv_isa(sv,"Tk::Event::IO"))
  return (PerlIOHandler *) SvPVX(SvRV(sv));
 croak("Not an Tk::Event::IO");
 return NULL;
}

SV *
PerlIO_TIEHANDLE(class, fh, mask)
char *class;
SV *fh;
int mask;                         /* OR'ed TCL_READABLE, TCL_WRITABLE, and TCL_EXCEPTION */
{
 HV *stash = gv_stashpv(class, TRUE);
 IO *io = sv_2io(fh);
 SV *obj = newSV(sizeof(PerlIOHandler));
 PerlIOHandler *filePtr = (PerlIOHandler *)SvPVX(obj);
 if (!initialized)
  PerlIOEventInit();
 Zero(filePtr,1,PerlIOHandler);
 filePtr->io        = sv_2io(fh);
 filePtr->handle    = SvREFCNT_inc(fh);
 filePtr->readyMask = 0;
 filePtr->pending   = 0;
 filePtr->nextPtr   = firstPerlIOHandler;
 firstPerlIOHandler = filePtr;
 PerlIO_watch(filePtr,mask);
 obj = newRV_noinc(obj);
 sv_bless(obj, stash);
 return obj;
}


SV *
PerlIO_handler(filePtr, mask, cb)
PerlIOHandler *filePtr;
int mask;
LangCallback *cb;
{
 STRLEN len;
 if (cb)
  {
   if (!SvROK(cb))
    cb = NULL;
   if (mask & TCL_READABLE)
    filePtr->readHandler      = (cb) ? SvREFCNT_inc(cb) : NULL;
   if (mask & TCL_WRITABLE)
    filePtr->writeHandler     = (cb) ? SvREFCNT_inc(cb) : NULL;
   if (mask & TCL_EXCEPTION)
    filePtr->exceptionHandler = (cb) ? SvREFCNT_inc(cb) : NULL;
   if (cb)
    PerlIO_watch(filePtr, filePtr->mask | mask);
   else
    PerlIO_watch(filePtr, filePtr->mask & ~mask);
  }
 else
  {
   switch (mask)
    {
     case TCL_EXCEPTION:
      cb = filePtr->exceptionHandler;
      break;
     case TCL_WRITABLE:
      cb = filePtr->writeHandler;
      break;
     case TCL_READABLE:
      cb = filePtr->readHandler;
      break;
     default:
      croak("Invalid handler type %d",mask);
    }
  }
 return SvREFCNT_inc(cb);
}


void
PerlIO_DESTROY(thisPtr)
PerlIOHandler *thisPtr;
{
 if (initialized)
  {
   PerlIOHandler **link = &firstPerlIOHandler;
   PerlIOHandler *filePtr;
   while ((filePtr = *link))
    {
     if (filePtr == thisPtr)
      {
       *link = filePtr->nextPtr;
       PerlIO_watch(filePtr,0);
       if (filePtr->readHandler)
        LangFreeCallback(filePtr->readHandler);
       if (filePtr->writeHandler)
        LangFreeCallback(filePtr->writeHandler);
       if (filePtr->exceptionHandler)
        LangFreeCallback(filePtr->exceptionHandler);
       SvREFCNT_dec(filePtr->handle);
      }
     else
      {
       link = &filePtr->nextPtr;
      }
    }
  }
}

static void
SetupProc(clientData,flags)
ClientData clientData;
int flags;
{
 dSP;
 ENTER;
 SAVETMPS;
 PUSHMARK(sp);
 XPUSHs(sv_2mortal(newRV((SV *)clientData)));
 XPUSHs(sv_2mortal(newSViv(flags)));
 PUTBACK;
 perl_call_method("setup",G_VOID);
 FREETMPS;
 LEAVE;
}

static void
CheckProc(clientData,flags)
ClientData clientData;
int flags;
{
 dSP;
 ENTER;
 SAVETMPS;
 PUSHMARK(sp);
 XPUSHs(sv_2mortal(newRV((SV *)clientData)));
 XPUSHs(sv_2mortal(newSViv(flags)));
 PUTBACK;
 perl_call_method("check",G_VOID);
 FREETMPS;
 LEAVE;
}

typedef struct
{
 Tcl_Event sv;
 SV *obj;
} PerlEvent;

static int
EventProc(evPtr, flags)
Tcl_Event *evPtr;
int flags;
{PerlEvent *pe = (PerlEvent *) evPtr;
 int code = 1;
 int count;
 dSP;
 ENTER;
 SAVETMPS;
 PUSHMARK(sp);
 XPUSHs(pe->obj);
 XPUSHs(sv_2mortal(newSViv(flags)));
 PUTBACK;
 count = perl_call_method("event",G_SCALAR);
 SPAGAIN;
 if (count)
  {
   SV *result = POPs;
   code = SvIV(result);
  }
 PUTBACK;
 FREETMPS;
 LEAVE;
 return code;
}

#ifndef NSIG
#define NSIG 64
#endif

static Signal_t handle_signal _((int sig));
static Signal_t (*old_handler) _((int sig)) = NULL;
static char seen[NSIG];
static int  asyncReady;
static int  asyncActive;

int
Tcl_AsyncInvoke(interp,code)
Tcl_Interp *interp;
int code;
{
 int i;
 int done_one = 1;
 asyncReady = 0;
 asyncActive = 1;
 while (done_one)
  {
   done_one = 0;
   for (i=0; i < NSIG; i++)
    {
     if (seen[i] > 0)
      {
       seen[i]--;
       (*old_handler)(i);
       done_one = 1;
       break;
      }
    }
  }
 asyncActive = 0;
 return code;
}

int
Tcl_AsyncReady()
{
 return asyncReady;
}


static Signal_t
handle_signal(sig)
int sig;
{
 if (sig >= 0 && sig < NSIG)
  {
   seen[sig]++;
   if (!asyncActive)
    {
     asyncReady = 1;
    }
  }
}

void
HandleSignals()
{
#if defined(PATCHLEVEL) && (PATCHLEVEL < 5)
 croak("Cannot HandleSignals with before perl5.005");
#else
 if (PL_sighandlerp != handle_signal)
  {
   old_handler    = PL_sighandlerp;
   PL_sighandlerp = handle_signal;
  }
#endif
}

XS(XS_Tk__Callback_Call)
{
 dXSARGS;
 STRLEN na;
 int i;
 int count;
 SV *cb = ST(0);
 SV *err;
 int wantarray = GIMME;
 if (!items)
  {
   croak("No arguments");
  }
 LangPushCallbackArgs(&ST(0));
 SPAGAIN;
 for (i=1; i < items; i++)
  {
   if (SvTAINTED(ST(i)))
    {
     croak("Arg %d to callback %_ is tainted",i,ST(i));
    }
   XPUSHs(ST(i));
  }
 PUTBACK;

 count = LangCallCallback(ST(0),GIMME|G_EVAL);
 SPAGAIN;

 err = ERRSV;
 if (SvTRUE(err))
  {
   croak("%s",SvPV(err,na));
  }

 if (count)
  {
   for (i=1; i <= count; i++)
    {
     ST(i-1) = sp[i-count];
    }
  }
 else
  {
   if (!(wantarray & G_ARRAY))
    {
     ST(0) = &PL_sv_undef;
     count++;
    }
  }
 PUTBACK;
 XSRETURN(count);
}

#define Tcl_setup(obj,flags)
#define Tcl_check(obj,flags)

#define Const_READABLE() TCL_READABLE
#define Const_WRITABLE() TCL_WRITABLE
#define Const_EXCEPTION() TCL_EXCEPTION

#define Const_DONT_WAIT()     (TCL_DONT_WAIT)
#define Const_WINDOW_EVENTS() (TCL_WINDOW_EVENTS)
#define Const_FILE_EVENTS()   (TCL_FILE_EVENTS)
#define Const_TIMER_EVENTS()  (TCL_TIMER_EVENTS)
#define Const_IDLE_EVENTS()   (TCL_IDLE_EVENTS)
#define Const_ALL_EVENTS()    (TCL_ALL_EVENTS)


MODULE = Tk::Event	PACKAGE = Tk::Event::IO PREFIX = Const_

PROTOTYPES: ENABLE

int
Const_READABLE()

int
Const_WRITABLE()

int
Const_EXCEPTION()

MODULE = Tk::Event	PACKAGE = Tk::Event PREFIX = Const_

PROTOTYPES: ENABLE  

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

MODULE = Tk::Event	PACKAGE = Tk::Event::IO	PREFIX = PerlIO_

PROTOTYPES: DISABLE

SV *
PerlIO_TIEHANDLE(class,fh,mask = 0)
char *	class
SV *	fh
int	mask

SV *
PerlIO_handle(filePtr)
PerlIOHandler *	filePtr

void
PerlIO_watch(filePtr,mode)
PerlIOHandler *	filePtr
int		mode

int
PerlIO_readable(filePtr)
PerlIOHandler *	filePtr

int
PerlIO_exception(filePtr)
PerlIOHandler *	filePtr

int
PerlIO_writable(filePtr)
PerlIOHandler *	filePtr

SV *
PerlIO_handler(filePtr, mask = TCL_READABLE, cb = NULL)
PerlIOHandler *	filePtr
int		mask
LangCallback *	cb

void
PerlIO_DESTROY(filePtr)
PerlIOHandler *	filePtr

MODULE = Tk::Event	PACKAGE = Tk::Event::Source	PREFIX = Tcl_

void
Tcl_setup(obj,flags)
SV *	obj
int	flags

void
Tcl_check(obj,flags)
SV *	obj
int	flags

void
new(class,sv)
char *	class
SV *	sv
CODE:
{
 HV *stash = gv_stashpv(class, TRUE);
 if (SvROK(sv))
  {
   sv = newSVsv(sv);
  }
 else
  {
   sv = newRV(sv);
  }
 sv_bless(sv, stash);
 Tcl_CreateEventSource(SetupProc,CheckProc,(ClientData)SvRV(sv));
 ST(0) = sv;
}

void
delete(sv)
SV *	sv
CODE:
{
 SV *obj = SvRV(sv);
 Tcl_DeleteEventSource(SetupProc,CheckProc,(ClientData)obj);
 SvREFCNT_dec(obj);
}

MODULE = Tk::Event	PACKAGE = Tk::Event	PREFIX = Tcl_

double
dGetTime()
CODE:
 {Tcl_Time time;
  TclpGetTime(&time);
  RETVAL = (double) time.sec + time.usec * 1e-6;
 }
OUTPUT:
 RETVAL

void
Tcl_Exit(status)
int	status

int
Tcl_DoOneEvent(flags)
int	flags

void
Tcl_QueueEvent(evPtr, position = TCL_QUEUE_TAIL)
Tcl_Event *		evPtr
Tcl_QueuePosition	position

void
Tcl_QueueProcEvent(proc, evPtr, position  = TCL_QUEUE_TAIL)
Tcl_EventProc *		proc
Tcl_Event *		evPtr
Tcl_QueuePosition	position

int
Tcl_ServiceEvent(flags)
int	flags

Tcl_TimerToken
Tcl_CreateTimerHandler(milliseconds, proc, clientData = NULL)
int		milliseconds
Tcl_TimerProc *	proc
ClientData	clientData

void
Tcl_DeleteTimerHandler(token)
Tcl_TimerToken	token

void
Tcl_SetMaxBlockTime(sec, usec = 0)
double	sec
IV	usec
CODE:
 {
  Tcl_Time ttime;
  ttime.sec  = sec;
  ttime.usec = (sec - ttime.sec) * 1e6 + usec;
  Tcl_SetMaxBlockTime(&ttime);
 }

void
Tcl_DoWhenIdle(proc,clientData = NULL)
Tcl_IdleProc *	proc
ClientData	clientData

void
Tcl_CancelIdleCall(proc,clientData = NULL)
Tcl_IdleProc *	proc
ClientData	clientData

void
Tcl_CreateExitHandler(proc,clientData = NULL)
Tcl_ExitProc *	proc
ClientData	clientData

void
Tcl_CreateFileHandler(fd, mask, proc, clientData = NULL)
int		fd
int		mask
Tcl_FileProc *	proc
ClientData	clientData

void
Tcl_DeleteFileHandler(fd)
int	fd

void
Tcl_Sleep(ms)
int	ms

int
Tcl_GetServiceMode()

int
Tcl_SetServiceMode(mode)
int	mode

int
Tcl_ServiceAll()

void
HandleSignals()

MODULE = Tk::Event	PACKAGE = Tk::Event

PROTOTYPES: DISABLE

BOOT:
 {
  newXS("Tk::Callback::Call", XS_Tk__Callback_Call, __FILE__);

  install_vtab("TkeventVtab",TkeventVGet(),sizeof(TkeventVtab));
 }
