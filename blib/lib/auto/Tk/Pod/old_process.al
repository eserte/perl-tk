# NOTE: Derived from .././blib/lib/Tk/Pod.pm.  Changes made here will be lost.
package Tk::Pod;

sub old_process
{
 my ($w,$file) = @_;
 open($file,"<$file") || die "Cannot open $file:$!";
 $w->filename($file);
 $/ = "";  
 my $cutting = 1;
 while (<$file>)
  {
   if ($cutting)
    {
     next unless /^=/;
     $cutting = 0;
    }
   chomp;
   if (/^\s/)
    {
     $w->verbatim($_);
    }
   elsif (/^=/)
    {
     my ($cmd,$num,$title) = /^=([a-z]+)(\d*)\s*([^\0]*)$/ ;
     die "$_" unless (defined $cmd);
     if ($cmd eq 'cut')
      {
       $cutting = 1;
      }
     else
      {
       $w->$cmd($title,$num);
      }
    }
   else
    {
     $w->text($_);
    }
  }
 close($file);
}

1;
