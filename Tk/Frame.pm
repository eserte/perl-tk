package Tk::Frame;
require Tk::Widget;
require Tk::Config;
use AutoLoader;
use Carp;
use strict qw(vars);
use Tk::Pretty;

$Tk::Frame::Debug = 1;

@Tk::Frame::ISA = qw(Tk::Widget);

Tk::Widget->Construct('Frame');

sub Tk_cmd { \&Tk::frame }

sub CreateArgs
{
 my ($package,$parent,$args) = @_;
 my @result = ();
 # Honour -class => if present                         
 my $class = delete $args->{-class};                     
 ($class) = $package =~ /([A-Za-z]+)$/ unless (defined $class);
 push(@result, '-class' => "\u$class") if (defined $class);
 my $colormap = delete $args->{-colormap};                     
 push(@result, '-colormap' => $colormap) if (defined $colormap);
 return @result;
}

sub Advertise
{
 my ($cw,$name,$widget)  = @_;
 $cw->{SubWidget} = {} unless (exists $cw->{SubWidget});
 $cw->{SubWidget}{$name} = $widget;              # advertise it
 return $widget;
}

sub Default
{
 my ($cw,$name,$widget)  = @_;
 $cw->Delegates(DEFAULT => $widget);
 $cw->ConfigSpecs(DEFAULT => [$widget]);
 $widget->pack('-expand' => 1, -fill => 'both');  # Suspect 
 goto &Advertise;
}

sub ConfigAlias
{
 my ($cw,$name,@skip) = @_;
 my $sw = $cw->subwidget($name);
 my $sc;
 my %skip = ();
 foreach $sc (@skip)
  {
   $skip{$sc} = 1;
  }
 $name .= "_";
 foreach $sc ($sw->configure)
  {
   my (@info) = @$sc;
   next if (@info == 2);
   my $option = $info[0];
   unless ($skip{$option})
    {
     $option =~ s/^-/-$name/;            
     $info[0] = Tk::Config->new($sw,$info[0]);
     pop(@info);                         
     $cw->ConfigSpecs($option => \@info);
    }
  }
}

sub subwidget 
{
 my $cw = shift;
 my @result = ();
 if (exists $cw->{SubWidget})
  {
   if (@_)
    {
     my $name;
     foreach $name (@_)
      {
       push(@result,$cw->{SubWidget}{$name}) if (exists $cw->{SubWidget}{$name});
      }
    }
   else
    {
     @result = values %{$cw->{SubWidget}};
    }
  }
 return (wantarray) ? @result : $result[0];
} 

sub subconfigure
{
 # This finds the widget or widgets to to which to apply a particular 
 # configure option

 my ($cw,$opt) = @_;
 my $config = $cw->ConfigSpecs;
 my $widget;
 my @subwidget = ();
 my (@arg) = ();
 push(@arg,$opt) unless ($opt eq DEFAULT);
 $widget = $config->{$opt}    if     (defined $opt);
 $widget = $config->{DEFAULT} unless (defined $widget);
 if (defined $widget)
  {
   croak "Invalid ConfigSpecs $widget" unless (ref($widget) && (ref $widget eq "ARRAY"));
   $widget = $widget->[0];
  }
 else
  {
   $widget = 'SELF';
  }
 my (@specs) = (ref $widget && ref $widget eq "ARRAY") ? (@$widget) : ($widget);
 foreach $widget (@specs)
  {
   if (ref $widget)
    {
     push(@subwidget,$widget)
    }
   elsif ($widget eq 'ADVERTISED')
    {
     push(@subwidget,$cw->subwidget)
    }
   elsif ($widget eq 'DESCENDANTS')
    {
     push(@subwidget,$cw->descendants) 
    }
   elsif ($widget eq 'CHILDREN')
    {
     push(@subwidget,$cw->children) 
    }
   elsif ($widget eq 'METHOD')
    {
     my ($method) = ($opt =~ /^-(.*)$/);
     push(@subwidget,Tk::Config->new($method,$method,$cw))
    }
   elsif ($widget eq 'SELF')
    {
     push(@subwidget,Tk::Config->new('Tk::configure', 'Tk::cget', $cw,@arg))
    }
   elsif ($widget eq 'PASSIVE') 
    {
     push(@subwidget,Tk::Config->new('_configure','_cget',$cw,@arg))
    }
   elsif ($widget eq 'CALLBACK') 
    {
     push(@subwidget,Tk::Config->new('_callback','_cget',$cw,@arg))
    }
   else
    {
     push(@subwidget,$cw->subwidget($widget));
    }
  }
 croak "No delegate subwidget '$widget' for $opt" unless (@subwidget);
 return (wantarray) ? @subwidget : $subwidget[0];
}

sub _cget
{
 croak("Wrong number of args to cget") unless (@_ == 2);
 my ($cw,$opt) = @_;
 return $cw->{Configure}{$opt}
}

sub _configure
{
 croak("Wrong number of args to configure") unless (@_ == 3);
 my ($cw,$opt,$val) = @_;
 $cw->{Configure}{$opt} = $val;
}

sub _callback
{
 croak("Wrong number of args to configure") unless (@_ == 3);
 my ($cw,$opt,$val) = @_;
 $cw->{Configure}{$opt} = Tk::Callback->new($val);
}

sub cget
{my ($cw,$opt) = @_;
 croak "Invalid option $opt" unless ($opt =~ /^-/);
 my (@subwidget) = $cw->subconfigure($opt);
 my @result = $cw->{Configure}{$opt};
 if (@subwidget == 1)
  {
   eval { @result = $subwidget[0]->cget($opt) };
   croak "cget: $@" if ($@);
  }
 return (wantarray) ? @result : $result[0];
}

sub configure
{
 # The default composite widget configuration method uses %Configure
 # in the widgets package to map configuration options
 # onto subwidgets. If such an array does not exist it applies
 # option/value pairs to every subwidget of the composite widget.  If
 # this is too general then use the `subwidget' method on an advertised
 # component widget for detailed configuration possibilities (the widget
 # developer shall have published a list of subwidget names).
 #
 # Or, use the `walk' method to traverse a composite widget hierarchy and
 # do your own thing.
 my @results = ();
 my $cw = shift;
 if (@_ <= 1)
  {
   if (@_)
    {
     my $sw = $cw->subconfigure(@_);
     @results = $sw->configure(@_);
    }
   else
    {
     my $spec = $cw->ConfigSpecs;
     my $opt;
     foreach $opt (keys %$spec)
      {
       my $sw = $cw->subconfigure($opt);
       my (@info) = @{$spec->{$opt}};
       if ($opt eq 'DEFAULT')
        {
         push(@results,$sw->configure);
        }
       else
        {
         # Bug here if cget fails  
         push(@results,[$opt,$info[1],$info[2],$info[3],$sw->cget($opt)]);
        }
      }
    }
  }
 else
  {
   my (%args) = @_;
   my ($opt,$val);
   my %changed = ();
   while (($opt,$val) = each %args)
    {
     my $var = \$cw->{Configure}{$opt};
     my $old = $$var;
     my $subwidget;
     $$var = $val;
     foreach $subwidget ($cw->subconfigure($opt))
      {
       next unless (defined $subwidget);
       eval { $subwidget->configure($opt => $val) };
       croak "$@" if ($Tk::Frame::Debug && $@);
      }
     $cw->ClearErrorInfo; 
     $val = $$var;
     $changed{$opt} = $val if (!defined $old || !defined $val || $old ne $val);
    }
   $cw->DoWhenIdle(['ConfigChanged',$cw,\%changed]) if (%changed);
  }
 return (wantarray) ? @results : $results[0];
}

sub ConfigDefault
{
 my ($cw,$args) = @_;

 croak "Bad args" unless (defined $args && ref $args eq 'HASH');

 my $specs = $cw->ConfigSpecs;
 my $opt; 
 $specs->{'DEFAULT'} = ['SELF'] unless (exists $specs->{'DEFAULT'});
 $specs->{'-cursor'} = ['SELF',undef,undef,undef] unless (exists $specs->{'-cursor'});

 # Now some hacks that cause colours to propogate down a composite widget 
 # tree - really needs more thought, other options adding such as active 
 # colours too and maybe fonts

 my $children = scalar($cw->children);
 my (@bg) = ('SELF');
 unshift(@bg,'CHILDREN') if $children;
 foreach $opt (qw(-bg -background ))
  {
   $specs->{$opt} = [\@bg,undef,undef,undef] unless (exists $specs->{$opt});
  }
 my (@fg) = ('PASSIVE');
 unshift(@fg,'CHILDREN') if $children;
 foreach $opt (qw(-fg -foreground ))
  {
   $specs->{$opt} = [\@fg,undef,undef,undef] unless (exists $specs->{$opt});
  }

 # Now walk %$specs supplying defaults for all the options mentioned,
 # potentially looking up .Xdefaults database options for the name/class
 # of the 'frame' 

 foreach $opt (keys %$specs)
  {
   if ($opt eq 'DEFAULT')
    {
     # What to do here ?  
    }
   else
    {
     unless (exists $args->{$opt})
      {
       my (@info) = @{$specs->{$opt}};
       $args->{$opt} = $info[3] if (defined $info[3]);
       # maybe should convert -fred info 'fred','Fred' here 
       if (defined $info[1] && defined $info[2])
        {
         my $db = $cw->OptionGet($info[1],$info[2]);
         $args->{$opt} = $db if (defined $db);
        }
      }
    }
  }

 # Should we enforce a Delagates(DEFAULT => )  as well ?
}

sub InitObject
{
 my ($cw,$args) = @_;
 $cw->{Configure} = {};
 $cw->InheritThis($args);
 # advertised frame widget - Why and what should it be called ?
 # $cw->Advertise("self" => $cw);       
 $cw->Populate($args);    
 $cw->ConfigDefault($args);
}


sub ConfigSpecs
{
 my ($cw,%args) = @_;
 if (exists $cw->{'ConfigSpecs'})
  {
   my $specs = $cw->{'ConfigSpecs'};
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
   $cw->{'ConfigSpecs'} = \%args;
  }
 return $cw->{'ConfigSpecs'};
}

sub Delegate
{
 my ($cw,$method,@args) = @_;
 my $delegate = $cw->Delegates;
 my $widget = $delegate->{$method};
 $widget = $delegate->{DEFAULT} unless (defined $widget);
 $widget = $cw->subwidget($widget) if (defined $widget && !ref $widget);
 $widget = $cw unless (defined $widget);
 $method = "Tk::$method" if ($widget == $cw);
 my @result;
 if (wantarray)
  {
   eval { @result   = $widget->$method(@args) };
  }
 else
  {
   eval { $result[0] = $widget->$method(@args) };
  }
 $cw->BackTrace("$@") if ($@);
 return (wantarray) ? @result : $result[0];
}

sub bind
{my ($cw,@args) = @_;
 $cw->Delegate('bind',@args);
}

sub selection
{my ($cw,@args) = @_;
 $cw->Delegate('selection',@args);
}

sub labelpack
{
 my ($cw,$val) = @_;
 my $w = $cw->subwidget('label');
 my @result = ();
 if (@_ > 1)
  {
   if (defined($w) && !defined($val))
    {
     $w->packforget;
    }
   elsif (defined($val) && !defined ($w))
    {
     require Tk::Label;
     $w = $cw->Component(Label => 'label',-textvariable => $cw->labelvariable);
     $cw->ConfigAlias('label',qw(text textvariable));
    }
   if (defined($val) && defined($w))
    {
     my %pack = @$val;
     unless (exists $pack{-side})
      {
       $pack{-side} = 'top' unless (exists $pack{-side});
      }
     unless (exists $pack{-fill})
      {
       $pack{-fill} = 'x' if ($pack{-side} =~ /(top|bottom)/);
       $pack{-fill} = 'y' if ($pack{-side} =~ /(left|right)/);
      }
     unless (exists($pack{'-before'}) || exists($pack{'-after'}))
      {
       my $before = ($cw->packslaves)[0];
       $pack{'-before'} = $before if (defined $before);
      }
     $w->pack(%pack);
    }
  }
 @result = $w->packinfo if (defined $w);
 return (wantarray) ? @result : \@result;
}

sub labelvariable
{
 my ($cw,$val) = @_;
 my $var = \$cw->{Configure}{'-labelvariable'};
 if (@_ > 1 && defined $val)
  {
   $$var = $val;
   $$val = '' unless (defined $$val);
   my $w = $cw->subwidget('label');
   unless (defined $w)
    {
     $cw->labelpack([]);
     $w = $cw->subwidget('label');
    }
   $w->configure(-textvariable => $val);
  }
 return $$var;
}

sub label
{
 my ($cw,$val) = @_;
 my $var = $cw->cget('-labelvariable');
 if (@_ > 1 && defined $val)
  {
   if (!defined $var)
    {
     $var = \$cw->{Configure}{'-label'};
     $cw->labelvariable($var);
    }
   $$var = $val;
  }
 return (defined $var) ? $$var : undef;;
}

sub Component
{
 my ($cw,$kind,$name,%args) = @_;
 $args{'Name'} = "\l$name" if (defined $name && !exists $args{'Name'});
 my $w;
 my $pack = delete $args{'-pack'};
 my $delegate = delete $args{'-delegate'};
 eval { $w = $cw->$kind(%args) };            # Create it
 croak "$@" if ($@);
 $w->pack(@$pack) if (defined $pack);
 $cw->Advertise($name,$w) if (defined $name);
 $cw->Delegates(map(($_ => $w),@$delegate)) if (defined $delegate); 
 return $w;                            # and return it
}

sub Validate { 1 }

sub Populate
{
 my ($cw,$args) = @_;
 $cw->ConfigSpecs('-labelpack'     => [ METHOD, undef, undef, undef]);
 $cw->ConfigSpecs('-labelvariable' => [ METHOD, undef, undef, undef]);
 $cw->ConfigSpecs('-label'         => [ METHOD, undef, undef, undef]);
}

sub ConfigChanged
{
 my ($cw,$args);
}       

1;

__END__

sub AddScrollbars
{
 my ($cw,$w) = @_;
 my $def = "";
 my ($x,$y) = ('','');
 my $c;
 foreach $c ($w->configure)
  {
   my $opt = $c->[0];
   if ($opt eq '-yscrollcommand')
    {
     my $slice  = $cw->Frame(Name => 'ysbslice');                                       
     my $ysb    = $slice->Scrollbar(-orient => 'vertical', -command => [ 'yview', $w ]);
     my $corner = $slice->Frame(Name=>'corner','-relief' => 'raised', '-width' => 20, '-height' => 20);
     $ysb->pack(-side => 'left', -fill => 'both');
     $cw->Advertise("yscrollbar" => $ysb); 
     $cw->Advertise("corner" => $corner);
     $cw->Advertise("ysbslice" => $slice);
     $corner->{'before'} = $ysb;
     $slice->{'before'} = $w;
     $w->configure(-yscrollcommand => ["set", $ysb]);
     $y = 's';
    }
   elsif ($opt eq '-xscrollcommand')
    {
     my $xsb = $cw->Scrollbar(-orient => 'horizontal', -command => [ 'xview', $w ]);
     $w->configure(-xscrollcommand => ["set", $xsb]);
     $cw->Advertise("xscrollbar" => $xsb); 
     $xsb->{'before'} = $w;
     $x = 'w';
    }
  }
 $cw->ConfigSpecs('-scrollbars' => ['METHOD','scrollbars','Scrollbars',$y.$x]);
}

sub scrollbars
{
 my ($cw,$opt) = @_;
 my $var = \$cw->{'-scrollbars'};
 if (@_ > 1)
  {
   my $old = $$var;
   if (!defined $old || $old ne $opt)
    {
     my $slice  = $cw->subwidget('ysbslice');
     my $xsb    = $cw->subwidget('xscrollbar');
     my $corner = $cw->subwidget('corner');
     my $xside = (($opt =~ /n/) ? 'top' : 'bottom');
     if (defined $slice)
      {
       if ($opt =~ /[we]/)
        {
         my $yside = (($opt =~ /w/) ? 'left' : 'right');  
         $slice->pack(-side => $yside, -fill => 'y',-before => $slice->{'before'});
        }
       else
        {
         $opt =~ s/[we]//;
         $slice->packforget;
        }
      }
     if (defined $xsb)
      {
       if ($opt =~ /[ns]/)
        {
         $xsb->pack(-side => $xside, -fill => 'x',-before => $xsb->{'before'});
        }
       else
        {
         $opt =~ s/[ns]//;
         $xsb->packforget;
        }
      }
     if (defined $corner)
      {
       if ($opt =~ /[ns]/ && $opt =~ /[we]/ && defined $corner->{'before'})
        {
         $corner->pack(-before => $corner->{'before'}, -side => $xside, -anchor => $opt,  -pady => 2, -fill => 'x');
        }
       else
        {
         $corner->packforget;
        }
      }
     $$var = $opt;
    }
  }
 return $$var;
}

sub FindMenu
{
 my ($w,$char) = @_;
 my $child;
 my $match;
 foreach $child ($w->children)
  {
   next unless (ref $child);
   $match = $child->FindMenu($char);
   return $match if (defined $match);
  }
 return undef;
}


