# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub Postscript
{
 my $w  = shift;
 $w->StartInterp unless(exists $w->{'pid'});
 if (exists $w->{'mwin'})
  {
   $w->SendClientMessage('NEXT',$w->{'mwin'},8,"");
   delete $w->{'mwin'};
  }
 my $fh = $w->{'FH'};
 my $pend = $w->{'Pending'};
 unless (@$pend)
  {
   $w->fileevent($fh,'writable',['SendIt',$w]);
  }
 push(@$pend,@_);
}

1;
