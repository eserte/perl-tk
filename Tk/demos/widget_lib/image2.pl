# image2.pl

use File::Basename;

sub loadDir;
sub loadImage;

sub image2 {

    # This demonstration script creates a simple collection of widgets
    # that allow you to select and view images in a Tk label.

    my($demo) = @ARG;
    $IMAGE2->destroy if Exists($IMAGE2);
    $IMAGE2 = $mw->Toplevel;
    my $w = $IMAGE2;
    dpos $w;
    $w->title('Image Demonstration #2');
    $w->iconname('image2');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'This demonstration allows you to view images using a Tk "photo" image.  First type a directory name in the listbox, then type Return to load the directory into the listbox.  Then double-click on a file name in the listbox to see that image.',
    );
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    $w_dirLabel = $w->Label(-text => 'Directory:');
    my $dirName = "$tk_library/demos/images";
    $w_dirName = $w->Entry(-width => 30, -textvariable => \$dirName);
    $w_spacer1 = $w->Frame(-height => '3m', -width => 20);
    $w_fileLabel = $w->Label(-text => 'File:');
    $w_f = $w->Frame;
    my(@pl) = (-side => 'top', -anchor => 'w');
    $w_dirLabel->pack(@pl);
    $w_dirName->pack(@pl);
    $w_spacer1->pack(@pl);
    $w_fileLabel->pack(@pl);
    $w_f->pack(@pl);

    $w_f_list = $w_f->Listbox(-width => 20, -height => 10);
    $w_dirName->bind('<Return>', [\&loadDir, $w_f_list, \$dirName]);
    $w_f_scroll = $w_f->Scrollbar(-command => ['yview', $w_f_list]);
    $w_f_list->configure(-yscrollcommand => ['set', $w_f_scroll]);
    @pl = (-side => 'left', -fill => 'y', -expand => 1);
    $w_f_list->pack(@pl);
    $w_f_scroll->pack(@pl);
    $w_f_list->insert(0, qw(earth.gif earthris.gif mickey.gif teapot.ppm));

    my $image2a = $w->Photo;
    $w_f_list->bind('<Double-1>' => [\&loadImage, $image2a, \$dirName]);
    $w_spacer2 = $w->Frame(-height => '3m', -width => 20);
    $w_imageLabel = $w->Label(-text => 'Image:');
    $w_image = $w->Label(-image => $image2a);
    @pl = (-side => 'top', -anchor => 'w');
    $w_spacer2->pack(@pl);
    $w_imageLabel->pack(@pl);
    $w_image->pack(@pl);

} # end image2

sub loadDir {

    # This procedure reloads the directory listbox from the directory
    # named in the demo's entry.
    #
    # Arguments:
    # e       -                 Reference to entry widget.
    # l       -                 Reference to listbox widget.
    # dirName -                 Directory name reference.

    my($e, $l, $dirName) = @ARG;

    $l->delete(0, 'end');
    my $i;
    foreach $i (sort <$$dirName/*>) {
	$l->insert('end', basename($i));
    }

} # end loadDir

sub loadImage {

    # Given the name of the toplevel window of the demo and the mouse
    # position, extracts the directory entry under the mouse and loads
    # that file into a photo image for display.
    #
    # Arguments:
    # l       -         Reference to listbox widget.
    # i       -         Reference to image object.
    # dirName -         Directory name reference.

    my($l, $i, $dirName) = @ARG;

    my $e = $l->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $i->configure(-file => "$$dirName/" . $l->get("\@$x,$y"));

    # NOTE:  $l->get('active') works just as well.  

} # end loadImage

1;

