require Tk::Ghostscript;
require Tk::DSC;

package Tk::Ghostview;
use strict qw(subs);

use Tk::Pretty;

@ISA = qw(Tk::Ghostscript);

Construct Tk::Widget 'Ghostview';

$scale  = 72;
$width  = 11*$scale;
$height = 11*$scale;

sub scale
{
 my ($w,$val) = @_;
 my $var = \$w->{Configure}{'-scale'};
 if (@_ > 1)
  {
   $$var = $val;
  }
 return $$var;
}

sub file
{
 my ($w,$val) = @_;
 my $var = \$w->{Configure}{'-file'};
 if (@_ > 1)
  {
   $$var = $val;
   my $doc = DSC->new($w,$val);
   $w->{'DOC'} = $doc;
   $w->toplevel->title($doc->{'Title'});
  }
 return $$var;
}

sub Populate
{
 my ($w,$args) = @_;
 $w->SUPER::Populate($args);
 $w->{'RedrawPending'} = 0;
 $w->{'PAGE'} = 0;
 $w->ConfigSpecs('-file'  => ['METHOD',undef,undef,undef]);
 $w->ConfigSpecs('-scale' => ['METHOD',undef,undef,72.0]);
}

sub ClassInit
{
 my ($class,$mw) = @_;
 $class->SUPER::ClassInit($mw);
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
 $gs->orientation($orient);
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
 if (defined $doc)
  {
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
  }
 $gs->Postscript("GS_Standard restore\n");
}
 
1;
