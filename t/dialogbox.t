# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN { plan test => 8 };

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::DialogBox };
ok($@, "", "loading Tk::DialogBox module");

my $top = new MainWindow;
$top->withdraw unless $^O eq 'MSWin32';
eval { $top->geometry('+10+10'); };  # This works for mwm and interactivePlacement

{
    my $d = $top->DialogBox;
    my $e = $d->add("Entry")->pack;
    $d->configure(-focus => $e,
		  -showcommand => sub {
		      my $w = shift;
		      ok($w, $d, "Callback parameter check");
		      $d->update;
		      my $fc = $d->focusCurrent || "";
		      ok($fc eq "" || $fc eq $e, 1,
			 "Check -focus option (current focus is on `$fc')");
		      my $ok_b = $d->Subwidget("B_OK");
		      ok(!!Tk::Exists($ok_b), 1, "Check default button");
		      ok(UNIVERSAL::isa($ok_b, "Tk::Button"));
		      $ok_b->after(300, sub { $ok_b->invoke }) if $ENV{BATCH};
		  });
    ok($d->Show, "OK");
}

{
    my $d = $top->DialogBox(-buttons => [qw(OK Cancel), "I don't know"],
			    -default_button => "Cancel");
    my $e = $d->add("Label", -text => "Hello, world!")->pack;
    $d->configure(-showcommand => sub {
		      $d->update;
		      my $d_b = $d->{default_button};
		      $d->after(300, sub { $d_b->invoke }) if $ENV{BATCH};
		  });
    ok($d->Show, "Cancel");
}

1;
__END__
