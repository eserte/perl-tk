use ExtUtils::MakeMaker;

WriteMakefile(
	NAME	=> 'Tk::pod',
	# DIR	=> [ 'pTk' ],
);

sub MY::postamble {
    '
html :: 
	@echo "Sorry no HTML building yet"
'
}


