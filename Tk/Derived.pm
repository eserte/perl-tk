package Tk::Derived;
require Tk::Widget;
require Tk::Configure;
use Carp;

sub Subwidget 
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

sub Subconfigure
{
 # This finds the widget or widgets to to which to apply a particular 
 # configure option

 my ($cw,$opt) = @_;
 my $config = $cw->ConfigSpecs;
 my $widget;
 my @subwidget = ();
 my (@arg) = ();
 push(@arg,$opt) unless ($opt eq DEFAULT);
 if (defined $opt)
  {
   $widget = $config->{$opt};
   unless (defined $widget)
    {
     $widget = ($opt =~ /^-(.*)$/) ? $config->{$1} : $config->{-$opt};
    }
  }
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
     $widget = Tk::Configure->new(@$widget) if (ref($widget) eq 'ARRAY');
     push(@subwidget,$widget)
    }
   elsif ($widget eq 'ADVERTISED')
    {
     push(@subwidget,$cw->Subwidget)
    }
   elsif ($widget eq 'DESCENDANTS')
    {
     push(@subwidget,$cw->Descendants) 
    }
   elsif ($widget eq 'CHILDREN')
    {
     push(@subwidget,$cw->children) 
    }
   elsif ($widget eq 'METHOD')
    {
     my ($method) = ($opt =~ /^-?(.*)$/);
     push(@subwidget,Tk::Configure->new($method,$method,$cw))
    }
   elsif ($widget eq 'SELF')
    {
     push(@subwidget,Tk::Configure->new('Tk::configure', 'Tk::cget', $cw,@arg))
    }
   elsif ($widget eq 'PASSIVE') 
    {
     push(@subwidget,Tk::Configure->new('_configure','_cget',$cw,@arg))
    }
   elsif ($widget eq 'CALLBACK') 
    {
     push(@subwidget,Tk::Configure->new('_callback','_cget',$cw,@arg))
    }
   else
    {
     push(@subwidget,$cw->Subwidget($widget));
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
# croak "Invalid option $opt" unless ($opt =~ /^-/);
 my (@subwidget) = $cw->Subconfigure($opt);
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
     my $sw = $cw->Subconfigure(@_);
     @results = $sw->configure(@_);
    }
   else
    {
     my $spec = $cw->ConfigSpecs;
     my $opt;
     foreach $opt (keys %$spec)
      {
       my $sw = $cw->Subconfigure($opt);
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
     foreach $subwidget ($cw->Subconfigure($opt))
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
 $specs->{'-bg'} = [\@bg,undef,undef,undef] unless (exists($specs->{'-bg'}) || exists($specs->{'-background'}));

 my (@fg) = ('PASSIVE');
 unshift(@fg,'CHILDREN') if $children;
 $specs->{'-fg'} = [\@fg,undef,undef,undef] unless (exists($specs->{'-fg'}) || exists($specs->{'-foreground'}));
 $cw->ConfigAlias(-fg => '-foreground', -bg => '-background');
  

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
         my $db = $cw->optionGet($info[1],$info[2]);
         $args->{$opt} = $db if (defined $db);
        }
      }
    }
  }
 # Should we enforce a Delagates(DEFAULT => )  as well ?
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

sub ConfigAlias
{
 my ($cw,%args) = @_;
 my $specs = $cw->ConfigSpecs;
 my $opt;
 foreach $opt (keys %args)
  {
   my $main = $args{$opt};
   if (exists $specs->{$opt})
    {
     $specs->{$main} = $specs->{$opt};
    }
   elsif (exists $specs->{$main})
    {
     $specs->{$opt} = $specs->{$main};
    }
   else 
    {
     croak "Neither $opt nor $main exist";
    }
  }
}

sub Delegate
{
 my ($cw,$method,@args) = @_;
 my $widget = $cw->DelegateFor($method);
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

sub Populate
{
 my ($cw,$args) = @_;
}

sub InitObject
{
 my ($cw,$args) = @_;
 $cw->{Configure} = {};
 $cw->Populate($args);    
 $cw->ConfigDefault($args);
}

sub ConfigChanged
{
 my ($cw,$args);
}       

1;
