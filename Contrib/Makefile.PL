use ExtUtils::MakeMaker qw(%att &WriteMakefile);

$Version = '1.0';
                           
WriteMakefile(
    'NAME'     => 'Tk::Contrib',
    'LINKTYPE' => '',
    'clean' => {FILES => "*% *.bak"},
    'linkext' => { LINKTYPE => ''},
    'VERSION'  => $Version
);


