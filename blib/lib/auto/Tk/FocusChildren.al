# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

#----------------------------------------------------------------------------
# focus.tcl --
#
# This file defines several procedures for managing the input
# focus.
#
# @(#) focus.tcl 1.6 94/12/19 17:06:46
#
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

sub FocusChildren { shift->children }

#
# focusNext --
# This procedure is invoked to move the input focus to the next window
# after a given one. "Next" is defined in terms of the window
# stacking order, with all the windows underneath a given top-level
# (no matter how deeply nested in the hierarchy) considered except
# for frames and toplevels.
#
# Arguments:
# w - Name of a window: the procedure will set the focus
# to the next window after this one in the traversal
# order.
1;
