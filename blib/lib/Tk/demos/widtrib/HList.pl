# HList - A hierarchial listbox widget.

use English;
use Tk::HList;
use strict;
use subs qw/show_dir/;
use vars qw/$top $FILEIMG $FOLDIMG/;

sub HList {
    my($demo) = @ARG;
    my $demo_widget = $MW->WidgetDemo(
        -name => $demo,
        -text => 'HList - A hierarchial listbox widget.',
	-geometry_manager => 'grid',
    );
    $top = $demo_widget->Top;	# get grid master
    my $h = $top->Scrolled(qw\HList -separator / -selectmode single -width 30
			   -height 20 -indent 35 -scrollbars se
			   -itemtype imagetext \
			   )->grid(qw/-sticky nsew/);
    $h->configure(-command => sub {
	print "Double click $_[0], size=", $h->info('data', $_[0]) ,".\n";
    });

    $FILEIMG = $top->Bitmap(-file => Tk->findINC('file.xbm'));
    $FOLDIMG = $top->Bitmap(-file => Tk->findINC('folder.xbm'));

    my $root = Tk->findINC('demos');
    chdir $root;
    show_dir '.', $root, $h;
}

sub show_dir {
    my($entry_path, $text, $h) = @ARG;
    opendir H, $entry_path;
    my(@dirent) = grep ! /^\.\.?$/, sort(readdir H);
    closedir H;
    $h->add($entry_path,  -text => $text, -image => $FOLDIMG);
    while ($ARG = shift @dirent) {
	my $file = "$entry_path/$ARG";
	if (-d $file) {
	    show_dir $file, $ARG, $h;
	} else {
	    my $size = -s $file;
	    $h->add($file,  -text => $ARG, -image => $FILEIMG, -data => $size);
	}
    }
} # end show_dir
