#define TCL_EVENT_IMPLEMENT
#ifdef WIN32 
#include "../pTk/tclWinNotify.c"
#else
#include "../pTk/tclUnixNotfy.c"
#endif
