#ifndef _TKGLUE
#define _TKGLUE

#ifndef BASEEXT
#define BASEEXT "Tk"
#endif

#ifndef _TKOPTION
#include "pTk/tkOption.h"
#include "pTk/tkOption_f.h"
#endif

#ifndef dTHR
#define dTHR int maybeTHR
#endif          

typedef struct EventAndKeySym
 {XEvent event;
  KeySym keySym;
  Tcl_Interp  *interp;
  Tk_Window   tkwin;
  SV    *window;
 } EventAndKeySym;

typedef struct Lang_CmdInfo 
 {Tcl_CmdInfo Tk;
  Tcl_Interp  *interp;
  Tk_Window   tkwin;
  SV          *image; 
 } Lang_CmdInfo;

#ifdef WIN32
#define DECLARE_WIN32_VTABLES	\
TkwinVtab *TkwinVptr;		\
TkwinintVtab * TkwinintVptr;
#else
#define DECLARE_WIN32_VTABLES 
#endif

#define DECLARE_VTABLES		\
TkoptionVtab   *TkoptionVptr;	\
XlibVtab   *XlibVptr   ;	\
TkVtab     *TkVptr     ;	\
TkintVtab  *TkintVptr  ;	\
LangVtab   *LangVptr   ;	\
TkglueVtab *TkglueVptr 
              
#ifdef WIN32
#define IMPORT_WIN32_VTABLES                                                   \
do {                                                                           \
  TkwinVptr     =   (TkwinVtab *) SvIV(perl_get_sv("Tk::TkwinVtab",5));        \
  TkwinintVptr  =   (TkwinintVtab *) SvIV(perl_get_sv("Tk::TkwinintVtab",5));  \
 } while (0);
#else
#define IMPORT_WIN32_VTABLES
#endif

#define IMPORT_VTABLES                                                         \
do {                                                                           \
  TkoptionVptr   =   (TkoptionVtab *) SvIV(perl_get_sv("Tk::TkoptionVtab",5)); \
  LangVptr   =   (LangVtab *) SvIV(perl_get_sv("Tk::LangVtab",5));             \
  TkVptr     =     (TkVtab *) SvIV(perl_get_sv("Tk::TkVtab",5));               \
  TkintVptr  =  (TkintVtab *) SvIV(perl_get_sv("Tk::TkintVtab",5));            \
  TkglueVptr = (TkglueVtab *) SvIV(perl_get_sv("Tk::TkglueVtab",5));           \
  XlibVptr   =   (XlibVtab *) SvIV(perl_get_sv("Tk::XlibVtab",5));             \
 } while (0)

extern Lang_CmdInfo *WindowCommand _ANSI_ARGS_((SV *win,HV **hptr, int moan));
extern Tk_Window SVtoWindow _ANSI_ARGS_((SV *win));
extern Tk_Font SVtoFont _ANSI_ARGS_((SV *win));
extern int Call_Tk _ANSI_ARGS_((Lang_CmdInfo *info,int argc, SV **args));
extern HV *InterpHv _ANSI_ARGS_((Tcl_Interp *interp,int fatal));
extern SV *WidgetRef _ANSI_ARGS_((Tcl_Interp *interp, char *path));
extern SV *TkToWidget _ANSI_ARGS_((Tk_Window tkwin,Tcl_Interp **pinterp));
extern SV *FindTkVarName _ANSI_ARGS_((char *varName,int flags));
extern void EnterWidgetMethods _ANSI_ARGS_((char *package, ...));
extern SV *MakeReference _ANSI_ARGS_((SV * sv));
extern void Lang_TkCommand _ANSI_ARGS_ ((char *name, Tcl_CmdProc *proc));
extern Tk_Window TkToMainWindow _ANSI_ARGS_((Tk_Window tkwin));
extern void Lang_TkSubCommand _ANSI_ARGS_ ((char *name, Tcl_CmdProc *proc));
extern SV *XEvent_Info _((EventAndKeySym *obj,char *s));
extern EventAndKeySym *SVtoEventAndKeySym _((SV *arg));

extern XS(XStoWidget);

EXTERN void ClearErrorInfo _ANSI_ARGS_((SV *interp));
EXTERN Tk_Window mainWindow;
EXTERN void DumpStack _ANSI_ARGS_((void));
EXTERN void  Boot_Glue _ANSI_ARGS_((void));
EXTERN void  Boot_Tix  _ANSI_ARGS_((void));
EXTERN void install_vtab _((char *name, void *table, size_t size));
extern SV *TagIt _((SV *sv, char *type));


#endif
