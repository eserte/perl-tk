/* 
 * tkProperty.c --
 *
 *                                                                                                  This file manages properties for the Tk toolkit,
 *
 * Copyright (c) 1994-1997 Nick-Ing-Simmons
 *
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that the
 * above copyright notice and the following two paragraphs appear in
 * all copies of this software.
 * 
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE AUTHOR
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHOR SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE AUTHOR HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */

#ifndef lint
static char rcsid[] = "$Header$";
#endif

#include "tkPort.h"
#include "tkInt.h"

/* /home/nick/bin/add_protos : Added declarations with prototypes */
static int  PropToResult _ANSI_ARGS_((Tcl_Interp *interp, Tk_Window tkwin, Atom type, unsigned char *p, int format, long unsigned int count));
static int  ArgToProp _ANSI_ARGS_((Tcl_Interp *interp, Tk_Window tkwin, Atom type, int format, Arg arg, unsigned char **prop, long unsigned int *count));
extern int  Tk_PropertyCmd _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int argc, Arg *args));
static int PropertyExists _ANSI_ARGS_((Tk_Window tkwin, Window xid, Atom key, long unsigned int *sizep));

static int
PropertyExists(tkwin, xid, key, sizep)
Tk_Window tkwin;
Window xid;
Atom key;
long unsigned int *sizep;
{
 unsigned long bytes_after = 0;
 Atom type = None;
 unsigned long count = 0;
 unsigned long bytesafter = 0;
 unsigned char *prop = NULL;
 int format = 0;
 if (!sizep)
  sizep = &bytes_after;
 XGetWindowProperty(Tk_Display(tkwin), xid, key, 0L, 0L, False,
                    AnyPropertyType, &type, &format, &count, sizep, &prop);
 if (prop)
  XFree((char *) prop);
 return format;
}

static int
PropToResult(interp, tkwin, type, p, format, count)
Tcl_Interp *interp;
Tk_Window tkwin;
Atom type;
unsigned char *p;
int format;
long unsigned int count;
{
 if (format == 8)
  {
   Lang_SetBinaryResult(interp,(char *) p, count, TCL_VOLATILE);
  }
 else
  {
   while (count--)
    {
     unsigned long value = 0;
     if (8 * sizeof(unsigned char) == format)
      {
       value = *((unsigned char *) p);
      }
     else if (8 * sizeof(unsigned short) == format)
      {
       value = *((unsigned short *) p);
      }
     else if (8 * sizeof(unsigned int) == format)
      {
       value = *((unsigned int *) p);
      }
     else if (8 * sizeof(unsigned long) == format)
      {
       value = *((unsigned long *) p);
      }
     else
      {
       Tcl_SprintfResult(interp, "No type for format %d", format);
       return TCL_ERROR;
      }
     p += (format / 8);

     if (type == XA_ATOM)
      {
       if ((Atom) value != None)
        Tcl_AppendElement(interp, Tk_GetAtomName(tkwin, value));
      }
     else
      {
       Tcl_IntResults(interp, 1, 1, value);
      }
    }
  }
 return TCL_OK;
}

static int
ArgToProp(interp, tkwin, type, format, arg, prop, count)
Tcl_Interp *interp;
Tk_Window tkwin;
Atom type;
int format;
Arg arg;
unsigned char **prop;
long unsigned int *count;
{
 int result = TCL_OK;
 if (format == 8)
  {
   char *s = LangString(arg);
   int l = strlen(s);
   *prop = (unsigned char *) ckalloc(l + 1);
   *count = l + 1;
   strcpy((char *)(*prop), s);
  }
 else
  {
   LangFreeProc *freeProc = NULL;
   int valc = 0;
   Arg *valv = NULL;
   result = Lang_SplitList(interp, arg, &valc, &valv, &freeProc);
   if (result == TCL_OK)
    {
     unsigned char *p = (unsigned char *) ckalloc(valc * format / 8);
     int i;
     *prop = p;
     *count = valc;
     for (i = 0; i < valc; i++)
      {
       int value = 0;
       if (type == XA_ATOM)
        {
         value = Tk_InternAtom(tkwin, LangString(valv[i]));
        }
       else
        {
         result = Tcl_GetInt(interp, valv[i], &value);
         if (result != TCL_OK)
          break;
        }
       if (8 * sizeof(unsigned char) == format)
        {
         *((unsigned char *) p) = value;
        }
       else if (8 * sizeof(unsigned short) == format)
        {
         *((unsigned short *) p) = value;
        }
       else if (8 * sizeof(unsigned int) == format)
        {
         *((unsigned int *) p) = value;
        }
       else if (8 * sizeof(unsigned long) == format)
        {
         *((unsigned long *) p) = value;
        }
       else
        {
         Tcl_SprintfResult(interp, "No type for format %d", format);
         result = TCL_ERROR;
         break;
        }
       p += (format / 8);
      }
     if (freeProc)
      (*freeProc) (valc, valv);
     if (result != TCL_OK)
      {
       ckfree(*prop);
       *prop = NULL;
       *count = 0;
      }
    }
  }
 return result;
}

int
Tk_PropertyCmd(clientData, interp, argc, args)
ClientData clientData;            /* Main window associated with
                                     * interpreter. */
Tcl_Interp *interp;               /* Current interpreter. */
int argc;                         /* Number of arguments. */
Arg *args;                        /* Argument strings. */
{

 Tk_Window tkwin = (Tk_Window) clientData;
 Tk_Window window;
 Atom atom;
 Window xid;
 int length;
 char c;

 if (argc < 3)
  {
 error:
   Tcl_SprintfResult(interp,
                "wrong # args: should be \"%.50s option window ?arg arg ...?\"",
                     LangString(args[0]));
   return TCL_ERROR;
  }

 window = Tk_NameToWindow(interp, LangString(args[2]), tkwin);
 if (window == NULL)
  return TCL_ERROR;
 tkwin = window;
 Tk_MakeWindowExist(window);
 xid = Tk_WindowId(window);

 c = LangString(args[1])[0];
 length = strlen(LangString(args[1]));
 if (!c)
  goto error;

 if (((c == 'g') && (strncmp(LangString(args[1]), "get", length) == 0)) ||
     ((c == 'e') && (strncmp(LangString(args[1]), "exists", length) == 0)) ||
     ((c == 'd') && (strncmp(LangString(args[1]), "delete", length) == 0))
  )
  {
   int result = TCL_OK;
   if (argc == 5)
    {
     if (!strcmp(LangString(args[4]), "root"))
      xid = RootWindowOfScreen(Tk_Screen(tkwin));
     else
      {
       char *end;
       xid = strtoul(LangString(args[4]), &end, 10);
       if (*end)
        {
         Tcl_SprintfResult(interp, "Bad number '%s'", LangString(args[4]));
         return TCL_ERROR;
        }
      }
     argc--;
    }
   if (argc != 4)
    {
     Tcl_SprintfResult(interp, "wrong # args: should be \"%.50s %s window Atom ?xid?\"",
                       LangString(args[0]), LangString(args[1]));
     return TCL_ERROR;
    }
   else
    {
     Atom atom = Tk_InternAtom(tkwin, LangString(args[3]));
     if (c == 'd')
      {
       XDeleteProperty(Tk_Display(tkwin), xid, atom);
      }
     else
      {
       long unsigned int size = 0;
       int format = PropertyExists(tkwin, xid, atom, &size);
       if (c == 'e')
        {
         Tcl_IntResults(interp, 1, 0, format);
        }
       else
        {
         Atom type = None;
         unsigned char *prop = NULL;
         unsigned long count = 0;
         XGetWindowProperty(Tk_Display(tkwin), xid, atom, 0L, size, False,
                         AnyPropertyType, &type, &format, &count, &size, &prop);
         if (format == 0 || type == None)
          {
           Tcl_SprintfResult(interp, "Property %s does not exist on 0x%lx",
                             LangString(args[3]), (unsigned long) xid);
           result = TCL_ERROR;
          }
         else
          {
           Tcl_SetResult(interp, Tk_GetAtomName(tkwin, type), TCL_STATIC);
           result = PropToResult(interp, tkwin, type, prop, format, count);
          }
         if (prop)
          XFree((char *) prop);
        }
      }
    }
   return result;
  }
 else if ((c == 'l') && (strncmp(LangString(args[1]), "list", length) == 0))
  {
   if (argc == 4)
    {
     if (!strcmp(LangString(args[3]), "root"))
      xid = RootWindowOfScreen(Tk_Screen(tkwin));
     else
      {
       char *end;
       xid = strtoul(LangString(args[3]), &end, 10);
       if (*end)
        {
         Tcl_SprintfResult(interp, "Bad number '%s'", LangString(args[3]));
         return TCL_ERROR;
        }
      }
     argc--;
    }
   if (argc == 3)
    {
     int num_prop = 0;
     Atom *list = XListProperties(Tk_Display(tkwin), xid, &num_prop);
     int i;
     for (i = 0; i < num_prop; i++)
      {
       if (list[i] != None)
        Tcl_AppendElement(interp, Tk_GetAtomName(tkwin, list[i]));
      }
     if (list)
      XFree((char *) list);
    }
   return TCL_OK;
  }
 else if ((c == 's') && (strncmp(LangString(args[1]), "set", length) == 0))
  {
   int result = TCL_OK;
   if (argc == 8)
    {
     if (!strcmp(LangString(args[7]), "root"))
      xid = RootWindowOfScreen(Tk_Screen(tkwin));
     else
      {
       char *end;
       xid = strtoul(LangString(args[7]), &end, 10);
       if (*end)
        {
         Tcl_SprintfResult(interp, "Bad number '%s'", LangString(args[7]));
         return TCL_ERROR;
        }
      }
     argc--;
    }
   if (argc != 7)
    {
     Tcl_SprintfResult(interp, "wrong # args: should be \"%.50s %s window Atom type format value ?xid?\"",
                       LangString(args[0]), LangString(args[1]));
     return TCL_ERROR;
    }
   else
    {
     Atom atom = Tk_InternAtom(tkwin, LangString(args[3]));
     Atom type = Tk_InternAtom(tkwin, LangString(args[4]));
     int format = 0;
     result = Tcl_GetInt(interp, args[5], &format);
     if (result == TCL_OK)
      {
       unsigned char *prop = NULL;
       unsigned long count = 0;
       result = ArgToProp(interp, tkwin, type, format, args[6], &prop, &count);
       if (result == TCL_OK)
        {
         XChangeProperty(Tk_Display(tkwin), xid, atom, type, format,
                         PropModeReplace, prop, count);
         if (prop)
          ckfree(prop);
        }
      }
    }
   return result;
  }
 else
  {
   Tcl_SprintfResult(interp,
              "bad option \"%.50s\":  must be get, exists, list, delete or set",
                     LangString(args[1]));
   return TCL_ERROR;
  }
}
