%.c : mTk/%.c ./Tcl-pTk 
	$(PERL) ./Tcl-pTk $< $@

%.h : mTk/%.h ./Tcl-pTk 
	$(PERL) ./Tcl-pTk $< $@

%.c : Tk/%.c ./Tcl-pTk
	$(PERL) ./Tcl-pTk $< $@


%.h : Tk/%.h ./Tcl-pTk
	$(PERL) ./Tcl-pTk $< $@

include Makefile

# Auto generation of Xlib.h disabled for now
#Xlib.h : config/Xdummy.c mkXinfo $(C_FILES) $(wildcard xpm/*.c)
#	$(PERL) mkXinfo Xlib.h -I . $(DEFINE) $(INC)  config/Xdummy.c 

c     : need counts 
	counts *.c | sort -rn > c

need  : GNUmakefile $(LIBOBJS) ../tkGlue.o 
	-ld -r -o /tmp/junk $(LIBOBJS) ../tkGlue.o
	nm -p /tmp/junk >$@

source : $(C_FILES) 

$(wildcard *.t) : mkVFunc

Methods.def : mkmethods $(C_FILES)
	$(PERL) mkmethods $@ $(C_FILES)

config :: Methods.def

-include $(wildcard *.d)
