package Tk::Widget;
require Tk;
use AutoLoader;
use Tk::Pretty;
use strict qw(vars);

use Carp;

@Tk::Widget::ISA = qw(Tk);

# stubs for 'autoloaded' widget classes
sub Button;
sub Canvas;
sub Checkbutton;
sub Entry;
sub Frame;
sub Label;
sub Listbox;
sub Menu;
sub Menubutton;
sub Message;
sub Scale;
sub Scrollbar;
sub Radiobutton;
sub Text;
sub Toplevel;

sub Pixmap;
sub Bitmap;
sub Photo;

sub Menubar;
sub ScrlListbox;
sub Optionmenu; 

sub import
{
 my $package = shift;
 my $need;
 foreach $need (@_)
  {
   unless (defined &{$need})
    {
     require "Tk/${need}.pm"; 
    }
   croak "Cannot locate $need" unless (defined &{$need});
  }
}

# Some tidy-ness functions for winfo stuff

BEGIN 
 {
  my $fn;
  foreach $fn (qw(cells class colormapfull depth exists geometry height id 
               ismapped manager name parent reqheight reqwidth rootx rooty
               screen screencells screendepth screenheight screenmmheight
               screenmmwidth  screenvisual screenwidth visual visualsavailable 
               vrootheight viewable vrootwidth vrootx vrooty width x y toplevel children
               pixels pointerx pointery pointerxy server fpixels rgb
              ))
   {
    *{"$fn"} = sub { shift->winfo($fn, @_) };
   }
 }

sub DESTROY
{
 my $w = shift;
 $w->destroy if ($w->IsWidget); # i.e. is Tk data still there
}

sub Install 
{
 # Dynamically loaded widgets add their core commands 
 # to the Tk base class here 
 my ($package,$mw) = @_;
}

sub classinit
{
 # Carry out class bindings (or whatever)
 my ($package,$mw) = @_;
 return $package;
}

sub InitClass
{
 my ($package,$parent) = @_;
 croak "Unexpected type of parent $parent" unless(ref $parent);
 my $mw = $parent->MainWindow;
 unless (exists $mw->{'_ClassInit_'}{$package})
  {
   $package->Install($mw);
   $mw->{'_ClassInit_'}{$package} = $package->classinit($mw);
  }
}

sub CreateArgs
{
 my ($package,$parent,$args) = @_;
 # Remove from hash %$args any configure-like
 # options which only apply at create time (e.g. -class for Frame)
 # return these as a list of -key => value pairs
 # Augment same hash with default values for missing mandatory options,
 # allthough this can be done later in InitObject.
 return ();
}

sub InitObject
{
 my ($obj,$args) = @_;
 # per object initialization, for example populating 
 # with sub-widgets, adding a few object bindings to augment
 # inherited class bindings, changing binding tags.
 # Also another chance to mess with %$args before configure...
}

sub SetBindtags
{
 my ($obj) = @_;
 $obj->bindtags([ref($obj),$obj,$obj->toplevel,'all']);
}

sub new
{
 my ($package,$parent,%args) = @_;
 $package->InitClass($parent);
 my @args  = $package->CreateArgs($parent,\%args);
 my $cmd   = $package->Tk_cmd;
 my $pname = $parent->PathName;
 $pname    = "" if ($pname eq ".");
 my $leaf  = delete $args{'Name'};
 my $lname;
 if (defined $leaf)
  {
   $lname = $pname . "." . $leaf;
  }
 else
  {
   $leaf   = "\L$package";
   $leaf   =~ s/^tk:://;
   $lname  = $pname . "." . $leaf;
   my $num = 0;
   while (defined ($parent->Widget($lname)))
    {
     $lname = $pname . "." . $leaf . ++$num;
    }
  }
 my $obj = eval { &$cmd($parent, $lname, @args) };
 croak "$@" if ($@);
 bless $obj,$package;
 $obj->InitObject(\%args);
 if (%args)
  {
   eval { $obj->configure(%args) };
   croak "$@" if ($@);
  }
 $obj->SetBindtags;
 return $obj;
}

sub True  { 1 }
sub False { 0 }

sub Construct
{
 my ($base,$name) = @_;
 my $class = (caller(0))[0];
# print "$base->$name is $class\n";
# @{$class.'::Inherit::ISA'} = @{$class.'::ISA'};
 *{"$name"} = sub { $class->new(@_) };
 *{"Is$name"} = \&False;
 *{$class.'::Is'.$name} = \&True;
}

sub Inherit
{
 my $w = shift;
 my $method = shift;
 my $what   = (caller(1))[3];
 my ($class) = $what =~ /^(.*)::[^:]+$/;
 @{$class.'::Inherit::ISA'} = @{$class.'::ISA'} unless (defined @{$class.'::Inherit::ISA'});
 $class .= '::Inherit::';
 $class .= $method;
 return $w->$class(@_);
}

sub InheritThis
{
 my $w      = shift;
 my $what   = (caller(1))[3];
 my ($class,$method) = $what =~ /^(.*)::([^:]+)$/;
#my $class = ref($w) ? ref($w) : $w;
 @{$class.'::Inherit::ISA'} = @{$class.'::ISA'} unless (defined @{$class.'::Inherit::ISA'});
 $class .= '::Inherit::';
 $class .= $method;
 return $w->$class(@_);
}

sub WidgetClass
{
 my $nameref  = shift;
 my $class = ref $nameref;
 my $name  = $$nameref;
 carp "(bless...)->WidgetClass is obsolete should be:\nTk::Widget->Construct('$name');";
 @{$class.'::Inherit::ISA'} = @{$class.'::ISA'};
 *{"$name"} = sub { $class->new(@_) };
 *{"Is$name"} = \&False;
 *{$class.'::Is'.$name} = \&True;
}

sub Delegates
{
 my ($cw,%args) = @_;
 if (exists $cw->{'Delegates'})
  {
   my $specs = $cw->{'Delegates'};
   if (%args)
    {
     my ($key,$val);
     while (($key,$val) = each %args)
      {
       $specs->{$key} = $val;
      }
    }
  }
 else
  {
   $cw->{'Delegates'} = \%args;
  }
 return $cw->{'Delegates'}
}

sub AUTOLOAD
{
 # Take a copy into a 'my' variable so we can recurse
 my $what = $Tk::Widget::AUTOLOAD;
 my $path = Tk::findINC("auto","$what.al");
 unless (defined($path))
  {
   my($package,$method) = ($what =~ /^(.*)::([^:]*)$/);
   if ($package eq 'Tk::Widget' && $method ne '__ANON__')
    {
     eval { require "Tk/$method.pm" };
     croak "$@" if ($@);
     goto &$what;
    }
   else 
    {
     if (ref $_[0] && $method !~ /^(ConfigSpecs|Delegates)/ )
      {                                    
       my $delegate = $_[0]->Delegates;    
       if (%$delegate)                     
        {                                  
         my $widget = $delegate->{$method};
         $widget = $delegate->{DEFAULT} unless (defined $widget);
         if (defined $widget)              
          {                                
           my $subwidget = (ref $widget) ? $widget : $_[0]->subwidget($widget);
           if (defined $subwidget)         
            {                              
#            print "AUTOLOAD: $what\n";
             *{$what} = sub { shift->Delegate($method,@_) }; 
             goto &$what;
            }                              
           else                            
            {                              
             croak "No delegate subwidget '$widget' for $what";
            }                              
          }                                
        }                                  
      }                                    
    }
  }
 # Okay that did not work - call regular AutoLoader
 # Figure out how to 'inherit' this ...
 $AutoLoader::AUTOLOAD = $what;
 goto &AutoLoader::AUTOLOAD;
}

1;

__END__

sub FindMenu
{
 # default FindMenu is that there no menu.
 return undef;
}

sub IS
{
 return (defined $_[1]) && $_[0] == $_[1];
}

sub XEvent { shift->{"_XEvent_"} }

sub rootproperty
{
 my $w = shift;
 return $w->property(@_,'root');
}

# atom, atomname, containing, interps, pathname 
# don't work this way - there is no window arg
# So we pretend there was an call the C versions from Tk.xs

sub atom       { shift->InternAtom(@_)  }
sub atomname   { shift->GetAtomName(@_) }
sub containing { shift->Containing(@_)  }


# interps not done yet
# pathname not done yet

# walk and descendants adapted from Stephen's composite
# versions as they only use core features they can go here.
# hierachy is reversed in that descendants calls walk rather
# than vice versa as this avoids building a list.
# Walk should possibly be enhanced so allow early termination
# like '-prune' of find.

sub walk 
{
 # Traverse a widget hierarchy while executing a subroutine.
 my($cw, $proc, @args) = @_;
 my $subwidget;
 foreach $subwidget ($cw->children) 
  {
   $subwidget->walk($proc,@args);
   &$proc($subwidget, @args);
  }
} # end walk

sub descendants
{
 # Return a list of widgets derived from a parent widget and all its
 # descendants of a particular class.  
 # If class is not passed returns the entire widget hierarchy.
 
 my($widget, $class) = @_;
 my(@widget_tree)    = ();
 
 $widget->walk(
               sub { my ($widget,$list,$class) = @_;
                     push(@$list, $widget) if  (!defined($class) or $class eq $widget->class);
                   }, 
               \@widget_tree, $class
              );
 return @widget_tree;
} 

sub packinfo
{
 my ($w) = @_;
 my $mgr = $w->manager;
 $w->$mgr('info');
}

sub packslaves
{
 my ($w) = @_;
 $w->pack('slaves');
}

sub packpropagate
{
 my $w = shift;
 $w->pack('propagate',@_);
}

sub packforget
{
 my ($w) = @_;
 my $mgr = $w->manager;
 $w->$mgr('forget') if (defined $mgr);
}


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
   # Pick a default active background that islighter than the
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

 unless (defined %Tk::Palette)
  {
   my $c = $w->Checkbutton();
   my $e = $w->Entry();
   my $s = $w->Scrollbar();
   $Tk::Palette{"activeBackground"}    = ($c->configure("-activebackground"))[3] ;
   $Tk::Palette{"activeForeground"}    = ($c->configure("-activeforeground"))[3];
   $Tk::Palette{"background"}          = ($c->configure("-background"))[3];
   $Tk::Palette{"disabledForeground"}  = ($c->configure("-disabledforeground"))[3];
   $Tk::Palette{"foreground"}          = ($c->configure("-foreground"))[3];
   $Tk::Palette{"highlightBackground"} = ($c->configure("-highlightbackground"))[3];
   $Tk::Palette{"highlightColor"}      = ($c->configure("-highlightcolor"))[3];
   $Tk::Palette{"insertBackground"}    = ($e->configure("-insertbackground"))[3];
   $Tk::Palette{"selectColor"}         = ($c->configure("-selectcolor"))[3];
   $Tk::Palette{"selectBackground"}    = ($e->configure("-selectbackground"))[3];
   $Tk::Palette{"selectForeground"}    = ($e->configure("-selectforeground"))[3];
   $Tk::Palette{"troughColor"}         = ($s->configure("-troughcolor"))[3];
   $c->destroy;
   $e->destroy;
   $s->destroy;
  }

 # Walk the widget hierarchy, recoloring all existing windows.
 $w->RecolorTree(\%new);
 # Change the option database so that future windows will get the
 # same colors.
 my $option;
 foreach $option (keys %new)
  {
   $w->option("add","*$option",$new{$option},"widgetDefault");
   # Save the options in the global variable Tk::Palette, for use the
   # next time we change the options.
   $Tk::Palette{$option} = $new{$option};
  }
}

# tkRecolorTree --
# This procedure changes the colors in a window and all of its
# descendants, according to information provided by the colors
# argument. It only modifies colors that have their default values
# as specified by the Tk::Palette variable.
#
# Arguments:
# w - The name of a window. This window and all its
# descendants are recolored.
# colors - The name of an array variable in the caller,
# which contains color information. Each element
# is named after a widget configuration option, and
# each value is the value for that option.
sub RecolorTree
{
 my ($w,$colors) = @_;
 my $dbOption;
 local ($@);
 foreach $dbOption (keys %$colors)
  {
   my $option = "-\L$dbOption";
   my $value;
   eval { $value = $w->cget($option) };
   if (defined $value)
    {
     if ($value eq $Tk::Palette{$dbOption})
      {
       $w->configure($option,$colors->{$dbOption})
      }
    }
  }
 my $child;
 foreach $child ($w->children)
  {
   $child->RecolorTree($colors);
  }
}
# tkDarken --
# Given a color name, computes a new color value that darkens (or
# brightens) the given color by a given percent.
#
# Arguments:
# color - Name of starting color.
# perecent - Integer telling how much to brighten or darken as a
# percent: 50 means darken by 50%, 110 means brighten
# by 10%.
sub Darken
{
 my ($w,$color,$percent) = @_;
 my @l = $w->rgb($color);
 my $red = $l[0]/256;
 my $green = $l[1]/256;
 my $blue = $l[2]/256;
 $red = int($red*$percent/100);
 $red = 255 if ($red > 255);
 $green = int($green*$percent/100);
 $green = 255 if ($green > 255);
 $blue = int($blue*$percent/100);
 $blue = 255 if ($blue > 255);
 sprintf("#%02x%02x%02x",$red,$green,$blue)
}
# tk_bisque --
# Reset the Tk color palette to the old "bisque" colors.
#
# Arguments:
# None.
sub tk_bisque
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

sub PrintConfig
{
 my ($w) = (@_);
 my $c;
 foreach $c ($w->configure)
  {
   print pretty(@$c),"\n";
  }
} 

sub Busy
{
 my ($w,%args) = @_;
 return unless $w->viewable;
 $args{'-cursor'} = 'watch' unless (exists $args{'-cursor'});
 unless (exists $w->{'Busy'})
  {
   my %old = ();           
   my $key;                
   my @tags = $w->bindtags;
   foreach $key (keys %args)
    {
     $old{$key} = $w->Tk::cget($key);
    }
   $old{'bindtags'} = \@tags;
   unless ($w->Tk::bind('Busy'))
    {                     
     $w->Tk::bind('Busy','<KeyPress>','bell');
     $w->Tk::bind('Busy','<ButtonPress>','bell');
    }                     
   $w->bindtags(['Busy']);
   $w->{'Busy'} = \%old;
  }
 $w->Tk::configure(%args);
 $w->grab;
 $w->update;
}

sub Unbusy
{
 my ($w) = @_;
 $w->grab('release');
 my $old = delete $w->{'Busy'};
 if (defined $old)
  {
   $w->update;
   $w->bindtags(delete $old->{'bindtags'});
   $w->Tk::configure(%{$old}); 
   $w->update;
  }
}

sub currentfocus
{
 my ($w) = @_;
 $w->Tk::focus('-displayof'); 
}

sub waitvisibility
{
 my ($w) = shift;
 $w->tkwait('visibility',$w);
}

sub waitwindow
{
 my ($w) = shift;
 $w->tkwait('window',$w);
}

sub EventWidget
{
 my ($w) = @_;
 return $w->{'_EventWidget_'};
}

sub Popwidget
{
 my ($ew,$method,$w,@args) = @_;
 $w->{'_EventWidget_'} = $ew;
 $w->$method(@args);
}
