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
    my ($leaf) = $name =~ /^(\w+)/;
    ok( $leaf, 'widget', "Appname does not match filename" );
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
## pathname did not work until Tk800.004
##
{
    my $path;
    my $c = $w->PathName;
    eval { $path = $mw->pathname($w->id); };
    ok($@, "", "Problem \$mw->pathname.");
    ok( $path, $c, "Pathname and pathname don't agree" );
}

1;
__END__
