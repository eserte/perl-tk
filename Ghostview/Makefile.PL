use ExtUtils::MakeMaker qw(%att &WriteMakefile);

$Version = '1.0';
                           
WriteMakefile(
    'NAME'     => 'Tk::Ghostview',
    'EXE_FILES' => ['pgs'],
    'clean' => {FILES => "*% *.bak"},
    'linkext' => { LINKTYPE => ''},
    'VERSION'  => $Version
);


