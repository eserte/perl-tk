BEGIN { $|=1; $^W=1; }
use strict;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

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
    is($@, "", "\$w->appname works");
    my ($leaf) = $name =~ /^(\w+)/;
    is( $leaf, 'widget', "Appname matches filename" );
    is( $mw->name, $name, "\$mw->name is equal to appname");
}
##
## scaling (missing until Tk800 until .004)
##
{
    my $scale;
    eval { $scale = $w->scaling; };
    is($@, "", "\$w->scaling works");
    like($scale, qr/^[0-9.]+$/, "Scaling factor is a number: '$scale'" );
}
##
## pathname did not work until Tk800.004
##
{
    my $path;
    my $c = $w->PathName;
    eval { $path = $mw->pathname($w->id); };
    is($@, "", "\$mw->pathname works");
    is( $path, $c, "Pathname and pathname agree" );
}

1;
__END__
