# search.pl

sub search_flash_matches;
sub search_load_file;
sub search_text;

sub search {

    # Create a top-level window with a text widget that allows you to load a
    # file and highlight all instances of a given string.

    my($demo) = @ARG;

    $SEARCH->destroy if Exists($SEARCH);
    $SEARCH = $MW->Toplevel;
    my $w = $SEARCH;
    dpos $w;
    $w->title('Text Demonstration - Search and Highlight');
    $w->iconname('search');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    $file_name = '';
    my $w_file = $w->Frame;
    my $w_file_label = $w_file->Label(-text => 'File name:', -width => 13,
				      -anchor => 'w');
    my $w_file_entry = $w_file->Entry(-width => 40,
				      -textvariable => \$file_name);
    my $w_file_button = $w_file->Button(-text => 'Load File');
    $w_file_label->pack(-side => 'left');
    $w_file_entry->pack(-side => 'left');
    $w_file_button->pack(-side => 'left', -pady => 5, -padx => 10);
    $w_file_entry->focus;

    $search_string = '';
    my $w_string = $w->Frame;
    my $w_string_label = $w_string->Label(-text => 'Search string:',
					  -width => 13, -anchor => 'w');
    my $w_string_entry = $w_string->Entry(-width => 40, 
					  -textvariable => \$search_string);
    my $w_string_button = $w_string->Button(-text => 'Highlight');
    $w_string_label->pack(-side => 'left');
    $w_string_entry->pack(-side => 'left');
    $w_string_button->pack(-side => 'left', -pady => 5, -padx => 10);

    my $w_t = $w->Text(-setgrid => 'true');
    my $w_s = $w->Scrollbar(-command => [$w_t, 'yview']);
    $w_t->configure(-yscrollcommand => [$w_s => 'set']);
    $w_file->pack(-side => 'top', -fill => 'x');
    $w_string->pack(-side => 'top', -fill => 'x');
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    my $command = [sub {shift @ARG if ref $ARG[0] eq 'Tk::Entry'; 
        search_load_file(@ARG)}, $w_t, \$file_name, $w_string_entry];
    $w_file_button->configure(-command => $command);
    $w_file_entry->bind('<Return>' => $command);

    $command = [sub {shift @ARG if ref $ARG[0] eq 'Tk::Entry';
        search_text(@ARG)}, $w_t, \$search_string, 'search'];
    $w_string_button->configure(-command => $command);
    $w_string_entry->bind('<Return>' => $command);

    # Set up display styles for text highlighting.

    if ($w->depth > 1) {
	search_flash_matches($w_t, ['configure', 'search',
                           -background => '#ce5555',
                           -foreground => 'white'], 800,
		          ['configure', 'search', 
                           -background => undef,  
                           -foreground => undef],   200);
      } else {
	search_flash_matches($w_t, ['configure', 'search', 
                           -background => 'black',
                           -foreground => 'white'], 800,
		          ['configure', 'search', 
                           -background => undef,
                           -foreground => undef],   200);
      }

    $w_t->insert('0.0', 'This window demonstrates how to use the tagging facilities in text
widgets to implement a searching mechanism.  First, type a file name
in the top entry, then type <Return> or click on "Load File".  Then
type a string in the lower entry and type <Return> or click on
"Highlight".  This will cause all of the instances of the string to
be tagged with the tag "search", and it will arrange for the tag\'s
display attributes to change to make all of the strings blink.');

    $w_t->mark('set', 'insert', '0.0');

} # end search

sub search_flash_matches {

    # The procedure below is invoked repeatedly to invoke two commands at
    # periodic intervals.  It normally reschedules itself after each execution
    # but if an error occurs (e.g. because the window was deleted) then it
    # doesn't reschedule itself.
    # Arguments:
    #
    # w -       Text widget reference.
    # cmd1 -	Reference to a list of tag options.
    # sleep1 -	Ms to sleep after executing cmd1 before executing cmd2.
    # cmd2 -	Reference to a list of tag options.
    # sleep2 -	Ms to sleep after executing cmd2 before executing cmd1 again.

    my($w, $cmd1, $sleep1, $cmd2, $sleep2) = @ARG;

    $w->tag(@{$cmd1});
    after($sleep1, [sub {search_flash_matches(@ARG)}, $w, $cmd2, $sleep2, 
		    $cmd1, $sleep1]);

} # end search_flash_matches

sub search_load_file {

    # The utility procedure below loads a file into a text widget, discarding
    # the previous contents of the widget. Tags for the
    # old widget are not affected, however.
    # Arguments:
    #
    # w -	The window into which to load the file.  Must be a text widget.
    # file -	Reference to the name of the file to load.  Must be readable.
    # e -       Entry widget to get next focus.

    my ($w, $file, $e) = @ARG;

    my ($buf, $bytes) = ('', 0);

    if (not open(F, "<$$file")) {
	$MW->Dialog(
            -title  => 'File Not Found',
            -text   => $OS_ERROR,
            -bitmap => 'error',
        )->Show;
	return;
    }
    $w->delete('1.0', 'end');
    $bytes = read F, $buf, 10000;	# after all, it IS just an example
    $w->insert('end', $buf);
    if ($bytes == 10000) {
	$w->insert('end', "\n\n**************** File truncated at 10,000 bytes! ****************\n");
    }
    close F;

    $e->focus;

} # end search_load_file

sub search_text {

    # The utility procedure below searches for all instances of a given
    # string in a text widget and applies a given tag to each instance found.
    # Arguments:
    #
    # w -	The window in which to search.  Must be a text widget.
    # string -	Reference to the string to search for.  The search is done 
    #           using exact matching only;  no special characters.
    # tag -	Tag to apply to each instance of a matching string.

    my($w, $string, $tag) = @ARG;

    $w->tag('remove',  $tag, '0.0', 'end');
    my($current, $length) = ('1.0', 0);
    
    while (1) {
	$current = $w->search(-count => \$length, $$string, $current, 'end');
	last if not $current;
	$w->tag('add', $tag, $current, "$current + $length char");
	$current = $w->index("$current + $length char");
    }

} # end search_text

1;
