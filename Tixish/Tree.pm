package Tk::Tree;
# Tree -- TixTree widget
#
# Derived from Tree.tcl in Tix 4.1
#
# Chris Dean <ctdean@cogit.com>

use vars qw($VERSION);
$VERSION = '3.019'; # $Id: //depot/Tk8/Tixish/Tree.pm#19 $

use Tk ();
use Tk::Derived;
use Tk::HList;
use base  qw(Tk::Derived Tk::HList);
use strict;

Construct Tk::Widget 'Tree';

sub Tk::Widget::ScrlTree { shift->Scrolled('Tree' => @_) }

sub Populate
{
 my( $w, $args ) = @_;

 $w->SUPER::Populate( $args );

 $w->ConfigSpecs(
        -ignoreinvoke => ['PASSIVE',  'ignoreInvoke', 'IgnoreInvoke', 0],
        -opencmd      => ['CALLBACK', 'openCmd',      'OpenCmd', 'OpenCmd' ],
        -indicatorcmd => ['CALLBACK', 'indicatorCmd', 'IndicatorCmd', 'IndicatorCmd'],
        -closecmd     => ['CALLBACK', 'closeCmd',     'CloseCmd', 'CloseCmd'],
        -indicator    => ['SELF', 'indicator', 'Indicator', 1],
        -indent       => ['SELF', 'indent', 'Indent', 20],
        -width        => ['SELF', 'width', 'Width', 20],
        -itemtype     => ['SELF', 'itemtype', 'Itemtype', 'imagetext'],
       );
}

sub autosetmode
{
 my( $w ) = @_;
 $w->setmode();
}

sub IndicatorCmd
{
 my( $w, $ent, $event ) = @_;

 my $mode = $w->getmode( $ent );

 if ( $event eq '<Arm>' )
  {
   if ($mode eq 'open' )
    {
     $w->_indicator_image( $ent, 'plusarm' );
    }
   else
    {
     $w->_indicator_image( $ent, 'minusarm' );
    }
  }
 elsif ( $event eq '<Disarm>' )
  {
   if ($mode eq 'open' )
    {
     $w->_indicator_image( $ent, 'plus' );
    }
   else
    {
     $w->_indicator_image( $ent, 'minus' );
    }
  }
 elsif( $event eq '<Activate>' )
  {
   $w->Activate( $ent, $mode );
   $w->Callback( -browsecmd => $ent );
  }
}

sub close
{
 my( $w, $ent ) = @_;
 my $mode = $w->getmode( $ent );
 $w->Activate( $ent, $mode ) if( $mode eq 'close' );
}

sub open
{
 my( $w, $ent ) = @_;
 my $mode = $w->getmode( $ent );
 $w->Activate( $ent, $mode ) if( $mode eq 'open' );
}

sub getmode
{
 my( $w, $ent ) = @_;

 return( 'none' ) unless $w->indicatorExists( $ent );

 my $img = $w->_indicator_image( $ent );
 return( 'open' ) if( $img eq 'plus' || $img eq 'plusarm' );
 return( 'close' );
}

sub setmode
{
 my ($w,$ent,$mode) = @_;
 unless (defined $mode)
  {
   $mode = 'none';
   my @args;
   push(@args,$ent) if defined $ent;
   my @children = $w->infoChildren( @args );
   if ( @children )
    {
     $mode = 'close';
     foreach my $c (@children)
      {
       $mode = 'open' if $w->infoHidden( $c );
       $w->setmode( $c );
      }
    }
  }

 if (defined $ent)
  {
   if ( $mode eq 'open' )
    {
     $w->_indicator_image( $ent, 'plus' );
    }
   elsif ( $mode eq 'close' )
    {
     $w->_indicator_image( $ent, 'minus' );
    }
   elsif( $mode eq 'none' )
    {
     $w->_indicator_image( $ent, undef );
    }
  }
}

sub Activate
{
 my( $w, $ent, $mode ) = @_;
 if ( $mode eq 'open' )
  {
   $w->Callback( -opencmd => $ent );
   $w->_indicator_image( $ent, 'minus' );
  }
 elsif ( $mode eq 'close' )
  {
   $w->Callback( -closecmd => $ent );
   $w->_indicator_image( $ent, 'plus' );
  }
 else
  {

  }
}

sub OpenCmd
{
 my( $w, $ent ) = @_;
 # The default action
 foreach my $kid ($w->infoChildren( $ent ))
  {
   $w->show( -entry => $kid );
  }
}

sub CloseCmd
{
 my( $w, $ent ) = @_;

 # The default action
 foreach my $kid ($w->infoChildren( $ent ))
  {
   $w->hide( -entry => $kid );
  }
}

sub Command
{
 my( $w, $ent ) = @_;

 return if $w->{Configure}{-ignoreInvoke};

 $w->Activate( $ent, $w->getmode( $ent ) ) if $w->indicatorExists( $ent );
}

sub _indicator_image
{
 my( $w, $ent, $image ) = @_;
 my $data = $w->privateData();
 if (@_ > 2)
  {
   if (defined $image)
    {
     $w->indicatorCreate( $ent, -itemtype => 'image' )
         unless $w->indicatorExists($ent);
     $data->{$ent} = $image;
     $w->indicatorConfigure( $ent, -image => $w->Getimage( $image ) );
    }
   else
    {
     $w->indicatorDelete( $ent ) if $w->indicatorExists( $ent );
     delete $data->{$ent};
    }
  }
 return $data->{$ent};
}

1;

__END__

#  Copyright (c) 1996, Expert Interface Technologies
#  See the file "license.terms" for information on usage and redistribution
#  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#  The file man.macros and some of the macros used by this file are
#  copyrighted: (c) 1990 The Regents of the University of California.
#               (c) 1994-1995 Sun Microsystems, Inc.
#  The license terms of the Tcl/Tk distrobution are in the file
#  license.tcl.

=cut
