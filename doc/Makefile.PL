
use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
      'linkext' => { LINKTYPE => ''},
      'clean'   => { FILES => '*.htm index.html podify subpodify *.pod */*.pod' },
      'MAN3PODS'=> {},
      );

sub MY::post_initialize
{
 my ($self) = @_;
 %{$self->{PM}} = ();
}

sub MY::postamble
{
 my ($self) = @_;
 my $sec;
 %{$self->{PM}} = ();
 my $dep = "MANFILES =";
 open(FILE,">MANFILES") || die "Cannot open MANFILES:$!";
 foreach $sec (qw(n 2))
  {
   my $name;
   foreach $name ($self->lsdir("man$sec"))
    {
     next if ($name =~ /^\./);
     next unless (-f "man$sec/$name");
     if ($name =~ /^(.*)\.$sec/)
      {
       $dep .= " \\\n\tman$sec/$name";
       print FILE "man$sec/$name\n";
      }
    }
  }
 close(FILE);
 return $dep . '

html : config index.html

index.html : man2html $(MANFILES) $(INST_MAN3DIR) MANFILES $(INST_MAN1DIR) 
	@echo "Making HTML"
	@$(PERL) man2html -tk -man1 $(INST_MAN1DIR) \
	         -man3 $(INST_MAN3DIR) -q -files MANFILES
podify: 
	$(PERL) tkman2pod $(MANFILES)
	touch podify

subpodify: tkman2pod $(MANFILES)
	$(PERL) tkman2pod -s $(MANFILES)
	touch subpodify

tk.ipf: subpodify
	pod2ipf --nofaqs --debug --by-dirs "--title=Tk/Perl book" \
		"--section-name=Perl/Tk Constructs" --dir=constructs \
		"--section-name=Tk Generic Methods" --dir=generic \
		"--section-name=Tk User Interaction" --dir=interaction \
		"--section-name=Partially Converted Methods" --dir=unfinished \
		"--section-name=Tix Extensions" --dir=tix \
		"--section-name=Tk Geometry Management" --dir=geometry \
		"--section-name=Tk Selection Handling" --dir=selection \
		"--section-name=Tk Image Classes" --dir=image_classes \
		"--section-name=Tk Library Procedures" --dir=library \
		"--section-name=Tk Modules" --dir=../blib/lib \
			--about > tk.ipf

tk.inf: tk.ipf
	ipfc /inf tk.ipf
';
}

