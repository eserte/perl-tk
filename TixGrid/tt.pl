#!/perl -w
# Tix Demostration Program
#
# This sample program is structured in such a way so that it can be
# executed from the Tix demo program "widget": it must have a
# procedure called "RunSample". It should also have the "if" statment
# at the end of this file so that it can be run as a standalone
# program using tixwish.

# A very simple demonstration of the tixGrid widget

use strict;
use vars qw($mw $g);
use Tk ();
use Tk::TixGrid;

my $hadMW = 0;
$hadMW= 1 unless (Tk::Exists($mw));

$mw = Tk::MainWindow->new();# unless $hadMW;
MakeGrid($mw);
Tk::MainLoop;# unless $hadMW;


# This command is called whenever the background of the grid needs to
# be reformatted. The x1, y1, x2, y2 specifies the four corners of the area
# that needs to be reformatted.
#
# area:
#  x-margin:	the horizontal margin
#  y-margin:	the vertical margin
#  s-margin:	the overlap area of the x- and y-margins
#  main:	The rest
#
#proc SimpleFormat {w area x1 y1 x2 y2} {


sub SimpleFormat
  {
    my ($w, $area, @entbox) = @_;
{local $,="|"; print "Fme:", @_,"\n";};
    my %bg = (
	's-margin' => 'gray65',
	'x-margin' => 'gray65',
	'y-margin' => 'gray65',
	'main'     => 'gray20',
    );

    if ($area eq 'main')
      {
	# The "grid" format is consecutive boxes without 3d borders
	#
	#$w->formatGrid(@entbox[1,4], -bordercolor=>$bg{$area},
	$w->format('grid', @entbox[1,4], -bordercolor=>$bg{$area},
		qw( -relief raised -bd 1
	 	    -filled 0 -bg red
		    -xon 1 -yon 1 -xoff 0 -yoff 0 -anchor se
		  ) );
      }
    elsif ($area =~ /^(x|y|s)-margin$/)
      {
	# border specifies consecutive 3d borders
	#
	#$w->formatBorder(@entbox[1,4],  -bg=>$bg{$area},
	$w->format('border', @entbox[1,4],  -bg=>$bg{$area},
		qw( -fill 1 -relief raised -bd 1
		    -selectbackground gray80
		  ) );
      }
  }

# Print a number in $ format
#
#
#proc Dollar {s} {

sub Dollar { return shift()."DM"   }

#    set n [string len $s]
#    set start [expr $n % 3]
#    if {$start == 0} {
#	set start 3
#    }
#
#    set str ""
#    for {set i 0} {$i < $n} {incr i} {
#	if {$start == 0} {
#	    append str ","
#	    set start 3
#	}
#	incr start -1
#	append str [string index $s $i]
#    }
#    return $str
#}

#proc MakeGrid {w} {
    # Create the grid
    #

sub MakeGrid
  {
    my ($w) = @_;

    $g = $w->TixGrid(qw(-bd 0));

    $g->pack(qw/-expand yes -fill both -padx 3 -pady 3/);

    $g->configure(-formatcmd=>[\&SimpleFormat, $g]);


    # Set the size of the columns
    #
    $g->size(qw/col 0 -size 10char/);
    $g->size(qw/col 1 -size auto/);
    $g->size(qw/col 2 -size auto/);
    $g->size(qw/col 3 -size auto/);
    $g->size(qw/col 4 -size auto/);

    # set the default size of the column and rows. these sizes will be used
    # if the size of a row or column has not be set via the "size col ?"
    # command
    $g->size(qw/col default -size 5char/);
    $g->size(qw/row default -size 1.1char -pad0 3/);

    for my $x (0..10)
      {
	for my $y (0..10)
          {
	    $g->set($x,$y, -itemtype=>'text', -text=>"($x,$y)" );
	  }
      }
  }

1;
__END__
