package Tk::DragDrop::SunDrop;
require  Tk::DragDrop::Rect;

use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/DragDrop/DragDrop/SunDrop.pm#5$

@ISA = qw(Tk::DragDrop::Rect);
use strict;
use Tk::DragDrop::SunConst;

Tk::DragDrop->Type('Sun');

BEGIN 
 {
  my @fields = qw(name win X Y width height flags);
  my $i = 0;
  no strict 'refs';
  for ($i=0; $i < @fields; $i++)
   {
    my $j    = $i;
    *{"$fields[$i]"} = sub { shift->[$j] };
   }
 }

sub Preview
{
 my ($site,$token,$e,$kind,$flags) = (@_);
 $token->BackTrace("No flags") unless defined $flags;
 my $sflags = $site->flags;
 return if ($kind == _motion && !($sflags & &MOTION));
 return if ($kind != _motion && !($sflags & &ENTERLEAVE));
 my $data = pack('LLSSLL',$kind,$e->t,$e->X,$e->Y,$site->name,$flags);
 $token->SendClientMessage('_SUN_DRAGDROP_PREVIEW',$site->win,32,$data);
}

sub Enter  
{
 my ($site,$token,$e) = @_;
 $site->SUPER::Enter($token,$e);
 $site->Preview($token,$e,_enter,0);
}

sub Leave  
{
 my ($site,$token,$e) = @_;
 $site->SUPER::Leave($token,$e);
 $site->Preview($token,$e,_leave,0);
}

sub Motion 
{
 my ($site,$token,$e) = @_;
 $site->SUPER::Motion($token,$e);
 $site->Preview($token,$e,_motion,0);
}

sub HandleDone
{
 my ($w,$seln,$offset,$max) = @_;
 $w->SelectionClear('-selection',$seln);
 return "";
}

sub HandleAck
{
 my ($w,$seln,$offset,$max) = @_;
 return "";
}

sub Drop
{
 my ($site,$w,$seln,$e) = @_;
 $site->SUPER::Drop($w,$seln,$e);
 $w->SelectionHandle('-selection'=>$seln,'-type'=>'_SUN_DRAGDROP_ACK',[\&HandleAck,$w,$seln]);
 $w->SelectionHandle('-selection'=>$seln,'-type'=>'_SUN_DRAGDROP_DONE',[\&HandleDone,$w,$seln]);
 my $atom  = $w->InternAtom($seln);                                 
 my $flags = &ACK_FLAG | &TRANSIENT_FLAG;                           
 my $data  = pack('LLSSLL',$atom,$e->t,$e->X,$e->Y,$site->name,$flags);
 $w->SendClientMessage('_SUN_DRAGDROP_TRIGGER',$site->win,32,$data);
}

sub CheckSites
{
 my ($class,$token) = @_;
 delete $token->{'SunDD'};
}

sub SiteList
{
 my ($class,$token) = @_;
 unless (exists $token->{'SunDD'})
  {
   my @data  = ();
   my @sites = ();
   eval {local $SIG{__DIE__}; @data = $token->SelectionGet( '-selection'=>"_SUN_DRAGDROP_DSDM",  "_SUN_DRAGDROP_SITE_RECTS") } ;
   if ($@)
    {
     $token->configure('-cursor'=>'hand2');
     $token->grab(-global);
    }
   else
    {
     while (@data)
      {
       my $version = shift(@data);
       if ($version != 0)          
        {                          
         warn "Unexpected site version $version";
         last;
        }                          
       push(@sites,bless [splice(@data,0,7)],$class);
      }
    }
   $token->{'SunDD'} = \@sites; 
  }
 return @{$token->{'SunDD'}};
}

1;
__END__
