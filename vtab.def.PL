#!perl -w 
use strict;
my $file = __FILE__;
$file =~ s/\.PL$//;
chmod(0666,$file) unless -w $file;
rename($file,"$file.old") unless -w $file;
open(F,">$file") || die "Cannot open $file:$!";
select(F);
my @vtable = qw(Tkoption Lang Tkevent Tk Tkint Tkglue Tkintdecls Tkdecls Tcldecls);
my @wtable = qw(Tkintxlibdecls Tkplatdecls Tkintplatdecls);
my @utable = qw(Xlib);

my $maxl = 0;
length > $maxl and $maxl = length foreach (@vtable,@wtable,@utable);

print "#ifdef WIN32\n";
do_tables(@vtable,@wtable);
print "#else\n";
do_tables(@vtable,@utable);
print "#endif\n";

sub do_tables
{
 my @tables = sort(@_);
 print "#define DECLARE_VTABLES\t\\\n";
 while (@tables)
  {
   my $tab = shift(@tables);
   my $pad = ' ' x ($maxl - length($tab));
   print $tab,"Vtab$pad *",$tab,"Vptr";
   print ";$pad\\" if @tables;
   print "\n"; 
  } 
 print "\n"; 
 print "#define IMPORT_VTABLES\tdo { \\\n";
 foreach my $tab (sort @_)
  {
   my $pad = ' ' x ($maxl - length($tab));
   print qq/${tab}Vptr$pad = $pad(${tab}Vtab *) SvIV(perl_get_sv("Tk::${tab}Vtab",GV_ADDWARN|GV_ADD));$pad \\\n/;
  } 
 print "} while (0)\n"; 
}
