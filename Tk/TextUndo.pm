package Tk::TextUndo;
require Tk::Text;
use AutoLoader;

@ISA = qw(Tk::Text);

Tk::Widget->Construct('TextUndo');

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<L4>','undo');
 return $class->SUPER::ClassInit($mw);
}

sub undo
{
 my ($w) = @_; 
 if (exists $w->{UNDO})
  {
   if (@{$w->{UNDO}})
    {
     my ($op,@args) = @{pop(@{$w->{UNDO}})};
     $w->$op(@args);   
     $w->SetCursor($args[0]);
     return;
    }
  }
 $w->bell;
}

sub addUndo
{
 my ($w,$op,@args) = @_;
 $w->{UNDO} = [] unless (exists $w->{UNDO});
 push(@{$w->{UNDO}},['SUPER::'.$op,@args]);
 # print "add(",join(',',$op,@args),")\n";
}

sub topUndo
{
 my ($w) = @_;
 return undef unless (exists $w->{UNDO});
 return $w->{UNDO}[-1];
}

sub insert
{
 my ($w,$index,$str,@tags) = @_;
 my $s = $w->index($index);
 $w->markSet('notepos' => $s);
 $w->SUPER::insert($s,$str,@tags);
 # Combine 'trivial' inserts into clumps
 if (length($str) == 1 && $str ne "\n")
  {
   my $t = $w->topUndo;
   if ($t && $t->[0] =~ /delete$/ && $w->compare($t->[2],'==',$s))
    {
     $t->[2] = $w->index('notepos');
     return;
    }
  }
 $w->addUndo('delete',$s,$w->index('notepos'));
}

sub delete
{
 my $w = shift;
 my $str = $w->get(@_);
 my $s = $w->index(shift);
 $w->SUPER::delete($s,@_);
 $w->addUndo('insert',$s,$str);
}

1;
__END__

sub Save
{
 my $text = shift;
 my $file = (@_) ? shift : $text->{FILE};
 $text->BackTrace("No filename defined") unless (defined $file);
 if (open(FILE,">$file"))
  {
   my $index = '1.0';
   while ($text->compare($index,'<','end'))
    {
     my $end = $text->index("$index + 1024 chars");
     print FILE $text->get($index,$end);
     $index = $end;
    }
   delete $text->{UNDO} if (close(FILE));
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}



sub OldSave
{
 my $text = shift;
 my $file = (@_) ? shift : $text->{FILE};
 $text->BackTrace("No filename defined") unless (defined $file);
 if (open(FILE,">$file"))
  {
   print FILE $text->get('1.0','end');
   delete $text->{UNDO} if (close(FILE));
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}

sub Load
{
 my ($text,$file) = @_;
 if (open(FILE,"<$file"))
  {
   $text->MainWindow->Busy;
   $text->SUPER::delete('1.0','end');
   delete $w->{UNDO};
   while (<FILE>)
    {
     $text->SUPER::insert('end',$_);
    }
   close(FILE);
   $text->{FILE} = $file;
   $text->MainWindow->Unbusy;
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}



