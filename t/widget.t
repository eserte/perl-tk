BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN { plan tests => 7 };

my $mw = Tk::MainWindow->new;
my $w = $mw->Label(-text=>'a widget but not a Wm')->grid;

##
## appname (missing until Tk800 until .004)
##
{
    my $name;
    eval { $name = $w->appname; };
    ok($@, "", "Problem \$w->appname.");
    ok( 1, $name =~ /widget\.t/, "Appname does not match filename" );
    ok( $mw->name, $name, "\$mw->name is not equal to appname");
}
##
## scaling (missing until Tk800 until .004)
##
{
    my $scale;
    eval { $scale = $w->scaling; };
    ok($@, "", "Problem \$w->scaling.");
    ok( scalar($scale=~/^[0-9.]+$/), 1, "Scaling factor not a number: '$scale'" );
}
##
## pathname does not work in Tk800.004
## 	the test, Widget.pod or both are wrong :-)
##
{
    my $path;
    my $c = $w->PathName;
    eval { $path = $mw->pathname($w->id); };
    ok($@, "", "Problem \$mw->pathname.");
    ok( ($path eq $c) ? 1 : 0, 1, "Got pathname '$path', not '$c'" );
}

1;
__END__
