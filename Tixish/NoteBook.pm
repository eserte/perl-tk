# $Id: NoteBook.pm,v 1.2 1996/12/02 00:35:21 rsi Exp $
#
# Implementation of NoteBook widget.
# Derived from NoteBook.tcl in Tix 4.0

# Contributed by Rajappa Iyer <rsi@ziplink.net>
# Hack by Nick for 'menu' traversal.

package Tk::NoteBook;
use strict;

use Tk qw(Ev);

use Carp;
require Tk::Frame;
require Tk::NBFrame;
require Tk::VStack;

Tk::Widget->Construct("NoteBook");

@Tk::NoteBook::ISA = qw(Tk::VStack);

sub TraverseToNoteBook;

sub ClassInit {
    my ($class,$mw) = @_;
    if (0) {
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

    if (1) {
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

#---------------------------
# Public methods
#---------------------------
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
    if (defined $w->{"top"}->{$child}) {
	$w->{"top"}->delete($child);
    }
}

#---------------------------------------
# Private methods
#---------------------------------------
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
    my $page;
    foreach $page (@{$w->{"windows"}}) {
	my $i = $w->{"top"}->pagecget($page, -underline);
	my $c = substr($page, $i, 1);
	if ($char =~ /$c/) {
	    if ($w->{"top"}->pagecget($page, -state) ne "disabled") {
		return $page;
	    }
	}
    }
    return undef;
}

# This is called by TraveseToMenu when an <Alt-Keypress> occurs
# See the code in Tk.pm
sub FindMenu {
    my ($w, $char) = @_;
    my $page;
    foreach $page (@{$w->{"windows"}}) {
	my $i = $w->{"top"}->pagecget($page, -underline);
	my $c = substr($page, $i, 1);
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
sub PostFirst {
    my ($w) = @_;
    my $page = delete $w->{"keypage"};
    if (defined $page) {
	$w->raise($page);
    }
}

1;

__END__

=head1 NAME

Tk::NoteBook - display several windows in limited space with notebook metaphor.

=head1 SYNOPSIS

  use Tk::NoteBook;
  ...
  $w = $frame->NoteBook();
  $page1 = $w->add("page1", options);
  $page2 = $w->add("page2", options);
  ...

=head1 DESCRIPTION

The NoteBook widget provides a notebook metaphor to display several
windows in limited space. The notebook is divided into a stack of pages
of which only one is displayed at any time. The other pages can be
selected by means of choosing the visual "tabs" at the top of the
widget. Additionally, the <Tab> key may be used to traverse the pages.
If B<-underline> is used, Alt- bindings will also work.

The widget takes all the options that a Frame does. In addition,
it supports the following options:

=over 4

=item B<-dynamicgeometry>

If set to false (default and recommended), the size of the NoteBook
will match the size of the largest page. Otherwise the size will
match the size of the current page causing the NoteBook to change
size when different pages of different sizes are selected.

=item B<-ipadx>

The amount of internal horizontal padding around the pages.

=item B<-ipady>

The amount of internal vertical padding around the pages.

=back

=head1 METHODS

The following methods may be used with a NoteBook object in addition
to standard methods.

=over 4

=item B<add(>I<page>, I<options>B<)>

Adds a page with name I<page> to the notebook. Returns an object
of type B<Frame>. The recognized I<options> are:

=over 4

=item B<-anchor>

Specifies how the information in a tab is to be displayed. Must be
one of B<n>, B<ne>, B<e>, B<se>, B<s>, B<sw>, B<w>, B<nw> or
B<center>.

=item B<-bitmap>

Specifies a bitmap to display on the tab of this page. The bitmap
is displayed only if none of the B<-label> or B<-image> options
are specified.

=item B<-image>

Specifies an image to display on the tab of this page. The image
is displayed only if the B<-label> option is not specified.

=item B<-label>

Specifies the text string to display on the tab of this page.

=item B<-justify>

When there are multiple lines of text displayed in a tab, this
option determines the justification of the lines.

=item B<-createcmd>

Specifies a Perl command to be called the first time the page is
shown on the screen. This option can be used to delay the creation
of the contents of a page until necessary. It can be useful in
situations where there are a large number of pages in a NoteBook
widget; with B<-createcmd> you do not have to make the user wait
until all pages are constructed before displaying the first page.

=item B<-raisecmd>

Specifies a Perl command to be called whenever this page is raised
by the user.

=item B<-state>

Specifies whether this page can be raised by the user. Must be
either B<normal> or B<disabled>.

=item B<-underline>

Specifies the integer index of a character to underline in the
tab. This option is used by the default bindings to implement
keyboard traversal for menu buttons and menu entries. 0
corresponds to the first character of text displayed on the
widget, 1 to the next character and so on.

=item B<-wraplength>

This option specifies the maximum line length of the label string
on this tab. If the line length of the label string exceeds this
length, then it is wrapped onto the next line so that no line is
longer than the specified length. The value may be specified in
any standard forms for screen distances. If this value is less
than or equal to 0, then no wrapping is done: lines will break
only at newline characters in the text.

=back

=item B<delete(>I<page>B<)>

Deletes the page identified by I<page>.

=item B<pagecget(>I<page>, I<option>B<)>

Returns the current value of the configuration otion given by
I<option> in the page given by I<page>. I<Option> may have any of
the values accepted in the B<add> method.

=item B<pageconfigure(>I<page>, I<options>B<)>

Like configure for the page indicated by I<page>. I<Options> may
be any of the options accepted by the B<add> method.

=item B<raise(>I<page>B<)>

Raise the page identified by I<page>.

=item B<raised()>

Returns the name of the currently raised page.

=back

=head1 AUTHOR

B<Rajappa Iyer> rsi@ziplink.net

This code and documentation was derived from NoteBook.tcl in
Tix4.0 written by Ioi Lam. It may be distributed under the same
conditions as Perl itself.

=cut
