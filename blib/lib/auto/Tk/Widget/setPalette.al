# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

# tk_setPalette --
# Changes the default color scheme for a Tk application by setting
# default colors in the option database and by modifying all of the
# color options for existing widgets that have the default value.
#
# Arguments:
# The arguments consist of either a single color name, which
# will be used as the new background color (all other colors will
# be computed from this) or an even number of values consisting of
# option names and values. The name for an option is the one used
# for the option database, such as activeForeground, not -activeforeground.
sub setPalette
{
 my $w = shift->MainWindow;
 my %new = (@_ == 1) ? (background => $_[0]) : @_;
 my $priority = delete($new{'priority'}) || 'widgetDefault';
 my $i;

 # Create an array that has the complete new palette. If some colors
 # aren't specified, compute them from other colors that are specified.

 die "must specify a background color" if (!exists $new{background});
 $new{"foreground"} = "black" unless (exists $new{foreground});
 my @bg = $w->rgb($new{"background"});
 my @fg = $w->rgb($new{"foreground"});
 my $darkerBg = sprintf("#%02x%02x%02x",9*$bg[0]/2560,9*$bg[1]/2560,9*$bg[2]/2560);
 foreach $i ("activeForeground","insertBackground","selectForeground","highlightColor")
  {
   $new{$i} = $new{"foreground"} unless (exists $new{$i});
  }
 unless (exists $new{"disabledForeground"})
  {
   $new{"disabledForeground"} = sprintf("#%02x%02x%02x",(3*$bg[0]+$fg[0])/1024,(3*$bg[1]+$fg[1])/1024,(3*$bg[2]+$fg[2])/1024);
  }
 $new{"highlightBackground"} = $new{"background"} unless (exists $new{"highlightBackground"});

 unless (exists $new{"activeBackground"})
  {
   my @light;
   # Pick a default active background that is lighter than the
   # normal background. To do this, round each color component
   # up by 15% or 1/3 of the way to full white, whichever is
   # greater.
   foreach $i (0, 1, 2)
    {
     $light[$i] = $bg[$i]/256;
     my $inc1 = $light[$i]*15/100;
     my $inc2 = (255-$light[$i])/3;
     if ($inc1 > $inc2)
      {
       $light[$i] += $inc1
      }
     else
      {
       $light[$i] += $inc2
      }
     $light[$i] = 255 if ($light[$i] > 255);
    }
   $new{"activeBackground"} = sprintf("#%02x%02x%02x",@light);
  }
 $new{"selectBackground"} = $darkerBg unless (exists $new{"selectBackground"});
 $new{"troughColor"} = $darkerBg unless (exists $new{"troughColor"});
 $new{"selectColor"} = "#b03060" unless (exists $new{"selectColor"});

 # Before doing this, make sure that the Tk::Palette variable holds
 # the default values of all options, so that tkRecolorTree can
 # be sure to only change options that have their default values.
 # If the variable exists, then it is already correct (it was created
 # the last time this procedure was invoked). If the variable
 # doesn't exist, fill it in using the defaults from a few widgets.
 my $Palette = $w->Palette;

 # Walk the widget hierarchy, recoloring all existing windows.
 $w->RecolorTree(\%new);
 # Change the option database so that future windows will get the
 # same colors.
 my $option;
 foreach $option (keys %new)
  {
   $w->option("add","*$option",$new{$option},$priority);
   # Save the options in the global variable Tk::Palette, for use the
   # next time we change the options.
   $Palette->{$option} = $new{$option};
  }
}

1;
