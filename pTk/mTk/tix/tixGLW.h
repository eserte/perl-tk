/*
 * tixGLW.h
 *
 *	This is the standard header file for all tix C code. It defines
 * many macros and utility functions to make it easier to write TCL commands
 * and TK widgets in C. No more needs to write 2000 line functions!
 *
 *
 */

#ifndef _TIX_GLW_H_
#define _TIX_GLW_H_

#ifdef __cplusplus
extern "C" {
#endif


Tk_3DBorder 			Tk_GetSGIOverlayBorder _ANSI_ARGS_((
				    Tcl_Interp *interp, Tk_Window tkwin,
				    Colormap colormap, Tk_Uid colorName));
XColor* 			Tk_SGIOverlayColor _ANSI_ARGS_((int index));


/*----------------------------------------------------------------------
 * The TIX GLW resource converters
 *----------------------------------------------------------------------	*/

extern Tk_CustomOption tixConfigOverlayBorder;
extern Tk_CustomOption tixConfigOverlayColor;


#ifdef __cplusplus
}
#endif

#endif /* _TIX_GLW_H_ */
