require Tk::Ghostscript;
require Tk::DSC;
# require Tk::Xlib;

package Tk::Ghostview;
use strict qw(subs);

use Tk::Pretty;

@ISA = qw(Tk::Ghostscript);

Tk::Widget->Construct('Ghostview');

$scale  = 72.0;
$width  = 11*$scale;
$height = 11*$scale;

sub new
{my $package   = shift;
 my $parent    = shift;
 my $file      = shift;
 $package->DoInit($parent);

# my $screen    = $parent->Screen;
# my $yscale    = 25.4*$screen->HeightOfScreen/$screen->HeightMMOfScreen;
# my $xscale    = 25.4*$screen->WidthOfScreen/$screen->WidthMMOfScreen;
# print "x=$xscale, y=$yscale\n";
 
 my $gs        = $parent->Ghostscript(
                         'x_pixels_per_inch' => $scale,
                         'y_pixels_per_inch' => $scale,
                         'BoundingBox' => [ 0,0, $width, $height]
                        );

 my $doc       = DSC->new($gs,$file);

 bless $gs,$package;
 $gs->{'DOC'} = $doc;
 if (defined $doc->{'Title'})
  {
   $parent->toplevel->title($doc->{'Title'});
  }
 $gs->{'RedrawPending'} = 0;
 $gs->{'PAGE'} = 0;
 my @bindtags = $gs->bindtags;
 unshift(@bindtags,$package);
 $gs->bindtags(\@bindtags);
 return $gs;
}

sub classinit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Expose>','Expose');
 $mw->bind($class,'<Next>','Next');
 $mw->bind($class,'<Prior>','Prior');
 $mw->bind($class,'<Home>','Home');
 $mw->bind($class,'<End>','End');
}

sub Doc  { shift->{'DOC'}  }
sub Page { shift->{'PAGE'} }

sub Contents { shift->Doc->Contents }

sub Orientation
{
 my ($gs,$orient) = @_;
 $gs->Tk::Ghostscript::Orientation($orient);
 $gs->Expose;
}

sub Expose
{
 my $gs = shift;
 $gs->DoWhenIdle(['DrawPage',$gs]) unless($gs->{'RedrawPending'}++);
}

sub SetPage
{
 my ($gs,$new) = @_;
 my $doc = $gs->Doc;
 my $page = $gs->Page;
 $new = $#{$doc->{'Posn'}} if ($new > $#{$doc->{'Posn'}});
 $new = 0 if ($new < 0);
 if ($page != $new || !exists $gs->{'pid'})
  {
   $gs->{'PAGE'} = $new;
   $gs->Expose;
  }
}

sub Next
{
 my $gs = shift;
 $gs->SetPage($gs->Page+1);
}

sub Prior
{
 my $gs = shift;
 $gs->SetPage($gs->Page-1);
}

sub Home
{
 my $gs = shift;
 $gs->SetPage(0);
}

sub End
{
 my $gs = shift;
 my $doc = $gs->Doc;
 $gs->SetPage($#{$doc->{'Posn'}});
}

sub DrawPage
{
 my $gs = shift;
 my $doc = $gs->Doc;
 my $page = $gs->Page;
 $gs->{'RedrawPending'} = 0;
 $gs->Postscript("/GS_Standard save def\n");
 if (0)
  {
   my ($llx,$lly,$urx,$ury) = $gs->BoundingBox;
   $gs->printf("0.9 setgray\n");     
   $gs->printf("%g %g moveto\n",$llx,$lly);
   $gs->printf("%g %g lineto\n",$urx,$lly);
   $gs->printf("%g %g lineto\n",$urx,$ury);
   $gs->printf("%g %g lineto\n",$llx,$ury);
   $gs->printf("closepath fill\n");
   $gs->printf("0 setgray\n");     
  }
 if (exists $doc->{'BeginProlog'})
  {
   $doc->CopySection($gs,'Prolog');
  }
 else
  {
   $doc->CopyTill($gs,0,'^%!','EndProlog','Page:','Trailer');
  }
 $doc->CopySection($gs,'Setup') if (exists $doc->{'BeginSetup'});
 $doc->SendPage($gs,$page);
 $gs->Postscript("GS_Standard restore\n");
}
 
1;
