vpath %.1 man
vpath %.3 man
vpath %.n man

MANn = $(notdir $(wildcard man/*.n))
HTn  = $(subst .n,.ht,$(MAN))
MAN3 = $(notdir $(wildcard man/*.3))
HT3  = $(subst .3,.ht,$(MAN))

HT : $(MAN3) $(MANn)
	tkman2ht $^

%.ht : %.3 tkman2ht
	tkman2ht $< 

%.ht : %.n tkman2ht
	tkman2ht $< 

