/* 
 * tkCmdTab.c --
 *
 *	This file provides table of Tk Widgets
 *	it used to be part of tkWindow.c
 *
 * Copyright (c) 1989-1994 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

static char sccsid[] = "@(#) tkWidgetTab.c 1.164 95/01/06 18:00:16";

#include "tkPort.h"
#include "tk.h"

Tk_Cmd Tk_Widgets[] = {
    /*
     * Widget class commands.
     */
    {"button",		Tk_ButtonCmd},
#if 0
    {"canvas",		Tk_CanvasCmd},
    {"text",		Tk_TextCmd},
    {"entry",		Tk_EntryCmd},
    {"menu",		Tk_MenuCmd},
    {"scale",		Tk_ScaleCmd},
    {"menubutton",	Tk_MenubuttonCmd},
    {"scrollbar",	Tk_ScrollbarCmd},
    {"listbox",		Tk_ListboxCmd},
#endif
    {"checkbutton",	Tk_CheckbuttonCmd},
    {"frame",		Tk_FrameCmd},
    {"label",		Tk_LabelCmd},
    {"message",		Tk_MessageCmd},
    {"radiobutton",	Tk_RadiobuttonCmd},
    {"toplevel",	Tk_FrameCmd},
    {(char *) NULL,	(int (*)()) NULL}
};


