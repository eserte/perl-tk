

use Tk::MMutil;
Tk::MMutil::TkExtMakefile(
      'MYEXTLIB' => 'xpm/libXpm$(LIB_EXT)',
      'OBJECT' => '$(O_FILES)',
      'dynamic_ptk' => 0
      );

sub MY::postamble {
'
$(MYEXTLIB)  : FORCE
	cd xpm; $(MAKE) libXpm$(LIB_EXT)

';
}


