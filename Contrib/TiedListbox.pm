# $Id: TiedListbox.pm,v 0.1 1997/04/09 10:56:10 ada Exp $
#
# TiedListbox: tie together the scrolling and/or selection of Listboxes

package Tk::TiedListbox;

require Tk::Listbox;
use Carp;

@Tk::TiedListbox::ISA=qw(Tk::Derived Tk::Listbox);

Tk::Widget->Construct('TiedListbox');

use Tk::Submethods ( 'tie' => [qw(scroll selection all)],
                     'selection' => [qw(anchor clear includes set)],
                     'scan' => [qw(mark dragto)]
                   );

sub tie {
  my $cw=shift;
  bless $cw,"Tk::TiedListbox";
  if(@_) {
    $cw->untie;
    $cw->{-tieoption}='all';
    if($_[0] eq 'scroll' || $_[0] eq 'selection' || $_[0] eq 'all') {
      $cw->{-tieoption}=shift;
    }
    @_=@{$_[0]} if ref($_[0]) eq 'ARRAY';
    $cw->{-tiedto}=[@_];
    foreach $w (@_) {
      bless $w,ref($cw) if(ref($w)=~/Listbox$/); # Let's hope this works
      if(ref($w) eq ref($cw)) {
        $w->untie;
        $w->{-tieoption}=$cw->{-tieoption};
        $w->{-tiedto}=[$cw,grep($_ ne $w,@_)];
      }
      else {
        carp "trying to tie a non-Listbox $w";
      }
    }
    return $cw;
  }
  else {
    $cw->{-tieoption}='all',$cw->{-tiedto}=[]
      unless ref $cw->{-tiedto};
    return($cw->{-tieoption},$cw->{-tiedto});
  }
}

sub untie
{
  my $cw=shift;
  my @ret=$cw->tie;
  foreach $w (@{$cw->{-tiedto}}) {
    $w->{-tiedto}=[grep($_ ne $cw,@{$w->{-tiedto}})];
  }
  @ret;
}

sub Tk::Listbox::tie {
  shift->Tk::TiedListbox::tie(@_);
}

sub activate {
  my $cw=shift;
  $cw->CallTie('selection','activate',[$cw->index($_[0])],\&ActivateTie);
}

sub ActivateTie {
  my($w,$sub,$index)=@_;
  $w->$sub($index) if $index<$w->size;
}

sub scan {
  my $cw=shift;
  $cw->SUPER::scan(@_);
  $cw->CallTie('scroll','yview',[($cw->SUPER::yview)[0]*$cw->size]);
}

sub see {
  my $cw=shift;
  $cw->CallTie('scroll','see',[$cw->index($_[0])]);
}

sub selection {
  my $cw=shift;
  if($_[0] eq 'anchor') {
    $cw->CallTie('selection','selection',['anchor',$cw->index($_[1])],
                 \&SelectionAnchorTie);
  }
  if($_[0] eq 'clear' || $_[0] eq 'set') {
    $cw->CallTie('selection','selection',
                 [$_[0],map($cw->index($_),@_[1..@_-1])],
                 \&SelectionSetClearTie);
  }
  elsif($_[0] eq 'includes') {
    return $cw->SUPER::selection(@_);
  } 
}

sub SelectionAnchorTie {
  my($w,$sub,$action,$index)=@_;
  $w->$sub($action,$index) if $index<$w->size;
}

sub SelectionSetClearTie {
  my($w,$sub,$action,@index)=@_;
  $w->$sub($action,@index) if $index[0]<$w->size || 
                              ($#index>=1 && $index[1]<$w->size);
}

sub yview {
  my $cw=shift;
  if(@_) {
    if($_[0] eq 'moveto') {
      $cw->SUPER::yview(@_);
      $cw->CallTie('scroll','yview',[($cw->SUPER::yview)[0]*$cw->size]);
    }
    elsif($_[0] eq 'scroll') {
      $cw->SUPER::yview(@_);
      $cw->CallTie('scroll','yview',[($cw->SUPER::yview)[0]*$cw->size]);
    }
    else {
      $cw->CallTie('scroll','yview',[$cw->index($_[0])]);
    }
  }
  else {
    return $cw->SUPER::yview();
  }
}

sub YviewScrollTie {
  my($w,$sub,$cw,$action,$num,$what)=@_;
  if($w eq $cw) {
    $w->$sub($action,$num,$what);
  }
  else {
    $w->$sub('moveto',($cw->yview)[0]*$cw->size/$w->size);
  }
}


sub CallTie {
  my($cw,$option,$sub,$args,$tiesub)=@_;
  my $supersub="SUPER::$sub";
  $tiesub=sub{my($w,$sub)=(shift,shift); $w->$sub(@_);} 
    unless defined $tiesub;
  my @ret=&$tiesub($cw,$supersub,@$args);
  if(ref($cw->{'-tiedto'}) &&
     ($cw->{'-tieoption'} eq 'all' ||
      $cw->{'-tieoption'} eq $option)) {
    foreach $w (@{$cw->{'-tiedto'}}) {
      &$tiesub($w,$supersub,@$args);
    }
  }
  @ret;
}

1;

__END__

=head1 NAME

Tk::TiedListbox - gang together Listboxes

=head1 SYNOPSIS

    use Tk::TiedListbox

    $l1 = $mw->Listbox(-exportselection => 0,...);
    $l2 = $mw->Listbox(-exportselection => 0,...);
    $l3 = $mw->Listbox(-exportselection => 0,...);
    $l1->tie([$l2,$l3]);

=head1 DESCRIPTION

TiedListbox causes two or more Listboxes to be operated in tandem.
One application is emulating multi-column listboxes. The scrolling,
selection, or both mechanisms may be tied together. The methods B<tie>
and B<untie> are provided, along with overridden versions of some of
the Listbox methods to provide tandem operation.

Scrollbars are fully supported. You can use either explicitly created
B<Scrollbar>s, the B<ScrlListbox> widget, or the B<Scrolled>
super-widget. Tricks to "attach" multiple tied listboxes to a single
scrollbar are unnecessary and will lead to multiple calls of the
listbox methods (a bad thing).

The configuration options, geometry, and items of the Listboxes are
not altered by tying them. The programmer will have to make sure that
the setup of the Listboxes make sense together. Here are some
(unenforced) guidelines:

For listboxes with tied selection:
  set B<-exportselection> to 0 for all but possibly one Listbox
  use identical B<-selectmode> for all Listboxes
  if items are added/deleted, they should be done all at once and 
    at the same index, or the selection should be cleared
  Listboxes should have the same number of items
For listboxes with tied scrolling:
  use the same window height and font for all Listboxes
  Listboxes should have the same number of items

=head1 METHODS

=over 4

=item I<$listbox>->B<tie>?(?I<option>?, [I<listbox>,...])?

Ties together I<$listbox> and the list of Listboxes with the given
I<option>. Returns I<$listbox>.

If no arguments are given, returns a list containing two items: the
tie option ("scroll", "selection", or "all") and the list of Listboxes
that I<$listbox> is tied to.

I<option> can be one of "scroll", "selection", or "all".  If omitted,
"all" is assumed. "scroll" makes the tied Listboxes to scroll
together, "selection" makes selections to occur simultaneously in all
tied Listboxes, and "all" effects both actions.

All the Listboxes are B<untie>d (if previously tied) before being tied
to each other; hence a Listbox can only be in one "tie group" at a
time. "Tiedness" is commutative.

The tie method can be called with either Listbox or TiedListbox
objects. All listbox objects specified are reblessed to TiedListbox
objects.

Code such as below can be used to tie ScrlListboxes:

  $slb1=ScrlListbox(...); # or Scrolled('Listbox',...
  $slb2=ScrlListbox(...); # or Scrolled('Listbox',...
  $slb1->tie([$slb2->Subwidget('scrolled')]);

=item I<$listbox>->B<untie()>

This function unties the Listbox from its "tie group". The other items
in the "tie group" (if more than one) remain tied to each other.

Returns a list containing two items: the old tie option ("scroll",
"selection", or "all") and the list of Listboxes that I<$listbox> was
tied to.

=head1 OVERRIDDEN METHODS

You probably don't care about these. They are just details to tie
together the behaviors of the listboxes.

All overriden methods take identical arguments as the corresponding
B<Listbox> methods (see the B<Listbox> documentation for a full
description). All overridden methods that take an index interpret that
index in the context of the listbox object provided.

=item I<$listbox>->B<activate>(...)
=item I<$listbox>->B<selection>(...)

To allow tied selection, these functions are overridden for listboxes
tied together with the "selection" or "all" option. When an item is
selected or activated in one listbox, the items with the same index
(if present) are selected or activated in all tied listboxes.

The B<selection>('includes',...) submethod returns only information
about the given I<$listbox>.

=item I<$listbox>->B<scan>(...)
=item I<$listbox>->B<see>(...)
=item I<$listbox>->B<yview>(...)

To allow tied scrolling, these functions are overridden for listboxes
tied together with the "scroll" or "all" option. When one listbox is
scrolled, all the other tied listboxes are scrolled by the same number
of items (if possible). An attempt is made to keep items of the same
index at the top of each tied listbox, while not interfering with the
normal scrolling operations.

The B<yview> method with no arguments returns only information about
the given I<$listbox>.

Horizontal scrolling (via B<xview>) is not tied.

=back

=head1 BUGS

Reblessing the widgets to TiedListbox might be too weird. It will
disable any additional features for widgets in a class derived from
Listbox (none yet that I know of).

The bindtags for reblessed widgets aren't updated. This is probably
wouldn't be a good thing to do automatically anyway.

=head1 AUTHOR

B<Andrew Allen> ada@fc.hp.com

This code may be distributed under the same conditions as Perl.


