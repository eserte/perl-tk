

sub mkBasic {

    # Create a top-level window that displays a basic text widget.

    $mkBasic->destroy if Exists($mkBasic);
    $mkBasic = $top->Toplevel();
    my $w = $mkBasic;
    dpos $w;
    $w->title('Text Demonstration - Basic Facilities');
    $w->iconname('Text Basics');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my $w_t = $w->Text(-relief => 'sunken', -bd => '2', -setgrid => 'true');
    my $w_s = $w->Scrollbar(-command => ['yview', $w_t]);
    $w_t->configure(-yscrollcommand => ['set', $w_s]);
    $w_ok->pack(-side => 'bottom');
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    $w_t->insert('0.0', 'This window is a text widget.  It displays one or more lines of text
and allows you to edit the text.  Here is a summary of the things you
can do to a text widget:

1. Scrolling. Use the scrollbar to adjust the view in the text window.

2. Scanning. Press mouse button 2 in the text window and drag up or down.
This will drag the text at high speed to allow you to scan its contents.

3. Insert text. Press mouse button 1 to set the insertion cursor, then
type text.  What you type will be added to the widget.

4. Select. Press mouse button 1 and drag to select a range of characters.
Once you\'ve released the button, you can adjust the selection by pressing
button 1 with the shift key down.  This will reset the end of the
selection nearest the mouse cursor and you can drag that end of the
selection by dragging the mouse before releasing the mouse button.
You can double-click to select whole words or triple-click to select
whole lines.

5. Delete. To delete text, select the characters you\'d like to delete
and type Backspace, Delete or Control-x.

6. Copy the selection. To copy the selection either from this window
or from any other window or application, select what you want, click
button 1 to set the insertion cursor, then click button 2 to copy the
selection to the point of the insertion cursor.

7. Edit.  Text widgets support the standard Motif editing characters
plus many Emacs editing characters.  Backspace and Control-h erase the
character to the left of the insertion cursor.  Delete and Control-d
erase the character to the right of the insertion cursor.  Control-w
and Meta-backspace delete the word to the left of the insertion cursor,
and Meta-d deletes the word to the right of the insertion cursor.
Control-k deletes from the insertion cursor to the end of the line, or
it deletes the newline character if that is the only thing left on the
line.  Control-o opens a new line by inserting a newline character to
the right of the insertion cursor.  Control-t transposes the two characters
to the right of the insertion cursor.

8. Resize the window.  This widget has been configured with the "setGrid"
option on, so that if you resize the window it will always resize to an
even number of characters high and wide.  Also, if you make the window
narrow you can see that long lines automatically wrap around onto
additional lines so that all the information is always visible.

When you\'re finished with this demonstration, press the "OK" button
below.');

    $w_t->mark('set', 'insert', '0.0');

} # end mkBasic


1;
