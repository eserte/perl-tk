package WidgetDemo;

use 5.002;
use Carp;
use English;
use Tk;
use strict;
@WidgetDemo::ISA = qw(Tk::Toplevel);
Construct Tk::Widget 'WidgetDemo';

=head1 NAME

WidgetDemo() - create a standard widget demo window.

=head1 SYNOPSIS

 use Tk::WidgetDemo;
 my $demo_widget = $MW->WidgetDemo(
     -name             => $demo,
     -text             => 'Learn how to write a widget demonstration!',
     -geometry_manager => 'grid',
     -font             => $FONT,
 );
 $TOP = $demo_widget->top;	# get grid master

=head1 DESCRIPTION

This constructor builds a standard widget demonstration window, composed of
three frames.  The top frame contains descriptive demonstration text.  The
bottom frame contains the "Dismiss" and "See Code" buttons.  The middle frame
is demonstration container, which came be managed by either the pack or grid
geometry manager.

=head1 METHODS

=head2 $demo_widget->top;

Returns the frame container reference for the demonstration.

=head1 AUTHOR

Stephen O. Lidie <lusol@Lehigh.EDU>

=head1 HISTORY

lusol@Lehigh.EDU, LUCC, 97/01/01

=head1 COPYRIGHT

Copyright (C) 1997 - 1997 Stephen O. Lidie. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

sub Populate {
    my($cw, $args) = @ARG;

    my (%arg_defaults) = (
        -name             => 'Unknown Demo Name',
	-font             => '-*-Helvetica-Medium-R-Normal--*-140-*-*-*-*-*-*',
	-text             => 'Unknown Demo Text',
	-geometry_manager => 'pack',
    );

    my(@margs, %ahsh, @args);
    @margs = grep ! defined $args->{$ARG}, keys %arg_defaults;
    %ahsh = %$args;
    @ahsh{@margs} = @arg_defaults{@margs};
    my($demo, $font, $text, $gm) =
	@ahsh{-name, -font, -text, -geometry_manager};
    delete $args->{-name};
    delete $args->{-font};
    delete $args->{-text};
    delete $args->{-geometry_manager};

    $cw->SUPER::Populate($args);
    $cw->title("$demo Demonstration");
    $cw->iconname($demo);

    my $msg = $cw->Label(
        -font       => $font,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => $text,
    );
    
    my $demo_frame = $cw->Frame;
    $cw->Advertise('WidgetDemo' => $demo_frame);

    my $buttons = $cw->Frame;
    my $dismiss = $buttons->Button(
        -text    => 'Dismiss',
        -command => [$cw => 'destroy'],
    );
    my $see = $buttons->Button(-text => 'See Code',
			       -command => [\&main::see_code, $demo]);

    if ($gm eq 'pack') {
	$msg->pack;
	$demo_frame->pack;
	$buttons->pack(qw(-side bottom -fill x -pady 2m));
	$dismiss->pack(qw(-side left -expand 1));
	$see->pack(qw(-side left -expand 1));
    } elsif ($gm eq 'grid') {
	$msg->grid;
	$demo_frame->grid;
	$buttons->grid(qw(-pady 2m -sticky ew));
	$buttons->gridColumnconfigure(qw(0 -weight 1));
	$buttons->gridColumnconfigure(qw(1 -weight 1));
	$dismiss->grid(qw(-row 0 -column 0));
	$see->grid(qw(-row 0 -column 1));
    } else {
	croak "Only pack or grid geometry management supported.";
    }

    return $cw;

} # end Populate, WidgetDemo constructor

sub top {return $_[0]->Subwidget('WidgetDemo')}

1;
