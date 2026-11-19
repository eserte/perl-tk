# -*- perl -*-

use strict;
use warnings;
use Test::More tests => 800;
use Tk;

# Keep the same option-name scalars alive across interpreter destruction.
# The cached option pointers must not survive the tables they refer to, even
# when the allocator reuses an interpreter or option-table address.  Include
# a synonym and an abbreviation, and keep another interpreter live at teardown.
# Running this test under a memory checker also checks the cached accesses.
my @options = map { "-$_" } qw(width height bd bord);

for my $iteration (1 .. 100) {
    my @windows = map { MainWindow->new } 1 .. 2;
    $_->withdraw for @windows;

    for my $window (0 .. $#windows) {
        my $mw = $windows[$window];
        my @values = ($iteration + $window, $iteration + $window + 1,
                      1 + $iteration % 5, 1 + $iteration % 5);
        my $frame = $mw->Frame(-width => $values[0],
                               -height => $values[1],
                               -borderwidth => $values[2]);
        for my $index (0 .. $#options) {
            # The second lookup exercises the cache for the current table.
            $frame->cget($options[$index]);
            is($frame->cget($options[$index]), $values[$index],
               "iteration $iteration, interpreter $window, $options[$index]");
        }
        $mw->destroy;
    }
}
