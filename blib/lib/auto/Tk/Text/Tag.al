# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Tag
{
 my $w = shift;
 my $name = shift;
 Carp::confess("No args") unless (ref $w and defined $name);
 $w->{_Tags_} = {} unless (exists $w->{_Tags_});
 unless (exists $w->{_Tags_}{$name})
  {
   require Tk::Text::Tag;
   $w->{_Tags_}{$name} = 'Tk::Text::Tag'->new($w,$name);
  }
 $w->{_Tags_}{$name}->configure(@_) if (@_); 
 return $w->{_Tags_}{$name};
}

1;
