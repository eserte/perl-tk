#define TCL_EVENT_IMPLEMENT
#ifdef WIN32
#include "../pTk/tclWinNotify.c"

void
Tcl_WatchHandle(HANDLE h, Tcl_HandleProc *proc, ClientData clientData)
{
#if 0
 int i = 0;
 while (i < notifier.hCount)
  {
   if (notifier.hArray[i] == h)
    break;
   i++;
  }
 if (i == notifier.hCount)
  {
   if (notifier.hCount < MAXIMUM_WAIT_OBJECTS)
    {
     notifier.hArray[i] = h;
     notifier.hCount++;
    }
  }
 if (i < notifier.hCount)
  {
   notifier.pArray[i].proc = proc;
   notifier.pArray[i].clientData = clientData;
  }
#endif
}


#else
#include "../pTk/tclUnixNotfy.c"
#endif
