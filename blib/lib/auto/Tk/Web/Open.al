# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub Open
{
 my ($w) = @_;
 unless (exists $w->{'Open'})
  {
   my $t = $w->toplevel;
   my $o = $w->toplevel->Toplevel(-popover => $w, -popanchor => 'n', -overanchor => 'n');
   $o->withdraw;
   $o->transient($t);
   $o->protocol(WM_DELETE_WINDOW => [withdraw => $o]);
   $w->{'Open'} = $o;
   $o->{'url'}  = $w->url;
   my $e = $o->LabEntry(-label => 'Location :',-labelPack => [ -side => 'left'],
                -textvariable => \$o->{'url'}, -width => length($o->{'url'}))->pack(-fill => 'x');
   my $b = $o->Button(-text => 'Open', 
                      -command =>  sub {  $o->withdraw ; $w->HREF('GET',$o->{'url'}) } 
                     )->pack(-side => 'left',-anchor => 'w', -fill => 'x');
   $e->bind('<Return>',[$b => 'invoke']); 
   $o->Button(-text => 'Clear', -command => sub { $o->{'url'} = "" })->pack(-side => 'left',-anchor => 'c', -fill => 'x');
   $o->Button(-text => 'Current', -command => sub { $o->{'url'} = $w->url })->pack(-side => 'left',-anchor => 'c', -fill => 'x');
   $o->Button(-text => 'Cancel', -command => [ withdraw => $o ])->pack(-side => 'right',-anchor => 'e',-fill => 'x');
   $e->focus;
  }
 my $o = $w->{'Open'};
 $o->{'url'}  = $w->url;
 $o->Popup;
}

1;
