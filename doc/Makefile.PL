
use Tk::MMutil;

Tk::MMutil::TkExtMakefile(
      'linkext' => { LINKTYPE => ''},
      'clean'   => { FILES => '*.htm index.html' }
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
      }
    }
  }

 return $dep . '

html : config index.html

index.html : man2html $(MANFILES) $(INST_MAN1DIR) $(INST_MAN3DIR)
	@echo "Making HTML"
	@$(PERL) man2html -tk -man1 $(INST_MAN1DIR) \
	         -man3 $(INST_MAN3DIR) -q $(MANFILES)
';
}

