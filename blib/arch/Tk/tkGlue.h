#ifndef _TKGLUE
#define _TKGLUE

#ifndef _TKOPTION
#include "pTk/tkOption.h"
#include "pTk/tkOption_f.h"
#endif


typedef struct Lang_CmdInfo 
 {Tcl_CmdInfo Tk;
  Tcl_Interp  *interp;
  Tk_Window   tkwin;
  SV          *image; 
 } Lang_CmdInfo;

#define DECLARE_VTABLES   \
TkoptionVtab   *TkoptionVptr   ;  \
XlibVtab   *XlibVptr   ;  \
TkVtab     *TkVptr     ;  \
TkintVtab  *TkintVptr  ;  \
LangVtab   *LangVptr   ;  \
TkglueVtab *TkglueVptr 

#define IMPORT_VTABLES                                                \
do {                                                                  \
  TkoptionVptr   =   (TkoptionVtab *) SvIV(perl_get_sv("Tk::TkoptionVtab",5));    \
  LangVptr   =   (LangVtab *) SvIV(perl_get_sv("Tk::LangVtab",5));    \
  TkVptr     =     (TkVtab *) SvIV(perl_get_sv("Tk::TkVtab",5));      \
  TkintVptr  =  (TkintVtab *) SvIV(perl_get_sv("Tk::TkintVtab",5));   \
  TkglueVptr = (TkglueVtab *) SvIV(perl_get_sv("Tk::TkglueVtab",5));  \
  XlibVptr   =   (XlibVtab *) SvIV(perl_get_sv("Tk::XlibVtab",5));    \
 } while (0)

extern Lang_CmdInfo *WindowCommand _ANSI_ARGS_((SV *win,HV **hptr, int moan));
extern Tk_Window SVtoWindow _ANSI_ARGS_((SV *win));
extern int Call_Tk _ANSI_ARGS_((Lang_CmdInfo *info,int argc, SV **args));
extern HV *InterpHv _ANSI_ARGS_((Tcl_Interp *interp,int fatal));
extern SV *WidgetRef _ANSI_ARGS_((Tcl_Interp *interp, char *path));
extern SV *TkToWidget _ANSI_ARGS_((Tk_Window tkwin,Tcl_Interp **pinterp));
extern SV *FindTkVarName _ANSI_ARGS_((char *varName,int flags));
extern void EnterWidgetMethods _ANSI_ARGS_((char *package, ...));
extern void XStoWidget _ANSI_ARGS_((CV * cv));
extern SV *MakeReference _ANSI_ARGS_((SV * sv));
extern void Lang_TkCommand _ANSI_ARGS_ ((char *name, Tcl_CmdProc *proc));
extern Tk_Window TkToMainWindow _ANSI_ARGS_((Tk_Window tkwin));

EXTERN void ClearErrorInfo _ANSI_ARGS_((SV *interp));
EXTERN Tk_Window mainWindow;
EXTERN void Dump_vec _ANSI_ARGS_((char *who,int count,SV **data));
EXTERN void DumpStack _ANSI_ARGS_((void));
EXTERN void  Boot_Glue _ANSI_ARGS_((void));
EXTERN void  Boot_Tix  _ANSI_ARGS_((void));
EXTERN void install_vtab _((char *name, void *table, size_t size));


#endif
