# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Optionmenu;
require Tk::Menubutton;
require Tk::Menu;


use vars qw($VERSION);
$VERSION = '2.009'; # $Id: //depot/Tk/Tk/Optionmenu.pm#9$

@ISA = qw(Tk::Derived Tk::Menubutton);

Construct Tk::Widget 'Optionmenu';

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

sub addOptions
{
 my $w = shift;
 my $menu = $w->menu;
 my $var = $w->cget(-textvariable);
 my $width = $w->cget('-width');
 while (@_)
  {
   my $val = shift;
   my $label = $val;
   if (ref $val) 
    {
     ($label, $val) = @$val;
    } 
   my $len = length($label);                          
   $width = $len if (!defined($width) || $len > $width);
   $menu->command(-label => $label, -command => [ $w , 'setOption', $label, $val ]);
   $w->setOption($label, $val) unless (defined $$var);
  }
 $w->configure('-width' => $width);
}

sub options
{
 my ($w,$opts) = @_;
 if (@_ > 1)
  {
   $w->menu->delete(0,'end');
   $w->addOptions(@$opts);
  }
 else
  {
   return $w->_cget('-options');
  }
}

1;

__END__

=head1 NAME

Tk::Optionmenu - Let the user select one of some predefined options values

=head1 SYNOPSIS

    use Optionmenu;

    $opt = $w->Optionmenu(
			-options => REFERENCE_to_OPTIONLIST,
			-command => CALLBACK,
			-variable => SCALAR_REF,
			);

    $opt->addOptions( OPTIONLIST );

    # OPTION LIST is
    #   a)  $val1, $val2, $val3,...
    #   b)  [ $val1=>$lab1], [$lab2=>val2], ... ] 
    #   c)  combination of a) and b), e.g.,
    #       val1, [$lab2=>val2], val3, val4, [...], ...



=head1 DESCRIPTION

The B<Optionmenu> widget allows the user chose between a given set
of options.

If the user should be able to change the available option have a look
at L<Tk::BrowseEntry>.

=head1 OPTIONS

=over 4

=item -options

(Re)sets the list of options presented.

=item -command

Defines the L<callback> that is invokes when a new option
is selected.

=item -variable

Reference to a scalar that contains the current value of the
selected option.

=back

=head1 METHODS

=over 4

=item addOptions

Adds OPTION_LIST to the already available options.

=back


=head1 EXAMPLE

    use Tk;
    my $mw = MainWindow->new();

    my $var;
    my $opt = $mw->Optionmenu(
                -options => [qw(jan feb mar apr)],
                -command => sub { print "got: ", shift, "\n" },
		-variable => \$var,
                )->pack;

    $opt->addOptions([may=>5],[jun=>6],[jul=>7],[aug=>8]);

    $mw->Label(-textvariable=>\$var, -relief=>'groove')->pack;
    $mw->Button(-text=>'Exit', -command=>sub{$mw->destroy})->pack;

    MainLoop;


=head1 SEE ALSO

L<Menubutton>, L<BrowseEntry>

=cut

