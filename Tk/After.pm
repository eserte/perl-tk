# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::After;
use Carp;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/After.pm#8$

sub _cancelAll
{
 my $h = shift;
 my $obj;
 foreach $obj (values %$h)
  {
   # carp "Auto cancel ".$obj->[1]." for ".$obj->[0]->PathName;
   $obj->cancel;
  }
}

sub submit
{
 my $obj     = shift;
 my $w       = $obj->[0];
 my $id      = $obj->[1];
 my $t       = $obj->[2];
 my $method  = $obj->[3];
 delete($w->{_After_}{$id}) if (defined $id);
 $id  = $w->Tk::after($t,[$method => $obj]);
 unless (exists $w->{_After_})
  {
   $w->{_After_} = {};
   $w->OnDestroy(sub { _cancelAll($w->{_After_}) });
  }
 $w->{_After_}{$id} = $obj;
 $obj->[1] = $id;
 return $obj;
}

sub DESTROY
{
 my $obj     = shift;
 @{$obj} = ();
}

sub new
{
 my ($class,$w,$t,$method,@cb) = @_;
 my $cb    = (@cb == 1) ? shift(@cb) : [@cb];
 my $obj   = bless [$w,undef,$t,$method,Tk::Callback->new($cb)],$class;
 return $obj->submit;
}

sub cancel
{
 my $obj = shift;
 my $id  = $obj->[1];
 my $w   = $obj->[0];
 if ($id)
  {
   $w->Tk::after('cancel'=> $id); 
   delete $w->{_After_}{$id};
   $obj->[1] = undef;
  }
 return $obj;
}

sub repeat
{
 my $obj = shift;
 $obj->submit;
 local $Tk::widget = $obj->[0];
 $obj->[4]->Call;
}

sub once
{
 my $obj = shift;
 my $w   = $obj->[0];
 my $id  = $obj->[1];
 delete $w->{_After_}{$id};
 local $Tk::widget = $w;
 $obj->[4]->Call;
}

1;
__END__

=head1 NAME

Tk::After - support class for Tk::Widget::after

=for category Binding Events and Callbacks

=head1 SYNOPSIS

  $id = $widget->after(time,callback);
  $id = $widget->afterIdle(callback);
  $widget->afterCancel($id);

  $id = $widget->repeat(period,callback);

Internally this class is used to implement above.

  $id = Tk::After->new($widget,$time,'method',callback);
  $id->cancel;

=head1 DESCRIPTION

This class is a wrapper used by Tk::Widget::after to auto-cancel
after calls when a widget is destroyed.

I<callback> is a normal perl/Tk callback. Method is either I<'once'> 
or I<'repeat'>

This is first attempt at the code and interface is likely to change.
So for the time being at least use $widget->after(...) interface.

