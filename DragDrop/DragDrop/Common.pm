package Tk::DragDrop::Common;

use strict;
use Carp;


use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/DragDrop/DragDrop/Common.pm#3$

sub Type
{
 my ($base,$name,$class) = @_;
 no strict 'refs';
 my $hash  = \%{"${base}::type"};
 my $array = \@{"${base}::types"};
 unless (exists $hash->{$name})
  {
   push(@$array,$name);
   $class = (caller(0))[0] unless (@_ > 2); 
   $hash->{$name} = $class;
   # confess "Strange class $class for $base/$name" unless ($class =~ /^Tk/);
   # print "$base $name is ",$class,"\n";
  }
}

sub import
{
 my $class = shift;
 no strict 'refs';
 my $types = \%{"${class}::type"};
 while (@_)
  {
   my $type = shift;
   unless (exists $types->{$type})
    {
     if ($type eq 'Local')
      {
       $class->Type($type,$class);
      }
     else
      {
       my ($kind) = $class =~ /([A-Z][a-z]+)$/;
       # print "$type $class is kind of '$kind'\n";
       my $file = Tk->findINC("DragDrop/${type}${kind}.pm");
       if (defined $file)
        {
         # print "Loading $file\n"; 
         require $file; 
        }
       else
        {
         croak "Cannot find ${type}${kind}";
        }
      }
    }
  }
}

1;
__END__

=head1 NAME

Tk::DragDrop::Common - private class used by Drag&Drop

=head1 DESCRIPTION

This class provides methods to automate the the loading and declaring 
of Drop and Site 'types'.



