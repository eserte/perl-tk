# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub StopInterp
{
 my $w = shift;
 if (exists $w->{'pid'})
  {
   my $fh = $w->{'FH'};
   kill('TERM',$w->{'pid'});
   delete $w->{'pid'};
   $w->fileevent($fh,'writable',"");
   close($fh);
   delete $w->{'Pending'};
  }
 delete $w->{'mwin'};
}

1;
