package Tk::DragDrop::SunSite;
require Tk::DropSite;
use Tk::DragDrop::SunConst;
@ISA = qw(Tk::DropSite);
use strict;

Tk::DropSite->Type('Sun');

sub SunDrop
{
 my ($w,$site) = @_;
 my $e = $w->XEvent;
 my ($atom,$t,$x,$y,$id,$flags) = unpack('LLSSLL',$e->A);
 $x -= $site->X;
 $y -= $site->Y;
 my $seln = $w->GetAtomName($atom);
 if ($flags & &ACK_FLAG)
  {
   eval {local $SIG{__DIE__}; $w->SelectionGet('-selection'=>$seln,"_SUN_DRAGDROP_ACK");};
  }
 $site->Callback(-dropcommand => $seln, $x, $y);
 if ($flags & &TRANSIENT_FLAG)
  {
   eval {local $SIG{__DIE__};  $w->SelectionGet('-selection'=>$seln,"_SUN_DRAGDROP_DONE");};
  }
 $w->configure('-relief' => $w->{'_DND_RELIEF_'}) if (defined $w->{'_DND_RELIEF_'})
}

sub SunPreview
{
 my ($w,$site) = @_;
 my $event = $w->XEvent;
 my ($kind,$t,$x,$y,$id,$flags) = unpack('LLSSLL',$event->A);
 $x -= $site->X;
 $y -= $site->Y;
 if ($kind == _enter)
  {
   $site->Callback(-entercommand => 1, $x, $y);
  }
 elsif ($kind == _leave)
  {
   $site->Callback(-entercommand => 0, $x, $y);
  }
 elsif ($kind == _motion)
  {
   $site->Callback(-motioncommand => $x, $y);
  }
}

sub InitSite
{
 my ($class,$site) = @_;
 my $w = $site->widget;
 $w->BindClientMessage('_SUN_DRAGDROP_TRIGGER',[\&SunDrop,$site]);
 $w->BindClientMessage('_SUN_DRAGDROP_PREVIEW',[\&SunPreview,$site]);
}

sub NoteSites
{
 my ($class,$t,$sites) = @_;
 my $count = @$sites;
 if ($count)
  {
   my @data  = (0,$count);
   my $s;             
   my $i = 0;         
   foreach $s (@$sites)
    {                 
     my $w = $s->widget;
     $w->MakeWindowExist;
     push(@data,${$w->WindowId});                   # XID
     push(@data,$i++);                              # Our "tag"
     push(@data,&ENTERLEAVE|&MOTION);               # Flags
     push(@data,0);                                 # Kind is "rect"
     push(@data,1);                                 # Number of rects
     push(@data,$s->x,$s->y,$s->width,$s->height);  # The rect
    }                 
   $t->property('set',
                "_SUN_DRAGDROP_INTEREST",           # name
                "_SUN_DRAGDROP_INTEREST",           # type
                32,                                 # format 
                \@data);                            # the data 
  }
 else
  {
   $t->property('delete',"_SUN_DRAGDROP_INTEREST");
  }
}


1;
