

use Tk::MMutil;
Tk::MMutil::TkExtMakefile(
      ($^O eq 'MSWin32' ? () : ('LIBS'        => ["-lm"])),
      OBJECT => '$(O_FILES)',
      TYPEMAPS => ['typemap'],
      'dynamic_ptk' => 1
      );


