use Tk::MMutil;
use Tk::Config;

Tk::MMutil::TkExtMakefile(
    'NAME'     => 'Tk::WinPhoto',
#   'EXE_FILES'  => ['tkjpeg'],
    'OBJECT'     => '$(O_FILES)',
    'VERSION_FROM' => 'WinPhoto.pm',
    'XS_VERSION'   => $Tk::Config::VERSION,
    'dist'     => { COMPRESS => 'gzip -f9', SUFFIX => '.gz' },
#   'clean'    => { FILES => 'jpeg/Makefile jpeg/config.status jpeg/jconfig.h' }  
);



