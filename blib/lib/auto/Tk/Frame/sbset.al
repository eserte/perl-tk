# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 183 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/sbset.al)"
sub sbset
{
 my ($cw,$sb,$ref,@args) = @_;
 $sb->set(@args);
 # print "sbset $cw ",$sb->cget('-orient')," p=$$ref need=",$sb->Needed," (",join(',',@args),")\n";
 $cw->queuePack if (@args == 2 && $sb->Needed != $$ref);
}

# end of Tk::Frame::sbset
1;
