# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN 
  {
   plan test => 15;
  };

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::BrowseEntry };
ok($@, "", "loading Tk::BrowseEntry module");

my $mw;
eval {$mw = Tk::MainWindow->new();};
eval { $mw->geometry('+10+10'); };
ok($@, "", "can't create MainWindow");
ok(Tk::Exists($mw), 1, "MainWindow creation failed");

my(@listcmd, @browsecmd);
my $listcmd   = sub { @listcmd = @_ };
my $browsecmd = sub { @browsecmd = @_ };

my $bla;
my $be = $mw->BrowseEntry(-listcmd => $listcmd,
			  -browsecmd => $browsecmd,
			  -textvariable => \$bla,
			 )->pack;
ok($@, "", "can't create BrowseEntry");
ok(Tk::Exists($be), 1, "BrowseEntry creation failed");

$be->insert('end', 1, 2, 3);
ok($be->get(0), 1, "wrong element in listbox");

$be->idletasks;
# this can "fail" if KDE screen save is up, or user is doing something
# else - such snags are what we should expect when calling binding
# methods directly ...
eval { $be->BtnDown };
warn $@ if $@;
ok(@listcmd, 1, "-listcmd failed");
ok($listcmd[0]->isa('Tk::BrowseEntry'), 1, "wrong 1st argument in -listcmd");

my $listbox = $be->Subwidget('slistbox')->Subwidget('listbox');
ok($listbox->isa('Tk::Listbox'), 1, "can't get listbox subwidget");

$listbox->selectionSet(0);
$listbox->idletasks;
my($x, $y) = $listbox->bbox($listbox->curselection);
$be->LbChoose($x, $y);
ok(@browsecmd, 2, "-browsecmd failed");
ok($browsecmd[0]->isa('Tk::BrowseEntry'), 1,
   "wrong 1st argument in -browsecmd");
ok($browsecmd[1], 1, "wrong 2nd argument in -browsecmd");

my $be2 = $mw->BrowseEntry(-choices => [qw/a b c d e/],
			   -textvariable => \$bla,
			   -state => "normal",
			  )->pack;
ok($@, "", "can't create BrowseEntry");
ok(Tk::Exists($be2), 1, "BrowseEntry creation failed");

#&Tk::MainLoop;

1;
__END__
