#include <stdarg.h>
#include "Tk.hh"

extern "C"  {
#include "pTk/tk_f.h"
#include "pTk/Lang_f.h"
#include "pTk/tkInt_f.h"
#include "pTk/Xlib_f.h"
}

MainWindow::MainWindow(void)
{                                        
 Tk_Initialize();
 interp  = Tcl_CreateInterp();
 tkwin   = Tk_CreateMainWindow(interp, NULL, "test","Test");
 command = NULL;
}

Tk_Window
TkWidget::MainWindow(void)
{
 if (tkwin)
  {
   TkWindow *winPtr = (TkWindow *) tkwin;
   TkMainInfo *mainInfo = winPtr->mainPtr;
   if (mainInfo)                        
    return (Tk_Window) mainInfo->winPtr;
  }
 return NULL;
}

void TkWidget::destroy(void)
{

}

TkCommand::TkCommand(void)
{

}

TkArg::TkArg(char *s)
{
 value = strdup(s);
 fprintf(stderr,"%p is %s\n",this,s);
}

ArgList::~ArgList()
{
 while (argc-- > 0)
  delete argv[argc];
 if (argv)
  free(argv);
}

void
ArgList::push(Arg a)
{
 argc++;
 if (argc > alloc)
  {
   size_t need = (argc+1)*sizeof(Arg);
   if (argv)
    argv = (Arg *) realloc(argv,need);
   else
    argv = (Arg *) malloc(need);
   alloc = argc; 
  }
 argv[argc-1] = a;
 argv[argc] = NULL;
 fprintf(stderr,"%p[%d] is %s\n",this,argc-1,LangString(a));
}

void
ArgList::push(va_list ap)
{
 char *s;
 while ((s = va_arg(ap,char *)))
  {
   fprintf(stderr,"push %p '%s'\n",this,s);
   this->push(s);
  }
}

ArgList::ArgList(va_list ap)
{
 this->init();
 this->push(ap);
}

ArgList::ArgList(...)
{
 va_list ap;
 va_start(ap,this);
 this->init();
 this->push(ap);
 va_end(ap);
}

void TkWidget::pack(...)
{va_list ap;
 va_start(ap,this);
 ArgList args("pack",ap);
 Tk_PackCmd(this->MainClient(), this->Interp(), args.Argc(), args.Argv());
 va_end(ap);
}

void TkWidget::configure(char *key, char *value)
{

}

void TkWidget::configure(char *key, LangCallback *value)
{

}

TkWidget::~TkWidget(void)
{

}

Tcl_Command
Lang_CreateWidget(Tcl_Interp *interp, Tk_Window tkwin, Tcl_CmdProc *proc,
                  ClientData clientData, Tcl_CmdDeleteProc *deleteProc)
{
 Tcl_Command result;
 fprintf(stderr,"Create %s\n",Tk_PathName(tkwin));
 return result;
}
 
Tcl_Interp *
Tcl_CreateInterp(void)
{
 return new TkInterp();
}

void
Tcl_DeleteInterp(Tcl_Interp *interp)
{
}

void
Lang_DeadMainWindow(Tcl_Interp *interp, Tk_Window tkwin)
{
}

Arg *
LangAllocVec(int n)
{
 return NULL;
}

void
LangFreeVec(int count, Arg*p)
{
}

Arg
LangStringArg(char *s)
{
 return NULL;
}

void
LangSetString(Arg *sp, char *s)
{
}

void
LangSetDefault(Arg *sp, char *s)
{
}

void
LangSetArg(Arg *sp, Arg arg)
{
}

void
LangSetInt(Arg *sp, int v)
{
}

void
LangSetDouble(Arg *sp, double v)
{
}

void
Lang_NewMainWindow(Tcl_Interp *interp, Tk_Window tkwin)
{
}

char *
LangString(Arg sv)
{
 fprintf(stderr,"string for %p : %s\n",sv,sv->value);
 if (sv)
  return sv->value;
 return "";
}

char *
Tcl_GetResult(Tcl_Interp *interp)
{
 return "";
}

Arg
Tcl_ResultArg(Tcl_Interp *interp)
{
 return NULL;
}

void
Tcl_AppendArg(Tcl_Interp *interp, Arg arg)
{
}

void
Tcl_AppendElement(Tcl_Interp *interp, char *string)
{
}

void
Tcl_ResetResult(Tcl_Interp *interp)
{
}

void
Tcl_SprintfResult(Tcl_Interp * interp, char *fmt,...)
{

}

void
Tcl_IntResults(Tcl_Interp * interp, int count, int append,...)
{

}

void
Tcl_DoubleResults(Tcl_Interp * interp, int count, int append,...)
{

}

Arg
Tcl_Concat(int argc, Arg *args)
{
 return NULL;
}

Arg
Tcl_Merge(int argc, Arg *args)
{
 return NULL;
}

int
Lang_SplitList(Tcl_Interp *interp, Arg sv, int *argcPtr, Arg **argvPtr, LangFreeProc (**freeProc))
{
 return TCL_ERROR;
}

void
Tcl_AppendResult (Tcl_Interp * interp,...)
{

}

void
Tcl_ArgResult(Tcl_Interp *interp, Arg sv)
{
}

Arg 
LangWidgetArg(Tcl_Interp *interp, Tk_Window tkwin)
{
 return NULL;
}

Arg
LangObjectArg(Tcl_Interp *interp, char *name)
{
 return NULL;
}

void
Tcl_SetResult(Tcl_Interp *interp, char *string, Tcl_FreeProc (*freeProc))
{
}

LangResultSave *
LangSaveResult(Tcl_Interp **interp)
{
 return NULL;
}

void
LangRestoreResult(Tcl_Interp **interp, LangResultSave *old)
{
}

void
Tcl_AddErrorInfo(Tcl_Interp *interp, char *message)
{
}

void
Tk_BackgroundError(Tcl_Interp *interp)
{
}


int
LangNull(Arg sv)
{
 return !sv || !strlen(LangString(sv));
}

char *
LangMergeString(int argc, Arg *args)
{
 return "";
}

void 
Lang_TkCommand(char *name, Tcl_CmdProc (*proc))
{
}

void 
LangDeadWindow(Tcl_Interp *interp, Tk_Window tkwin)
{
}

void
Lang_DeleteWidget(Tcl_Interp *interp, TkCommand *info)
{
}

void
Lang_DeleteObject(Tcl_Interp *interp, TkCommand *info)
{
}

Tcl_Command
Lang_CreateObject(Tcl_Interp *interp, char *cmdName, Tcl_CmdProc (*proc), ClientData clientData, Tcl_CmdDeleteProc (*deleteProc))
{
 return NULL;
}

Tcl_Command
Lang_CreateImage(Tcl_Interp *interp, char *cmdName, Tcl_CmdProc (*proc), ClientData clientData, Tcl_CmdDeleteProc (*deleteProc), Tk_ImageType *typePtr)
{
 return NULL;
}

Tcl_Command
Tcl_CreateCommand(Tcl_Interp *interp, char *cmdName, Tcl_CmdProc (*proc), ClientData clientData, Tcl_CmdDeleteProc (*deleteProc))
{
 return NULL;
}

void 
Tcl_CallWhenDeleted(Tcl_Interp *interp, Tcl_InterpDeleteProc (*proc), ClientData clientData)
{
}

int
Tcl_GetBoolean(Tcl_Interp *interp, Arg sv, int *boolPtr)
{
 return TCL_ERROR;
}

int
Tcl_GetDouble(Tcl_Interp *interp, Arg sv, double *doublePtr)
{
 return TCL_ERROR;
}

int
Tcl_GetInt(Tcl_Interp *interp, Arg sv, int *intPtr)
{
 return TCL_ERROR;
}

Arg
Tcl_GetVar2(Tcl_Interp *interp, Var sv, char *part2, int flags)
{
 return NULL;
}

int 
LangCmpOpt(char *opt, char *arg, size_t len)
{
 int result = 0;
 if (!len)
  len = strlen(arg);
 if (*opt == '-')
  opt++;
 if (*arg == '-')
  {
   arg++;
   if (len)
    len--;
  }
 while (len--)
  {char ch = *arg++;;
   if ((result = *opt++ - ch) || !ch)
    break;
  }
 return result;
}

int
LangCmpArg(Arg a, Arg b)
{
 return strcmp(LangString(a),LangString(b));
}

char *
Tcl_SetVar2(Tcl_Interp *interp, Var sv, char *part2, char *newValue, int flags)
{
 return "";
}

int
Tcl_TraceVar2(Tcl_Interp *interp, Var sv, char *part2, int flags, Tcl_VarTraceProc (*tkproc), ClientData clientData)
{
 return TCL_ERROR;
}

char *
LangLibraryDir(void)
{
 return ".";
}

int 
Tcl_LinkVar(Tcl_Interp *interp, char *varName, char *addr, int type)
{
 return TCL_ERROR;
}

void
Tcl_UnlinkVar(Tcl_Interp *interp, char *varName)
{
}

void
Tcl_UntraceVar2(Tcl_Interp *interp, Var sv, char *part2, int flags, Tcl_VarTraceProc (*tkproc), ClientData clientData)
{
}

void
Tcl_UntraceVar(Tcl_Interp *interp, Var varName, int flags, Tcl_VarTraceProc (*proc), ClientData clientData)
{
 Tcl_UntraceVar2(interp, varName, NULL, flags, proc, clientData);
}

int
Tcl_TraceVar(Tcl_Interp *interp, Var varName, int flags, Tcl_VarTraceProc (*proc), ClientData clientData)
{
 return Tcl_TraceVar2(interp, varName, NULL, flags, proc, clientData);
}

char *
Tcl_SetVar(Tcl_Interp *interp, Var varName, char *newValue, int flags)
{
 return Tcl_SetVar2(interp, varName, NULL, newValue, flags);
}

Arg
Tcl_GetVar(Tcl_Interp *interp, Var varName, int flags)
{
 return Tcl_GetVar2(interp, varName, NULL, flags);
}

Var
LangFindVar(Tcl_Interp *interp, Tk_Window tkwin, char *name)
{
 return NULL;
}

int
LangStringMatch(char *string, Arg match)
{
 return 0;
}

int
LangSaveVar(Tcl_Interp *interp, Arg sv, Var *vp, int type)
{
 return TCL_ERROR;
}

void
LangFreeVar(Var sv)
{
}

Arg 
LangVarArg(Var sv)
{
 return NULL;
}

LangCallback *
LangMakeCallback(Arg sv)
{
 return NULL;
}

LangCallback *
LangCopyCallback(LangCallback *sv)
{
 return NULL;
}

void
LangFreeCallback(LangCallback *sv)
{
}

Arg
LangCallbackArg(LangCallback * sv)
{
 return NULL;
}

int
LangDoCallback (Tcl_Interp * interp, LangCallback * sv, int result, int argc,...)
{
 return TCL_ERROR;
}

int
LangMethodCall(Tcl_Interp * interp, Arg sv, char *method, int result, int argc,...)
{
 return TCL_ERROR;
}

int
LangEval(Tcl_Interp *interp, char *cmd, int global)
{
 return TCL_ERROR;
}

void
LangClientMessage(Tcl_Interp *interp, Tk_Window tkwin, XEvent *event)
{
}

int
LangEventCallback(Tcl_Interp *interp, LangCallback *sv, XEvent *event, KeySym keySym)
{
 return TCL_ERROR;
}

int 
Tcl_GetOpenFile(Tcl_Interp *interp, Arg string, int doWrite, int checkUsage, FILE **filePtr)
{
 return TCL_ERROR;
}

void
LangFreeArg(Arg sv, Tcl_FreeProc (*freeProc))
{
}

void
Tk_ChangeScreen(Tcl_Interp *interp, char *dispName, int screenIndex)
{
 
}

char *
Tcl_TildeSubst(Tcl_Interp *interp, char *name, Tcl_DString *bufferPtr)
{
 return name;
}

char *
Tcl_PosixError(Tcl_Interp *interp)
{
 return strerror(errno);
}

void
Lang_SetErrorCode(Tcl_Interp *interp, char *code)
{
}

int
LangCmpCallback(LangCallback *a, Arg b)
{
 return 0;
}

int 
LangEventHook(int flags)
{
 return 0;
}

void 
LangBadFile(int fd)
{
}

void
LangCloseHandler(Tcl_Interp *interp, Arg arg, FILE *f, Lang_FileCloseProc (*proc))
{
}

int
TkReadDataPending(FILE *f)
{
 return 0;
}

Tk_Window
Tk_MainWindow(Tcl_Interp *interp)
{
 return NULL;
}

void
LangExit(int value)
{
 exit(value);
}

char *
Lang_GetErrorCode(Tcl_Interp *interp)
{
 return "";
}

char *
Lang_GetErrorInfo(Tcl_Interp *interp)
{
 return "";
}

void
Lang_BuildInImages(void)
{
}

Arg
LangCopyArg(Arg sv)
{
 return NULL;
}

void 
Tcl_Panic (char *fmt,...)
{
 va_list ap;
 va_start(ap,fmt);
 vfprintf(stderr,fmt,ap);
 abort();
 va_end(ap);
}

int
Lang_RegExpExec(Tcl_Interp *interp,Tcl_RegExp  re, char *string, char *start)
{
 return 0;
}

void 
Tcl_RegExpRange(Tcl_RegExp re, int index, char **startPtr, char **endPtr)
{

}

Tcl_RegExp
Lang_RegExpCompile(Tcl_Interp *interp, char *string, int fold)
{
 return NULL;
}
 
void 
Lang_FreeRegExp(Tcl_RegExp re)
{
}

char *
Tcl_SetVarArg(Tcl_Interp *interp, Var sv, Arg newValue, int flags)
{
 return "";
}

Button::Button(TkWidget *parent,...)
{
 va_list ap;
 va_start(ap,parent);
 ArgList args("button",".button",NULL);
 args.push(ap);
 Tk_ButtonCmd(parent->MainClient(), parent->Interp(), args.Argc(), args.Argv());
 va_end(ap);
}

XlibVtab   *XlibVptr   ;  
TkVtab     *TkVptr     ;  
TkintVtab  *TkintVptr  ;  
LangVtab   *LangVptr   ;  

void Tk_Initialize(void)
{
 LangVptr  = LangVGet();
 TkVptr    = TkVGet();
 TkintVptr = TkintVGet();
 XlibVptr  = XlibVGet();
}


