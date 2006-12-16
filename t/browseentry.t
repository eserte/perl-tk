# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN
  {
   plan test => 22;
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

my( $bla, $be );
eval { $be = $mw->BrowseEntry(-listcmd => $listcmd,
			  -browsecmd => $browsecmd,
			  -textvariable => \$bla,
				 )->pack; };
ok("$@", "", "can't create BrowseEntry");
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

my $be2;
eval { $be2 = $mw->BrowseEntry(-choices => [qw/a b c d e/],
			   -textvariable => \$bla,
			   -state => "normal",
				  )->pack; };
ok("$@", "", "can't create BrowseEntry");
ok(Tk::Exists($be2), 1, "BrowseEntry creation failed");

{
    # Testcase:
    # From: "Puetz Kevin A" <PuetzKevinA AT JohnDeere.com>
    # Message-ID: <0B4BDC724143544EB509F90F7791EB64026EF8E1@edxmb16.jdnet.deere.com>
    my $var = 'val2';
    my $browse = $mw->BrowseEntry
	(-label => 'test',
	 -listcmd => sub { $_[0]->choices([undef, 'val1','val2']) },
	 -variable => \$var,
	)->pack;
    ok($var eq 'val2');
    $browse->update;
    $browse->BtnDown;
    $browse->update;
    ok($var eq 'val2');
    $browse->destroy;
}

{
    # http://perlmonks.org/?node_id=590170
    my $active_text_color = "#000000";
    my $bgcolor = "#FFFFFF";
    my $text_font = 'helvetica 12';
    my $browse = $mw->BrowseEntry(-label=>'Try Me:',
				  -labelPack=>[qw(-side left -anchor w)],
				  -labelFont=>$text_font,
				  -labelForeground=>$active_text_color,
				  -labelBackground=>$bgcolor,
				  -width=>5,
				  -choices=>[qw(A B C)],
				 )->pack(-side=>'left', -expand=>1, -fill=>'x');
    my @children = $browse->children;
    ok(scalar(@children), 3, "No auto-creation of Frame label");
    ok((scalar grep { $_->isa("Tk::LabEntry") } @children), 1, "Has one LabEntry");
    ok((scalar grep { $_->isa("Tk::Button")   } @children), 1, "Has one Button");
    ok((scalar grep { $_->isa("Tk::Toplevel") } @children), 1, "Has one Toplevel");
    ok((scalar grep { $_->isa("Tk::Label")    } @children), 0, "Has no Label");
}

#&Tk::MainLoop;

1;
__END__
