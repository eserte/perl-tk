#include "tkPort.h"
#include "tk.h"
#include "tkVMacro.h"

int
Tk_StateParseProc (clientData, interp, tkwin, value, widgRec, offset)
ClientData clientData;
Tcl_Interp *interp;
Tk_Window tkwin;
Arg value;
char *widgRec;
int offset;
{                 
 return TkStateParseProc(clientData, interp, tkwin, value, widgRec, offset);
}

Arg
Tk_StatePrintProc (clientData, tkwin, widgRec, offset, freeProcPtr)
ClientData clientData;
Tk_Window tkwin;
char *widgRec;
int offset;
Tcl_FreeProc **freeProcPtr;
{
 return TkStatePrintProc(clientData, tkwin, widgRec, offset, freeProcPtr);
}


int
Tk_TileParseProc (clientData, interp, tkwin, value, widgRec, offset)
ClientData clientData;
Tcl_Interp *interp;
Tk_Window tkwin;
Arg value;
char *widgRec;
int offset;
{                 
 return TkTileParseProc(clientData, interp, tkwin, value, widgRec, offset);
}

Arg
Tk_TilePrintProc (clientData, tkwin, widgRec, offset, freeProcPtr)
ClientData clientData;
Tk_Window tkwin;
char *widgRec;
int offset;
Tcl_FreeProc **freeProcPtr;
{
 return TkTilePrintProc(clientData, tkwin, widgRec, offset, freeProcPtr);
}


int
Tk_OffsetParseProc (clientData, interp, tkwin, value, widgRec, offset)
ClientData clientData;
Tcl_Interp *interp;
Tk_Window tkwin;
Arg value;
char *widgRec;
int offset;
{                 
 return TkOffsetParseProc(clientData, interp, tkwin, value, widgRec, offset);
}

Arg
Tk_OffsetPrintProc (clientData, tkwin, widgRec, offset, freeProcPtr)
ClientData clientData;
Tk_Window tkwin;
char *widgRec;
int offset;
Tcl_FreeProc **freeProcPtr;
{
 return TkOffsetPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr);
}

int
Tk_OrientParseProc (clientData, interp, tkwin, value, widgRec, offset)
ClientData clientData;
Tcl_Interp *interp;
Tk_Window tkwin;
Arg value;
char *widgRec;
int offset;
{                 
 return TkOrientParseProc(clientData, interp, tkwin, value, widgRec, offset);
}

Arg
Tk_OrientPrintProc (clientData, tkwin, widgRec, offset, freeProcPtr)
ClientData clientData;
Tk_Window tkwin;
char *widgRec;
int offset;
Tcl_FreeProc **freeProcPtr;
{
 return TkOrientPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr);
}

int
Tk_PixelParseProc (clientData, interp, tkwin, value, widgRec, offset)
ClientData clientData;
Tcl_Interp *interp;
Tk_Window tkwin;
Arg value;
char *widgRec;
int offset;
{                 
 return TkPixelParseProc(clientData, interp, tkwin, value, widgRec, offset);
}

Arg
Tk_PixelPrintProc (clientData, tkwin, widgRec, offset, freeProcPtr)
ClientData clientData;
Tk_Window tkwin;
char *widgRec;
int offset;
Tcl_FreeProc **freeProcPtr;
{
 return TkPixelPrintProc(clientData, tkwin, widgRec, offset, freeProcPtr);
}


