# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 781 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Tag.al)"
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

# end of Tk::Text::Tag
1;
