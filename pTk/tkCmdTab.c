/* 
 * tkCmdTab.c --
 *
 *	This file provides table of Tk Commands
 *	it used to be part of tkWindow.c
 *
 * Copyright (c) 1989-1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

static char sccsid[] = "@(#) tkCmdTab.c 1.164 95/01/06 18:00:16";

#include "tkPort.h"
#include "tk.h"

/*
 * The following structure defines all of the commands supported by
 * Tk, and the C procedures that execute them.
 */


Tk_Cmd Tk_Commands[] = {
    /*
     * Commands that are part of the intrinsics:
     */
    {"after",		Tk_AfterCmd},
    {"bell",		Tk_BellCmd},
    {"bind",		Tk_BindCmd},
    {"bindtags",	Tk_BindtagsCmd},
    {"clipboard",	Tk_ClipboardCmd},
    {"destroy",		Tk_DestroyCmd},
    {"exit",		Tk_ExitCmd},
    {"fileevent",	Tk_FileeventCmd},
    {"focus",		Tk_FocusCmd},
    {"grab",		Tk_GrabCmd},
    {"grid",		Tk_GridCmd},
    {"image",		Tk_ImageCmd},
    {"lower",		Tk_LowerCmd},
    {"option",		Tk_OptionCmd},
    {"pack",		Tk_PackCmd},
    {"place",		Tk_PlaceCmd},
    {"raise",		Tk_RaiseCmd},
    {"selection",	Tk_SelectionCmd},
    {"tk",		Tk_TkCmd},
    {"tkwait",		Tk_TkwaitCmd},
    {"update",		Tk_UpdateCmd},
    {"winfo",		Tk_WinfoCmd},
    {"wm",		Tk_WmCmd},
    {"property",	Tk_PropertyCmd},
    {         NULL,	(int (*)()) NULL}
};


