package Tk::IO;
require Tk;
require DynaLoader;
@Tk::IO::ISA = qw(DynaLoader);

bootstrap Tk::IO;

%open  = ();

sub new
{
 my $package = shift;
 my $fh  = caller() . "::" . shift;
 return bless \$fh;
}

sub open
{
 my $package = shift;
 my $fh;
 my $count = 0;
 do { $fh = $package . "::F" . $count++ } while (defined $open{$fh});
 if (open($fh,shift))
  {
   return bless $open{$fh} = \$fh;
  }
 warn "Cannot open $fh:$!";
 return undef;
}

sub preadline
{
 my $fh  = shift;
 my $var = "";
 my $offset = 0; 
# print "readline\n";
 until (index($var,"\n") >= 0)
  {
   my $count = $fh->read($var,1,$offset);
   last unless (defined $count && $count > 0);
   $offset += $count;
  }
 return $var;
}

sub close
{
 my $fh = shift;
 if (defined $open{$$fh})
  {
   my $code = close($$fh);
   $open{$$fh} = undef;
   return $code;
  }
 return 1;
}

sub DESTROY
{  
 my $fh = shift;
 if (defined $open{$$fh})
  {
   warn "Cannot close $$fh" unless $fh->close;
  }
}

1;
