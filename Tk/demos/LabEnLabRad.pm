package Tk::LabeledEntryLabeledRadiobutton;
require Tk::Frame;
@ISA = qw(Tk::Frame);

require Tk::LabEntry;
require Tk::LabRadio;

Tk::Widget->Construct('LabeledEntryLabeledRadiobutton');

sub Populate
{

    # LabeledEntryLabeledRadiobutton(s) constructor.
    #
    # Advertised subwidgets:  labeled_entry, labeled_radiobutton.

    my($cw, $args) = @_;

    my $e = $cw->Component(LabEntry => 'labeled_entry');
    $e->pack(-side => 'left', -expand => 1, -fill => 'both');

    my $r = $cw->Component(LabRadiobutton => 'labeled_radiobutton',
                           -radiobuttons   => delete $args->{'-radiobuttons'}
                          );
    $r->pack(-side => 'left', -expand => 1, -fill => 'both');
    $cw->ConfigSpecs(-entry_label    => [ Tk::Config->new($e,'-label'), undef, undef, 'Entry' ],
                     -radio_label    => [ Tk::Config->new($r,'-label'), undef, undef, Choose ],
                     -entry_variable => [ Tk::Config->new($e,'-textvariable'), undef, undef, \$cw->{Config}{-text} ],
                     -radio_variable => [ Tk::Config->new($r,'-variable'), undef, undef, undef ],
                     -indicatoron    => [ 'labeled_radiobutton' , undef, undef, undef ],
                     DEFAULT         => [ ['labeled_entry','labeled_radiobutton']],
                    );
    $cw->Delegates(DEFAULT => 'labeled_entry');

} # end LabeledEntryLabeledRadiobutton(s) constructor

1;
