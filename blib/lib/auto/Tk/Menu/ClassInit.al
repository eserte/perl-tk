# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

#
#-------------------------------------------------------------------------
# Elements of tkPriv that are used in this file:
#
# cursor - Saves the -cursor option for the posted menubutton.
# focus - Saves the focus during a menu selection operation.
# Focus gets restored here when the menu is unposted.
# inMenubutton - The name of the menubutton widget containing
# the mouse, or an empty string if the mouse is
# not over any menubutton.
# popup - If a menu has been popped up via tk_popup, this
# gives the name of the menu. Otherwise this
# value is empty.
# postedMb - Name of the menubutton whose menu is currently
# posted, or an empty string if nothing is posted
# A grab is set on this widget.
# relief - Used to save the original relief of the current
# menubutton.
# window - When the mouse is over a menu, this holds the
# name of the menu; it's cleared when the mouse
# leaves the menu.
#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# Overall note:
# This file is tricky because there are four different ways that menus
# can be used:
#
# 1. As a pulldown from a menubutton. This is the most common usage.
# In this style, the variable tkPriv(postedMb) identifies the posted
# menubutton.
# 2. As a torn-off menu copied from some other menu. In this style
# tkPriv(postedMb) is empty, and the top-level menu is no
# override-redirect.
# 3. As an option menu, triggered from an option menubutton. In thi
# style tkPriv(postedMb) identifies the posted menubutton.
# 4. As a popup menu. In this style tkPriv(postedMb) is empty and
# the top-level menu is override-redirect.
#
# The various binding procedures use the state described above to
# distinguish the various cases and take different actions in each
# case.
#-------------------------------------------------------------------------
# Bind --
# This procedure is invoked the first time the mouse enters a menubutton
# widget or a menubutton widget receives the input focus. It creates
# all of the class bindings for both menubuttons and menus.
#
# Arguments:
# w - The widget that was just entered or just received
# the input focus.
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.
sub ClassInit
{
 my ($class,$mw) = @_;
 # Must set focus when mouse enters a menu, in order to allow
 # mixed-mode processing using both the mouse and the keyboard.
 $mw->bind($class,"<Enter>", 'Enter');
 $mw->bind($class,"<Leave>", ['Leave',Ev(X),Ev(Y),Ev('s')]);
 $mw->bind($class,"<Motion>", ['Motion',Ev('y'),Ev('s')]);
 $mw->bind($class,"<ButtonPress>",'ButtonDown');
 $mw->bind($class,"<ButtonRelease>",'Invoke');
 $mw->bind($class,"<space>",'Invoke');
 $mw->bind($class,"<Return>",'Invoke');
 $mw->bind($class,"<Escape>",'Escape');
 $mw->bind($class,"<Left>",['LeftRight',"left"]);
 $mw->bind($class,"<Right>",['LeftRight',"right"]);
 $mw->bind($class,"<Up>",['NextEntry',-1]);
 $mw->bind($class,"<Down>",['NextEntry',1]);
 $mw->bind($class,"<KeyPress>", ['TraverseWithinMenu',Ev(A)]);
 return $class;
}

1;
