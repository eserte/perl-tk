package MainWindow;
require AutoLoader;
require Tk;
require Tk::Toplevel;

use Getopt::Long qw(GetOptions);
use Carp;

@ISA = qw(Tk::Toplevel);

@Windows = ();

sub new
{
 my $package = shift;
 my $name = $0;
 $name    =~ s#^.*/##; 
 my $top = eval { bless CreateMainWindow("\l$name", "\u$name", @_), $package };
 croak($@ . "$package" ."::new(" . join(',',@_) .")") if ($@);
 $top->InitBindings;
 $top->InitObject(\%args);
 eval { $top->configure(%args) };
 croak "$@" if ($@);
 $top->SetBindtags;
 push(@Windows,$top);
 return $top;
}

sub InitBindings
{
 my $mw = shift;
 $mw->bind('all',"<Tab>","focusNext");
 $mw->bind('all',"<Shift-Tab>","focusPrev");
                                    
 $mw->bind('all',"<Alt-KeyPress>",['TraverseToMenu',Tk::Ev(A)]);
 $mw->bind('all',"<F10>",'FirstMenu');
}

sub CmdLine
{
 my $top = shift;
 my $state = $top->state;

 local ($opt_iconposition,$opt_geometry,$opt_iconic);

 my $result = GetOptions('iconposition=s','geometry=s','iconic!');

 if (defined $opt_iconposition)
  {
   my $icon = $top->iconwindow;
   my ($x,$y) = split(',',$opt_iconposition); 
   $top->iconposition($x,$y);
  }

 if (defined $opt_geometry)
  {
   $top->geometry($opt_geometry);
   $top->positionfrom('user');
   $top->sizefrom('user'); 
  }

 $top->protocol(WM_SAVE_YOURSELF => ['SaveYourself',$top]);
 $top->command([$0,@ARGV]);
 if (defined $opt_iconic && $opt_iconic)
  {
   $top->iconify unless ($state eq 'iconic');
  }
 else
  {
   $top->deiconify unless ($state eq 'normal');
  }
}

END
{
 my $top;
 while ($top = pop(@Windows))
  {
   if ($top->IsWidget)
    {
     # Tk data structuctures are still in place
     # this can occur if non-callback perl code did a 'die'.
     # It will also handle some cases of non-Tk 'exit' being called
     # Destroy this mainwindow and hence is descendants ...
     $top->destroy; 
    }
  }
}


1;

__END__

sub SaveYourself
{
 my $top  = shift;
 my $icon = $top->iconwindow;
 my @args = @{$top->command};
 @args = ($0) unless (@args);
 my @iconpos;
 if (defined($icon))
  {
   my $geom = $icon->geometry;
   @iconpos = $geom =~ /\d+x\d+([+-]\d+)([+-]\d+)/;
  }
 else
  {
   @iconpos = $top->iconposition;
  }

 push(@args,'-iconposition' => "$iconpos[0],$iconpos[1]") if (@iconpos == 2);

 if ($top->state() eq 'iconic')
  {
   @args = grep(!/^-(no)?iconic/,@args);
   push(@args,'-iconic');
  }

 push(@args,'-geometry' => $top->geometry);
 $top->command([@args]);
}


