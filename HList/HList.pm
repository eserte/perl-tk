# Converted from listbox.tcl --
#
# This file defines the default bindings for Tk listbox widgets.
#
# @(#) listbox.tcl 1.7 94/12/17 16:05:18
#
# Copyright (c) 1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package Tk::HList; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('HList');
sub Tk::Widget::ScrlHList { shift->Scrolled('HList'=>@_) }

bootstrap Tk::HList; 

sub Tk_cmd { \&Tk::hlist }

EnterMethods Tk::HList __FILE__,qw(add addchild anchor column
                                   delete dragsite dropsite entrycget
                                   entryconfigure geometryinfo hide item info
                                   nearest see selection show xview yview);

sub ClassInit
{
 my ($class,$mw) = @_;

 return $class;
}

1;

