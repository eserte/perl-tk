
sub text_load_file {

    # The utility procedure below loads a file into a text widget, discarding the previous contents of the widget. Tags for the
    # old widget are not affected, however.
    # Arguments:
    #
    # w -	The window into which to load the file.  Must be a text widget.
    # file -	The name of the file to load.  Must be readable.

    my ($w, $file) = @_;

    my ($buf, $bytes) = ('', 0);

    if (not open(F, "<$file")) {
	$top->Dialog('File Not Found', $!, 'error', 'OK', 'OK')->Show('-global');
	return;
    }
    $w->delete('1.0', 'end');
    $bytes = read F, $buf, 10000;	# after all, it IS just an example
    $w->insert('end', $buf);
    if ($bytes == 10000) {
	$w->insert('end', "\n\n**************** File truncated at 10,000 bytes! ****************\n");
    }
    close F;

} # end text_load_file


sub text_search {

    # The utility procedure below searches for all instances of a given string in a text widget and applies a given tag
    # to each instance found.
    # Arguments:
    #
    # w -	The window in which to search.  Must be a text widget.
    # string -	The string to search for.  The search is done using exact matching only;  no special characters.
    # tag -	Tag to apply to each instance of a matching string.

    my($w, $string, $tag) = @_;

    $w->tag('remove',  $tag, '0.0', 'end');
    (my $num_lines) = $w->index('end') =~ /(\d*)\.\d*/;
    my($l, $i) = length $string;

    for($i = 1; $i <=$num_lines; $i++) {
	my $line = $w->get("${i}.0", "${i}.1000");
	next if not defined $line or $line !~ /$string/;
	my $offset = 0;
	while (1) {
	    my $index = index $line, $string, $offset;
	    last if $index == -1;
	    $offset += $index;
	    $w->tag('add', $tag, sprintf("%d.%d", $i, $offset), sprintf("%d.%d", $i, $offset+$l));
	    $offset += $l;
	    $line = substr $line, $index+$l;
	} # whilend
    } # forend

} # end text_search


sub text_toggle {

    # The procedure below is invoked repeatedly to invoke two commands at periodic intervals.  It normally reschedules itself
    # after each execution but if an error occurs (e.g. because the window was deleted) then it doesn't reschedule itself.
    # Arguments:
    #
    # w -       Text widget reference.
    # cmd1 -	Reference to a list of tag options.
    # sleep1 -	Ms to sleep after executing cmd1 before executing cmd2.
    # cmd2 -	Reference to a list of tag options.
    # sleep2 -	Ms to sleep after executing cmd2 before executing cmd1 again.

    my($w, $cmd1, $sleep1, $cmd2, $sleep2) = @_;

    # return if not Exists $w;
    $w->tag(@{$cmd1});
    $w->after($sleep1, [sub {text_toggle(@_)}, $w, $cmd2, $sleep2, $cmd1, $sleep1]);

} # end text_toggle

sub mkTxtSearch {

    # Create a top-level window with a text widget that allows you to load a file and highlight all instances of a given string.

    $mkTxtSearch->destroy if Exists($mkTxtSearch);
    $mkTxtSearch = $top->Toplevel();
    my $w = $mkTxtSearch;
    dpos $w;
    $w->title('Text Demonstration - Search and Highlight');
    $w->iconname('Text Search');

    $file_name = '';
    my $w_file = $w->Frame();
    my $w_file_label = $w_file->Label(-text => 'File name:', -width => 13, -anchor => 'w');
    my $w_file_entry = $w_file->Entry(-width => 40, -textvariable => \$file_name);
    my $w_file_button = $w_file->Button(-text => 'Load File');
    $w_file_label->pack(-side => 'left');
    $w_file_entry->pack(-side => 'left');
    $w_file_button->pack(-side => 'left', -pady => 5, -padx => 10);

    $search_string = '';
    my $w_string = $w->Frame();
    my $w_string_label = $w_string->Label(-text => 'Search string:', -width => 13, -anchor => 'w');
    my $w_string_entry = $w_string->Entry(-width => 40, -textvariable => \$search_string);
    my $w_string_button = $w_string->Button(-text => 'Highlight');
    $w_string_label->pack(-side => 'left');
    $w_string_entry->pack(-side => 'left');
    $w_string_button->pack(-side => 'left', -pady => 5, -padx => 10);

    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my $w_t = $w->Text(-setgrid => 'true');
    my $w_s = $w->Scrollbar(-command => ['yview', $w_t]);
    $w_t->configure(-yscrollcommand => ['set', $w_s]);
    $w_file->pack(-side => 'top', -fill => 'x');
    $w_string->pack(-side => 'top', -fill => 'x');
    $w_ok->pack(-side => 'bottom');
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    $w_file_button->configure(-command => [sub {text_load_file($_[0], $file_name)}, $w_t]);
    $w_file_entry->bind('<Return>' =>
			[sub {shift; text_load_file($_[0], $file_name); $_[1]->focus}, $w_t, $w_string_entry]);
    $w_string_button->configure(-command => [sub {text_search($_[0], $search_string, 'search')}, $w_t]);
    $w_string_entry->bind('<Return>' => [sub {shift; text_search($_[0], $search_string, 'search')}, $w_t]);

    # Set up display styles for text highlighting.

    if ($mkTxtSearch->depth > 1) {
	text_toggle($w_t, ['configure', 'search', -background => 'SeaGreen4', -foreground => 'white'], 800,
		          ['configure', 'search', -background => undef,       -foreground => undef],   200);
      } else {
	text_toggle($w_t, ['configure', 'search', -background => 'black',     -foreground => 'white'], 800,
		          ['configure', 'search', -background => undef,       -foreground => undef],   200);
      }

    $w_t->insert('0.0', 'This window demonstrates how to use the tagging facilities in text
widgets to implement a searching mechanism.  First, type a file name
in the top entry, then type <Return> or click on "Load File".  Then
type a string in the lower entry and type <Return> or click on
"Load File".  This will cause all of the instances of the string to
be tagged with the tag "search", and it will arrange for the tag\'s
display attributes to change to make all of the strings blink.');

    $w_t->mark('set', 'insert', '0.0');

    $w->bind('<Any-Enter>' => [sub {shift; shift->focus}, $w_file_entry]);

} # end mkTxtSearch


1;
