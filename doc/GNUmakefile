vpath %.1 man1
vpath %.3 man3
vpath %.2 man2
vpath %.n mann


%.htm : %.2 man2html 
	man2html -tk $< 

%.htm : %.n man2html 
	man2html -tk $< 

%.pod : %.n tkman2pod 
	tkman2pod $< 

-include Makefile

install_ti : index.html
	rm -f /usr/local/doc/perl/Tk/*
	install -m 644 *.htm *.html /usr/local/doc/perl/Tk



