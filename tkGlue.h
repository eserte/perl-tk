#ifndef _TKGLUE
#define _TKGLUE

#ifndef BASEEXT
#define BASEEXT "Tk"
#endif

#ifndef _TKOPTION
#include "pTk/tkOption.h"
#include "pTk/tkOption_f.h"
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
  Tk_Font     tkfont;
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
TkeventVtab *TkeventVptr   ;	\
TkglueVtab *TkglueVptr

#ifdef WIN32
#define IMPORT_WIN32_VTABLES                                                   \
do {                                                                           \
  TkwinVptr     =   (TkwinVtab *) SvIV(perl_get_sv("Tk::TkwinVtab",GV_ADDWARN|GV_ADD));        \
  TkwinintVptr  =   (TkwinintVtab *) SvIV(perl_get_sv("Tk::TkwinintVtab",GV_ADDWARN|GV_ADD));  \
 } while (0);
#else
#define IMPORT_WIN32_VTABLES
#endif

#ifndef INT2PTR
#define INT2PTR(any,d) (any)(d)
#endif
#ifndef PTR2IV
#define PTR2IV(p)	INT2PTR(IV,p)
#endif

#define IMPORT_VTABLES                                                         \
do {                                                                           \
  TkoptionVptr = INT2PTR(TkoptionVtab *, SvIV(perl_get_sv("Tk::TkoptionVtab",GV_ADDWARN|GV_ADD))); \
  LangVptr     = INT2PTR(LangVtab *, SvIV(perl_get_sv("Tk::LangVtab",GV_ADDWARN|GV_ADD)));         \
  TkeventVptr  = INT2PTR(TkeventVtab *, SvIV(perl_get_sv("Tk::TkeventVtab",GV_ADDWARN|GV_ADD)));   \
  TkVptr       = INT2PTR(TkVtab *, SvIV(perl_get_sv("Tk::TkVtab",GV_ADDWARN|GV_ADD)));             \
  TkintVptr    = INT2PTR(TkintVtab *, SvIV(perl_get_sv("Tk::TkintVtab",GV_ADDWARN|GV_ADD)));       \
  TkglueVptr   = INT2PTR(TkglueVtab *, SvIV(perl_get_sv("Tk::TkglueVtab",GV_ADDWARN|GV_ADD)));     \
  XlibVptr     = INT2PTR(XlibVtab *, SvIV(perl_get_sv("Tk::XlibVtab",GV_ADDWARN|GV_ADD)));         \
 } while (0)

#define VTABLE_INIT() IMPORT_VTABLES

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
extern Tk_Window TkToMainWindow _ANSI_ARGS_((Tk_Window tkwin));
extern void Lang_TkSubCommand _ANSI_ARGS_ ((char *name, Tcl_CmdProc *proc));
extern void Lang_TkCommand _ANSI_ARGS_ ((char *name, Tcl_CmdProc *proc));
extern SV *XEvent_Info _((EventAndKeySym *obj,char *s));
extern EventAndKeySym *SVtoEventAndKeySym _((SV *arg));
extern int XSTkCommand _ANSI_ARGS_((CV *cv, Tcl_CmdProc *proc, int items, SV **args));

extern XS(XStoWidget);

EXTERN void ClearErrorInfo _ANSI_ARGS_((SV *interp));
EXTERN Tk_Window mainWindow;
EXTERN void DumpStack _ANSI_ARGS_((void));
EXTERN void  Boot_Glue _ANSI_ARGS_((void));
EXTERN void  Boot_Tix  _ANSI_ARGS_((void));
EXTERN void install_vtab _ANSI_ARGS_((char *name, void *table, size_t size));
extern SV *TagIt _((SV *sv, char *type));
extern void Font_DESTROY _((SV *sv));                
struct pTkCheckChain;
extern void Tk_CheckHash _((SV *sv,struct pTkCheckChain *chain));


#ifndef WIN32
#define HWND void *
#endif
EXTERN HWND SVtoHWND _ANSI_ARGS_((SV *win));

#endif
