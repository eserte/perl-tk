use ExtUtils::MakeMaker;

$Version = '1.0';
                           
WriteMakefile(
    'NAME'     => 'Tk::Pod',
    'LINKTYPE' => '',
    'EXE_FILES' => ['tkpod'],
    'clean' => {FILES => "*% *.bak"},
    'linkext' => { LINKTYPE => ''},
    'VERSION'  => $Version
);


