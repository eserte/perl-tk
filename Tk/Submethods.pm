package Tk::Submethods;

sub import
{
 my $class = shift;
 no strict 'refs';
 my $package = caller(0);
 while (@_)
  {
   my $fn = shift;
   my $sm = shift;
   my $sub;
   foreach $sub (@{$sm})
    {
     my ($suffix) = $sub =~ /(\w+)$/;
     *{$package.'::'."$fn\u$suffix"} = sub { shift->$fn($sub,@_) };
    }
  }
}

sub Direct
{
 my $class = shift;
 no strict 'refs';
 my $package = caller(0);
 while (@_)
  {
   my $fn = shift;
   my $sm = shift;
   my $sub;
   foreach $sub (@{$sm})
    {
     *{$package.'::'.$sub} = sub { shift->$fn($sub,@_) };
    }
  }
}

1;

__END__

=head1 NAME

Tk::Submethods - add aliases for tk sub-commands

=head1 SYNOPSIS

  use Tk::Submethods ( 'command1' => [qw(sub1 sub2 sub3)],
                       'command2' => [qw(sub1 sub2 sub3)]);  


=head1 DESCRIPTION

Creates C<-E<gt>commandSub(...)> as an alias for C<-E<gt>command('sub',...)>
e.g. C<-E<gt>grabRelease> for C<-E<gt>grab('release')>.

For each command/subcommand pair this creates a closure with command
and subcommand as bound lexical variables and assigns a reference to this
to a 'glob' in the callers package.

Someday the sub-commands may be created directly in the C code.

=cut
