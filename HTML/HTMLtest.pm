package Tk::HTMLtest;
require Tk::HTML;

@ISA = qw(Tk::HTML);

sub new
{
 my ($class,%args) = @_;
 return bless \%args,$class;
}

sub delete  {}
sub insert  {}
sub tag     {}
sub DESTROY {}
sub index   {0}
sub window  {}
sub cget    {0}
sub Frame   {0}

1;
