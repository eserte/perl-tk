package Tk::DropSite;
require Tk::DragDrop::Common;
require Tk::DragDrop::Rect;

use vars qw($VERSION @ISA);
$VERSION = '3.004'; # $Id: //depot/Tk8/DragDrop/DropSite.pm#4$

@ISA = qw(Tk::DragDrop::Common Tk::DragDrop::Rect);

Construct Tk::Widget 'DropSite';

use strict;
use vars qw(%type @types);

Tk::DragDrop->Tk::DragDrop::Common::Type('Local');

my @toplevels;

BEGIN                  
{
 my $name;
 no strict 'refs';
 foreach $name (qw(x y X Y width height widget))
  {
   my $key = $name;
   *{"$key"} = sub { shift->{$key} };
  }
}

sub CheckSites
{
 my ($class,$token) = @_;
}

sub SiteList
{
 my ($class,$widget) = @_;
 my $t;
 my @list;
 foreach $t (@toplevels)
  {
   my $sites = $t->{'DropSites'};
   if ($sites)
    {
     $sites = $sites->{'Local'};
     push(@list,@{$sites}) if ($sites);
    }
  }
 return @list;
}

sub XY
{
 my ($site,$event) = @_;
 return ($event->X - $site->X,$event->Y - $site->Y);
}

sub Apply
{
 my $site = shift;
 my $name = shift;
 my $cb   = $site->{$name};
 if ($cb)
  {
   my $event = shift;
   $cb->Call(@_,$site->XY($event));
  }
}

sub Drop
{
 my ($site,$win,$seln,$event) = @_;
 $site->SUPER::Drop($win,$seln,$event);
 $site->Apply(-dropcommand => $event, $seln);
}

sub Enter
{
 my ($site,$token,$event) = @_;
 $site->SUPER::Enter($token,$event);
 $site->Apply(-entercommand => $event, 1);
}

sub Leave
{
 my ($site,$token,$event) = @_;
 $site->SUPER::Leave($token,$event);
 $site->Apply(-entercommand => $event, 0);
}

sub Motion
{
 my ($site,$token,$event) = @_;
 $site->SUPER::Motion($token,$event);
 $site->Apply(-motioncommand => $event);
}

sub NoteSites
{
 my ($class,$t,$sites) = @_;
 unless (grep($_ == $t,@toplevels))
  {
   $Tk::DragDrop::types{'Local'} = $class if (@$sites);
   push(@toplevels,$t);
   $t->OnDestroy(sub { @toplevels = grep($_ != $t,@toplevels) });
  }
}

sub UpdateDropSites
{
 my ($t) = @_;
 my $type;
 foreach $type (@types)
  {
   my $sites = $t->{'DropSites'}->{$type};
   if ($sites && @$sites)
    {
     my $class = $type{$type};
     $class->NoteSites($t,$sites);
    }
  }
}

sub QueueDropSiteUpdate
{
 my $obj = shift;
 my $class = ref($obj);
 my $t   = $obj->widget->toplevel;
 unless ($t->{'DropUpdate'})
  {
   $t->afterIdle(sub { UpdateDropSites($t) });
  }
}

sub delete
{
 my ($obj) = @_;
 my $w = $obj->widget;
 $w->bindtags([grep($_ ne $obj,$w->bindtags)]);
 my $t = $w->toplevel;
 my $type;
 foreach $type (@{$obj->{'-droptypes'}})
  {
   my $a = $t->{'DropSites'}->{$type};
   @$a    = grep($_ ne $obj,@$a);
  }
 $obj->QueueDropSiteUpdate;
}

sub DropSiteUpdate
{
 my $obj = shift;
 my $w   = $obj->widget;
 $obj->{'x'}      = $w->X;
 $obj->{'y'}      = $w->Y;
 $obj->{'X'}      = $w->rootx;
 $obj->{'Y'}      = $w->rooty;
 $obj->{'width'}  = $w->Width;
 $obj->{'height'} = $w->Height;
 $obj->QueueDropSiteUpdate;
}

sub TopSiteUpdate
{
 my ($t) = @_;
 my $type;
 foreach $type (@types)
  {
   my $sites = $t->{'DropSites'}->{$type};
   if ($sites && @$sites)
    {
     my $site;
     foreach $site (@$sites)
      {
       $site->DropSiteUpdate;
      }
    }
  }
}

sub Callback
{
 my $obj = shift;
 my $key = shift;
 my $cb  = $obj->{$key};
 $cb->Call(@_) if (defined $cb);
}

sub InitSite
{
 my ($class,$site) = @_;
 # Tk::DragDrop->Type('Local');
}

sub new
{
 my ($class,$w,%args) = @_;
 my $t = $w->toplevel;
 $args{'widget'} = $w;
 if (exists $args{'-droptypes'})
  {
   $args{'-droptypes'} = [$args{'-droptypes'}] unless (ref $args{'-droptypes'});
  }
 else
  {
   $args{'-droptypes'} = \@types; 
  }
 my ($key,$val);
 while (($key,$val) = each %args)
  {
   if ($key =~ /command$/)
    {
     $val = Tk::Callback->new($val);
    }
  }
 my $obj = bless \%args,$class;
 unless (exists $t->{'DropSites'})
  {
   $t->{'DropSites'} = {}; 
   $t->{'DropUpdate'} = 0; 
  }
 my $type;
 foreach $type (@{$args{'-droptypes'}})
  {
   Tk::DropSite->import($type) unless (exists $type{$type});
   my $class = $type{$type};
   $class->InitSite($obj);
   unless (exists $t->{'DropSites'}->{$type})
    {
     $t->{'DropSites'}->{$type}  = [];
    }
   push(@{$t->{'DropSites'}->{$type}},$obj);
  }
 $w->OnDestroy([$obj,'delete']);
 $obj->DropSiteUpdate;
 $w->bindtags([$w->bindtags,$obj]);
 $w->Tk::bind($obj,'<Configure>',[$obj,'DropSiteUpdate']);
 $t->Tk::bind($class,'<Configure>',[\&TopSiteUpdate,$t]);
 unless (grep($_ eq $class,$t->bindtags))
  {
   $t->bindtags([$t->bindtags,$class]);
  }
 return $obj;
}

1;
