package WidgetDemo;

use 5.004;
use Carp;

use vars qw($VERSION @ISA);
$VERSION = '3.010'; # $Id: //depot/Tk8/demos/demos/widget_lib/WidgetDemo.pm#10$

use Tk;
use Tk::Toplevel;
use strict;
@ISA = 'Tk::Toplevel';
Construct Tk::Widget 'WidgetDemo';

=head1 NAME

WidgetDemo() - create a standard widget demonstration window.

=for category Other Modules and Languages

=head1 SYNOPSIS

 use WidgetDemo;
 my $TOP = $MW->WidgetDemo(
     -name             => $demo,
     -text             => 'Learn how to write a widget demonstration!',
     -title            => 'WidgetDemo Demonstration',
     -iconname         => 'WidgetDemo',
     -geometry_manager => 'grid',
     -font             => $FONT,
 );

=head1 DESCRIPTION

This constructor builds a standard widget demonstration window, composed of
three frames.  The top frame contains descriptive demonstration text.  The
bottom frame contains the "Dismiss" and "See Code" buttons.  The middle frame
is demonstration container, which came be managed by either the pack or grid
geometry manager.

The -text attribute is supplied to a Label widget, which is left-adjusted
with -wraplength set to 4 inches.  If you require different specifications
then pass an array to -text; the first element is the text string and
the remaining array elements are standard Label widget attributes - WidgetDemo
will rearrange things as required..

    -text => ['Hello World!', qw/-wraplength 6i/],

=head1 AUTHOR

Steve Lidie <Stephen.O.Lidie@Lehigh.EDU>

=head1 HISTORY

lusol@Lehigh.EDU, LUCC, 97/02/11
lusol@Lehigh.EDU, LUCC, 97/06/07
Stephen.O.Lidie@Lehigh.EDU, LUCC, 97/06/07
 . Add Delegates() call that obviates the need for Top().  Many thanks to
   Achim Bohnet for this patch.
 . Fix -title so that it works.

=head1 COPYRIGHT

Copyright (C) 1997 - 1998 Stephen O. Lidie. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# %WIDGDEMO is a class global that tracks all WidgetDemo composite widgets,
# providing a means of destroying a previous instance of a demonstration.

my %WIDGDEMO;			# class hash of active widget demonstrations

sub Populate {
    my($cw, $args) = @_;

    my (%arg_defaults) = (
        -name             => 'Unknown Demo Name',
	-font             => '-*-Helvetica-Medium-R-Normal--*-140-*-*-*-*-*-*',
	-text             => 'Unknown Demo Text',
	-geometry_manager => 'pack',
    );
    my $name = $arg_defaults{-name};
    $arg_defaults{-title} = "$name Demonstration",
    $arg_defaults{-iconname} = $name;

    my(@margs, %ahsh, @args);
    @margs = grep ! defined $args->{$_}, keys %arg_defaults;
    %ahsh = %$args;
    @ahsh{@margs} = @arg_defaults{@margs};
    my($demo, $font, $text, $title, $iconname, $gm) =
	@ahsh{-name, -font, -text, -title, -iconname, -geometry_manager};
    delete $args->{-name};
    delete $args->{-font};
    delete $args->{-text};
    delete $args->{-iconname};
    delete $args->{-geometry_manager};

    $WIDGDEMO{$demo}->destroy if Exists($WIDGDEMO{$demo});
    $WIDGDEMO{$demo} = $cw;

    $cw->SUPER::Populate($args);
    $cw->iconname($iconname);

    my(@label_attributes) = ();
    if (ref($text) eq 'ARRAY') {
	@label_attributes = @$text[1 .. $#{$text}];
	$text = $text->[0];
    }
    my $msg = $cw->Label(
        -font       => $font,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => $text,
        @label_attributes,			 
    );
    
    my $demo_frame = $cw->Frame;
    $cw->Advertise('WidgetDemo' => $demo_frame); # deprecated

    my $buttons = $cw->Frame;
    my $dismiss = $buttons->Button(
        -text    => 'Dismiss',
        -command => [$cw => 'destroy'],
    );
    my $see = $buttons->Button(-text => 'See Code',
			       -command => [\&main::see_code, $demo]);

    if ($gm eq 'pack') {
	$msg->pack;
	$demo_frame->pack(qw/-fill both/);
	$buttons->pack(qw/-side bottom -fill x -pady 2m/);
	$dismiss->pack(qw/-side left -expand 1/);
	$see->pack(qw/-side left -expand 1/);
    } elsif ($gm eq 'grid') {
	$msg->grid;
	$demo_frame->grid;
	$buttons->grid(qw/-pady 2m -sticky ew/);
	$buttons->gridColumnconfigure(qw/0 -weight 1/);
	$buttons->gridColumnconfigure(qw/1 -weight 1/);
	$dismiss->grid(qw/-row 0 -column 0/);
	$see->grid(qw/-row 0 -column 1/);
    } else {
	croak "Only pack or grid geometry management supported.";
    }

    $cw->Delegates('Construct' => $demo_frame);
    return $cw;

} # end Populate, WidgetDemo constructor

sub Top {return $_[0]->Subwidget('WidgetDemo')}	# deprecated
*top = *top = \&Top;  # peacify -w

1;
