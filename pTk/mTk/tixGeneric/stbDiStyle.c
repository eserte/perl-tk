#include "tixPort.h"
#include "tix.h"
#include "tkVMacro.h"

static int   DItemStyleParseProc _ANSI_ARGS_((ClientData clientData,
		Tcl_Interp *interp, Tk_Window tkwin, Arg value,
		char *widRec, int offset));

static Arg   DItemStylePrintProc _ANSI_ARGS_((
		ClientData clientData, Tk_Window tkwin, char *widRec,
		int offset, Tcl_FreeProc **freeProcPtr));

static int 
DItemStyleParseProc(clientData, interp, tkwin, value, widRec,offset)
    ClientData clientData;
    Tcl_Interp *interp;
    Tk_Window tkwin;
    Arg value;
    char *widRec;
    int offset;
{
 return TixDItemStyleParseProc(clientData, interp, tkwin, value, widRec,offset);
}

static Arg
DItemStylePrintProc(clientData, tkwin, widRec,offset, freeProcPtr)
    ClientData clientData;
    Tk_Window tkwin;
    char *widRec;
    int offset;
    Tcl_FreeProc **freeProcPtr;
{
 return TixDItemStylePrintProc(clientData, tkwin, widRec,offset, freeProcPtr);
}


Tk_CustomOption tixConfigItemStyle = {
    DItemStyleParseProc, DItemStylePrintProc, 0,
};

