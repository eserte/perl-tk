/*
 * tixItcl.c --
 *
 *	Compatibility functions that allow Tix to work under Incr Tcl.
 *
 * Copyright (c) 1996, Expert Interface Technologies
 *
 * See the file "license.terms" for information on usage and
 * redistribution of this file, and for a DISCLAIMER OF ALL
 * WARRANTIES.
 *
 */

#ifdef ITCL_2

#include <tclInt.h>
#include "tixInt.h"
#include "tixItcl.h"


/*----------------------------------------------------------------------
 * TixItclSetGlobalNameSp --
 *
 *	Set the ITcl scope to the global scope. This way, all the Tix
 *	commands and variables will be defined in the global scope. This
 *	is necessary for Tix to function properly under ITcl.
 *
 *----------------------------------------------------------------------
 */

int
TixItclSetGlobalNameSp(nameSpPtr, interp)
    TixItclNameSp * nameSpPtr;
    Tcl_Interp * interp;
{
    nameSpPtr->savedVarFramePtr = nameSpPtr->iPtr->varFramePtr;
    nameSpPtr->iPtr->varFramePtr = NULL;

    nameSpPtr->nsToken = Itcl_ActivateNamesp(interp, 
	    (Itcl_Namespace)(nameSpPtr->iPtr->globalNs));
    if (nameSpPtr->nsToken == NULL) {
	return 0;
    } else {
	return 1;
    }
}

/*----------------------------------------------------------------------
 * TixItclRestoreGlobalNameSp --
 *
 *	Set the ITcl scope to the scope saved by TixItclSetGlobalNameSp.
 *
 *----------------------------------------------------------------------
 */

void
TixItclRestoreGlobalNameSp(nameSpPtr, interp)
    TixItclNameSp * nameSpPtr;
    Tcl_Interp * interp;
{
    if (nameSpPtr->nsToken != NULL) {
	Itcl_DeactivateNamesp(interp, nameSpPtr->nsToken);
    }
    nameSpPtr->iPtr->varFramePtr = nameSpPtr->savedVarFramePtr;
}

#endif /* #ifdef  ITCL_2 */


#ifndef ITCL_2

#include <tcl.h>
/*
 * Put a dummy symbol here -- some linkers do not like a .o file
 * with no code and symbols.
 */

EXTERN void TixItclDummy _ANSI_ARGS_((void));


void
TixItclDummy()
{
}

#endif  /* #ifndef  ITCL_2 */
