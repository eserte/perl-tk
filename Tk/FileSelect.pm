package Tk::FileSelect;

use vars qw($VERSION);
$VERSION = '3.029'; # $Id: //depot/Tk8/Tk/FileSelect.pm#29$

use Tk qw(Ev);
use strict;
use Carp;
use base qw(Tk::Toplevel);
use Tk::widgets qw(LabEntry Button Frame Listbox Scrollbar);

Construct Tk::Widget 'FileSelect';

# Documentation after __END__

sub import {
    if (defined $_[1] and $_[1] eq 'as_default') {
	local $^W = 0;
	package Tk;
	*FDialog      = \&Tk::FileSelect::FDialog;
	*MotifFDialog = \&Tk::FileSelect::FDialog;
    }
}

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
        -width            => [ ['file_list','dir_list'], undef, undef, 14 ],
        -height           => [ ['file_list','dir_list'], undef, undef, 14 ],
        -directory        => [ 'METHOD', undef, undef, '.' ],
        -initialdir       => '-directory',
        -filelabel        => [ 'PASSIVE', 'fileLabel', 'FileLabel', 'File' ],
        -initialfile      => [ 'PASSIVE', undef, undef, '' ],
        -filelistlabel    => [ 'PASSIVE', undef, undef, 'Files' ],
        -filter           => [ 'METHOD',  undef, undef, undef ],
        -defaultextension => [ 'SETMETHOD',  undef, undef, undef ],
        -regexp           => [ 'PASSIVE', undef, undef, undef ],
        -dirlistlabel     => [ 'PASSIVE', undef, undef, 'Directories'],
        -dirlabel         => [ 'PASSIVE', undef, undef, 'Directory'],
        '-accept'         => [ 'CALLBACK',undef,undef, undef ],
        -verify           => [ 'PASSIVE', undef, undef, ['!-d'] ],
        -create           => [ 'PASSIVE', undef, undef, 0 ],
        DEFAULT           => [ 'file_list' ],
    );
    $w->Delegates(DEFAULT => 'file_list');

    return $w;

} # end Populate

sub translate
  {
      my ($bs,$ch) = @_;
      return "\\$ch" if (length $bs);
      return '.*'  if ($ch eq '*');
 return '.'   if ($ch eq '?');
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

sub defaultextension
{
 my ($cw,$key,$val) = @_;
 $val = ".$val" if ($val !~ /^\./);
 $cw->filter("*$val");
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
 if (!defined $w->cget('-filter') or $w->cget('-filter') eq '')
  {
   $w->configure('-filter', '*');
  }
 unless (Tk::tainting())
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
     $w->{Directory} = $dir . '/' . $w->cget('-filter');
     $w->BackTrace("Cannot chdir($dir) :$!");
    }
  }
 if (opendir(DIR, $dir))
  {
   my $file = $w->cget('-initialfile');
   my $seen = 0;
   $w->Subwidget('dir_list')->delete(0, 'end');
   $w->Subwidget('file_list')->delete(0, 'end');
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
     $w->Subwidget('file_list')->see($seen);
    }
   else
    {
     $w->configure(-initialfile => undef) unless $w->cget('-create');
    }
   $w->{Configure}{'-directory'} = $dir;
   $w->Unbusy;
   $w->{'reread'} = 0;
   $w->{Directory} = $dir . '/' . $w->cget('-filter');
  }
 else
  {
   my $panic = $w->{Configure}{'-directory'};
   $w->Unbusy;
   $w->{'reread'} = 0;
   chdir($panic) || $w->BackTrace("Cannot chdir($panic) : $!");
   $w->{Directory} = $dir . '/' . $w->cget('-filter');
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
       $cw->Error("$name does not match '".$cw->cget('-filter').'\'');
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

sub FDialog
{
 my($cmd, %args) = @_;
 if ($cmd =~ /Save/)
  {
   $args{-create} = 1;
   $args{-verify} = [qw(!-d -w)];
  }
 delete $args{-filetypes};
 delete $args{-force};
 Tk::DialogWrapper('FileSelect',$cmd, %args);
}

1;

__END__

=cut

