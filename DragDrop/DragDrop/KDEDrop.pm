package Tk::DragDrop::KDEDrop;
use strict;
use vars qw($VERSION);
$VERSION = '3.005'; # $Id: //depot/Tk8/DragDrop/DragDrop/KDEDrop.pm#5$
use base qw(Tk::DragDrop::Rect);

Tk::DragDrop->Type('KDE');

sub NewDrag
{
 my ($class,$token) = @_;  
 $token->{$class} = {};
}

sub new
{
 my ($class,$token,$id) = @_;
 return bless {id => $id, token =>$token},$class;
}


sub Drop
{
 my ($site,$token,$seln,$e) = @_;
 my $w   = $token->parent;
 my $string;
 Tk::catch { $string = $w->SelectionGet(-selection => $seln, -type => 'FILE_NAME') };
 if (!$@ && defined $string)
  {
   $w->property('set','DndSelection','STRING',8,"file:$string",'root');
   my $data = pack('LLLLL',128,0,0,$e->X,$e->Y);
   $w->SendClientMessage('DndProtocol',$site->{id},32,$data);
  } 
 else
  {
   warn $@ if $@;
  }
}    

sub FindSite
{
 my ($class,$token,$X,$Y) = @_;
 my $id = $token->PointToWindow($X,$Y);
 my $seen = 1;
 my $best;
 while ($id)
  {
   my @prop;
   Tk::catch { @prop = $token->property('get','KDE_DESKTOP_WINDOW', $id) };
   $seen = 1 if (!$@ && shift(@prop) eq 'KDE_DESKTOP_WINDOW');
   $best = $id if $seen;
   $id = $token->PointToWindow($X,$Y,$id)
  }
 if (defined $best)
  {
   my $hash = $token->{$class};
   my $site = $hash->{$best};
   if (!defined $site)
    {
     $site = $class->new($token,$best);
     $hash->{$best} = $site;
    }
   return $site;
  } 
 return undef;
}          

sub Enter
{
 my ($site,$token,$e) = @_;
}

sub Leave
{
 my ($site,$token,$e) = @_;
}

sub Motion
{
 my ($site,$token,$e) = @_;
}


1;
__END__
