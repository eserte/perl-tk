package Tk::HTMLText;
require Tk::ROText;
require Tk::Photo;
require Tk::Pixmap;
require Tk::Bitmap;
require Tk::HTML;
use Carp;
use strict qw(vars subs);

@Tk::HTMLText::ISA = qw(Tk::HTML Tk::Derived Tk::ROText);

Tk::Widget->Construct('HTMLText');

sub InitObject
{
 my ($w,$args) = @_;
 $w->Cleanout;
 $w->SUPER::InitObject($args);
 
 $args->{-wrap} = 'word';
 $args->{-width} = 80;
 $args->{-height} = 40;
 $args->{-background} = '#fff5e1';
 $args->{-font} = $w->Font(family => 'courier');

 my $opt = '*'. substr($w->PathName,1) . '*';

 $w->option('add',$opt . 'background' => '#fff5e1'); 
 $w->option('add',$opt . 'highlightBackground' => 'green'); 

 $w->tag('configure','text', -font => $w->Font(family => 'times'));
 $w->tag('configure','CODE',-font => $w->Font(family => 'courier', weight => 'bold'));
 $w->tag('configure','KBD',-font => $w->Font(family => 'courier'));
 $w->tag('configure','VAR',-font => $w->Font(family => 'helvetica',slant => 'o', weight => 'bold'));
 $w->tag('configure','B',-font => $w->Font(family => 'times', weight => 'bold' ));
 $w->tag('configure','H1',-font => $w->Font(family => 'times', weight => 'bold', size => 180));
 $w->tag('configure','H2',-font => $w->Font(family => 'times', weight => 'bold', size => 140));
 $w->tag('configure','I',-font => $w->Font(family => 'times',slant => 'i', weight => 'bold' ));
 $w->tag('configure','BLOCKQUOTE', -font => $w->Font(family => 'helvetica',slant => 'o', weight => 'bold'),
         -lmargin1 => 35, -lmargin2 => 30, -rmargin => 30);
 $w->tag('configure','ADDRESS', -font => $w->Font(family => 'times',slant => 'i'));
 $w->tag('configure','HREF',-underline => 1, -font => $w->Font(family => 'times',slant => 'i', weight => 'bold' ));
 $w->tag('configure','CENTER',-justify => 'center');
 $w->{Configure} = {};
 $w->ConfigSpecs('-showlink' => ['CALLBACK',undef,undef,undef]);
}

sub ShowLink
{
 my ($w,$link) = @_;
 my $cb = $w->cget('-showlink');
 $cb->Call($link) if (defined $cb);
}

sub AUTOLOAD
{
 my $what = $Tk::HTMLText::AUTOLOAD;
 print "AUTOLOAD:$what\n";
 my($package,$method) = ($what =~ /^(.*)::([^:]*)$/);
 if ($method =~ /^[A-Z][A-Z0-9_]*$/)
  {
   print STDERR "Don't know how to $method\n";
   *{$what} = sub { return shift };
   goto &$what;
  }
 $Tk::Widget::AUTOLOAD = $what;
 goto &Tk::Widget::AUTOLOAD;
}


1;

__END__
