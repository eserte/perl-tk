use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
      'MYEXTLIB' => 'xpm/libXpm$(LIB_EXT)',
      'OBJECT' => '$(O_FILES)',
      'dynamic_ptk' => 1
      );

sub MY::post_initialize
{
 my $self = shift;
 $self->Tk::MMutil::mTk_CHO({'tkImgPmap.c' => $self->catfile("mTk",'tkImgPmap.c')});
 '';
}

sub MY::postamble {
my $self = shift;
$self->Tk::MMutil::mTk_postamble().
'
$(MYEXTLIB)  : FORCE
	cd xpm && $(MAKE) libXpm$(LIB_EXT)

';
}


