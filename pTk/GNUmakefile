include Makefile

# Auto generation of Xlib.h disabled for now
#Xlib.h : config/Xdummy.c mkXinfo $(C_FILES) $(wildcard xpm/*.c)
#	$(PERL) mkXinfo Xlib.h -I . $(DEFINE) $(INC)  config/Xdummy.c 

N_FILES = $(subst $(OBJ_EXT),.n,$(O_FILES))

.SUFFIXES : .n

.c.n :
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) -o $@ -DNO_VTABLES $(DEFINE) $(GCCOPT) $*.c

nfiles :
	echo $(N_FILES)

c     : need counts 
	counts *.c | sort -rn > c

need  : GNUmakefile $(N_FILES) ../tkGlue.o 
	-ld -r -o /tmp/junk $(N_FILES) ../tkGlue.o
	nm -p /tmp/junk | grep ' [A-Z] ' >$@

clean ::
	rm -f *.n 

$(wildcard *.t) : mkVFunc

-include $(wildcard *.d)


