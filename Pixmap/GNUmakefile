%.c : mTk/%.c ../pTk/Tcl-pTk 
	$(PERL) ../pTk/Tcl-pTk $< $@

%.h : mTk/%.h ../pTk/Tcl-pTk 
	$(PERL) ../pTk/Tcl-pTk $< $@

include Makefile
-include $(wildcard *.d)
