# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use FindBin;
use lib $FindBin::RealBin;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

use TkTest qw(catch_grabs);

plan tests => 13;

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

use_ok("Tk");
use_ok("Tk::FBox");

my $top = new MainWindow;
eval { $top->geometry('+10+10'); }; # This works for mwm and interactivePlacement

my $f;

my $delay = 500;

######################################################################
# open
eval {
    $f = $top->FBox(-defaultextension => ".PL",
		    -filetypes => [
				   ['Text Files',       ['.txt', '.text']],
				   ['TCL Scripts',      '.tcl'           ],
				   ['C Source Files',   '.c',      'TEXT'],
				   ['GIF Files',        '.gif',          ],
				   ['GIF Files',        '',        'GIFF'],
				   ['All Files',        '*',             ],
				  ],
		    -initialdir => ".",
		    -initialfile => "Makefile.PL",
		    -title => "Load file (with filetypes)",
		    -type => "open",
		    -filter => "*.PL", # ignored
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget");

catch_grabs {
    $f->after($delay, sub { $f->destroy }) if $ENV{BATCH};
    my $result = $f->Show;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("After showing FBox")
} 1;

######################################################################
# open without filetypes
eval {
    $f = $top->FBox(-defaultextension => ".PL",
		    -initialdir => ".",
		    -initialfile => "Makefile.PL",
		    -title => "Load file (without filetypes, with filter)",
		    -type => "open",
		    -filter => "*.PL",
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget");

catch_grabs {
    $f->after($delay, sub { $f->destroy }) if $ENV{BATCH};
    my $result = $f->Show;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("After showing FBox")
} 1;

######################################################################
# save
eval {
    $f = $top->FBox(-defaultextension => ".PL",
		    -filetypes => [
				   ['Text Files',       ['.txt', '.text']],
				   ['TCL Scripts',      '.tcl'           ],
				   ['C Source Files',   '.c',      'TEXT'],
				   ['GIF Files',        '.gif',          ],
				   ['GIF Files',        '',        'GIFF'],
				   ['All Files',        '*',             ],
				  ],
		    -initialdir => ".",
		    -initialfile => "Makefile.PL",
		    -title => "Save file",
		    -type => "save",
		    -filter => "*.PL", # ignored
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget for save");

catch_grabs {
    $f->after($delay, sub { $f->destroy }) if $ENV{BATCH};
    my $result = $f->Show;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("After showing FBox");
} 1;

######################################################################
# dir
eval {
    $f = $top->FBox(-initialdir => ".",
		    -title => "Choose directory",
		    -type => "dir",
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget for choosing directories");

catch_grabs {
    $f->after($delay, sub { $f->destroy }) if $ENV{BATCH};
    my $result = $f->Show;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("After showing FBox");
} 1;

######################################################################
# getOpenFile etc.
SKIP: {
    skip("getOpenFile etc. only on X11", 3)
	if $Tk::platform ne 'unix';

    my $mw;
    my $result;

    $mw = MainWindow->new;
    $mw->after($delay, sub { $mw->destroy }) if $ENV{BATCH};
    $result = $mw->getOpenFile;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("called getOpenFile");

    $mw = MainWindow->new;
    $mw->after($delay, sub { $mw->destroy }) if $ENV{BATCH};
    $result = $mw->getSaveFile;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("called getSaveFile");

    $mw = MainWindow->new;
    $mw->after($delay, sub { $mw->destroy }) if $ENV{BATCH};
    $result = $mw->chooseDirectory;
    if (!$ENV{BATCH}) {
	diag "Result is <$result>";
    }
    pass("called chooseDirectory");
}

1;
__END__
