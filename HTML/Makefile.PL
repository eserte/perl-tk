use ExtUtils::MakeMaker;

$Version = '1.0';
                           
WriteMakefile(
    'NAME'     => 'Tk::HTML',
    'LINKTYPE' => '',
    'EXE_FILES' => ['tkhtml'],
    'clean' => {FILES => "*% *.bak"},
    'linkext' => { LINKTYPE => ''},
    'VERSION'  => $Version
);


