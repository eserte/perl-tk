package Tk::NoteBook;
#
# Implementation of NoteBook widget.
# Derived from NoteBook.tcl in Tix 4.0

# Contributed by Rajappa Iyer <rsi@earthling.net>
# Hacked by Nick for 'menu' traversal.
# Restructured by Nick 

use vars qw($VERSION @ISA);

$VERSION = '3.008'; # $Id: //depot/Tk8/Tixish/NoteBook.pm#8$
require Tk::NBFrame;

@ISA = qw(Tk::Derived Tk::NBFrame);
Tk::Widget->Construct("NoteBook");
use strict;

use Tk qw(Ev);

use Carp;
require Tk::Frame;

sub TraverseToNoteBook;

sub ClassInit 
{
 my ($class,$mw) = @_;
 # class binding does not work right due to extra level of
 # widget hierachy
 $mw->bind($class,"<ButtonPress-1>", ['MouseDown',Ev('x'),Ev('y')]);
 $mw->bind($class,"<ButtonRelease-1>", ['MouseUp',Ev('x'),Ev('y')]);
 
 $mw->bind($class,"<B1-Motion>", ['MouseDown',Ev('x'),Ev('y')]);
 $mw->bind($class,"<Left>", ['FocusNext','prev']);
 $mw->bind($class,"<Right>", ['FocusNext','next']);
 
 $mw->bind($class,"<Return>", 'SetFocusByKey');
 $mw->bind($class,"<space>", 'SetFocusByKey');
 return $class;
}            

sub raised 
{
 return shift->{"topchild"};
}
       
sub Populate 
{      
 my ($w, $args) = @_;
 
 $w->SUPER::Populate($args);
 $w->{"pad-x1"} = 0;
 $w->{"pad-x2"} = 0;
 $w->{"pad-y1"} = 0;
 $w->{"pad-y2"} = 0;
 
 $w->{"nWindows"} = 0;
 $w->{"minH"} = 1;
 $w->{"minW"} = 1;
 
 $w->{"counter"} = 0;
 $w->{"resize"} = 0;
 
 $w->ConfigSpecs(-ipadx => ["PASSIVE", "ipadX", "Pad", 0],
                 -ipady => ["PASSIVE", "ipadY", "Pad", 0],
                 -takefocus => ["SELF", "takeFocus", "TakeFocus", 0],
                 -dynamicgeometry => ["PASSIVE", "dynamicGeometry", "DynamicGeometry", 0]);
 
 # SetBindings
 $w->bind("<Configure>", sub {$w->MasterGeomProc;});
 
 $args->{-slave} = 1;
 $args->{-takefocus} = 1;
 $args->{-relief} = 'raised';
 
 $w->QueueResize;
}

#---------------------------
# Public methods
#---------------------------                   

sub page_widget
{
 my $w = shift;
 $w->{'_pages_'} = {} unless exists $w->{'_pages_'};
 my $h = $w->{'_pages_'};
 if (@_)
  {
   my $name = shift;
   if (@_)
    {
     my $cw = shift;
     if (defined $cw)
      {
       $h->{$name} = $cw;
      }
     else
      {
       return delete $h->{$name};
      }
    }
   return $h->{$name};
  }
 else
  {
   return (values %$h);
  }
}

sub add 
{
 my ($w, $child, %args) = @_; 
 
 croak("$child already exists") if defined $w->page_widget($child);
 
 my $f = Tk::Frame->new($w,Name => $child,-relief => 'raised');
 
 my $ccmd = delete $args{-createcmd};
 my $rcmd = delete $args{-raisecmd};
 $f->{-createcmd} = $ccmd if (defined $ccmd);
 $f->{-raisecmd} = $rcmd if (defined $rcmd);
 
 # manage our geometry
 $w->ManageGeometry($f);
 # create default bindings
 $f->bind("<Configure>", sub {$w->ClientGeomProc('-configure', $f)});
 $f->bind("<Destroy>", sub {$w->delete($child,1);}); # XXX
 $w->page_widget($child,$f);
 $w->{"nWindows"}++;
 push(@{$w->{"windows"}}, $child);
 $w->SUPER::add($child,%args);
 return $f;
}

sub raise 
{
 my ($w, $child) = @_;
 return unless defined $child;
 if ($w->pagecget($child, -state) eq "normal") 
  {
   $w->activate($child);
   $w->focus($child);
   my $childw = $w->page_widget($child);
   if ($childw) 
    {
     if (defined $childw->{-createcmd}) 
      {
       &{$$childw->{-createcmd}}($childw);
       delete $childw->{-createcmd};
      }
     # hide the original visible window
     my $oldtop = $w->{"topchild"};
     if (defined($oldtop) && ($oldtop ne $child)) 
      {        
       $w->page_widget($oldtop)->UnmapWindow;
      }
     $w->{"topchild"} = $child;
     my $myW = $w->Width;
     my $myH = $w->Height;
   
     my $cW = $myW - $w->{"pad-x1"} - $w->{"pad-x2"} - 2 * (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
     my $cH = $myH - $w->{"pad-y1"} - $w->{"pad-y2"} - 2 * (defined $w->{-ipady} ? $w->{-ipady} : 0);
     my $cX = $w->{"pad-x1"} + (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
     my $cY = $w->{"pad-y1"} + (defined $w->{-ipady} ? $w->{-ipady} : 0);
   
     if ($cW > 0 && $cH > 0) 
      {    
       $childw->MoveResizeWindow($cX, $cY, $cW, $cH);
       $childw->MapWindow;
       $childw->raise;
      }
     if ((not defined $oldtop) || ($oldtop ne $child)) 
      {
       if (defined $childw->{-raisecmd}) 
        {
         &{$childw->{-raisecmd}}($childw);
        }
      }
    }
  }
}          

sub pageconfigure 
{
 my ($w, $child, %args) = @_;
 my $childw = $w->page_widget($child);
 if (defined $childw) 
  {
   my $ccmd = delete $args{-createcmd};
   my $rcmd = delete $args{-raisecmd};
   $childw->{-createcmd} = $ccmd if (defined $ccmd);
   $childw->{-raisecmd} = $rcmd if (defined $rcmd);
   $w->SUPER::pageconfigure($child, %args) if (keys %args);
  }
}

sub pages {
    my ($w) = @_;
    return @{$w->{"windows"}};
}

sub pagecget 
{
 my ($w, $child, $opt) = @_;
 my $childw = $w->page_widget($child);
 if (defined $childw)
  {
   return $childw->{-createcmd} if ($opt =~ /-createcmd/);
   return $childw->{-raisecmd} if ($opt =~ /-raisecmd/);
   return $w->SUPER::pagecget($child, $opt);
  } 
 else 
  {
   carp "page $child does not exist";
  }
}

sub delete 
{
 my ($w, $child, $destroy) = @_;          
 my $childw = $w->page_widget($child,undef);
 if (defined $childw) 
  {         
   $childw->bind("<Destroy>", undef);
   $childw->destroy;
   @{$w->{"windows"}} = grep($_ !~ /$child/, @{$w->{"windows"}});
   $w->{"nWindows"}--;
   $w->SUPER::delete($child);
   # see if the child to be deleted was the top child
   if ((defined $w->{"topchild"}) && ($w->{"topchild"} eq $child)) 
    {                             
     delete $w->{"topchild"};
     if ( @{$w->{'windows'}}) 
      {
       $w->raise($w->{'windows'}[0]);
      }
    }
  } 
 else 
  {
   carp "page $child does not exist" unless $destroy;
  }
}

#---------------------------------------
# Private methods
#---------------------------------------

sub MouseDown {
    my ($w, $x, $y) = @_;
    my $name = $w->identify($x, $y);
    $w->focus($name);
    $w->{"down"} = $name;
}

sub MouseUp {
    my ($w, $x, $y) = @_;
    my $name = $w->identify($x, $y);
    if ((defined $name) &&
        ($name eq $w->{"down"}) &&
        ($w->pagecget($name, -state) eq "normal")) {
        $w->raise($name);
    } else {
        $w->focus($name);
    }
}

sub FocusNext {
    my ($w, $dir) = @_;
    my $name;

    if (not defined $w->info("focus")) {
        $name = $w->info("active");
        $w->focus($name);
    } else {
        $name = $w->info("focus" . $dir);
        $w->focus($name);
    }
}

sub SetFocusByKey {
    my ($w) = @_;

    my $name = $w->info("focus");
    if (defined $name) {
        if ($w->pagecget($name, -state) eq "normal") {
            $w->raise($name);
            $w->activate($name);
        }
    }
}

sub NoteBookFind {
    my ($w, $char) = @_;
 
    my $page;
    foreach $page (@{$w->{"windows"}}) {
        my $i = $w->pagecget($page, -underline);
        my $c = substr($page, $i, 1);
        if ($char =~ /$c/) {
            if ($w->pagecget($page, -state) ne "disabled") {
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
        my $i = $w->pagecget($page, -underline);
        my $l = $w->pagecget($page, -label);
        next if (not defined $l);
        my $c = substr($l, $i, 1);
        if ($char =~ /$c/i) {
            if ($w->pagecget($page, -state) ne "disabled") {
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

sub MasterGeomProc 
{
 my ($w) = @_;
 if (Tk::Exists($w)) 
  {
   $w->{"resize"} = 0 unless (defined $w->{"resize"}); 
   $w->QueueResize;
  }
}

sub SlaveGeometryRequest 
{
 my $w = shift;
 if (Tk::Exists($w)) 
  {
   $w->QueueResize;
  }
}

sub LostSlave {
    my ($w, $s) = @_;
    print "Loosing $s\n";
    $s->UnmapWindow;
}

sub ClientGeomProc 
{
 my ($w, $flag, $client) = @_;
 $w->QueueResize if (Tk::Exists($w));
 if ($flag =~ /-lostslave/) 
  {
   carp "Geometry Management Error: Another geometry manager has taken control of $client. This error is usually caused because a widget has been created in the wrong frame: it should have been created inside $client instead of $w";
  }
}

sub QueueResize 
{
 my $w = shift;
 $w->DoWhenIdle(['Resize', $w]) unless ($w->{"resize"}++);
}   

sub Resize {

    my ($w) = @_;

    return unless Tk::Exists($w) && $w->{"nWindows"} && $w->{"resize"};

    my ($tW, $tH) = split(" ", $w->geometryinfo);
    $w->{"pad-x1"} = 2;
    $w->{"pad-x2"} = 2;
    $w->{"pad-y1"} = $tH + (defined $w->{"-ipadx"} ? $w->{"-ipadx"} : 0) + 1;
    $w->{"pad-y2"} = 2;
    $w->{"minW"} = $tW;
    $w->{"minH"} = $tH;

    $w->{"resize"} = 0;
    my $reqW = $w->{-width} || 0;
    my $reqH = $w->{-height} || 0;

    if ($reqW * $reqH == 0) 
     {
        if ((not defined $w->{-dynamicgeometry}) ||
            ($w->{-dynamicgeometry} == 0)) {
            $reqW = 1;
            $reqH = 1;
            
            my $childw;
            foreach $childw ($w->page_widget) 
             {
                my $cW = $childw->ReqWidth;
                my $cH = $childw->ReqHeight;
                $reqW = $cW if ($reqW < $cW);
                $reqH = $cH if ($reqH < $cH);
            }
        } else {
            if (defined $w->{"topchild"}) {
                my $topw = $w->page_widget($w->{"topchild"});
                $reqW = $topw->ReqWidth;
                $reqH = $topw->ReqHeight;
            } else {
                $reqW = 1;
                $reqH = 1;
            }
        }
        $reqW += $w->{"pad-x1"} + $w->{"pad-x2"} + 2 * (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
        $reqH += $w->{"pad-y1"} + $w->{"pad-y2"} + 2 * (defined $w->{-ipady} ? $w->{-ipady} : 0);
        $reqW = ($reqW > $w->{"minW"}) ? $reqW : $w->{"minW"};
        $reqH = ($reqH > $w->{"minH"}) ? $reqH : $w->{"minH"};
    }
    if (($w->ReqWidth != $reqW) ||
        ($w->ReqHeight != $reqH)) {
        $w->{"counter"} = 0 if (not defined $w->{"counter"});
        if ($w->{"counter"} < 50) {
            $w->{"counter"}++;
            $w->GeometryRequest($reqW, $reqH);
            $w->DoWhenIdle(sub {$w->Resize;});
            $w->{"resize"} = 1;
            return;
        }
    }
    $w->{"counter"} = 0;
    $w->raise($w->{"topchild"} || ${$w->{"windows"}}[0]);
    $w->{"resize"} = 0;
}

1;

__END__

=head1 NAME

Tk::NoteBook - display several windows in limited space with notebook metaphor.

=for category Tix Extensions

=head1 SYNOPSIS

  use Tk::NoteBook;
  ...
  $w = $frame->NoteBook();
  $page1 = $w->add("page1", options);
  $page2 = $w->add("page2", options);
  ...
  $page2 = $w->add("page2", options);

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

=head1 AUTHORS

B<Rajappa Iyer>  <rsi@earthling.net>
Nick Ing-Simmons <nick@ni-s.u-net.com>

This code and documentation was derived from NoteBook.tcl in
Tix4.0 written by Ioi Lam. It may be distributed under the same
conditions as Perl itself.

=cut
