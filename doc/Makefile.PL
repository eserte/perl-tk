
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

sub MY::manifypods
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
manifypods: index.html

index.html : man2html $(MANFILES)
	@echo "Making HTML"
	@$(PERL) man2html -tk -q $(MANFILES)
';
}

