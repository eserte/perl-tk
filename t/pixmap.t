#!/usr/bin/perl -w
use strict;
use Test;
plan tests => 1;

my($icon)=<<'END';
/* XPM */
static char * junk_xpm[] = {
"10 10 6 1",
"       c #000000",
".      c #FFFFFF",
"X      c #B129F8",
"o      c #F869A6",
"O      c #00FF00",
"+      c #1429F8",
" X..oo.+. ",
" .X....+. ",
" ..X...+. ",
" o..X.... ",
" oo..X... ",
" .oo..X.. ",
" ......X. ",
" .+.....X ",
" .+..oo.. ",
" .+...oo. "};
END
use Tk;
my $mw = tkinit;
$mw->geometry("+20+20");
my $label = $mw->Label(-image=>$mw->Pixmap(-data=>$icon))->pack;
$mw->after(1000,[destroy => $mw]);
MainLoop;
ok(1);
