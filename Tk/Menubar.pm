# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Menubar;
require Tk::Frame;
require Tk::Derived;
require Tk::Menu;
require Tk::Menu::Item;

use vars qw($VERSION @ISA);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/Menubar.pm#8$

use base  qw(Tk::Derived Tk::Menu);
use strict;

Construct Tk::Frame 'Menubar';

# Just make it a Frame until we figure out what else
# it should do.

sub Populate
{
 my ($cw,$args) = @_;
 $cw->SUPER::Populate($args);
 my $parent = $cw->parent;
 $parent->Advertise('menubar' => $cw);
 $cw->{'MenuButtons'} = {};
 $parent->configure(-menu => $cw);
}

sub Menubutton
{
 my ($cw,%args) = @_;
 my $name = delete($args{'-text'}) || $args{'-label'};;
 $args{'-label'} = $name if (defined $name);
 my $items = delete $args{'-menuitems'};
 my %pack = ();
 my $pack = delete $args{'-pack'};
 %pack = @{ $pack } if defined $pack;
 my $opt;
 foreach $opt (qw(-after -before -side -padx -ipadx -pady -ipady -fill))
  {
   my $val = delete $args{$opt};
   $pack{$opt} = $val if (defined $val);
  }
 if (defined($name) && !defined($args{-underline}))
  {
   my $underline = ($name =~ s/^(.*)~/$1/) ? length($1): undef;
   if (defined($underline) && ($underline >= 0))
    {
     $args{-underline} = $underline;
     $args{-label} = $name;
    }
  }
 my $mb = $cw->{'MenuButtons'}{$name};
 if (defined $mb)
  {
   $mb->configure(%args);
   # $mb->pack(%pack) if (%pack);
  }
 else
  {
   $mb = $cw->Cascade(%args); 
   $cw->{'MenuButtons'}{$name} = $mb;
   # $pack{'-side'} = 'left' unless (exists $pack{'-side'});
   # $mb->pack(%pack);
  }
 $mb->menu->AddItems(@$items) if (defined $items);
 return $mb;
}

sub command
{
 my ($cw,%args) = @_;
 my $button = delete $args{-button};
 $button = ['Misc', -underline => 0 ] unless (defined $button);
 my @bargs = ();
 ($button,@bargs) = @$button if (ref($button) && ref $button eq 'ARRAY');
 unless (defined $cw->Subwidget($button))
  {
   $cw->Component('Menubutton' => $button, -text => $button, 
                  '-pack' => [ -side => 'left', -fill => 'y' ], @bargs);
  }
 $cw->Subwidget($button)->command(%args);
}

1;
