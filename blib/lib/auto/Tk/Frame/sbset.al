# NOTE: Derived from ./blib/lib/Tk/Frame.pm.  Changes made here will be lost.
package Tk::Frame;

sub sbset
{
 my ($cw,$sb,$ref,@args) = @_;
 $sb->set(@args);
 # print "sbset $cw ",$sb->cget('-orient')," p=$$ref need=",$sb->Needed," (",join(',',@args),")\n";
 $cw->queuePack if (@args == 2 && $sb->Needed != $$ref);
}

1;
