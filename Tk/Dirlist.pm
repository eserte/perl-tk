package Tk::Dirlist;
require Tk::Derived;
require Tk::HList;
require DirHandle;
use Cwd;
@ISA = qw(Tk::Derived Tk::HList);
use strict;
Construct Tk::Widget 'Dirlist';

sub getimage
{
 my ($w,$key) = @_;
 unless (exists $w->{$key})
  {
   my $file = Tk->findINC("$key.xpm");
   $w->{$key} = $w->Pixmap(-file => $file) if ($file);
   unless ($w->{$key})
    {
     $file = Tk->findINC("$key.xbm");
     $w->{$key} = $w->Bitmap(-file => $file) if ($file);
    }
   print "$key file=$file\n";
  }
 return $w->{$key}; 
}


sub Populate
{
 my ($cw,$args) = @_;
 $cw->configure(-separator => '/', -itemtype => 'imagetext');
 $cw->ConfigSpecs(-directory => ['SETMETHOD','directory','Directory','.']);
}

sub fullpath
{
 my ($path) = @_;
 my $cwd = getcwd;
 if (chdir($path))
  {
   $path = getcwd;
   chdir($cwd);
  }
 else
  {
   warn "Cannot cd to $path:$!"
  }
 print "$path\n";
 return $path;
}

sub AddDir
{
 my ($w,$dir) = @_;
 my $path = "";
 my $prefix = "";
 my $first = 0;
 my $name;
 foreach $name (split m#/#,$dir)
  {
   $first++;
   if ($name eq "")
    {
     next unless ($first == 1);
     $path = '/';
     $name = '/';
    }
   else
    {
     $path .= $prefix;
     $path .= $name;
     $prefix = '/';
    }
   unless ($w->info('exists' => $path))
    {
     print "Add $path\n";
     $w->add($path,-image => $w->getimage('folder'), -text => $name);
    }
  }
}

sub choose_image
{
 my ($w,$path) = @_;
 return "folder" if (-d $path);
 return "srcfile"  if ($path =~ /\.[ch]$/);
 return "textfile" if (-T $path);
 return "file";
}


sub directory
{
 my ($w,$key,$val) = @_;
 my $h = DirHandle->new($val);
 $w->AddDir($val = fullpath($val));
 my $f;
 $w->entryconfigure($val,-image => $w->getimage('openfolder'));
 foreach $f (sort $h->read)
  {
   next if ($f =~ /^\.+$/);
   my $path = "$val/$f";
   unless ($w->info('exists' => $path))
    {
     my $image = $w->getimage($w->choose_image($path));
     $w->add($path,-image => $image, -text => $f);
    }
  }
 $h->close;
}

1;
