#include <stdio.h>
#include <stdarg.h>
#define Tcl_Interp     TkInterp
#define LangCallback   TkCallback
#define Arg            TkArg *
#define Var            TkVar *
#define Tcl_Command    TkCommand *
#define LangResultSave TkResult
#define Tcl_RegExp     TkRegexp *

class TkInterp;
class TkArg;
class TkCallback;
class TkVar;
class TkCommand;
class TkResult;
class TkRegexp;

#include "pTk/Lang.h"
#include "pTk/tkPort.h"
#include "pTk/tkInt.h"

extern void Tk_Initialize(void);

class ArgList;

class TkArg
{
 char *value;
friend char *LangString(Arg);
public:
 TkArg(char *s);
};

class TkInterp 
{
public:
 Interp(void);
};

class TkResult
{
public:
 Result();
};



class ArgList
{
 int alloc;
 int argc;
 Arg *argv;
 void init() { alloc = argc = 0; argv = NULL; } 
public:
 void push(char *s) { this->push(new TkArg(s)); };
 void push(Arg);
 void push(va_list);
 ~ArgList();
 int Argc()   { return argc; }
 Arg *Argv()  { return argv; }
 ArgList(va_list);
 ArgList(...);
};

class TkVar
{
public:
 TkVar();
};

class TkCommand
{
public:
 TkCommand(void);

};

class TkRegexp
{
public:
 TkRegexp(void);

};

class TkWidget
{
protected:
 ClientData cd;
 Tcl_CmdProc *proc;
 Tcl_Interp *interp;
 Tk_Window tkwin;
 Tcl_Command *command;
public:
 Tk_Window  MainWindow();
 ClientData MainClient() { return (ClientData) (this->MainWindow()); };
 Tcl_Interp *Interp() { return interp; };
 virtual void destroy(void);
 virtual ~TkWidget(void);
 virtual void pack(...);
 virtual void configure(char *,char *);
 virtual void configure(char *,LangCallback *);
};

class TkCallback
{
 TkWidget *widget;
 void (TkWidget::*method)(void);
public:
 TkCallback(TkWidget *w,void (TkWidget::*m)(void)) { widget = w; method = m; }
};

class MainWindow : public TkWidget
{
public:
 MainWindow(void);
};

class Button : public TkWidget
{
public:
 Button(TkWidget *,...);
};


