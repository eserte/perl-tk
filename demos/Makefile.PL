use ExtUtils::MakeMaker;

$Version = '1.0';
                           
WriteMakefile(
    'NAME'     => 'Tk::demos',
    'LINKTYPE' => '',
    'EXE_FILES' => ['widget'],
    'clean' => {FILES => "*% *.bak"},
    'linkext' => { LINKTYPE => ''},
    'VERSION'  => $Version
);


