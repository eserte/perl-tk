# CXX = g++
CPPFLAGS = -I.. -I/usr/openwin/include 
CXXFLAGS = -Wall -Wno-unused -Werror -g -MMD
  
LDFLAGS  = -L/usr/openwin/lib -R/usr/openwin/lib
LDLIBS   = -lX11 -lm 
PERL_INC = /usr/local/lib/perl5/sun4-solaris/5.00201/CORE

%.s : %.cc
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -S $< 

all : Main

proto : 
	protoize -C -c "$(CPPFLAGS) -I$(PERL_INC)" tkGlue.c 

Main : Main.o  Tk.o ../pTk/libpTk.a 

-include $(wildcard *.d)
