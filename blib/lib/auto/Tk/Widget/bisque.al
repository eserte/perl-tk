# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

# tk_bisque --
# Reset the Tk color palette to the old "bisque" colors.
#
# Arguments:
# None.
sub bisque
{
 shift->setPalette("activeBackground" => "#e6ceb1",
               "activeForeground" => "black",
               "background" => "#ffe4c4",
               "disabledForeground" => "#b0b0b0",
               "foreground" => "black",
               "highlightBackground" => "#ffe4c4",
               "highlightColor" => "black",
               "insertBackground" => "black",
               "selectColor" => "#b03060",
               "selectBackground" => "#e6ceb1",
               "selectForeground" => "black",
               "troughColor" => "#cdb79e"
              );
}

1;
