/* 
 * Demo.c --
 *
 *	Demonstrates how to create a Windows DLL that uses Tcl/Tk and
 *	(optionally) Tix.
 *
 *	A Windows DLL for Tcl/TK must have three functions. Two of them
 *      are DLL Entry Points, required by Windows and are called when
 *	the DLL is loaded into Windows. The third one is a function
 *	called <Pkg>_Init, which is called when the DLL is loaded into
 *	tclsh.exe or wish.exe via the "load" command.
 *
 * DLL Entry Points:
 *
 *	For the two DLL entry points, actually only one of them is called,
 *	depending which compiler you are using. If you use VC++, you should
 *	define the function DllMain. If you use Borland C++, you should
 *	define the function DllEntryPoint. In this file, we just define
 *	both of them so that this file can be happily compiled under
 *	both compilers. We will just make DllEntryPoint to call DllMain(),
 *	which should carry any initialization actions required. In most
 *	cases, however, we wouldn't do any initialization and just return
 *	TRUE.
 *
 * <Pkg>_Init function
 *
 *	You must have a function called <Pkg>_Init, where <Pkg> is the name
 *	of your package. In our case, we name the package "Demo" so the
 *	function is Demo_Init(). It should just do the normal sort of
 *	initializations required by a Tcl extension (create commands,
 *	variables, etc). In our example, we create a command called
 *	"demoHello" which just returns the string "Hello Tcl/Tk World".
 *
 * Linking to the C language API of Tix
 *
 *	Nothing special needs to be done. You have to make sure the Tix
 *	header files are in the INCLUDE directories and like against Tix41.lib
 *	when you create your DLL. See the "demo_tix.dll" target in
 *	the makefile.bc
 */
#include <tkPort.h>
#include <tkWinInt.h>
#include <tkInt.h>

/*
 * Forward Declarations
 */

BOOL APIENTRY		DllMain _ANSI_ARGS_((HINSTANCE hInst,
			    DWORD reason, LPVOID reserved));

int			Demo_HelloCmd _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp * interp, int argc, char ** argv));
/*
 *----------------------------------------------------------------------
 *
 * DllEntryPoint --
 *
 *	This wrapper function is used by Borland to invoke the
 *	initialization code for Tk.  It simply calls the DllMain
 *	routine.
 *
 * Results:
 *	See DllMain.
 *
 * Side effects:
 *	See DllMain.
 *
 *----------------------------------------------------------------------
 */

BOOL APIENTRY
DllEntryPoint(hInst, reason, reserved)
    HINSTANCE hInst;		/* Library instance handle. */
    DWORD reason;		/* Reason this function is being called. */
    LPVOID reserved;		/* Not used. */
{
    return DllMain(hInst, reason, reserved);
}

/*
 *----------------------------------------------------------------------
 *
 * DllMain --
 *
 *	DLL entry point.
 *
 * Results:
 *	TRUE on sucess, FALSE on failure.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

BOOL APIENTRY
DllMain(hInstance, reason, reserved)
    HINSTANCE hInstance;
    DWORD reason;
    LPVOID reserved;
{
    /*
     * If we are attaching to the DLL from a new process, tell Tk about
     * the hInstance to use. If we are detaching then clean up any
     * data structures related to this DLL.
     */
    
    return(TRUE);
}


int
Demo_HelloCmd(clientData, interp, argc, argv)
    ClientData clientData;
    Tcl_Interp * interp;
    int argc;
    char ** argv;
{
    Tcl_AppendResult(interp, "Hello Tcl/Tk World", NULL);

    return TCL_OK;
}

int _export
Demo_Init(interp)
    Tcl_Interp * interp;
{
    Tcl_CreateCommand(interp, "demoHello", Demo_HelloCmd, NULL, NULL);

    return TCL_OK;
}
