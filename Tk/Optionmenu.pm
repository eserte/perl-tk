package Tk::Optionmenu;
require Tk::Menubutton;
require Tk::Menu;

@ISA = qw(Tk::Menubutton);

Tk::Widget->Construct('Optionmenu');

sub InitObject
{
 my ($w,$args) = @_;
 $w->InheritThis($args);
 $args->{-indicatoron} = 1;
 my $opt = delete $args->{-options};
 my $var = delete $args->{-textvariable};
 unless (defined $var)
  {
   my $gen = undef;
   $var = \$gen;
  }
 $w->configure(-menu => $w->Menu(-tearoff => 0),  -textvariable => $var);
 if (defined $opt)
  {
   $w->Options(@$opt);
  }
}

sub setOption
{
 my ($w,$val) = @_;
 my $var = $w->cget(-textvariable);
 $$var = $val;
}

sub Options
{
 my $w = shift;
 my $menu = $w->cget(-menu);
 my $var = $w->cget(-textvariable);
 while (@_)
  {
   my $val = shift;
   $menu->command(-label => $val, -command => [ $w , 'setOption', $val ]);
   $$var = $val unless (defined $$var);
  }
}


1;
