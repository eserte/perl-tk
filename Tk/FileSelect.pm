package Tk::FileSelect; 
               
use vars qw($VERSION);
$VERSION = '3.009'; # $Id: //depot/Tk8/Tk/FileSelect.pm#9$

use Tk qw(Ev);
use strict;
use Carp;
@Tk::FileSelect::ISA = qw(Tk::Toplevel);           

Construct Tk::Widget 'FileSelect';
  
# Documentation after __END__

sub Cancel
{
 my ($cw) = @_;
 $cw->{Selected} = undef;
}

sub Accept {

    # Accept the file or directory name if possible.
    
    my ($cw) = @_;

    my($path, $so) = ($cw->cget('-directory'), $cw->SelectionOwner);
    my $leaf = undef;
    my $leaves;
    my %error_text = (
        '-r' => 'is not readable by effective uid/gid',
        '-w' => 'is not writeable by effective uid/gid',
        '-x' => 'is not executable by effective uid/gid',
        '-R' => 'is not readable by real uid/gid',
        '-W' => 'is not writeable by real uid/gid',
        '-X' => 'is not executable by real uid/gid',
        '-o' => 'is not owned by effective uid/gid',
        '-O' => 'is not owned by real uid/gid',
        '-e' => 'does not exist',
        '-z' => 'is not of size zero',
        '-s' => 'does not exists or is of size zero',
        '-f' => 'is not a file',
        '-d' => 'is not a directory',
        '-l' => 'is not a link',
        '-S' => 'is not a socket',
        '-p' => 'is not a named pipe',
        '-b' => 'is not a block special file',
        '-c' => 'is not a character special file',
        '-u' => 'is not setuid',
        '-g' => 'is not setgid',
        '-k' => 'is not sticky',
        '-t' => 'is not a terminal file',
        '-T' => 'is not a text files',
        '-B' => 'is not a binary file',
        '-M' => 'has no modification date/time',
        '-A' => 'has no access date/time',
        '-C' => 'has no inode change date/time',
    );

    if (defined $so and
          $so == $cw->Subwidget('dir_list')->Subwidget('listbox')) {
        $leaves = [$cw->Subwidget('dir_list')->getSelected];
        $leaves = [$cw->Subwidget('dir_entry')->get] if !scalar(@$leaves);
    } else {
        $leaves = [$cw->Subwidget('file_list')->getSelected];
        $leaves = [$cw->Subwidget('file_entry')->get] if !scalar(@$leaves);
    }

    foreach $leaf (@$leaves)
    {
      if (defined $leaf and $leaf ne '') {
        if (!$cw->cget('-create') || -e "$path/$leaf")
         {
          foreach (@{$cw->cget('-verify')}) {
              my $r = ref $_;
              if (defined $r and $r eq 'ARRAY') {
                  #local $_ = $leaf; # use strict var problem here
                  return if not &{$_->[0]}($cw, $path, $leaf, @{$_}[1..$#{$_}]);
              } else {
                  my $s = eval "$_ '$path/$leaf'";
                  print $@ if $@;
                  if (not $s) {
                      my $err;
                      if (substr($_,0,1) eq '!')
                       {
                        my $t = substr($_,1);
                        if (exists $error_text{$t})
                         {
                          $err = $error_text{$t};
                          $err =~ s/\b(?:no|not) //;
                         }
                       }
                      $err = $error_text{$_} unless defined $err;
                      $err = "failed '$_' test" unless defined $err;
                      $cw->Error("'$leaf' $err.");
                      return;
                  } 
              }     
          } # forend
         }
        else
         {
          unless (-w $path)
           {
            $cw->Error("Cannot write to $path");
            return;
           }
         }
        $leaf = $path . '/' . $leaf;
      } else {
        $leaf =  undef;
      }
    }
    if (scalar(@$leaves))
    {
      my $sm = $cw->Subwidget('file_list')->cget(-selectmode);
      $cw->{Selected} = $leaves;
    }

} # end Accept

sub Accept_dir
{
 my ($cw,$new) = @_;
 my $dir  = $cw->cget('-directory');
 $cw->configure(-directory => "$dir/$new");
}


sub Populate {
    
    my ($w, $args) = @_;
    
    require Tk::Listbox;
    require Tk::Button;
    require Tk::Dialog;
    require Tk::Toplevel;
    require Tk::LabEntry;       
    require Cwd;         

    $w->SUPER::Populate($args);
    $w->protocol('WM_DELETE_WINDOW' => ['Cancel', $w ]);
    
    $w->{'reread'} = 0;  
    $w->withdraw;
    
    # Create filter (or directory) entry, place at the top.
    
    my $e = $w->Component(
        LabEntry       => 'dir_entry', 
        -textvariable  => \$w->{Directory},
        -labelVariable => \$w->{Configure}{-dirlabel},
    );
    $e->pack(-side => 'top', -expand => 0, -fill => 'x');
    $e->bind('<Return>' => [$w => 'validateDir', Ev(['get'])]);

    # Create file entry, place at the bottom.

    $e = $w->Component(
        LabEntry       => 'file_entry', 
        -textvariable => \$w->{Configure}{-initialfile},
        -labelVariable => \$w->{Configure}{-filelabel},
    );
    $e->pack(-side => 'bottom', -expand => 0, -fill => 'x');
    $e->bind('<Return>' => [$w => 'validateFile', Ev(['get'])]); 
    
    # Create directory scrollbox, place at the left-middle.
    
    my $b = $w->Component(
        ScrlListbox    => 'dir_list', 
        -labelVariable => \$w->{Configure}{-dirlistlabel},
        -scrollbars    => 'se',
    );
    $b->pack(-side => 'left', -expand => 1, -fill => 'both');
    $b->bind('<Double-Button-1>' => [$w => 'Accept_dir', Ev(['getSelected'])]);
    
    # Add a label.
    
    my $f = $w->Frame();
    $f->pack(-side => 'right', -fill => 'y', -expand => 0);
    $b = $f->Button('-text' => 'Accept', -command => [ 'Accept', $w ]);
    $b->pack(-side => 'top', -fill => 'x', -expand => 1);
    $b = $f->Button('-text' => 'Cancel', -command => [ 'Cancel', $w ]);
    $b->pack(-side => 'top', -fill => 'x', -expand => 1);
    $b = $f->Button( '-text'  => 'Reset', 
                     -command => [$w => 'configure','-directory','.'],
    );
    $b->pack(-side => 'top', -fill => 'x', -expand => 1);
    $b = $f->Button( '-text'  => 'Home', 
                     -command => [$w => 'configure','-directory',$ENV{'HOME'}],
    );
    $b->pack(-side => 'top', -fill => 'x', -expand => 1);
    
    # Create file scrollbox, place at the right-middle.
    
    $b = $w->Component(
        ScrlListbox    => 'file_list',
        -labelVariable => \$w->{Configure}{-filelistlabel},
        -scrollbars    => 'se',
    );
    $b->pack(-side => 'right', -expand => 1, -fill => 'both');
    $b->bind('<Double-1>' => [$w => 'Accept']);
    
    # Create -very dialog.

    my $v = $w->Component(
        Dialog   => 'dialog',
        -title   => 'Verify Error',
        -bitmap  => 'error',
        -buttons => ['Dismiss'],
    );
    
    $w->ConfigSpecs(
        -width           => [ ['file_list','dir_list'], undef, undef, 14 ], 
        -height          => [ ['file_list','dir_list'], undef, undef, 14 ], 
        -directory       => [ 'METHOD', undef, undef, '.' ],
        -initialdir      => '-directory', 
        -filelabel       => [ 'PASSIVE', undef, undef, 'File' ],
        -initialfile     => [ 'PASSIVE', undef, undef, '' ],
        -filelistlabel   => [ 'PASSIVE', undef, undef, 'Files' ],
        -filter          => [ 'METHOD', undef, undef, '*' ],
        -filterlabel     => [ 'PASSIVE', undef, undef, 'Files Matching' ],
        -regexp          => [ 'PASSIVE', undef, undef, undef ],
        -dirlistlabel    => [ 'PASSIVE', undef, undef, 'Directories'],
        -dirlabel        => [ 'PASSIVE', undef, undef, 'Directory'],
        '-accept'        => [ 'CALLBACK',undef,undef, undef ],
        -verify          => [ 'PASSIVE', undef, undef, ['!-d'] ],
        -create          => [ 'PASSIVE', undef, undef, 0 ],
        DEFAULT          => [ 'file_list' ],
    );
    $w->Delegates(DEFAULT => 'file_list');

    return $w;
    
} # end Populate

sub translate
  {
      my ($bs,$ch) = @_;
      return "\\$ch" if (length $bs);
      return ".*"  if ($ch eq '*');
 return "."   if ($ch eq '?');
 return "\\."  if ($ch eq '.');
 return "\\/" if ($ch eq '/');
 return "\\\\" if ($ch eq '\\');
 return $ch;
}

sub filter
{
 my ($cw,$val) = @_;
 my $var = \$cw->{Configure}{'-filter'};
 if (@_ > 1)
  {
   my $regex = $val;
   $$var = $val; 
   $regex =~ s/(\\?)(.)/&translate($1,$2)/ge;
   $cw->{'match'} = sub { shift =~ /^${regex}$/ };
   unless ($cw->{'reread'}++)
    {
     $cw->Busy;
     $cw->DoWhenIdle(['reread',$cw,$cw->cget('-directory')]) 
    }
  }
 return $$var;
}

sub directory
{
 my ($cw,$val) = @_;
 $cw->idletasks if $cw->{'reread'};
 my $var = \$cw->{Configure}{'-directory'};
 my $dir = $$var;
 if (@_ > 1 && defined $val)
  {
   if (substr($val,0,1) eq '~')
    {
     if (substr($val,1,1) eq '/')
      {
       $val = $ENV{'HOME'} . substr($val,1); 
      }
     else
      {my ($uid,$rest) = ($val =~ m#^~([^/]+)(/.*$)#);
       $val = (getpwnam($uid))[7] . $rest;
      }
    }
   unless ($cw->{'reread'}++)
    {
     $cw->Busy;
     $cw->afterIdle(['reread',$cw,$val]) 
    }
  }
 return $$var;
}

sub reread
{ 
 my ($w,$dir) = @_;
 my $pwd = Cwd::getcwd();
 unless ($^T)
  {
   if (chdir($dir))
    {
     my $new = Cwd::getcwd();
     if ($new)
      {
       $dir = $new;
      }
     else
      {
       carp "Cannot getcwd in '$dir'" unless ($new);
      }
     chdir($pwd) || carp "Cannot chdir($pwd) : $!"; 
    }
   else
    {
     $w->Unbusy;                                        
     $w->{'reread'} = 0;                                
     $w->{Directory} = $dir . "/" . $w->cget('-filter');
     $w->BackTrace("Cannot chdir($dir) :$!");
    }
  }
 if (opendir(DIR, $dir))                            
  {               
   my $file = $w->cget('-initialfile');
   my $seen = 0;
   $w->Subwidget('dir_list')->delete(0, "end");       
   $w->Subwidget('file_list')->delete(0, "end");      
   my $accept = $w->cget('-accept');                  
   my $f;                                           
   foreach $f (sort(readdir(DIR)))                  
    {                                               
     next if ($f eq '.');                           
     my $path = "$dir/$f";                          
     if (-d $path)                                  
      {                                             
       $w->Subwidget('dir_list')->insert('end', $f);
      }                                             
     else                                           
      {                                             
       if (&{$w->{match}}($f))                       
        {                                            
         if (!defined($accept) || $accept->Call($path))
          {  
           $seen = $w->Subwidget('file_list')->index('end') if ($file && $f eq $file);                                            
           $w->Subwidget('file_list')->insert('end', $f) 
          }                                          
        }                                            
      }                                             
    }                                               
   closedir(DIR);                                   
   if ($seen)
    {
     $w->Subwidget('file_list')->selectionSet($seen);
    }
   else
    {
     $w->configure(-initialfile => undef);
    }
   $w->{Configure}{'-directory'} = $dir;                                        
   $w->Unbusy;                                        
   $w->{'reread'} = 0;                                
   $w->{Directory} = $dir . "/" . $w->cget('-filter');
  }                                                 
 else
  {
   my $panic = $w->{Configure}{'-directory'};
   $w->Unbusy;                                        
   $w->{'reread'} = 0;                                
   chdir($panic) || $w->BackTrace("Cannot chdir($panic) : $!");
   $w->{Directory} = $dir . "/" . $w->cget('-filter');
   $w->BackTrace("Cannot opendir('$dir') :$!");
  }
} 

sub validateDir
{
 my ($cw,$name) = @_;
 my ($base,$leaf) = ($name =~ m#^(.*)/([^/]+)$#);
 if ($leaf =~ /[*?]/)
  {
   $cw->configure('-directory' => $base);
   $cw->configure('-filter' => $leaf);
  }
 else
  {
   $cw->configure('-directory' => $name);
  }
}

sub validateFile
{ 
 my ($cw,$name) = @_;
 my $i = 0;
 my $n = $cw->index('end');
 # See if it is an existing file
 for ($i= 0; $i < $n; $i++)
  {
   my $f = $cw->get($i);
   if ($f eq $name)
    {
     $cw->selection('set',$i);
     $cw->Accept;
    }
  }
 # otherwise allow if -create is set, directory is writable
 # and it passes filter and accept criteria
 if ($cw->cget('-create'))
  {
   my $path = $cw->cget('-directory');
   if (-w $path)
    {
     if (&{$cw->{match}}($name))                       
      {                                            
       my $accept = $cw->cget('-accept');                  
       my $full   = "$path/$name";
       if (!defined($accept) || $accept->Call($full))
        {                                          
         $cw->{Selected} = [$full];
        }                                          
       else
        {
         $cw->Error("$name is not 'acceptable'");
        }
      }                                            
     else
      {
       $cw->Error("$name does not match '".$cw->cget('-filter')."'");
      }
    }
   else
    {
     $cw->Error("Directory '$path' is not writable");
     return;
    }
  }
} 

sub Error
{
 my $cw  = shift;
 my $msg = shift;
 my $dlg = $cw->Subwidget('dialog');
 $dlg->configure(-text => $msg);
 $dlg->Show;
}

sub Show
{
 my ($cw,@args) = @_;
 $cw->Popup(@args); 
 $cw->waitVisibility;
 $cw->focus;
 $cw->waitVariable(\$cw->{Selected});
 $cw->withdraw;
 return defined($cw->{Selected}) 
      ? (wantarray) ? @{$cw->{Selected}} : $cw->{Selected}[0]
      : undef;

}

1;  

__END__

=head1 NAME

FileSelect - a widget for choosing files


=head1 SYNOPSIS

 use Tk::FileSelect;
 
 $FSref = $top->FileSelect(-directory => $start_dir);
               $top            - a window reference, e.g. MainWindow->new
               $start_dir      - the starting point for the FileSelect
 $file = $FSref->Show;
               Executes the fileselector until either a filename is
               accepted or the user hits Cancel. Returns the filename
               or the empty string, respectively, and unmaps the
               FileSelect.
 $FSref->configure(option => value[, ...])
               Please see the Populate subroutine as the configuration
               list changes rapidly.


=head1 DESCRIPTION

This Module pops up a Fileselector box, with a directory entry on
top, a list of directories in the current directory, a list of
files in the current directory, an entry for entering/modifying a
file name, an accept button and a cancel button.

You can enter a starting directory in the directory entry. After
hitting Return, the listboxes get updated. Double clicking on any
directory shows you the respective contents. Single clicking on a
file brings it into the file entry for further consideration,
double clocking on a file pops down the file selector and calls
the optional command with the complete path for the selected file.
Hitting return in the file selector box or pressing the accept
button will also work. *NOTE* the file selector box will only then
get destroyed if the file name is not zero length. If you want
yourself take care of it, change the if(length(.. in sub
accept_file.


=head1 AUTHORS

Based on original FileSelect by
Klaus Lichtenwalder, Lichtenwalder@ACM.org, Datapat GmbH, Munich,
April 22, 1995 adapted by
Frederick L. Wagner, derf@ti.com, Texas Instruments Incorporated, Dallas,
21Jun95


=head1 HISTORY 


=head2 950621 -- The following changes were made:

=over 4

=item *

Rewrote Tk stuff to take advantage of new Compound widget module, so
FileSelect is now composed of 2 LabEntry and 2 ScrlListbox2 
subwidgets.

=item *

Moved entry labels (from to the left of) to above the entry fields.

=item *

Caller is now able to control these aspects of widget, in both
FileSelect (new) and configure :

(Please see subroutine Populate for details, as these options 
change rapidly!)

=item *

I changed from Double-Button-1 to Button-1 in the Files listbox,
to work with multiple mode in addition to browse mode.  I also
made some name changes (LastPath --> saved_path, ...).

=item *

The show method is not yet updated.  

=item *

The topLevel stuff is not done yet.  I took it out while I toy with
the idea of FileSelect as a subwidget.  Then the 'normal' topLevel
thing with Buttons along the bottom could be build on top of it. 

=item *

By request of Henry Katz <katz@fs09.webo.dg.com>, I added the functionality
of using the Directory entry as a filter. So, if you want to only see the
*.c files, you add a .c (the *'s already there :) and hit return.

=back


=head2 95/10/17, SOL, LUCC.  lusol@Lehigh.EDU 

=over 4

=item *

 Allow either file or directory names to be accepted.

=item *

Require double click to move into a new directory rather than a single 
click.  This allows a single click to select a directory name so it can
be accepted.

=item *

Add -verify list option so that standard Perl file test operators (like
-d and -x) can be specified for further name validation.  The default
value is the special value '!-d' (not a directory), so any name can be
selected as long as it's not a directory - after all, this IS FileSelect!

For example:

    $fs->configure(-verify => ['-d', [\&verify_code, $P1, $P2, ... $Pn]]);

ensures that the selected name is a directory.  Further, if an element of
the list is an array reference, the first element is a code reference to a
subroutine and the remaining optional elements are it's parameters.  The
subroutine is called like this:

    &verify_code($cd, $leaf, $P1, $P2, ... $Pn);

where $cd is the current directory, $leaf is a directory or file name, and
$P1 .. $Pn are your optional parameters.  The subroutine should return TRUE
if success or FALSE if failure.

=back


=head2 961008 -- derf@ti.com :

By request of Jim Stern <js@world.northgrum.com> and Brad Vance
<bvance@ti.com>, I updated the Accept and Show functions to support 
selection of multiple files.  I also corrected a typo in the -verify code.

=cut 

