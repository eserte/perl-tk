# An example of a geometry manager "widget" in perl
package Tk::Tiler;
require Tk::Frame;
@ISA = qw(Tk::Frame);

Tk::Widget->Construct('Tiler');

use Tk::Pretty;

sub focuschildren
{
 return (wantarray) ? () : 0;
}

sub Populate
{
 my ($obj,%args) = @_;
 $obj->{Slaves} = [];
 $obj->{LayoutPending} = 0;
 $obj->{Start} = 0;
 $obj->{Rows}  = 10;
 $obj->{Cols}  = 5;
 $obj->{Sw}    = 0;
 $obj->{Sh}    = 0;
 $obj->ConfigSpecs('-takefocus'      => [SELF, 'takeFocus','TakeFocus',1],
                   '-highlightthickness' => [SELF, 'highlightThickness','HighlightThickness',2],
                   '-yscrollcommand' => [CALLBACK,undef,undef,undef]
                  );
 return $obj;
}

sub Layout
{
 my $m = shift;
 my $bw = $m->cget(-highlightthickness);
 my $why = $m->{LayoutPending};
 $m->{LayoutPending} = 0;
 my $W = $m->Width;
 my $H = $m->Height;
 my $w = $m->{Sw};
 my $h = $m->{Sh};
 my $x = $bw; 
 my $y = $bw; 
 my $start = 0;
 my $s;
 if ($W < $w || $H < $h)
  {
   $W = 5*$w;                 
   $H = 10*$h;                
   $m->GeometryRequest($W,$H);
  }
 # Set size and position of slaves
 $m->{Cols}  = $cols = int($W/$w);
 $m->{Rows}  = $rows = int($H/$h);
 $m->{Need}  = $need = int( (@{$m->{Slaves}}+$cols-1)/$cols );
 $m->{Start} = $need - $rows if ($m->{Start} + $rows > $need);
 $m->{Start} = 0             if ($m->{Start} < 0);
 my $row = 0;
 my @posn  = ();
 foreach $s (@{$m->{Slaves}})
  {
   if ($row < $m->{Start})
    {
     $s->UnmapWindow;
     $x += $w;
     if ($x+$w > $W)
      {
       $x = $bw;
       $row++;
      }
    }
   elsif ($y+$h > $H)
    {
     $s->UnmapWindow;
     $s->ResizeWindow($w,$h) if ($why & 1);
    }
   else
    {
     push(@posn,[$s,$x,$y]);
     $x += $w;
     if ($x+$w > $W)
      {
       $x = $bw;
       $y += $h;
       $row++;
      }
    }
   $s->ResizeWindow($w,$h) if ($why & 1);
  }
 $row++ if ($x);
 if (defined $m->{Prev} && $m->{Prev} > $m->{Start})
  {
   @posn = reverse(@posn);
  }
 while (@posn)
  {
   my $posn = shift(@posn);
   my ($s,$x,$y) = (@$posn);
   $s->MoveWindow($x,$y);
   $s->MapWindow;
  }
 $m->{Prev} = $m->{Start};
 if (defined ($cb = $m->cget('-yscrollcommand')))
  {
   $cb->Call($m->{Start}/$need,$row/$need);
  }
}

sub QueueLayout
{
 my ($m,$why) = @_;
 $m->DoWhenIdle(['Layout',$m]) unless ($m->{LayoutPending});
 $m->{LayoutPending} |= $why;
}

sub SlaveGeometryRequest
{
 my ($m,$s) = @_;
 my $sw = $s->ReqWidth;
 my $sh = $s->ReqHeight;
 if ($sw > $m->{Sw})
  {
   $m->{Sw} = $sw;
   $m->QueueLayout(1);
  }
 if ($sh > $m->{Sh})
  {
   $m->{Sh} = $sh;
   $m->QueueLayout(1);
  }
}

sub LostSlave
{
 my ($m,$s) = @_;
 @{$m->{Slaves}} = grep($_ != $s,@{$m->{Slaves}});
 $m->QueueLayout(2);
}

sub Manage
{
 my $m = shift;
 my $s;
 foreach $s (@_)
  {
   $m->ManageGeometry($s);      
   push(@{$m->{Slaves}},$s);    
   $m->SlaveGeometryRequest($s);
  }
 $m->QueueLayout(2);
}

sub moveto
 {
  my ($m,$frac) = (@_);
  $m->{Start} = int($m->{Need} * $frac);
  $m->QueueLayout(4);
 }

sub scroll
 {
  my ($m,$delta,$type) = @_;
  $delta *= $m->{Rows}/2 if ($type eq 'pages');
  $m->{Start} += $delta;
  $m->QueueLayout(4);
 }

sub yview { my $w = shift; my $c = shift; $w->$c(@_) }

sub FocusIn
{
 my ($w) = @_;
 print "Focus ",$w->PathName,"\n";
}

sub classinit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Configure>',['QueueLayout',8]);
 $mw->bind($class,'<Up>',       ['scroll',-1,'units']);
 $mw->bind($class,'<Down>',     ['scroll',1,'units']);
 $mw->bind($class,'<Next>',     ['scroll',1,'pages']);
 $mw->bind($class,'<Prior>',    ['scroll',-1,'pages']);
 $mw->bind($class,'<Home>',     ['moveto',0]);
 $mw->bind($class,'<End>',      ['moveto',1]);
 $mw->bind($class,'<FocusIn>',  'NoOp');
 return $class;
}

1;
