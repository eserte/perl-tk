BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN { plan tests => 16 };

my $mw = Tk::MainWindow->new;

my $text;
{
   require Tk::Text;
   ok($@, "", 'Problem loading Tk::Text');
   eval { $text = $mw->Text(); };
   ok($@, "", 'Problem creating Text widget');
   ok( Tk::Exists($text) );
   eval { $text->grid; };
   ok($@, "", '$text->grid problem');
}
##
## A scrolled (e.g., entry) does not work work as embedded window
##
{
    my $normal = $text->Entry();
    my $scroll = $text->Scrolled('Entry');
    ok( Tk::Exists($normal) );
    ok( Tk::Exists($scroll) );

    eval { $text->window('create','end', -window=>$normal); };
    ok($@ , "", "can't embedd \$normal=$normal. Error is: $@");
    eval { $text->window('create','end', -window=>$scroll); };
    ok($@ , "", "can't embedd \$scroll=$scroll. Error is: $@");

    $text->update;
   
    ok( ($normal->manager), 'text', "\$normal=$normal not managed by text widget");
    ok( ($scroll->manager), 'text', "\$scroll=$scroll not managed by text widget");
   
    ok( ($normal->geometry eq '1x1+0+0'), '', '$normal not visible. Geometry'.$normal->geometry);
    ok( ($scroll->geometry eq '1x1+0+0'), '', '$scroll not visible. Geometry'.$scroll->geometry);
}
##
## Bugs 1) windowCreate(-create=>callback) method expects a pathname
##		and not a widget ref.
##      2) eval {} does not catch error message below
##
##ptksh> $l=$t->Label(-text=>'fool');
##ptksh> $t->window('create','end',-create=>sub{$l})
##ptksh> Tk::Error: bad window path name "Tk::Label=HASH(0x1405b4198)"
##  at /home/ach/perl/5.004_64/site+standard/auto/Tk/Error.al line 13.
##
{
    my $l;
    eval { $l = $text->Label(-text=>'an embedded label'); };
    ok($@ , "", "error create widget for later windowCreate: $@");

    eval { $text->window('create', 'end', -create=>sub{ $l }); };
    ok($@ , "", "windowCreate definition had problems: $@");

    eval { $text->update; };  # make sure Text is visible so -create will be called
    ok($@ , "", "windowCreate('1.0',-create=>callback) does not work: $@");

#   # test if error message of -create is catched by eval
#   eval { $text->window('create', '1.0', -create=>sub{"generate an error"}); };
#   ok($@ , "", "a foo windowCreate definition had problems: $@");
#   eval { $text->update; };
#   ok($@ ne "", 1, "windowCreate(-create=>callback) err msg not catched.");

}
##
## windowCreate(-window=>doesnotexits) does not give an error
##
{
    my $foobar;
    eval { $text->window('create', '1.0', -window => 'doesnotexits'); };
    ok($@ ne "", 1, "windowCreate -window does not complain if argument is not a widget ref");
}

1;
__END__
