package WidgetDemo;

use 5.004;
use Carp;

use vars qw($VERSION @ISA);
$VERSION = '4.004'; # $Id: //depot/Tkutf8/demos/demos/widget_lib/WidgetDemo.pm#4 $

use Tk;
use Tk::Toplevel;
use strict;
use base  'Tk::Toplevel';
Construct Tk::Widget 'WidgetDemo';

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
	$buttons->pack(qw/-side bottom -fill x -pady 2m/);
	$dismiss->pack(qw/-side left -expand 1/);
	$see->pack(qw/-side left -expand 1/);
	$msg->pack;
	$demo_frame->pack(qw/-fill both/);
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
