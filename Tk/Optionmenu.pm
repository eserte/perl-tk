# Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Optionmenu;
require Tk::Menubutton;
require Tk::Menu;

use vars qw($VERSION);
$VERSION = '3.025'; # $Id: //depot/Tk8/Tk/Optionmenu.pm#25 $

use base  qw(Tk::Derived Tk::Menubutton);

use strict;

Construct Tk::Widget 'Optionmenu';

sub Populate
{
 my ($w,$args) = @_;
 $w->SUPER::Populate($args);
 $args->{-indicatoron} = 1;
 my $var = delete $args->{-textvariable};
 unless (defined $var)
  {
   my $gen = undef;
   $var = \$gen;
  }
 my $menu = $w->menu(-tearoff => 0);
 $w->configure(-textvariable => $var);

 # Should we allow -menubackground etc. as in -label* of Frame ?

 $w->ConfigSpecs(-command => ['CALLBACK',undef,undef,undef],
                 -options => ['METHOD', undef, undef, undef],
		 -variable=> ['PASSIVE', undef, undef, undef],
		 -font    => [['SELF',$menu], undef, undef, undef],

   -takefocus          => [ qw/SELF takefocus          Takefocus          1/ ],
   -highlightthickness => [ qw/SELF highlightThickness HighlightThickness 1/ ],
   -relief             => [ qw/SELF relief             Relief        raised/ ],

                );

 # configure -variable and -command now so that when -options
 # is set by main-line configure they are there to be set/called.
 $w->configure(-variable => $var) if ($var = delete $args->{-variable});
 $w->configure(-command  => $var) if ($var = delete $args->{-command});
}

sub setOption
{
 my ($w, $label, $val) = @_;
 $val = $label if @_ == 2;
 my $var = $w->cget(-textvariable);
 $$var = $label;
 $var = $w->cget(-variable);
 $$var = $val if $var;
 $w->Callback(-command => $val);
}

sub addOptions
{
 my $w = shift;
 my $menu = $w->menu;
 my $var = $w->cget(-textvariable);
 my $old = $$var;
 my $width = $w->cget('-width');
 my %hash;
 my $first;
 while (@_)
  {
   my $val = shift;
   my $label = $val;
   if (ref $val)
    {
     ($label, $val) = @$val;
    }
   my $len = length($label);
   $width = $len if (!defined($width) || $len > $width);
   $menu->command(-label => $label, -command => [ $w , 'setOption', $label, $val ]);
   $hash{$label} = $val;
   $first = $label unless defined $first;
  }
 if (!defined($old) || !exists($hash{$old}))
  {
   $w->setOption($first, $hash{$first}) if defined $first;
  }
 $w->configure('-width' => $width);
}

sub options
{
 my ($w,$opts) = @_;
 if (@_ > 1)
  {
   $w->menu->delete(0,'end');
   $w->addOptions(@$opts);
  }
 else
  {
   return $w->_cget('-options');
  }
}

1;

__END__

=cut

