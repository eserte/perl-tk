# Class that handles cget/configure for options that 
# need translating from public form 
# e.g. $cw->configure(-label => 'fred')
# into $cw->subwiget('label')->configure(-text => 'fred')
# Should probably do something clever with regexp's here

package Tk::Configure;
use Carp;
use Tk::Pretty;

sub new
{
 my ($class,@args) = @_;
 unshift(@args,'configure','cget') if (@args < 3);
 return bless \@args,$class;
}

sub cget
{
 croak("Wrong number of args to cget") unless (@_ == 2);
 my ($alias,$key) = @_;
 my ($set,$get,$widget,@args) = @$alias;
 my @result;
 eval { @result = $widget->$get(@args) };
 croak "$get: $@" if ($@);
 return (wantarray) ? @result : $result[0];
}

sub configure
{
 my $alias = shift;
 shift if (@_);
 my ($set,$get,$widget,@args) = @$alias;
 $widget->$set(@args,@_);
}

*TIESCALAR = \&new;
*TIEHASH   = \&new;

sub FETCH
{
 my $alias = shift;
 my ($set,$get,$widget,@args) = @$alias;
 return $widget->$get(@args,@_);
}

sub STORE
{
 my $alias = shift;
 my ($set,$get,$widget,@args) = @$alias;
 $widget->$set(@args,@_);
}

1;
