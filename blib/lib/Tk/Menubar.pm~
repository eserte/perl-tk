# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Menubar;
require Tk::Frame;
require Tk::Menubutton;

use vars qw($VERSION);
$VERSION = '2.008'; # $Id: //depot/Tk/Tk/Menubar.pm#8$

@ISA = qw(Tk::Frame);
use strict;

Construct Tk::Frame 'Menubar';

# Just make it a Frame until we figure out what else
# it should do.

sub Populate
{
 my ($cw,$args) = @_;
 $cw->SUPER::Populate($args);
 my $parent = $cw->parent;
 my @pack   = (-fill => 'x', -side => 'top', -expand => 0);
 my $before = ($parent->packSlaves)[0];
 unshift(@pack,-before => $before) if (defined $before);
 $parent->Advertise('menubar' => $cw);
 $cw->{'MenuButtons'} = {};
 $cw->pack(@pack);
}

sub Menubutton
{
 my ($cw,%args) = @_;
 my $name = $args{'-text'};
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
     $args{-text} = $name;
    }
  }
 $name = lcfirst($name);
 $name =~ s/\s/_/g; 
 my $mb = $cw->{'MenuButtons'}{$name};
 if (defined $mb)
  {
   $mb->configure(%args);
   $mb->pack(%pack) if (%pack);
  }
 else
  {
   $pack{'-side'} = 'left' unless (exists $pack{'-side'});
   $mb = $cw->SUPER::Menubutton(Name => $name,%args); 
   $cw->{'MenuButtons'}{$name} = $mb;
   $mb->pack(%pack);
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
