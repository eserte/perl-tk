# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Table;
use strict;
use Tk::Pretty;
use AutoLoader;
require Tk::Frame;
@Tk::Table::ISA = qw(Tk::Frame);
Construct Tk::Widget 'Table';

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Configure>',['QueueLayout',8]);
 $mw->bind($class,'<FocusIn>',  'NoOp');
 $mw->XYscrollBind($class);
 return $class;
}

sub _view
{
 my ($t,$s,$page,$a,$op,$num,$type) = @_;
 if ($op eq 'moveto')
  {
   $$s = int(@$a*$num);
  }
 else
  {
   $num *= ($page/2) if ($type eq 'pages');
   $$s += $num;
  }
 $$s = 0 if ($$s < 0);
 $t->QueueLayout(4);
}

sub xview
{
 my $t  = shift;
 $t->_view(\$t->{Left},$t->cget('-columns'),$t->{Width},@_);
}

sub yview
{
 my $t  = shift;
 $t->_view(\$t->{Top},$t->cget('-rows'),$t->{Height},@_);
}

sub FocusChildren
{
 return (wantarray) ? () : 0;
}
                                        
sub Populate
{
 my ($t,$args) = @_;
 $t->SUPER::Populate($args);
 $t->ConfigSpecs('-scrollbars'         => [METHOD   => 'scrollbars','Scrollbars','nw'],
                 '-takefocus'          => [SELF => 'takeFocus','TakeFocus',1],
                 '-rows'               => [METHOD => 'rows','Rows',10],
                 '-fixedrows'          => [METHOD => 'fixedRows','FixedRows',0],
                 '-columns'            => [METHOD => 'columns','Columns',10],
                 '-fixedcolumns'       => [METHOD => 'fixedColumn','FixedColumns',0],
                 '-highlightthickness' => [SELF => 'highlightThickness','HighlightThickness',2]
                 );
 $t->{'Width'}  = [];
 $t->{'Height'} = [];
 $t->{'Row'}    = [];
 $t->{'Slave'}  = {};
 $t->{'Top'}    = 0;
 $t->{'Left'}   = 0;
 $t->{'Bottom'} = 0;
 $t->{'Right'}  = 0;
 $t->{LayoutPending} = 0;
}

sub sizeN
{
 my ($n,$a) = @_;
 my $max = 0;
 my $i = 0;
 my $sum = 0;
 while ($i < @$a && $i < $n)
  {
   my $n = $a->[$i++];
   $a->[$i-1] = $n = 0 unless (defined $n);
   $sum += $n;
  }
 $max = $sum if ($sum > $max);
 while ($i < @$a)
  {
   $sum = $sum-$a->[$i-$n]+$a->[$i];
   $max = $sum if ($sum > $max);
   $i++;
  }
 return $max;
}


sub total
{
 my ($a)   = @_;
 my $total = 0;
 my $x;
 foreach $x (@{$a})
  {
   $total += $x;
  }
 return $total;
}

sub constrain
{
 my ($sb,$a,$pixels,$fixed) = @_;
 my $n     = $$sb+$fixed;
 my $total = 0;
 my $i;
 $n = @$a if ($n > @$a);
 $n = $fixed if ($n < $fixed);
 for ($i= 0; $i < $fixed; $i++)
  {
   $total += $a->[$i];
  }
 for ($i=$n; $total < $pixels && $i < @$a; $i++)
  {
   $total += $a->[$i];
  }
 while ($n > $fixed)
  {
   if (($total += $a->[--$n]) > $pixels)
    {
     $n++;
     last;
    }
  }
 $$sb = $n-$fixed;
}

sub Layout
{
 my ($t)    = @_;
 my $rows   = @{$t->{Row}};
 my $bw     = $t->cget(-highlightthickness);
 my $frows  = $t->cget(-fixedrows);
 my $fcols  = $t->cget(-fixedcolumns);
 my $sb     = $t->cget(-scrollbars);
 my $H      = $t->Height;
 my $W      = $t->Width; 
 my $tadj   = $bw; 
 my $badj   = $bw; 
 my $ladj   = $bw; 
 my $radj   = $bw; 
 my @xs     = ($W,0,0,0);
 my @ys     = (0,$H,0,0);
 my $xsb;
 my $ysb;

 my $why   = $t->{LayoutPending};
 $t->{LayoutPending} = 0;

 if ($sb =~ /^[ns]/)
  {
   $t->{xsb} = $t->Scrollbar(-orient => 'horizontal', -command => ['xview' => $t]) unless (defined $t->{xsb});
   $xsb   = $t->{xsb};
   $xs[3] = $xsb->ReqHeight;
   if ($sb =~ /^n/)
    {
     $xs[1] = $tadj;
     $tadj += $xs[3];
    }
   else
    {
     $badj += $xs[3];
     $xs[1] = $H-$badj;
    }
  }
 else
  {
   $t->{xsb}->UnmapWindow if (defined $t->{xsb});
  }

 if ($sb =~ /[ew]$/)
  {
   $t->{ysb} = $t->Scrollbar(-orient => 'vertical', -command => ['yview' => $t]) unless (defined $t->{ysb});
   $ysb    = $t->{ysb};
   $ys[2]  = $ysb->ReqWidth;
   if ($sb =~ /w$/)
    {
     $ys[0] = $ladj;
     $ladj += $ys[2];
    }
   else
    {
     $radj += $ys[2];
     $ys[0] = $W-$radj;
    }
  }
 else
  {
   $t->{ysb}->UnmapWindow if (defined $t->{ysb});
  }

 constrain(\$t->{Top}, $t->{Height},$H-($tadj+$badj),$frows);
 constrain(\$t->{Left},$t->{Width}, $W-($ladj+$radj),$fcols);

 my $top  = $t->{Top}+$frows;
 my $left = $t->{Left}+$fcols;

 if ($why & 49)  
  {
   # Width and/or Height of element or 
   # number of rows and/or columns or
   # scrollbar presence has changed
   my $w = sizeN($t->cget('-columns'),$t->{Width})+$radj+$ladj;
   my $h = sizeN($t->cget('-rows'),$t->{Height})+$tadj+$badj;
   $t->GeometryRequest($w,$h);
  }

 if ($rows)
  {
   my $cols  = @{$t->{Width}};
   my $yhwm  = $top-$frows;
   my $xhwm  = $left-$fcols;
   my $y     = $tadj;
   my $r;
   for ($r = 0; $r < $rows; $r++)
    {
     my $h = $t->{Height}[$r];
     if (($r < $top && $r >= $frows) || ($y+$h > $H-$badj))
      {
       if (defined $t->{Row}[$r])
        {
         my $c;
         for ($c = 0; $c < @{$t->{Row}[$r]}; $c++)
          {
           my $s = $t->{Row}[$r][$c];
           if (defined $s)
            {
             $s->UnmapWindow;
             if ($why & 1)
              {
               my $w = $t->{Width}[$c]; 
               $s->ResizeWindow($w,$h);
              }
            }
          }
        }
      }
     else 
      {
       my $hwm  = $left-$fcols;
       my $sh   = 0;
       my $x    = $ladj;
       my $c;
       $ys[1] = $y if ($y < $ys[1] && $r >= $frows);
       for ($c = 0; $c <$cols; $c++)
        {
         my $s = $t->{Row}[$r][$c];
         my $w = $t->{Width}[$c]; 
         if (($c < $left && $c >= $fcols) || ($x+$w > $W-$radj) )
          {
           if (defined $s)
            {
             $s->UnmapWindow;
             $s->ResizeWindow($w,$h) if ($why & 1);
            }
          }
         else
          {
           $xs[0] = $x if ($x < $xs[0] && $c >= $fcols);
           if (defined $s)
            {
             if ($why & 1)
              {
               $s->MoveResizeWindow($x,$y,$w,$h);
              }
             else
              {
               $s->MoveWindow($x,$y);
              }
             $s->MapWindow;
            }
           $x     += $w;
           if ($c >= $fcols)
            {
             $hwm++;      
             $sh    += $w 
            }
          }
        }
       $xhwm = $hwm if ($hwm > $xhwm);
       $xs[2] = $sh if ($sh > $xs[2]);
       $y     += $h;
       if ($r >= $frows)
        {
         $ys[3] += $h;
         $yhwm++;
        }
      }
    }
   $t->{Bottom} = $yhwm;
   $t->{Right}  = $xhwm;
   if (defined $xsb && $xs[2] > 0)
    {
     $xsb->MoveResizeWindow(@xs);
     $cols -= $fcols; 
     if ($cols > 0)
      {
       $xsb->set($t->{Left}/$cols,$t->{Right}/$cols);
       $xsb->MapWindow;
      }
    }
   if (defined $ysb && $ys[3] > 0)
    {
     $ysb->MoveResizeWindow(@ys);
     $rows -= $frows;
     if ($rows > 0)
      {
       $ysb->set($t->{Top}/$rows,$t->{Bottom}/$rows);
       $ysb->MapWindow;
      }
    }
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
 my ($row,$col) = @{$m->{Slave}{$s->PathName}};
 my $sw = $s->ReqWidth;
 my $sh = $s->ReqHeight;
 my $sz = 0;
 if ($sw > $m->{Width}[$col])
  {
   $m->{Width}[$col] = $sw;
   $m->QueueLayout(1);
   $sz++;
  }
 if ($sh > $m->{Height}[$row])
  {
   $m->{Height}[$row] = $sh;
   $m->QueueLayout(1);
   $sz++;
  }
 if (!$sz)
  {
   $s->ResizeWindow($m->{Width}[$col],$m->{Height}[$row]);
  }
}

sub get
{
 my ($t,$row,$col) = @_;
 return $t->{Row}[$row][$col];
}

sub LostSlave
{
 my ($t,$s) = @_;
 my $info   = delete $t->{Slave}{$s->PathName};
 if (defined $info)
  {
   my ($row,$col) = @$info;
   $t->{Row}[$row][$col] = undef;
   $s->UnmapWindow;
  }
 else
  {
   $t->BackTrace("Cannot find" . $s->PathName);
  }
 $t->QueueLayout(2);
}

sub put
{
 my ($t,$row,$col,$w) = @_;
 $w = $t->Label(-text => $w) unless (ref $w);
 $t->ManageGeometry($w);
 unless (defined $t->{Row}[$row])
  {
   $t->{Row}[$row] = []; 
   $t->{Height}[$row] = 0; 
  }
 unless (defined $t->{Width}[$col])
  {
   $t->{Width}[$col] = 0;
  }
 my $old = $t->{Row}[$row][$col];
 if (defined $old)
  {
   $old->UnmanageGeometry;
   $t->LostSlave($old);
  }
 $t->{Row}[$row][$col] = $w;
 $t->{Slave}{$w->PathName} = [$row,$col];
 $t->SlaveGeometryRequest($w);
 $t->QueueLayout(2);
 return $old;
}

#
# configure methods
#

sub scrollbars
{
 my ($t,$v) = @_;
 if (@_ > 1)
  {
   $t->_configure(-scrollbars => $v);
   $t->QueueLayout(32);
  }
 return $t->_cget('-scrollbars');
}

sub rows
{
 my ($t,$r) = @_;
 if (@_ > 1)
  {
   $t->_configure(-rows => $r);
   $t->QueueLayout(16);
  }
 return $t->_cget('-rows');
}

sub fixedrows
{
 my ($t,$r) = @_;
 if (@_ > 1)
  {
   $t->_configure(-fixedrows => $r);
   $t->QueueLayout(16);
  }
 return $t->_cget('-fixedrows');
}

sub columns
{
 my ($t,$r) = @_;
 if (@_ > 1)
  {
   $t->_configure(-columns => $r);
   $t->QueueLayout(16);
  }
 return $t->_cget('-columns');
}

sub fixedcolumns
{
 my ($t,$r) = @_;
 if (@_ > 1)
  {
   $t->_configure(-fixedcolumns => $r);
   $t->QueueLayout(16);
  }
 return $t->_cget('-fixedcolumns');
}

1;
__END__
sub Create
{
 my $t = shift;
 my $r = shift;
 my $c = shift;
 my $kind = shift;
 $t->put($r,$c,$t->$kind(@_));
}

sub totalColumns
{
 scalar @{shift->{'Width'}};
}

sub totalRows
{
 scalar @{shift->{'Height'}};
}

sub Posn
{
 my ($t,$s) = @_;
 my $info   = $t->{Slave}{$s->PathName};
 return (wantarray) ? @$info : $info;
}

sub see
{
 my $t = shift;
 my ($row,$col) = (@_ == 2) ? @_ : @{$t->{Slave}{$_[0]->PathName}};
 my $see = 1;
 if (($row -= $t->cget('-fixedrows')) >= 0)
  {
   if ($row < $t->{Top})
    {
     $t->{Top} = $row;
     $t->QueueLayout(4);
     $see = 0;
    }
   elsif ($row >= $t->{Bottom})
    {
     $t->{Top} += ($row - $t->{Bottom}+1);
     $t->QueueLayout(4);
     $see = 0;
    }
  }
 if (($col -= $t->cget('-fixedcolumns')) >= 0)
  {
   if ($col < $t->{Left})
    {
     $t->{Left} = $col;
     $t->QueueLayout(4);
     $see = 0;
    }
   elsif ($col >= $t->{Right})
    {
     $t->{Left} += ($col - $t->{Right}+1);
     $t->QueueLayout(4);
     $see = 0;
    }
  }
 return $see;
}


=head1 NAME

Tk::Table - Scrollable 2 dimensional table of Tk widgets

=head1 SYNOPSIS

  use Tk::Table;

  $table = $parent->Table(-rows => number,
                          -columns => number,
                          -scrollbars => anchor,
                          -fixedrows => number,
                          -fixedcolumns => number,
                          -takefocus => boolean);

  $widget = $table->Button(...);

  $old = $table->put($row,$col,$widget);
  $old = $table->put($row,$col,"Text");  # simple Label 
  $widget = $table->get($row,$col);

  $cols = $table->totalColumns;
  $rows = $table->totalRows;

  $table->see($widget);
  $table->see($row,$col);

  ($row,$col) = $table->Posn($widget);

=head1 DESCRIPTION 

Tk::Table is an all-perl widget/geometry manager which allows a two dimensional
table of arbitary perl/Tk widgets to be displayed.

Entries in the Table are simply ordinary perl/Tk widgets. They should
be created with the Table as their parent. Widgets are positioned in the 
table using:

 $table->put($row,$col,$widget)

All the widgets in each column are set to the same width - the requested
width of the widest widget in the column.
Likewise, all the widgets in each row are set to the same height - the requested
height of the tallest widget in the column.             

A number of rows and/or columns can be marked as 'fixed' - and so can serve
as 'headings' for the remainder the rows which are scrollable.

The requested size of the table as a whole is such that the number of rows
specified by -rows (default 10), and number of columns specified by -columns
(default 10) can be displayed.

If the Table is told it can take the keyboard focus then cursor and scroll
keys scroll the displayed widgets.

The Table will create and manage its own scrollbars if requested via 
-scrollbars.

The Tk::Table widget is derived from a Tk::Frame, so inherits all its
configure options.

=head1 BUGS / Snags / Possible enhancements

=over 3

=item * 

Very large Tables consume a lot of X windows

=item * 

No equivalent of pack's -anchor/-pad etc. options 

=back 

=cut



