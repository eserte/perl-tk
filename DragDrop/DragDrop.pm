package Tk::DragDrop;
require Tk::DragDrop::Common;
require Tk::Toplevel;
require Tk::Label;

use vars qw($VERSION @ISA);
$VERSION = '3.017'; # $Id: //depot/Tk8/DragDrop/DragDrop.pm#17$

use base  qw(Tk::DragDrop::Common Tk::Toplevel);

# This is a little tricky, ISA says 'Toplevel' but we 
# define a Tk_cmd to actually build a 'Label', then 
# use wmRelease in Populate to make it a toplevel. 

my $useWmRelease = 1; # ($^O ne 'MSWin32');

sub Tk_cmd { ($useWmRelease) ? \&Tk::label : \&Tk::toplevel }

Construct Tk::Widget 'DragDrop';

use strict;
use vars qw(%type @types);
use Carp;


sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Map>','Mapped');
 $mw->bind($class,'<Any-KeyPress>','Done');
 $mw->bind($class,'<Any-ButtonRelease>','Drop');
 $mw->bind($class,'<Any-Motion>','Drag');
 return $class;
}


sub Populate
{
 my ($token,$args) = @_;
 my $parent = $token->parent;
 if ($useWmRelease)
  {
   $token->wmRelease;
   $token->saveunder(1);     
   $token->ConfigSpecs(-text => ['SELF','text','Text',$parent->class]);
  }
 else
  {
   my $lab = $token->Label->pack(-expand => 1, -fill => 'both');
   bless $lab,ref($token);
   $lab->bindtags([ref($token), $lab, $token, 'all']);
   $token->ConfigSpecs(-text => [$lab,'text','Text',$parent->class],
                       DEFAULT => [$lab]);
  }
 $token->withdraw;
 $token->overrideredirect(1);
 $token->ConfigSpecs(-sitetypes       => ['METHOD','siteTypes','SiteTypes',undef],
                     -startcommand    => ['CALLBACK',undef,undef,undef],
                     -predropcommand  => ['CALLBACK',undef,undef,undef],
                     -postdropcommand => ['CALLBACK',undef,undef,undef],
                     -cursor          => ['SELF','cursor','Cursor','hand2'],
                     -handlers        => ['SETMETHOD','handlers','Handlers',[[[$token,'SendText']]]],  
                     -selection       => ['SETMETHOD','selection','Selection',"dnd_" . $parent->toplevel->name],  
                     -event           => ['SETMETHOD','event','Event','<B1-Motion>']
                    );
 $token->{InstallHandlers} = 0;
 $args->{-borderwidth} = 3;
 $args->{-relief} = 'flat';
 $args->{-takefocus} = 1;
}

sub sitetypes
{
 my ($w,$val) = @_;
 confess "Not a widget $w" unless (ref $w);
 my $var = \$w->{Configure}{'-sitetypes'};
 if (@_ > 1)
  {
   if (defined $val)
    {
     $val = [$val] unless (ref $val);
     my $type;
     foreach $type (@$val)
      {
       Tk::DragDrop->import($type);
      }
    }
   $$var = $val;
  }
 return (defined $$var) ? $$var : \@types;
}

sub SendText
{
 my ($w,$offset,$max) = @_;
 my $s = substr($w->cget('-text'),$offset);
 $s = substr($s,0,$max) if (length($s) > $max);
 return $s;
}

sub handlers
{
 my ($token,$opt,$value) = @_;
 $token->{InstallHandlers} = (defined($value) && @$value);
 $token->{'handlers'}  = $value;
}

sub selection
{
 my ($token,$opt,$value) = @_;
 my $handlers = $token->{'handlers'};
 $token->{InstallHandlers} = (defined($handlers) && @$handlers);
}

sub event
{
 my ($w,$opt,$value) = @_;
 # delete old bindings
 $w->parent->Tk::bind($value,[$w,'StartDrag']);
}

sub Mapped
{
 my ($token) = @_;
 my $e = $token->parent->XEvent;
 $token = $token->toplevel;
 $token->grabGlobal;
 $token->focus;
 if (defined $e)
  {
   my $X = $e->X;
   my $Y = $e->Y;
   $token->MoveToplevelWindow($X,$Y); 
   $token->NewDrag;
   $token->FindSite($X,$Y);
  }
}

sub FindSite
{
 my ($token,$X,$Y) = @_;
 my $types = $token->sitetypes;
 if (defined $types && @$types)
  {
   my $type;
   foreach $type (@$types)
    {
     my $site;
     my $class = $type{$type};
     if (defined $class)
      {
       foreach $site ($class->SiteList($token))
        {
         return $site if ($site->Over($X,$Y));
        }
      }
    }
  }
 else
  {
   warn "No sitetypes";
  }
 return undef;
}

sub NewDrag
{
 my ($token) = @_;
 my $types = $token->sitetypes;
 if (defined $types && @$types)
  {
   my $type;
   foreach $type (@$types)
    {
     my $class = $type{$type};
     if (defined $class)
      {
       $class->CheckSites($token);
      }
    }
  }
}

sub Drag
{
 my $token = shift;
 my $e = $token->XEvent;
 my $X  = $e->X;
 my $Y  = $e->Y;
 $token = $token->toplevel;
 my $site = $token->FindSite($X,$Y);
 my $over = $token->{'Over'};
 if ($over)
  {
   if (!defined($site) || !$over->Match($site))
    {
     $over->Leave($token,$e);
     $site->Enter($token,$e) if (defined $site);
    }
   else
    {
     $over->Motion($token,$e);
    }
  }
 elsif (defined $site)
  {
   $site->Enter($token,$e);
  }
 $token->MoveToplevelWindow($X,$Y);
}

sub Done
{
 my $token = shift;
 my $e     = $token->XEvent;
 $token    = $token->toplevel;
 my $over  = $token->{'Over'};
 $over->Leave($token,$e) if (defined $over);
 my $w     = $token->parent;
 eval {local $SIG{__DIE__}; $token->grabRelease };
 $token->withdraw;
 delete $w->{'Dragging'};
 $w->update;
}

sub HandleLoose
{
 my ($w,$seln) = @_;
 return "";
}

sub Drop
{
 my $ewin  = shift;
 my $e     = $ewin->XEvent;
 my $token = $ewin->toplevel;
 Done($ewin);
 my $site  = $token->FindSite($e->X,$e->Y);
 if (defined $site)
  {
   my $seln = $token->cget('-selection'); 
   unless ($token->Callback(-predropcommand => $seln, $site))
    {
     my $w = $token->parent;  
     if ($token->{InstallHandlers})
      {                       
       my $h;                 
       foreach $h (@{$token->cget('-handlers')})
        {                     
         $w->SelectionHandle('-selection' => $seln,@$h);
        }                     
       $token->{InstallHandlers} = 0;
      }                       
     if (!$w->IS($w->SelectionOwner('-selection'=>$seln)))              
      {                                                                 
       $w->SelectionOwn('-selection' => $seln, -command => [\&HandleLoose,$w,$seln]);
      }                                                                 
     $site->Drop($w,$seln,$e); 
     $token->Callback(-postdropcommand => $seln);
    }
  }
}

sub StartDrag
{
 my $token = shift;
 my $w     = $token->parent;
 unless ($w->{'Dragging'})
  {
   my $e = $w->XEvent;
   my $X = $e->X;
   my $Y = $e->Y;
   my $was = $token->{'XY'};
   if ($was)
    {
     if ($was->[0] != $X || $was->[1] != $Y)
      {
       unless ($token->Callback('-startcommand'))
        {
         delete $token->{'XY'};  
         $w->{'Dragging'} = $token;
         $token->MoveToplevelWindow($X,$Y);
         $token->raise;          
         $token->deiconify;      
         $token->FindSite($X,$Y);
        }
      }
    }
   else
    {
     $token->{'XY'} = [$X,$Y];
    }
  }
}


1;
