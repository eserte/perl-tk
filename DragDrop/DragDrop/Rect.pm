package Tk::DragDrop::Rect;
use Carp;

# Proxy class which represents sites to the dropping side

use vars qw($VERSION);
$VERSION = '4.004'; # $Id: //depot/Tkutf8/DragDrop/DragDrop/Rect.pm#5 $

sub Over
{
 my ($site,$X,$Y) = @_;
 my $x = $site->X;
 my $y = $site->Y;
 my $w = $site->width;
 my $h = $site->height;

 my $val = ($X >= $x && $X < ($x + $w) && $Y >= $y && $Y < ($y + $h));
 # print "Over ",$site->Show," $X,$Y => $val\n";
 return $val;
}

sub FindSite
{
 my ($class,$widget,$X,$Y) = @_;
 foreach my $site ($class->SiteList($widget))
  {
   return $site if ($site->Over($X,$Y));
  }
 return undef;
}

sub NewDrag
{
 my ($class,$widget) = @_;
}

sub Match
{
 my ($site,$other) = @_;
 return 0 unless (defined $other);
 return 1 if ($site == $other);
 return 0 unless (ref($site) eq ref($other));
 for ("$site")
  {
   if (/ARRAY/)
    {
     my $i;
     return 0 unless (@$site == @$other);
     for ($i = 0; $i < @$site; $i++)
      {
       return 0 unless ($site->[$i] == $other->[$i]);
      }
     return 1;
    }
   elsif (/SCALAR/)
    {
     return $site == $other;
    }
   elsif (/HASH/)
    {
     my $key;
     foreach $key (keys %$site)
      {
       return 0 unless exists $other->{$key};
       return 0 unless ($other->{$key} eq $site->{$key});
      }
     foreach $key (keys %$other)
      {
       return 0 unless exists $site->{$key};
       return 0 unless ($other->{$key} eq $site->{$key});
      }
     return 1;
    }
   return 0;
  }
 return 0;
}


1;
