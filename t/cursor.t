# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN {
    if ($Tk::platform eq 'MSWin32') {
	plan test => 1;
    } else {
	plan test => 2, todo => [1];
    }
}

my $mw;
$mw = Tk::MainWindow->new();
$mw->geometry('+10+10');  # This works for mwm and interactivePlacement

if ($Tk::platform eq 'MSWin32') {
    my $curfile = "demos/demos/images/cursor.cur";
    $mw->configure(-cursor => $curfile);
    $mw->update;
    ok($mw->cget(-cursor), $curfile);
} else {
    $mw->configure(-cursor => ['@demos/demos/images/cursor.xbm','black']);
    $mw->update;
    $mw->after(200);
    ok(ref $mw->cget(-cursor) eq 'ARRAY');
    my $tclcurspec = '@demos/demos/images/cursor.xbm black';
    $mw->configure(-cursor => $tclcurspec);
    ok($mw->cget(-cursor), $tclcurspec);
}

__END__
