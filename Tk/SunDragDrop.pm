package Tk::SUNDND;

# Site flags
sub ENTERLEAVE     {1<<0}
sub MOTION         {1<<1}
sub DEFAULT_SITE   {1<<2}

# Trigger flags
sub MOVE_FLAG      {1<<0}
sub ACK_FLAG       {1<<1}
sub TRANSIENT_FLAG {1<<2}
sub FORWARDED_FLAG {1<<3}

# Preview Types
sub Enter  {7}
sub Leave  {8}
sub Motion {6}


package Tk::DragToken;
@Tk::DragToken::ISA = qw(Tk::Toplevel);
Tk::Widget->Construct('DragToken');

use Carp;

sub ClassInit
{
 my ($class,$mw) = shift;
 return $class;
}

sub Populate
{
 my ($token,$args) = @_;
 my $parent = $token->parent;
 my $e = $parent->XEvent;
 $token->overrideredirect(1);
 $token->saveunder(1);     
 $token->MoveWindow($e->X,$e->Y) if (defined $e);

 $token->{'Owner'} = $parent;
 $token->bind('<Any-ButtonRelease>','Tk::DragToken::Drop');
 $token->bind('<Any-Motion>','Tk::DragToken::Drag');
 $parent->{'DragToken'} = $token;
 $args->{-cursor} = 'watch';
 $args->{-borderwidth} = 3;
 $args->{-relief} = 'flat';
}

sub Done
{
 my $token = shift;
 my $w     = $token->{'Owner'};
 $w->update;
}

sub Post
{
 my ($token,$X,$Y) = @_;
 $token->idletasks;
 $token->MoveWindow($X,$Y) if (defined $X && defined $Y);
 $token->grab();
 $token->update;
 
 my @sites = ();
 eval { @sites = $token->SelectionGet( '-selection'=>"_SUN_DRAGDROP_DSDM", 
                                   "_SUN_DRAGDROP_SITE_RECTS") } ;
 if ($@)
  {
   my $msg = "$@";
   my $w = $token->{'Owner'};
   $token->grab('release');
   delete $w->{'DragToken'};
   $token->destroy;
   croak($msg);
  }
 else
  {
   $token->configure('-cursor'=>'hand2');
   $token->grab(-global);
  }
 $token->{'Sites'} = \@sites;
}

sub Preview
{
 my ($token,$e,$site,$kind,$flags) = (@_);
 croak "No flags" unless defined $flags;
 if (defined $site)
  {
   $token->{'Over'} = $site;
   $token->configure(-relief => 'sunken');
   return if ($kind == &Tk::SUNDND::Motion && !($$site[2] & &Tk::SUNDND::MOTION));
   return if ($kind != &Tk::SUNDND::Motion && !($$site[2] & &Tk::SUNDND::ENTERLEAVE));
   my $data = pack('LLSSLL',$kind,$e->t,$e->X,$e->Y,$$site[1],$flags);
   $token->SendClientMessage('_SUN_DRAGDROP_PREVIEW',$$site[0],32,$data);
  }
 else
  {
   $token->configure(-relief => 'raised');
   delete($token->{'Over'});
  }
}

sub Site
{
 my ($token,$X,$Y) = @_;
 my $sites = $token->{'Sites'};
 return undef unless (defined $sites);
 my @sites = @$sites;
 while (@sites)
  {
   my $version = shift(@sites);
   if ($version != 0)
    {
     warn "Unexpected site version $version";
     return undef;
    }
   my $site    = shift(@sites);
   my $win     = shift(@sites);
   my $x       = shift(@sites);
   my $y       = shift(@sites);
   my $width   = shift(@sites);
   my $height  = shift(@sites);
   my $flags   = shift(@sites);
   if ($X >= $x && $X < ($x + $width) &&
       $Y >= $y && $Y < ($y + $height))
    {
     return [$win,$site,$flags];
    }
  }
 return undef;
}

sub Drag
{
  my $token = shift;
  my $e = $token->XEvent;
  my $X = $e->X;
  my $Y = $e->Y;
  $token = $token->toplevel;
  if (defined $token->{'Sites'})
   {
    my $site = $token->Site($X,$Y);
    if (defined $token->{'Over'})
     {
      if (!defined($site) || 
          $token->{'Over'}[0] != $$site[0] ||
          $token->{'Over'}[1] != $$site[1])
       {
        $token->Preview($e,$token->{'Over'},&Tk::SUNDND::Leave,0); 
        $token->Preview($e,$site,&Tk::SUNDND::Enter,0); 
       }
      else
       {
        $token->Preview($e,$site,&Tk::SUNDND::Motion,0); 
       }
     }
    else
     {
      $token->Preview($e,$site,&Tk::SUNDND::Enter,0); 
     }
   }
  $token->MoveWindow($X,$Y);
}

sub Drop
{
 my $token = shift;
 my $e     = $token->XEvent;
 $token = $token->toplevel;
 eval { $token->grab('release') };
 if (defined $token->{'Sites'})
  {
   my $w     = $token->{'Owner'};
   my $seln = $w->{'DragDrop'};
   my $site = $token->Site($e->X,$e->Y);
   $token->Preview($e,$token->{'Over'},&Tk::SUNDND::Leave,0); 
   if (defined $site && defined $seln)
    {              
     my $atom  = $w->InternAtom($seln);
     my $flags = &Tk::SUNDND::ACK_FLAG | &Tk::SUNDND::TRANSIENT_FLAG;
     my $data  = pack('LLSSLL',$atom,$e->t,$e->X,$e->Y,$$site[1],$flags);
     if (!$w->IS($w->SelectionOwner('-selection'=>$seln)))
      {            
       $w->SelectionOwn('-selection'=>$seln,'-command'=>['HandleLoose',$w,$seln]);
      }            
     $w->SendClientMessage('_SUN_DRAGDROP_TRIGGER',$$site[0],32,$data);
    }              
   delete($w->{'DragToken'});
   $token->destroy;
  }
 else
  {
   $token->DoWhenIdle(['Drop',$token]);
  }
}


# Put things into widget base class so that any widget can 
# be made a drop site.
package Tk::Widget;  

# use strict qw(subs); # seems to segfault when used in secondary file
# use Carp;


$DropSiteUpdatePending = 0;

sub DragDrop
{
 my $w = shift;
 my $token = $w->{'DragToken'};
 if (!defined $token)
  {
   my $e = $w->XEvent;
   my $X = $e->X;
   my $Y = $e->Y;
   my $t = $w->containing($X,$Y);
   if (!defined($t) || $t != $w)
    {
     $token = $w->DragToken();
     $token->Label('-text' => $w->class, @_)->pack;
     $token->Post($X,$Y);
    }
  }
}

sub HandleAck
{
 my ($w,$seln,$offset,$max) = @_;
 return "";
}

sub HandleDone
{
 my ($w,$seln,$offset,$max) = @_;
 $w->SelectionClear('-selection',$seln);
 return "";
}

sub HandleLoose
{
 my ($w,$seln) = @_;
 return "";
}

sub DragDropSource
{
 my $w     = shift;
 my $seln  = (@_) ? shift : undef;
 if (!defined $seln)
  {
   $seln = "dnd_" . $w->toplevel->name;
  }
 $w->SelectionHandle('-selection'=>$seln,'-type'=>'_SUN_DRAGDROP_ACK',['HandleAck',$w,$seln]);
 $w->SelectionHandle('-selection'=>$seln,'-type'=>'_SUN_DRAGDROP_DONE',['HandleDone',$w,$seln]);
 $w->{'DragDrop'} = $seln;
 return $seln;
}

sub UpdateDropSites
{
 my $t = shift;
 my $sites = $t->{'DropSites'};
 my $count = @$sites;
 if ($count)
  {
   my @data  = (0,$count);
   my $w;             
   my $i = 0;         
   foreach $w (@$sites)
    {                 
     push(@data,${$w->WindowId});                   # XID
     push(@data,$i++);                              # Our "tag"
     push(@data,&Tk::SUNDND::ENTERLEAVE|&Tk::SUNDND::MOTION); # Flags
     push(@data,0);                                 # Kind is "rect"
     push(@data,1);                                 # Number of rects
     push(@data,$w->X,$w->Y,$w->Width,$w->Height);  # The rect
#    printf("Site %x\n",${$w->WindowId});
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
 $DropSiteUpdatePending = 0;
}

sub QueueDropSiteUpdate
{
 unless (!$DropSiteUpdatePending++)
  {
   my $w = shift;                                                        
   my $t = $w->toplevel;                                                 
   $t->DoWhenIdle(['UpdateDropSites',$t]);
  }
}

sub AcceptDrop
{
 my $w = shift;
 my $t = $w->toplevel;
 my $sites = $t->{'DropSites'};
 my $cb = Tk::Callback->new([@_]);
 unless (defined $sites)
  {
   $t->{'DropSites'} = $sites = [];
  }
 if (!grep($_ == $w,@$sites))
  {
   $w->MakeWindowExist;
   push(@$sites,$w);
   $w->QueueDropSiteUpdate;
   $w->bind('<Configure>','QueueDropSiteUpdate');
   $w->BindClientMessage('_SUN_DRAGDROP_TRIGGER',['SunDrop',$cb]);
   $w->BindClientMessage('_SUN_DRAGDROP_PREVIEW','SunPreview');
  }
}

sub SunDrop
{
 my $w = shift;
 my $cb = shift;
 my $e = $w->XEvent;
 my ($atom,$t,$x,$y,$id,$flags) = unpack('LLSSLL',$e->A);
 my $seln = $w->GetAtomName($atom);
 if ($flags & &Tk::SUNDND::ACK_FLAG)
  {
   eval { $w->SelectionGet('-selection'=>$seln,"_SUN_DRAGDROP_ACK");};
  }
 $cb->Call($seln) if (defined $cb && ref $cb);
 if ($flags & &Tk::SUNDND::TRANSIENT_FLAG)
  {
   eval { $w->SelectionGet('-selection'=>$seln,"_SUN_DRAGDROP_DONE");};
  }
 $w->configure('-relief' => $w->{'_DND_RELIEF_'}) if (defined $w->{'_DND_RELIEF_'})
}

sub SunPreview
{
 my $w = shift;
 my $e = $w->XEvent;
 my ($kind,$t,$x,$y,$id,$flags) = unpack('LLSSLL',$e->A);
 if ($kind == &Tk::SUNDND::Enter)
  {
   # enter
   $w->{'_DND_RELIEF_'} = eval{ $w->cget('-relief') };
   if (defined $w->{'_DND_RELIEF_'})
    {
     $w->configure('-relief' => 'sunken');
    }
  }
 elsif ($kind == &Tk::SUNDND::Leave)
  {
   # leave
   $w->configure('-relief' => $w->{'_DND_RELIEF_'}) if (defined $w->{'_DND_RELIEF_'})
  }
 elsif ($kind == &Tk::SUNDND::Motion)
  {
   # motion 
  }
}

1;
