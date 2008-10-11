# -*- cperl -*-

use Tk::MMutil;
Tk::MMutil::TkExtMakefile(
      ($^O eq 'MSWin32' ? () : ('LIBS'        => ["-lm"])),
      OBJECT => '$(O_FILES)',
      TYPEMAPS => ['typemap'],
#     'dynamic_ptk' => 1
      );


sub MY::test_via_harness
{
 my($self, $perl, $tests) = @_;
 qq{\t$perl "-I../t" "-MTkTest" "-MExtUtils::Command::MM" }.
 qq{"-e" "check_display_harness; test_harness(\$(TEST_VERBOSE), '\$(INST_LIB)', '\$(INST_ARCHLIB)')" $tests\n};
}
