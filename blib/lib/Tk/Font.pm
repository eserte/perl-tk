package Tk::Font;
use vars qw($VERSION);
$VERSION = '2.010'; # $Id: //depot/Tk/Tk/Font.pm#10$

=head1 NAME

Tk::Font - a class for finding X Fonts

=head1 SYNOPSIS

 use Tk::Font;

 $font = $widget->Font(foundry => 'adobe',
                       family  => 'times',
                       point   => 120
                      );

 $font = $widget->Font('*-courier-medium-r-normal-*-*');

=head1 DESCRIPTION

   This module can be use to interrogate the X server what fonts are
   avaliable.

=head1 METHODS

=head2 Foundry( [ $val ] )

=head2 Family( [ $val ] )

=head2 Weight( [ $val ] )

=head2 Slant( [ $val ] )

=head2 Swidth( [ $val ] )

=head2 Adstyle( [ $val ] )

=head2 Pixel( [ $val ] )

=head2 Point( [ $val ] )

=head2 Xres( [ $val ] )

=head2 Yres( [ $val ] )

=head2 Space( [ $val ] )

=head2 Avgwidth( [ $val ] )

=head2 Registry( [ $val ] )

=head2 Encoding( [ $val ] )

Set the given field in the font name to C<$val> if given and return the current
or previous value

=head2 Name( [ $max ] )

In a list context it returns a list of all font names that match the
fields given. It will return a maximum of C<$max> names, or 128 if
$max is not given.

In a scalar contex it returns the first matching name or undef

=head2 Clone( [ key => value, [ ...]] )

Create a duplicate of the curent font object and modify the given fields

=head1 AUTHOR

Graham Barr <Graham.Barr@tiuk.ti.com>

=head1 HISTORY

11-Jan-96 Initial version

=head1 COPYRIGHT

Copyright (c) 1995-1996 Graham Barr. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut

require Tk::Widget;
require Tk::Xlib;
use strict;

Construct Tk::Widget 'Font';

my @field = qw(foundry family weight slant swidth adstyle pixel
               point xres yres space avgwidth registry encoding);

map { eval "sub \u$_ { shift->elem('$_', \@_) }" } @field;

use overload '""' => 'as_string';

sub new
{
 my $pkg = shift;
 my $w   = shift;

 my %me = ();
 my $d  = $w->Display;

 local $_;

 if(scalar(@_) == 1)
  {
   my $pattern = shift;

   if($pattern =~ /\A(-[^-]*){14}\Z/)
    {
     @me{@field} = split(/-/, substr($pattern,1));
    }
   else
    {
     $me{Name} = $pattern;
  
     if($pattern =~ /^[^-]?-([^-]*-){2,}/)
      {
       my $f = $d->XListFonts($pattern,1);
    
       if($f && $f =~ /\A(-[^-]*){14}/)
        {
         my @f = split(/-/, substr($f,1));
         my @n = split(/-/, $pattern);
         my %f = ();
         my $i = 0;
    
         shift @n if($pattern =~ /\A-/);
  
         while(@n && @f)
          {
           if($n[0] eq '*')
            {
             shift @n;
            }
           elsif($n[0] eq $f[0])
            {
             $f{$field[$i]} = shift @n;
            }
           $i++;
           shift @f;
          }

         %me = %f
           unless(@n);
        }
      }
    }
  }
 else
  {
   %me = @_;
  }

 map { $me{$_} ||= '*' } @field;

 $me{Display} = $d;
 $me{MainWin} = $w->MainWindow;

 bless \%me, $pkg;
}

sub Pattern
{
 my $me  = shift;
 return join("-", "",@{$me}{@field});
}

sub Name
{
 my $me  = shift;
 my $max = wantarray ? shift || 128 : 1;

 my $name = $me->{Name} ||
            join("-", "",@{$me}{@field});

 return $name if ($^O eq 'MSWin32');

 $me->{Display}->XListFonts($name,$max);
}

sub as_string
{
 return shift->Name;
}

sub elem
{
 my $me   = shift;
 my $elem = shift;

 return undef
   if(exists $me->{'Name'});

 my $old  = $me->{$elem};

 $me->{$elem} = shift
   if(@_);

 $old;
}

sub Clone
{
 my $me = shift;

 $me = bless { %$me }, ref($me);

 unless(exists $me->{'Name'})
  {
   while(@_)
    {
     my $k = shift;
     my $v = shift || $me->{MainWin}->BackTrace('Tk::Font->Clone( key => value, ... )');
     $me->{$k} = $v;
    }
  }

 $me;
}

sub ascent
{
 my $me = shift;
 my $name = $me->Name;
 $me->{MainWin}->FontAscent($name);
}

sub descent
{
 my $me = shift;
 my $name = $me->Name;
 $me->{MainWin}->FontDescent($name);
}

1;

