
package Plot;

# Class "Plot": constructor, methods, destructor, global class data,
# etcetera.
#
# Because a Plot object is a composite widget all the Composite base
# class methods and advertised widgets are available to you.
#
# Advertised Plot widgets:  canvas, entry, PostScript_button, view_button.

require 5.002;
use English;
@ISA = qw(Tk::Frame);
Construct Tk::Widget 'Plot';
use strict;

# Plot Virtual Methods
# 
# 	$plot = $MW->Plot(
#           -title_color        => 'Brown',
#           -inactive_highlight => 'Skyblue2',
#           -active_highlight   => 'red',
#       );

sub Populate {

    # Plot composite widget constructor.

    my($cw, $args) = @ARG;

    $cw->SUPER::Populate($args);
    my($tc, $ih, $ah) = (
	delete $args->{-title_color},
	delete $args->{-inactive_highlight},
	delete $args->{-active_highlight},
    );

    my %pinfo;			# plot information hash
    $pinfo{'lastX'} = 0;
    $pinfo{'lastY'} = 0;
    $pinfo{'areaX2'} = -1;
    $pinfo{'prcmd'} = 'lpr';

    my $plot_font = '-*-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*';

    my $c = $cw->Canvas(
        -relief => 'raised', 
        -width  => '450', 
        -height => '300',
        -cursor => 'top_left_arrow',
    );
    $cw->Advertise('canvas' => $c);
    $c->pack(-side => 'top', -fill => 'x');

    $c->create('line', 100, 250, 400, 250, -width => 2);
    $c->create('line', 100, 250, 100, 50, -width => 2);
    $c->create('text', 225, 20, -text => 'A Simple Plot', -font => $plot_font,
	       -fill => $tc);
    
    my($i, $x, $y, $point, $item);
    for($i = 0; $i <= 10; $i++) {
	$x = 100 + ($i * 30);
	$c->create('line', $x, 250, $x, 245, -width => 2);
	$c->create('text', $x, 254, -text => 10 * $i, -anchor => 'n',
		   -font => $plot_font);
    } # forend
    for ($i = 0; $i <= 5; $i++) {
	$y =  250 - ($i * 40);
	$c->create('line', 100, $y, 105, $y, -width => 2);
	$c->create('text', 96, $y, -text => $i * 50.0, -anchor => 'e',
		   -font => $plot_font);
    } # forend
    
    foreach $point ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180],
		    [75, 160], [98, 223]) {
	$x = 100 + (3 * ${$point}[0]);
        $y = 250 - (4 * ${$point}[1]) / 5;
        $item = $c->create('oval', $x-6, $y-6, $x+6, $y+6, -width => 1,
			   -outline => 'black', -fill => $ih);
        $c->addtag('point', 'withtag', $item);
    }

    $c->bind('point', '<Any-Enter>' => [sub{shift->itemconfigure(@ARG)},
					'current', -fill => $ah]);
    $c->bind('point', '<Any-Leave>' => [sub{shift->itemconfigure(@ARG)},
					'current', -fill => $ih]);
    $c->bind('point', '<1>' => [sub {plot_down(@ARG)}, \%pinfo]);
    $c->bind('point', '<ButtonRelease-1>' => sub {shift->dtag('selected')});
    $c->Tk::bind('<B1-Motion>' => [sub {plot_move(@ARG)}, \%pinfo]);
    $c->Tk::bind('<2>' => [sub {area_down(@ARG)}, \%pinfo]);
    $c->Tk::bind('<B2-Motion>' => [sub {area_move(@ARG)}, \%pinfo]);

    my $w_prcmd = $cw->Entry(
        -textvariable => \$pinfo{'prcmd'},
    );
    $cw->Advertise('entry' => $w_prcmd);
    $w_prcmd->pack;

    my $w_print = $cw->Button(
        -text         => 'Print in PostScript Format',
        -command      => [\&area_save, $c, \%pinfo],
    );
    $cw->Advertise('PostScript_button' => $w_print);
    $w_print->pack;
    $w_prcmd->bind('<Return>' => [$w_print => 'invoke']);

    my $w_view = $cw->Button(
        -text    => 'View Composite Plot Widget',
        -command => [\&::view_widget_code,
	             Tk->findINC('demos/widget_lib/Plot.pm'),
                    ],
    );
    $cw->Advertise('view_button' => $w_view);
    $w_view->pack;

    return $cw;

} # end Populate, Plot constructor

# Private methods.

sub area_down {

    my($w, $pinfo) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $pinfo->{'areaX1'} = $x;
    $pinfo->{'areaY1'} = $y;
    $pinfo->{'areaX2'} = -1;
    $pinfo->{'areaY2'} = -1;
    eval {local $SIG{'__DIE__'}; $w->delete('area');};

} # end area_down

sub area_move {

    my($w, $pinfo) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    if($x != $pinfo->{'areaX1'} && $y != $pinfo->{'areaY1'}) {
      eval {local $SIG{'__DIE__'}; $w->delete('area');};
      $w->addtag('area','withtag',$w->create('rect',$pinfo->{'areaX1'},
                                           $pinfo->{'areaY1'},$x,$y));
      $pinfo->{'areaX2'} = $x;
      $pinfo->{'areaY2'} = $y;
    }
} # end area_move

sub area_save {
    
    my($w, $pinfo) = @ARG;
    
    my($x1, $x2, $y1, $y2, $a);
    
    if($pinfo->{'areaX2'} != -1) {
	($x1, $x2, $y1, $y2) = 
	  @$pinfo{'areaX1', 'areaX2', 'areaY1', 'areaY2'}; # slice !
	($x1, $x2) = @$pinfo{'areaX2', 'areaX1'} if $x2 <= $x1;
	($y1, $y2) = @$pinfo{'areaY2', 'areaY1'} if $y2 <= $y1;
	$a = $w->postscript('-x' => $x1, '-y' => $y1,
			    -width => $x2 - $x1, -height => $y2 - $y1);
    } else {
	$a = $w->postscript;
    }
    
    $SIG{'PIPE'} = sub {};
    open(LPR, "| $pinfo->{'prcmd'}");
    print LPR $a;
    close(LPR);

} # end area_save

sub plot_down {

    my($w, $pinfo) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->dtag('selected');
    $w->addtag('selected', 'withtag', 'current');
    $w->raise('current');
    $pinfo->{'lastX'} = $x;
    $pinfo->{'lastY'} = $y;

} # end plot_down

sub plot_move {

    my($w, $pinfo) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->move('selected',  $x-$pinfo->{'lastX'}, $y-$pinfo->{'lastY'});
    $pinfo->{'lastX'} = $x;
    $pinfo->{'lastY'} = $y;

} # end plot_move

1;
