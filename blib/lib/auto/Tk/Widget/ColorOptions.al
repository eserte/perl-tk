# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub ColorOptions
{
 my ($w,$args) = @_;
 my $opt;
 $args = {} unless (defined $args);
 foreach $opt (qw(-foreground -background -disabledforeground
                  -activebackground -activeforeground
              ))
  {
   $args->{$opt} = $w->cget($opt) unless (exists $arg{$opt})
  }
 return (wantarray) ? %$args : $args;
}

1;
