# image2.pl

use File::Basename;

sub image2_load_dir;
sub image2_load_image;

sub image2 {

    # This demonstration script creates a simple collection of widgets
    # that allow you to select and view images in a Tk label.

    my($demo) = @ARG;
    $IMAGE2->destroy if Exists($IMAGE2);
    $IMAGE2 = $MW->Toplevel;
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
    $w_msg->pack;

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&see_code, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_dir_label = $w->Label(-text => 'Directory:');
    my $dir_name = Tk->findINC('demos/images');
    my $w_dir_name = $w->Entry(-width => 30, -textvariable => \$dir_name);
    my $w_spacer1 = $w->Frame(-height => '3m', -width => 20);
    my $w_file_label = $w->Label(-text => 'File:');
    my $w_f = $w->Frame;
    my(@pl) = (-side => 'top', -anchor => 'w');
    $w_dir_label->pack(@pl);
    $w_dir_name->pack(@pl);
    $w_spacer1->pack(@pl);
    $w_file_label->pack(@pl);
    $w_f->pack(@pl);

    my $w_f_list = $w_f->Listbox(-width => 20, -height => 10);
    $w_dir_name->bind('<Return>' => [\&image2_load_dir, $w_f_list, \$dir_name]);
    my $w_f_scroll = $w_f->Scrollbar(-command => [$w_f_list => 'yview']);
    $w_f_list->configure(-yscrollcommand => [$w_f_scroll => 'set']);
    @pl = (-side => 'left', -fill => 'y', -expand => 1);
    $w_f_list->pack(@pl);
    $w_f_scroll->pack(@pl);
    $w_f_list->insert(0, qw(earth.gif earthris.gif mickey.gif teapot.ppm));

    my $image2a = $w->Photo;
    $w_f_list->bind('<Double-1>' => [\&image2_load_image, $image2a, \$dir_name]);
    my $w_spacer2 = $w->Frame(-height => '3m', -width => 20);
    my $w_image_label = $w->Label(-text => 'Image:');
    my $w_image = $w->Label(-image => $image2a);
    @pl = (-side => 'top', -anchor => 'w');
    $w_spacer2->pack(@pl);
    $w_image_label->pack(@pl);
    $w_image->pack(@pl);

} # end image2

sub image2_load_dir {

    # This procedure reloads the directory listbox from the directory
    # named in the demo's entry.
    #
    # Arguments:
    # e       -                 Reference to entry widget.
    # l       -                 Reference to listbox widget.
    # dir_name -                 Directory name reference.

    my($e, $l, $dir_name) = @ARG;

    $l->delete(0, 'end');
    my $i;
    foreach $i (sort <$$dir_name/*>) {
	$l->insert('end', basename($i));
    }

} # end image2_load_dir

sub image2_load_image {

    # Given the name of the toplevel window of the demo and the mouse
    # position, extracts the directory entry under the mouse and loads
    # that file into a photo image for display.
    #
    # Arguments:
    # l       -         Reference to listbox widget.
    # i       -         Reference to image object.
    # dir_name -         Directory name reference.

    my($l, $i, $dir_name) = @ARG;

    my $e = $l->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $i->configure(-file => "$$dir_name/" . $l->get("\@$x,$y"));

    # NOTE:  $l->get('active') works just as well.  

} # end image2_load_image

1;

