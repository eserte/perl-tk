# $Id: NoteBook.pm,v 1.1 1996/08/29 21:45:49 rsi Exp $
#
# Implementation of NoteBook widget.
# Derived from NoteBook.tcl in Tix 4.0

# Contributed by Rajappa Iyer <rsi@netcom.com>
# Hack by Nick for 'menu' traversal.

package Tk::NoteBook;

use Tk qw(Ev);

use Carp;
require Tk::Frame;
require Tk::NBFrame;
require Tk::VStack;

Tk::Widget->Construct("NoteBook");

@Tk::NoteBook::ISA = qw(Tk::VStack);

sub TraverseToNoteBook;

sub ClassInit
{
 my ($class,$mw) = @_;
 if (0)
  {
   # class binding does not work right due to extra level of 
   # widget hierachy
   $mw->bind($class,"<ButtonPress-1>", ['MouseDown',Ev('x'),Ev('y')]);
   $mw->bind($class,"<ButtonRelease-1>", ['MouseUp',Ev('x'),Ev('y')]);
                                                
   $mw->bind($class,"<B1-Motion>", ['MouseDown',Ev('x'),Ev('y')]);
   $mw->bind($class,"<Left>", ['FocusNext','prev']);
   $mw->bind($class,"<Right>", ['FocusNext','next']);
                                                
   $mw->bind($class,"<Return>", 'SetFocusByKey');
   $mw->bind($class,"<space>", 'SetFocusByKey');
  }
 return $class;
}

sub Populate {
    my ($cw, $args) = @_;

    $cw->SUPER::Populate($args);
    $cw->{"pad-x1"} = 0;
    $cw->{"pad-x2"} = 0;
    $cw->{"pad-y1"} = 20;
    $cw->{"pad-y2"} = 0;

    my $f = $cw->Component("NBFrame" => "nbframe");

    if (1)
     {
      # Should be class bindings 
    $f->bind("<ButtonPress-1>", sub {
	$cw->MouseDown($f->XEvent->x, $f->XEvent->y);
    });
    $f->bind("<ButtonRelease-1>", sub {
	$cw->MouseUp($f->XEvent->x, $f->XEvent->y);
    });
    $f->bind("<B1-Motion>", sub {
	$cw->MouseDown($f->XEvent->x, $f->XEvent->y);
    });
    $f->bind("<Left>", sub {$cw->FocusNext("prev");});
    $f->bind("<Right>", sub {$cw->FocusNext("next");});
    $f->bind("<Return>", sub {$cw->SetFocusByKey;});
    $f->bind("<space>", sub {$cw->SetFocusByKey;});

     }

    $f->configure(-slave => 1, -takefocus => 1, -relief => "raised");
    $cw->{"top"} = $f;
    $cw->ConfigSpecs(-takefocus => ["SELF", "takeFocus", "TakeFocus", 0],
		     "DEFAULT" => [$f]);
}

sub add {
    my ($w, $child, %args) = @_;
    my $c = $w->SUPER::add($child, %args);
    delete $args{-createcmd};
    delete $args{-raisecmd};
    if (keys %args) {
	$w->{"top"}->add($child, %args);
    }
    return $c;
}

sub raise {
    my ($w, $child) = @_;
    $w->SUPER::raise($child);
    if ($w->{"top"}->pagecget($child, -state) eq "normal") {
	$w->{"top"}->activate($child);
	$w->{"top"}->focus($child);
    }
}

sub delete {
    my ($w, $child) = @_;
    $w->SUPER::delete($child);
    $w->{"top"}->delete($child);
}

sub Resize {
    my ($w) = @_;
    
    my ($tW, $tH) = split(" ", $w->{"top"}->geometryinfo);
    $w->{"pad-x1"} = 2;
    $w->{"pad-x2"} = 2;
    $w->{"pad-y1"} = $tH + (defined $w->{"-ipadx"} ? $w->{"-ipadx"} : 0) + 1;
    $w->{"pad-y2"} = 2;
    $w->{"minW"} = $tW;
    $w->{"minH"} = $tH;
    $w->SUPER::Resize;
}

sub MouseDown {
    my ($w, $x, $y) = @_;
    my $name = $w->{"top"}->identify($x, $y);
    $w->{"top"}->focus($name);
    $w->{"down"} = $name;
}

sub MouseUp {
    my ($w, $x, $y) = @_;
    my $name = $w->{"top"}->identify($x, $y);
    if ((defined $name) &&
	($name eq $w->{"down"}) &&
	($w->{"top"}->pagecget($name, -state) eq "normal")) {
	$w->{"top"}->activate($name);
	$w->SUPER::raise($name);
    } else {
	$w->{"top"}->focus($name);
    }
}

sub FocusNext {
    my ($w, $dir) = @_;
    my $name;
    
    if (not defined $w->{"top"}->info("focus")) {
	$name = $w->{"top"}->info("active");
	$w->{"top"}->focus($name);
    } else {
	$name = $w->{"top"}->info("focus" . $dir);
	$w->{"top"}->focus($name);
    }
}

sub SetFocusByKey {
    my ($w) = @_;

    my $name = $w->{"top"}->info("focus");
    if (defined $name) {
	if ($w->{"top"}->pagecget($name, -state) eq "normal") {
	    $w->raise($name);
	    $w->{"top"}->activate($name);
	}
    }
}

sub NoteBookFind {
    my ($w, $char) = @_;

    foreach $page (@{$w->{"windows"}}) {
	$i = $w->{"top"}->pagecget($page, -underline);
	$c = substr($page, $i, 1);
	if ($char =~ /$c/) {
	    if ($w->{"top"}->pagecget($page, -state) ne "disabled") {
		return $page;
	    }
	}
    }
    return undef;
}

#
# This is called by TraveseToMenu when an <Alt-Keypress> occurs
# See the code in Tk.pm
# 
sub FindMenu
{
    my ($w, $char) = @_;

    foreach $page (@{$w->{"windows"}}) {
	$i = $w->{"top"}->pagecget($page, -underline);
	$c = substr($page, $i, 1);
	if ($char =~ /$c/) {
	    if ($w->{"top"}->pagecget($page, -state) ne "disabled") {
                $w->{"keypage"} = $page;
		return $w;
	    }
	}
    }
    return undef;
}

#
# This is called to post the supposed 'menu' 
# when we have returned ourselves as a 'menu' matching
# and <Alt-KeyPress>,  See the code in Tk.pm
# 
sub PostFirst
{
 my ($w) = @_;
 my $page = delete $w->{"keypage"};
 if (defined $page)
  {
   $w->raise($page);
  }
}

1;

#
# $Log: NoteBook.pm,v $
# Revision 1.1  1996/08/29 21:45:49  rsi
# Initial revision
#
#
