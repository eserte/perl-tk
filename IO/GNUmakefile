%.c : mTk/%.c ../pTk/munge 
	$(PERL) ../pTk/munge $< $@

%.h : mTk/%.h ../pTk/munge 
	$(PERL) ../pTk/munge $< $@

include Makefile
-include $(wildcard *.d)
