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

 # Should we allow -menubackground etc. as in -label* of Frame ?

 $w->ConfigSpecs(-command => [CALLBACK,undef,undef,undef],
                 -options => [METHOD, undef, undef, undef],
		 -variable=> [PASSIVE, undef, undef, undef],
                );

 $w->configure(-variable => delete $args->{-variable});
}

sub setOption
{
 my ($w, $label, $val) = @_;
 $val = $label if @_ == 2;
 my $var = $w->cget(-textvariable);
 $$var = $label;
 $var = $w->cget(-variable);
 $$var = $val if $var;
 $w->Callback(-command => $val);
}

sub options
{
 my ($w,$opts) = @_;
 if (@_ > 1)
  {
   my $menu = $w->menu;
   my $var = $w->cget(-textvariable);
   my $width = $w->cget('-width');
   my($val, $label);
   foreach $val (@$opts) 
    {
     if (ref $val) {
	($label, $val) = @$val;
     } else {
	$label = $val;
     }
     my $len = length($label);
     $width = $len if (!defined($width) || $len > $width);
     $menu->command(-label => $label, -command => [ $w , 'setOption', $label, $val ]);
     $w->setOption($label, $val) unless (defined $$var);
    }
   $w->configure('-width' => $width);
  }
 else
  {
   return $w->_cget('-options');
  }
}

1;
