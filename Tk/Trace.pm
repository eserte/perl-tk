package Tk::Trace;

use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/Tk/Trace.pm#4 $

use Tie::Watch;
use strict;

my %trace;                      # watchpoints indexed by stringified ref
my %op = (                      # map Tcl op to tie function
    'r' => ['-fetch',   \&fetch],
    'w' => ['-store',   \&store],
    'u' => ['-destroy', \&destroy],
);

sub fetch {

    # fetch() wraps the user's callback with necessary tie() bookkeeping
    # and invokes the callback with the proper arguments. It expects:
    #
    # $_[0] = Tie::Watch object
    # $_[1] = undef for a scalar, an index/key for an array/hash
    #
    # The user's callback is passed these arguments:
    #
    #   $_[0]        = undef for a scalar, index/key for array/hash
    #   $_[1]        = current value
    #   $_[2]        = operation (r, w, or u)
    #   $_[3 .. $#_] = optional user callback arguments
    #
    # The user callback returns the final value to assign the variable.

    my $self = shift;		             # Tie::Watch object
    my $val = $self->Fetch(@_);	             # get variable's current value
    my $aref = $self->Args(-fetch);          # argument reference
    my $sub = shift @$aref;	             # user's callback
    unshift @_, undef if scalar @_ == 0;     # undef "index" for a scalar
    my @args = @_;                           # save for post-callback work
    $args[1] = &$sub(@_, $val, 'r', @$aref); # invoke user callback
    shift @args unless defined $args[0];     # drop scalar "index"
    $self->Store(@args);                     # update variable's value

} # end fetch

sub store {

    # store() wraps the user's callback with necessary tie() bookkeeping
    # and invokes the callback with the proper arguments. It expects:
    #
    # $_[0] = Tie::Watch object
    # $_[1] = new value for a scalar, index/key for an array/hash
    # $_[2] = undef for a scalar, new value for an array/hash
    #
    # The user's callback is passed these arguments:
    #
    #   $_[0]        = undef for a scalar, index/key for array/hash
    #   $_[1]        = new value
    #   $_[2]        = operation (r, w, or u)
    #   $_[3 .. $#_] = optional user callback arguments
    #
    # The user callback returns the final value to assign the variable.

    my $self = shift;		             # Tie::Watch object
    $self->Store(@_);                        # store variable's new value
    my $aref = $self->Args(-store);          # argument reference
    my $sub = shift @$aref;                  # user's callback
    unshift @_, undef if scalar @_ == 1;     # undef "index" for a scalar
    my @args = @_;                           # save for post-callback work
    $args[1] = &$sub(@_, 'w', @$aref);       # invoke user callback
    shift @args unless defined $args[0];     # drop scalar "index"
    $self->Store(@args);                     # update variable's value

} # end store

sub destroy {
    my $self = shift;
    my $aref = $self->Args(-destroy);        # argument reference
    my $sub = shift @$aref;	             # user's callback
    my $val = $self->Fetch(@_);              # get final value
    &$sub(undef, $val, 'u', @$aref);         # invoke user callback
    $self->Destroy(@_);                      # destroy variable
}

sub Tk::Widget::traceVariable {
    my($parent, $vref, $op, $callback) = @_;
    die "Illegal parent." unless ref $parent;
    die "Illegal variable." unless ref $vref;
    die "Illegal trace operation '$op'." unless $op;
    die "Illegal trace operation '$op'." if $op =~ /[^rwu]/;
    die "Illegal callback." unless $callback;

    # Need to add our internal callback to user's callback arg list
    # so we can call it first, followed by the user's callback and
    # any user arguments.

    my($fetch, $store, $destroy);
    if (ref $callback eq 'CODE') {
        $fetch   = [\&fetch,   $callback];
        $store   = [\&store,   $callback];
        $destroy = [\&destroy, $callback];
    } else {                    # assume [] form
        $fetch   = [\&fetch,   @$callback];
        $store   = [\&store,   @$callback];
        $destroy = [\&destroy, @$callback];
    }

    my @wargs;
    push @wargs, (-fetch   => $fetch)   if $op =~ /r/;
    push @wargs, (-store   => $store)   if $op =~ /w/;
    push @wargs, (-destroy => $destroy) if $op =~ /w/;
    my $watch = Tie::Watch->new(
        -variable => $vref,
        @wargs,
    );

    $trace{$vref} = $watch;

} # end traceVariable

sub Tk::Widget::traceVdelete {
    my($parent, $vref, $op_not_honored, $callabck_not_honored) = @_;
    if (defined $trace{$vref}) {
        $trace{$vref}->Unwatch;
        delete $trace{$vref};
    }
}

sub Tk::Widget::traceVinfo {
    my($parent, $vref) = @_;
    return (defined $trace{$vref}) ? $trace{$vref}->Info : undef;
}

=head1 NAME

Tk::Trace - emulate Tcl/Tk B<trace> functions.

=head1 SYNOPSIS

 use Tk::Trace

 $mw->traceVariable(\$v, 'wru' => [\&update_meter, $scale]);
 %vinfo = $mw->traceVinfo(\$v);
 print "Trace info  :\n  ", join("\n  ", @{$vinfo{-legible}}), "\n";
 $mw->traceVdelete(\$v);

=head1 DESCRIPTION

This class module emulates the Tcl/Tk B<trace> family of commands by
binding subroutines of your devising to Perl variables using simple
B<Tie::Watch> features.

Callback format is patterned after the Perl/Tk scheme: supply either a
code reference, or, supply an array reference and pass the callback
code reference in the first element of the array, followed by callback
arguments.

User callbacks are passed these arguments:

 $_[0]        = undef for a scalar, index/key for array/hash
 $_[1]        = variable's current (read), new (write), final (undef) value
 $_[2]        = operation (r, w, or u)
 $_[3 .. $#_] = optional user callback arguments

As a Trace user, you have an important responsibility when writing your
callback, since you control the final value assigned to the variable.
A typical callback might look like:

 sub callback {
    my($index, $value, $op, @args) = @_;
    return if $op eq 'u';
    # .... code which uses $value ...
    return $value;     # variable's final value
 }

Note that the callback's return value becomes the variable's final value,
for either read or write traces.

For write operations, the variable is updated with its new value before
the callback is invoked.

Only one callback can be attached to a variable, but read, write and undef
operations can be traced simultaneously.

=head1 METHODS

=over 4

=item $mw->traceVariable(varRef, op => callback);

B<varRef> is a reference to the scalar, array or hash variable you
wish to trace.  B<op> is the trace operation, and can be any combination
of B<r> for read, B<w> for write, and B<u> for undef.  B<callback> is a
standard Perl/Tk callback, and is invoked, depending upon the value of
B<op>, whenever the variable is read, written, or destroyed.

=item %vinfo = $mw->traceVinfo(varRef);

Returns a hash detailing the internals of the Trace object, with these
keys:

 %vinfo = (
     -variable =>  varRef
     -debug    =>  '0'
     -shadow   =>  '1'
     -value    =>  'HELLO SCALAR'
     -destroy  =>  callback
     -fetch    =>  callback
     -store    =>  callback
     -legible  =>  above data formatted as a list of string, for printing
 );

For array and hash Trace objects, the B<-value> key is replaced with a
B<-ptr> key which is a reference to the parallel array or hash.
Additionally, for an array or hash, there are key/value pairs for
all the variable specific callbacks.

=item $mw->traceVdelete(\$v);

Stop tracing the variable.

=back

=head1 EXAMPLE

 use Tk;
 use Tk::Trace;

 # Trace a Scale's variable and move a meter in unison.

 $pi = 3.1415926;
 $mw = MainWindow->new;
 $c = $mw->Canvas(qw/-width 200 -height 110 -bd 2 -relief sunken/)->grid;
 $c->createLine(qw/100 100 10 100 -tag meter/);
 $s = $mw->Scale(qw/-orient h -from 0 -to 100 -variable/ => \$v)->grid;
 $mw->Label(-text => 'Slide Me for 5 Seconds')->grid;

 $mw->traceVariable(\$v, 'w' => [\&update_meter, $s]);

 $mw->after(5000 => sub {
     print "Untrace time ...\n";
     %vinfo = $s->traceVinfo(\$v);
     print "Watch info  :\n  ", join("\n  ", @{$vinfo{-legible}}), "\n";
     $c->traceVdelete(\$v);
 });

 MainLoop;

 sub update_meter {
     my($index, $value, $op, @args) = @_;
     return if $op eq 'u';
     $min = $s->cget(-from);
     $max = $s->cget(-to);
     $pos = $value / abs($max - $min);
     $x = 100.0 - 90.0 * (cos( $pos * $pi ));
     $y = 100.0 - 90.0 * (sin( $pos * $pi ));
     $c->coords(qw/meter 100 100/, $x, $y);
     return $value;
 }

=head1 HISTORY

 Stephen.O.Lidie@Lehigh.EDU, Lehigh University Computing Center, 2000/08/01
 . Version 1.0, for Tk800.022.

=head1 COPYRIGHT

Copyright (C) 2000 - 2003 Stephen O. Lidie. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
