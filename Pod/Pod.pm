package Tk::Pod;
require Tk::Toplevel;
require Tk::Text;
require Tk::Menubar;
use Tk qw(Ev);
use AutoLoader;
use Carp;
use Tk::Pretty;
use Tk::Parse;
@ISA = qw(Tk::Toplevel);

Tk::Widget->Construct('Pod');

BEGIN { @POD = @INC };

sub Dir
{
 my $class = shift;
 unshift(@POD,@_);
}

sub Find
{
 my ($file) = @_;
 my $dir;
 foreach $dir ("",@POD)
  {
   my $prefix;
   foreach $prefix ("","pod/")
    {
     my $suffix;
     foreach $suffix ("",".pod",".pm")
      {
       my $path = "$dir/" . $prefix . $file . $suffix;
       return $path if (-r $path && -T $path);
       $path =~ s,::,/,g;
       return $path if (-r $path && -T $path);
      }
    }
  }
 croak("Cannot find pod for $file in \@INC");
}

sub file {
  my $w = shift;
  if (@_)
    {
      my $file = shift;
      $w->{'File'} = $file;
      my $path = Find($file);
      $w->configure('-path' => $path);
      $w->delete('1.0' => 'end');
      use Benchmark;
      # my $t = new Benchmark;
      $w->process($path);
      # print &timediff(new Benchmark, $t)->timestr,"\n";
    }
  else
    {
      return $w->{'File'};
    }
}

sub reload
{
 my ($w) = @_;
 $w->Busy;
 $w->delete('0.0','end');
 $w->process($w->cget('-path'));
 $w->Unbusy;
}

sub edit
{
 my ($w) = @_;
 my $path = $w->cget('-path');
 my $edit = $ENV{'EDITOR'};
 if (defined $edit)
  {
   if (fork)
    {
     wait; # parent
    }
   else
    {
     #child
     if (fork)
      {
       # still child
       exec("true");
      }
     else
      {
       # grandchild 
       exec("$edit $path");
      }
    }
  }
}

sub Populate
{
 my ($w,$args) = @_;
 $w->SUPER::Populate($args);
 my $path = $args->{-path};
 my $p = $w->Component('Text' => 'pod', -wrap => 'word',
                       -background => 'white',
                       -font => $w->Font(family => 'courier'));
 $p->pack(-expand => 1, -fill => 'both');
 $w->AddScrollbars($p,$args{'-scrollbars'});

 $p->tag('configure','text', -font => $w->Font(family => 'times'));
 $p->tag('configure','C',-font => $w->Font(family => 'courier', weight => 'bold'));
 $p->tag('configure','S',-font => $w->Font(family => 'courier', weight => 'bold', slant => 'o'));
 $p->tag('configure','B',-font => $w->Font(family => 'times', weight => 'bold' ));
 $p->tag('configure','I',-font => $w->Font(family => 'times',slant => 'i', weight => 'bold' ));
 $p->tag('configure','S',-font => $w->Font(family => 'times',slant => 'i' ));
 $p->tag('configure','F',-font => $w->Font(family => 'helvetica', weight => 'bold'));
 $p->insert('0.0',"\n");

 $w->{List}   = []; # stack of =over
 $w->{Item}   = undef;
 $w->{'indent'} = 0;
 $w->{Length}  = 64;
 $w->{Indent}  = {}; # tags for various indents
 $p->bind('<Double-1>',[$w, 'DoubleClick']);


 my $mbar = $w->Component('Menubar' => 'menubar');
 my $file = $mbar->Component('Menubutton' => 'file', '-text' => 'File', '-underline' => 0);
 $file->pack('-side' => 'left','-anchor' => 'w');
 $file->command('-label' => 'Quit',  '-underline' => 0, '-command' => ['quit',$w] );
 $file->command('-label' => 'Re-Read',  '-underline' => 0, '-command' => ['reload',$w] );
 $file->command('-label' => 'Edit',  '-underline' => 0, '-command' => ['edit',$w] );

 my $help = $mbar->Component('Menubutton' => 'help', '-text' => 'Help', '-underline' => 0);
 $help->pack('-side' => 'right','-anchor' => 'e');

 $mbar->pack('-side' => 'top', '-fill' => 'x', '-before' => ($w->packSlaves)[0]);
 $w->Delegates(Menubutton => $mbar, DEFAULT => $p);
 $w->ConfigSpecs('-file' =>   ['METHOD',undef,undef,undef],
                 -path   =>   ['PASSIVE',undef,undef,undef],
                 -scrollbars => ['METHOD','scrollbars','Scrollbars','w'],
                 DEFAULT => [$p]);
 # $w->process($path);
 $args->{-width} = $w->{Length};
 $w->protocol('WM_DELETE_WINDOW',['quit',$w]);
}

sub quit
{
 my ($w) = @_;
 my $p = $w->parent;
 $w->destroy;
 foreach $w ($p->children)
  {
   return if ($w->toplevel eq $w);
  }
 $p->destroy if ($p->state eq 'withdrawn');
}

%tag = qw(C 1 B 1 I 1 L 1 F 1 S 1 Z 1);

sub Font
{
 my ($w,%args)    = @_;
 $args{'family'}  = 'times'  unless (exists $args{'family'});
 $args{'weight'}  = 'medium' unless (exists $args{'weight'});
 $args{'slant'}   = 'r'      unless (exists $args{'slant'});
 $args{'size'}    = 140      unless (exists $args{'size'});
 $args{'spacing'} = '*'     unless (exists $args{'spacing'});
 $args{'slant'}   = substr($args{'slant'},0,1);
 my $name = "-*-$args{'family'}-$args{'weight'}-$args{'slant'}-*-*-*-$args{'size'}-*-*-$args{'spacing'}-*-iso8859-1";
 return $name;
}

sub DoubleClick
{
 my ($w) = @_;
 my $sel = $w->SelectionGet;
 if (defined $sel)
  {
   $w->MainWindow->Pod('-file' => $sel);
  }
}

sub Link
{
 my ($w,$index,$link) = @_;
 my (@range) = $w->tag('nextrange',$link,$index);
 if (@range == 2)
  {
   $w->see($range[0]);
  }
 else
  {
   my $mw = $w->MainWindow;
   my $man = $link;
   my $sec;
   ($man,$sec) = split(m#/#,$link) if ($link =~ m#/#);
   $mw->Pod('-file' => $man);
  }
}

%translate =
(
 'lt' => '<',
 'gt' => '>',
 'amp' => '&'
 );

# '<' and '>' have been replaced with \x7f because E<..> have been
# turned into real characters.
sub _expand
{
 my ($w,$line) = @_;

 if ($line =~ /^(.*?)\b([A-Z])\x7f(.*?)\x7f(.*)$/)
  {
   my ($pre,$tag,$what,$post) = ($1,$2,$3,$4);
   $w->insert('end -1c',$pre);
    {
     my $start = $w->index('end -1c');
     $what = $w->_expand($what);         
     if ($tag eq 'L')
      {
       $tag = '!'.$what;
       $w->tag('bind',$tag,'<Button-1>',[$w,'Link',Ev('@%x,%y'),$what]);
       $w->tag('configure',$tag,-underline=> 1, -font => $w->Font(family => 'times',slant => 'i'));
      }
     $w->tag('add',$tag,$start,'end -1c');
    }
   $post = $w->_expand($post);
   return $pre . $what . $post;
  }
 else
  {
   $w->insert('end -1c',$line);
   return $line;
  }
}

sub expand
{
 my ($w,$line) = @_;

 $line =~ s/[<>]/\x7f/g;

 $line =~ s/E\x7f([a-z]*)\x7f/$translate{$1}/g;
 return (_expand ($w, $line));
}

sub append
{
 my $w = shift;
 my $line;
 foreach $line (@_)
  {
   $w->expand($line);
  }
}

sub text
{
 my ($w,$body) = @_;
 $body = join(' ',split(/\s*\n/,$body));
 my $start = $w->index('end -1c');
 $w->append($body,"\n\n");
 $w->tag('add','text',$start,'end -1c');
}

sub verbatim
{
 my ($w,$body) = @_;
 my $line;
 foreach $line (split(/\n/,$body))
  {
   # Really need to have length after tabs expanded.
   my $l = length($line)+$w->{indent};
   if ($l > $w->{Length})
    {
     $w->{Length} = $l;
     $w->configure(-width => $l) if ($w->viewable);
    }
  }
 $w->insert('end -1c',$body . "\n\n",['verbatim']);
}

sub head1
{
 my ($w,$title) = @_;
 my $start = $w->index('end -1c');
 $w->append($title);
 $num = 2 unless (defined $num);
 $w->tag('add',$title,$start,'end -1c');
 $w->tag('configure',$title,-font => $w->Font(family => 'times', 
         weight => 'bold',size => 180));
 $w->tag('raise',$title,'text');
 $w->append("\n\n");
}

sub head2
{
 my ($w,$title) = @_;
 my $start = $w->index('end -1c');
 $w->append($title);
 $w->tag('add',$title,$start,'end -1c');
 $w->tag('configure',$title,
         -font => $w->Font(family => 'times', weight => 'bold'));
 $w->tag('raise',$title,'text');
 $w->append("\n\n");
}

sub IndentTag
{
 my ($w,$indent) = @_;
 my $tag = "Indent" . ($indent+0);
 unless (exists $w->{Indent}{$tag})
  {
   $w->{Indent}{$tag} = $indent;
   $indent *= 8;
   $w->tag('configure',$tag,
           -lmargin2 => $indent . 'p', 
           -rmargin  => $indent . 'p', 
           -lmargin1 => $indent . 'p'
          );
  }
 return $tag;
}

sub enditem
{
 my ($w) = @_;
 my $item = delete $w->{Item};
 if (defined $item)
  {
   my ($start,$indent) = @$item;
   $w->tag('add',$w->IndentTag($indent),$start,'end -1c');
  }
}

sub item
{
 my ($w,$title) = @_;
 $w->enditem;
 my $type = $w->{listtype};
 my $indent = $w->{indent};
 print "item(",join(',',@_,$type,$indent),")\n" unless ($type == 1 || $type == 3);
 my $start = $w->index('end -1c');
 $title =~ s/\n/ /;
 $w->append($title);
 $w->tag('add',$title,$start,'end -1c');
 $w->tag('configure',$title,-font => $w->Font(weight => 'bold'));
 $w->tag('raise',$title,'text');
 $w->append("\n") if ($type == 3);
 $w->append(" ")  if ($type != 3);
 $w->{Item} = [ $w->index('end -1c'), $w->{indent} ];
}

sub setindent 
{ 
 my ($w,$arg) = @_; 
 $w->{'indent'} = $arg 
}

sub listbegin 
{ 
 my ($w) = @_;
 my $item = delete $w->{Item};
 push(@{$w->{List}},$item);
}

sub listend
{
 my ($w) = @_;
 $w->enditem;
 $w->{Item} = pop(@{$w->{List}});
}

sub over { } 

sub back { } 

sub filename
{
 my ($w,$title) = @_;
 $w->toplevel->title($title);
}

sub setline   {}
sub setloc    {}
sub endfile   {}
sub listtype  { my ($w,$arg) = @_; $w->{listtype} = $arg }
sub cut       {} 


sub process
{
 my ($w,$file) = @_;
 my @save = @ARGV;
 @ARGV = $file;
 print STDERR "Parsing $file\n";
 my (@pod) = Simplify(Parse());
 my ($cmd,$arg);
 print STDERR "Render $file\n";
 my $update = 2;
 while ($cmd = shift(@pod))
  {
   my $arg = shift(@pod);
   $w->$cmd($arg);
   unless ($update--) {
     $w->update;
     $update = 2;
   } 
  }
 @ARGV = @save;
}

1;
__END__

sub old_process
{
 my ($w,$file) = @_;
 open($file,"<$file") || die "Cannot open $file:$!";
 $w->filename($file);
 $/ = "";  
 my $cutting = 1;
 while (<$file>)
  {
   if ($cutting)
    {
     next unless /^=/;
     $cutting = 0;
    }
   chomp;
   if (/^\s/)
    {
     $w->verbatim($_);
    }
   elsif (/^=/)
    {
     my ($cmd,$num,$title) = /^=([a-z]+)(\d*)\s*([^\0]*)$/ ;
     die "$_" unless (defined $cmd);
     if ($cmd eq 'cut')
      {
       $cutting = 1;
      }
     else
      {
       $w->$cmd($title,$num);
      }
    }
   else
    {
     $w->text($_);
    }
  }
 close($file);
}





