include Makefile

parallel : 
	$(MAKE) -j 4 config
	$(MAKE) -j 4 -C pTk 
	$(MAKE) -j 4 -C Pixmap/xpm
	$(MAKE) -j 4 

so      : $(INST_DYNAMIC) 

glue    : tkGlue.c 
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(INC) -Wmissing-prototypes $<

ccglue    : tkGlue.c 
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $(INC) $<


