# $Id$

package main;

unshift(@INC, "../..");

use Tk;
use English;
use Carp;

require Tk::BrowseEntry;

$month = "January";

outer:
{
    $top = MainWindow->new;
    $f = $top->Frame;
    $c = $f->BrowseEntry(-label => "Month:", -variable => \$month);
    $c->pack;
    $c->insert("end", "January");
    $c->insert("end", "February");
    $c->insert("end", "March");
    $c->insert("end", "April");
    $c->insert("end", "May");
    $c->insert("end", "June");
    $c->insert("end", "July");
    $c->insert("end", "August");
    $c->insert("end", "September");
    $c->insert("end", "October");
    $c->insert("end", "November");
    $c->insert("end", "December");
    $bf = $f->Frame;
    $bf->Button(-text => "Quit",
		-command => sub {
		    print "The month is $month\n";
		    exit;
		}, -relief => "raised")->pack;
    
    $bf->pack;
    $f->pack;
    MainLoop;
}
