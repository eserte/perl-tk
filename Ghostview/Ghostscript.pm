=head1 NAME

Ghostscript - Beginings of a lowlevel PostScript viewing widget

=head1 SYNOPSIS

    my $gs= $parent->Ghostscript(
                    'x_pixels_per_inch' => $scale,
                    'y_pixels_per_inch' => $scale,
                    'BoundingBox' => [ 0,0, $width, $height]
                    );
    $gs->Postscript("....");


=head1 DESCRIPTION

Tested with gs3 via F<pgs> and F<Ghostview.pm>.

Aim is to have both GS and "Display Postscript" widgets
which present same interface to higher level document viewers.

=cut
package Tk::Ghostscript;
use AutoLoader;

use strict qw(subs);
use POSIX qw(F_GETFL F_SETFL O_NONBLOCK fcntl);

# use Tk::Xlib;

use Carp;
use Tk::Pretty;

@ISA = qw(Tk::Frame);
Tk::Widget->Construct('Ghostscript');

sub Portrait   {  0}   # Normal portrait orientation 
sub Landscape  { 90}   # Normal landscape orientation 
sub Upsidedown {180}   # Don't think this will be used much 
sub Seascape   {270}   # Landscape rotated the wrong way 

sub Populate
{
 my ($w,$args) = @_;
 my %hash = ( 
              'bpixmap'           => 0,
              'page_orientation'  => &Portrait(),
              'BoundingBox'       => [0,0,int(210*72/25.4),int(297*72/25.4)], 
              'x_pixels_per_inch' => 72.0,
              'y_pixels_per_inch' => 72.0,
              'Margins'           => [0,0,0,0]
            );
 %hash = (%hash,@_);
 while (($key,$value) = each %hash)
  {
   $w->{$key} = $value;
  }

 $w->{'FH'} = \*{"GS" . $w->PathName};

 $w->BindClientMessage('DONE','StopInterp');
 $w->BindClientMessage('PAGE','PAGE');
 $w->ConfigSpecs('-orientation' => ['METHOD','orientation','Orientation','Portrait']
                );
} 


1;

__END__

sub StartInterp
{
 my $w = shift;
 $w->StopInterp;
 $w->idletasks;
 $w->MakeWindowExist;
 my $win  = ${$w->WindowId};  # Window for properties/events
 my $dest = ${$w->WindowId};  # Xid of drawable to draw on (gs3 and later)
 $ENV{'GHOSTVIEW'} = sprintf("%d %d",$win,$dest);
 $w->property('set','GHOSTVIEW','STRING',8,
              sprintf("%d %d %d %d %d %d %g %g %d %d %d %d",
               $w->{'bpixmap'},
               $w->{'page_orientation'},
               @{$w->{'BoundingBox'}},
               $w->{'x_pixels_per_inch'}, $w->{'y_pixels_per_inch'},
               @{$w->{'Margins'}}));
 my $screen = $w->Screen;
# my $bg = $screen->WhitePixelOfScreen;
# my $fg = $screen->BlackPixelOfScreen;
# $w->property('set','GHOSTVIEW_COLORS','STRING',8,sprintf("Monochrome %d %d",$fg,$bg));
 $w->{'Pending'} = [];
 $w->XSync(0);
 my $fh = $w->{'FH'};
 $w->{'pid'} = open($fh,"| gs -sDEVICE=x11 -dQUIET -dNOPAUSE -");
 my $fl = fcntl($fh,F_GETFL,0);
 die "Cannot F_GETFL:$!" unless (defined $fl);
 fcntl($fh,F_SETFL,$fl | O_NONBLOCK) || die "Cannot F_SETFL:$!";
}

sub PAGE
{
 my $w = shift;
 my $e = $w->XEvent;
 my ($m,$d) = unpack('LL',$e->A);
 $w->{'mwin'} = $m;
}

sub Postscript
{
 my $w  = shift;
 $w->StartInterp unless(exists $w->{'pid'});
 if (exists $w->{'mwin'})
  {
   $w->SendClientMessage('NEXT',$w->{'mwin'},8,"");
   delete $w->{'mwin'};
  }
 my $fh = $w->{'FH'};
 my $pend = $w->{'Pending'};
 unless (@$pend)
  {
   $w->fileevent($fh,'writable',['SendIt',$w]);
  }
 push(@$pend,@_);
}

sub printf
{my $w = shift;
 my $fmt = shift;
 $w->Postscript(sprintf($fmt,@_));
}

sub SendIt
{
 my $w  = shift;
 my $fh = $w->{'FH'};
 my $pend = $w->{'Pending'};
 while (@$pend)
  {
   my $line = shift(@$pend);           
   my $len  = length($line);           
   my $done = syswrite($fh,$line,$len);
   $done = 0 unless (defined $done);
   if ($done < $len)
    {
     unshift(@{$pend},substr($line,$done));
     last;
    }
  }
 if (exists $w->{'mwin'})
  {
   $w->SendClientMessage('NEXT',$w->{'mwin'},8,"");
   delete $w->{'mwin'};
  }
 $w->fileevent($fh,'writable',"") unless (@$pend);
}

sub StopInterp
{
 my $w = shift;
 if (exists $w->{'pid'})
  {
   my $fh = $w->{'FH'};
   kill('TERM',$w->{'pid'});
   delete $w->{'pid'};
   $w->fileevent($fh,'writable',"");
   close($fh);
   delete $w->{'Pending'};
  }
 delete $w->{'mwin'};
}

sub NoteSize
{
}

sub ChangeView
{
 my $w = shift;
 my ($llx,$lly,$urx,$ury) = @{$w->{'BoundingBox'}};
 my $x = int(($urx - $llx)*$w->{'x_pixels_per_inch'}/72.0);
 my $y = int(($ury - $lly)*$w->{'y_pixels_per_inch'}/72.0);
 $w->StopInterp;
 if ($w->{'page_orientation'} % 180 == 0)
  {
   $w->configure('-width' => $x,'-height' => $y);
  }
 else
  {
   $w->configure('-width' => $y,'-height' => $x);
  }
}

sub BoundingBox
{
 my $w = shift;
 return @{$w->{'BoundingBox'}} unless (@_);
 croak "Invalid bounding box" . Pretty(\@_) unless (@_ == 4); 
 my @bb = @_;
 $w->{'BoundingBox'} = \@bb;
 $w->ChangeView;
}

sub orientation
{
 my $w = shift;
 if (@_)
  {
   my $view = shift;
   $w->{'page_orientation'} = $w->$view();
   $w->ChangeView;
  }
 my @names = ('Portrait','Landscape','Upsidedown','Seascape');
 return $names[$w->{'page_orientation'}/90];
}

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Configure>','NoteSize');
 $mw->bind($class,'<Destroy>','StopInterp');
 return $class;
}

1;

