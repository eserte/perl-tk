# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Converted from tearoff.tcl --
#
# This file contains procedures that implement tear-off menus.
#
# @(#) tearoff.tcl 1.3 94/12/17 16:05:25
#
# Copyright (c) 1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# tkTearoffMenu --
# Given the name of a menu, this procedure creates a torn-off menu
# that is identical to the given menu (including nested submenus).
# The new torn-off menu exists as a toplevel window managed by the
# window manager. The return value is the name of the new menu.
#
# Arguments:
# w - The menu to be torn-off (duplicated).
sub TearOffMenu
{
 my $w = shift;
 # Find a unique name to use for the torn-off menu. Find the first
 # ancestor of w that is a toplevel but not a menu, and use this as
 # the parent of the new menu. This guarantees that the torn off
 # menu will be on the same screen as the original menu. By making
 # it a child of the ancestor, rather than a child of the menu, it
 # can continue to live even if the menu is deleted; it will go
 # away when the toplevel goes away.
 my $parent = $w->parent;
 while ($parent->toplevel != $parent || $parent->IsMenu)
  {
   $parent = $parent->parent;
  }
 my $menu = $w->MenuDup($parent);
 # $menu->overrideredirect(0);
 $menu->configure(-transient => 0);
 $menu->transient($parent);
 # Pick a title for the new menu by looking at the parent of the
 # original: if the parent is a menu, then use the text of the active
 # entry. If it's a menubutton then use its text.
 $parent = $w->parent;
 if ($parent->IsMenubutton)
  {
   $menu->title($parent->cget("-text"))
  }
 elsif ($parent->IsMenu)
  {
   $menu->title($parent->entrycget("active","-label"))
  }
 $menu->configure("-tearoff",0);
 $menu->post($w->x,$w->y);
 # Set tkPriv(focus) on entry: otherwise the focus will get lost
 # after keyboard invocation of a sub-menu (it will stay on the
 # submenu).
 $menu->bind("<Enter>",EnterFocus);
 $menu->Callback('-tearoffcommand');
}

1;
