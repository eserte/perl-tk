# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub SendIt
{
 my $w  = shift;
 my $fh = $w->{'FH'};
 my $pend = $w->{'Pending'};
 while (@$pend)
  {
   my $line = shift(@$pend);           
   my $len  = length($line);           
   my $done = syswrite($fh,$line,$len);
   $done = 0 unless (defined $done);
   if ($done < $len)
    {
     unshift(@{$pend},substr($line,$done));
     last;
    }
  }
 if (exists $w->{'mwin'})
  {
   $w->SendClientMessage('NEXT',$w->{'mwin'},8,"");
   delete $w->{'mwin'};
  }
 $w->fileevent($fh,'writable',"") unless (@$pend);
}

1;
