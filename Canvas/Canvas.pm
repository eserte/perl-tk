package Tk::Canvas;
use vars qw($VERSION);
$VERSION = '4.004'; # $Id: //depot/Tkutf8/Canvas/Canvas.pm#4 $

use Tk qw($XS_VERSION);

use base qw(Tk::Widget);
Construct Tk::Widget 'Canvas';

bootstrap Tk::Canvas;

sub Tk_cmd { \&Tk::canvas }

Tk::Methods('addtag','bbox','bind','canvasx','canvasy','coords','create',
            'dchars','delete','dtag','find','focus','gettags','icursor',
            'index','insert','itemcget','itemconfigure','lower','move',
            'postscript','raise','scale','scan','select','type','xview','yview');

use Tk::Submethods ( 'create' => [qw(arc bitmap grid group image line oval
				     polygon rectangle text window)],
		     'scan'   => [qw(mark dragto)],
		     'select' => [qw(from clear item to)],
		     'xview'  => [qw(moveto scroll)],
		     'yview'  => [qw(moveto scroll)],
		     );

*CanvasBind  = \&Tk::bind;
*CanvasFocus = \&Tk::focus;

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->XYscrollBind($class);
 return $class;
}

sub BalloonInfo
{
 my ($canvas,$balloon,$X,$Y,@opt) = @_;
 my @tags = ($canvas->find('withtag', 'current'),$canvas->gettags('current'));
 foreach my $opt (@opt)
  {
   my $info = $balloon->GetOption($opt,$canvas);
   if ($opt =~ /^-(statusmsg|balloonmsg)$/ && UNIVERSAL::isa($info,'HASH'))
    {
     $balloon->Subclient($tags[0]);
     foreach my $tag (@tags)
      {
       return $info->{$tag} if exists $info->{$tag};
      }
     return '';
    }
   return $info;
  }
}



1;

