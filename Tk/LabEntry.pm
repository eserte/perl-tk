# Class LabeledEntry

package Tk::LabEntry;
require Tk::Frame;
@ISA = qw(Tk::Frame);

Tk::Widget->Construct('LabEntry');

sub Populate 
{
 require Tk::Entry;
 # LabeledEntry constructor.
 #
 my($cw, $args) = @_;
 $cw->InheritThis($args);
 # Advertised subwidgets:  entry.
 my $e = $cw->Entry();
 $e->pack('-expand' => 1, '-fill' => 'both');
 $cw->Advertise('entry' => $e );
 $cw->ConfigSpecs(DEFAULT => [$e]);
 $cw->Delegates(DEFAULT => $e);
 $cw->AddScrollbars($e) if (exists $args->{-scrollbars});
} 

1;
