/*
  Copyright (c) 1997-1998 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "tkGlue.h"

Tcl_Channel
Tcl_OpenFileChannel(interp,fileName,modeString,permissions)
Tcl_Interp *interp;
char *fileName;
char *modeString;
int permissions;
{PerlIO *f = PerlIO_open(fileName,modeString);
 if (!f)
  {
   /* FIXME - use strerr() or perl's equivalent */
   Tcl_SprintfResult(interp,"Cannot open '%s' in mode '%s'",fileName, modeString);
  }
 return (Tcl_Channel) f;
}

Tcl_Channel
Tcl_GetChannel (Tcl_Interp *interp,char *chanName, int *modePtr)
{
 Tcl_SprintfResult(interp,"Tcl_GetChannel %s not implemeted",chanName);
 return NULL;
}


int
Tcl_Read(chan,bufPtr,toRead)
Tcl_Channel chan;
char *bufPtr;
int toRead;
{
 PerlIO *f = (PerlIO *) chan;
 return PerlIO_read(f,bufPtr,toRead);
}

int
Tcl_Write(chan, buf, count)
Tcl_Channel chan;
char *buf;
int count;
{
 PerlIO *f = (PerlIO *) chan;
 if (count < 0)
  count = strlen(buf);
 return PerlIO_write(f,buf,count);
}

int
Tcl_Close(interp,chan)
Tcl_Interp *interp;
Tcl_Channel chan;
{
 return PerlIO_close((PerlIO *) chan);
}

int
Tcl_Seek(chan, offset, mode)
Tcl_Channel chan;
int offset;
int mode;
{
 PerlIO_seek((PerlIO *) chan, offset, mode);
 return PerlIO_tell((PerlIO *) chan);
}

int
Tcl_Eof(Tcl_Channel chan)
{
 PerlIO *f = (PerlIO *) chan;
 return PerlIO_eof(f);
}

int
Tcl_SetChannelOption(Tcl_Interp *interp, Tcl_Channel chan,
                  char *optionName, char *newValue)
{
 PerlIO *f = (PerlIO *) chan;
 if (LangCmpOpt("-translation",optionName,-1) == 0)
  {
   if (strcmp(newValue,"binary") == 0)
    {
#ifdef USE_PERLIO
     PerlIO_binmode(aTHX_ f, '<', O_BINARY, Nullch);
#else
#if defined(WIN32) || defined(__EMX__)  || defined(__CYGWIN__)
     setmode(PerlIO_fileno(f), O_BINARY);
#endif
#endif
     return TCL_OK;
    }
  }
 warn("Set option %s=%s on channel %d", optionName, newValue, PerlIO_fileno(f));
 return TCL_OK;
}




