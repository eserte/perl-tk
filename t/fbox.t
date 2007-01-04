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

plan tests => 6;

use_ok("Tk");
use_ok("Tk::FBox");

my $top = new MainWindow;
eval { $top->geometry('+10+10'); };  # This works for mwm and interactivePlacement

my $f;
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
		    -title => "Load file",
		    -type => "open",
		    -filter => "*.PL",
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget");

$f->after(1000, sub { $f->destroy });
$f->Show;
pass("After showing FBox");

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
		    -filter => "*.PL",
		    -font => "Helvetica 14",
		   );
};
is($@, "", "creating Tk::FBox widget for save");
$f->after(1000, sub { $f->destroy });
$f->Show;
pass("After showing FBox");

1;
__END__
