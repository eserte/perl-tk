package Tk::Optionmenu;
require Tk::Menubutton;
require Tk::Menu;

@ISA = qw(Tk::Derived Tk::Menubutton);

Tk::Widget->Construct('Optionmenu');

sub Populate
{
 my ($w,$args) = @_;
 $w->SUPER::Populate($args);
 $args->{-indicatoron} = 1;
 my $var = delete $args->{-textvariable};
 unless (defined $var)
  {
   my $gen = undef;
   $var = \$gen;
  }
 $w->menu(-tearoff => 0);
 $w->configure(-textvariable => $var);
 $w->ConfigSpecs(-command => [CALLBACK,undef,undef,undef],
                 -options => [METHOD, undef, undef, undef] 
                );
}

sub setOption
{
 my ($w,$val) = @_;
 my $var = $w->cget(-textvariable);
 $$var = $val;
 my $cb = $w->cget('-command');
 $cb->Call($val) if (defined $cb);
}

sub options
{
 my ($w,$opts) = @_;
 if (@_ > 1)
  {
   my $menu = $w->menu;
   my $var = $w->cget(-textvariable);
   my $width = $w->cget('-width');
   my $val;
   foreach $val (@$opts) 
    {
     my $len = length($val);
     $width = $len if (!defined($width) || $len > $width);
     $menu->command(-label => $val, -command => [ $w , 'setOption', $val ]);
     $w->setOption($val) unless (defined $$var);
    }
   $w->configure('-width' => $width);
  }
 else
  {
   return $w->_cget('-options');
  }
}

1;
