package Tk::ScrlListbox; 
require Tk::Frame;
@ISA = qw(Tk::Frame);

Tk::Widget->Construct('ScrlListbox');

sub Populate
{
 my ($cw,$args) = @_;
 $cw->InheritThis($args);
 my $l = $cw->Listbox();
 $cw->AddScrollbars($l);
 $cw->ConfigSpecs('-scrollbars' => ['METHOD','scrollbars','Scrollbars','w']);
 return $cw->Default('listbox' => $l);
}

1;
