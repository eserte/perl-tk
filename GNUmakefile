include Makefile

parallel : 
	$(MAKE) -j 4 config
	$(MAKE) -j 4 -C pTk 
	$(MAKE) -j 4 -C Pixmap/xpm
	$(MAKE) -j 4 

so      : $(INST_DYNAMIC) 
                        
%.i     : %.c 
	$(CCCMD) -E $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(GCCOPT) $(INC) -Wmissing-prototypes $< >$@

%.X     : %.c 
	gcc -aux-info $@ $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(GCCOPT) $(INC) -S -o /dev/null $< 

glue    : tkGlue.c 
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(GCCOPT) $(INC) -Wmissing-prototypes $<

ccglue    : tkGlue.c 
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(GCCOPT) $(INC) $<

debug_malloc.so : debug_malloc.o GNUmakefile 
	$(CC) -G -o $@ $< 
                         
                       
