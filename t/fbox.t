# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN { plan test => 6 };

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::FBox };
ok($@, "", "loading Tk::FBox module");

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
ok($@, "", "creating Tk::FBox widget");

$top->after(300, sub { $f->destroy });
$f->Show;
ok(1);

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
ok($@, "", "creating Tk::FBox widget for save");

$top->after(300, sub { $f->destroy });
$f->Show;
ok(1);

1;
__END__
