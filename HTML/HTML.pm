package Tk::HTML;
require Tk::ROText;
require Tk::HTML::Handler;

use Carp;
@ISA = qw(Tk::Derived Tk::ROText);
use strict;

Tk::Widget->Construct('HTMLText');

sub Font
{
 my ($w,%fld)     = @_;
 $fld{'family'}   = 'times'   unless (exists $fld{'family'});
 $fld{'weight'}   = 'medium'  unless (exists $fld{'weight'});
 $fld{'slant'}    = 'r'       unless (exists $fld{'slant'});
 $fld{'size'}     = 140       unless (exists $fld{'size'});
 $fld{'spacing'}  = '*'       unless (exists $fld{'spacing'});
 $fld{'registry'} = 'iso8859' unless (exists $fld{'registry'});
 $fld{'encoding'} = '1'       unless (exists $fld{'encoding'});
 $fld{'slant'}    = substr($fld{'slant'},0,1);
 my $name = "-*-$fld{'family'}-$fld{'weight'}-$fld{'slant'}-*-*-*-$fld{'size'}-*-*-$fld{'spacing'}-*-$fld{'registry'}-$fld{'encoding'}";
 return $name;
}

sub call_ISINDEX 
{
 my($w,$e) = @_;
 my $method = "GET";
 my $url;
 if(defined $w->{'base'}) { $url = $w->{'base'}; } else { $url = $w->url; }
 my $query = Tk::HTML::Form::encode($w,$e->get);
 $w->HREF("$url?$query",'GET');
}

sub FindImage
{
 my ($w,$src,$l) = @_;
 $src = $w->HREF($src,'GET');
 my $img;
 eval { require Tk::Pixmap; $img = $w->Pixmap(-data => $src) };
 eval { require Tk::Bitmap; $img = $w->Bitmap(-data => $src) } if ($@);
 eval { require Tk::Photo;  $img = $w->Photo(-data => $src)  } if ($@);
 if ($@)
  {
   warn "$@";
  }
 else
  {
   $l->configure(-image => $img);
  }
}

sub IMG_CLICK 
{
 my($w,$c,$t,$aref,$n) = @_;
 my $Ev = $c->XEvent;
 my $cor = $c->cget(-borderwidth);
 if($t eq "ISMAP") 
  {
   $w->HREF($aref . "?" . ($Ev->x - $cor) . "," . ($Ev->y - $cor),'GET');
  } 
 elsif ($t eq "AREF")
  {
   $w->HREF($aref,'GET');
  }
 else 
  {
   my $s = "$n.x=" . ($Ev->x - $cor) . "&$n.y=" . ($Ev->y - $cor);
   $aref->Submit($s);
  }
}

sub HTML::dump {
  my($a,$b) = @_;
  ${($a->configure(-textvariable))[4]} = $b;
}

sub plain
{
 my ($w,$text) = @_; 
 my $var = \$w->{Configure}{-plain};
 if (@_ > 1)
  {
   $$var = $text;
   $w->delete('0.0','end');
   $w->insert('end',$text);
  }
 return $$var;
}

sub fragment
{
 my ($w,$tag) = @_;
 my @info = $w->tagRanges($tag);
 if ($w->tagRanges($tag))
  {
   $w->yview($tag.'.first');
  }
 else
  {
   warn "No tag `$tag'";
  }
}

sub parse
{
 my ($w,$html) = @_;
 unless (ref $html)
  {
   my $s = Tk::timeofday();
   print STDERR "Parsing ...";
   local $HTML::Parse::IGNORE_UNKNOWN = 0;
   my $obj = HTML::Parse::parse_html($html);
   $obj->{'_source_'} = $html;
   printf STDERR " %.3g seconds\n",Tk::timeofday()-$s;
   return $obj;
  }
 return $html;
}

sub html
{
 my ($w,$html,$frag) = @_; 
 my $var = \$w->{Configure}{-html};
 if (@_ > 1)
  {
   $$var = $w->parse($html);
   my $s = Tk::timeofday();
   print STDERR "Rendering ...";
   my $h = new Tk::HTML::Handler widget => $w;
   $$var->traverse(sub { $h->traverse(@_) });
   printf STDERR " %.3g seconds\n",Tk::timeofday()-$s;
   $w->fragment($frag) if (defined $frag);
  }
 return $$var;
}

sub file
{
 my ($w,$file) = @_; 
 my $var = \$w->{Configure}{-file};
 if (@_ > 1)
  {
   open($file,"<$file") || croak "Cannot open $file:$!";
   $$var = $file;
   $w->html(join('',<$file>));
   close($file);
  }
 return $$var;
}

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<b>','Back');
 $mw->bind($class,'<space>',['yview','scroll',1,'pages']);
 $mw->bind($class,'<BackSpace>',['yview','scroll',-1,'pages']);
 return $class->SUPER::ClassInit($mw);
}

sub base
{

}

sub InitObject
{
 my ($w,$args) = @_;
 $w->SUPER::InitObject($args);
 
 $args->{-wrap} = 'word';
 $args->{-width} = 80;
 $args->{-height} = 40;
 $args->{-font} = $w->Font(family => 'courier');

 $w->tagConfigure('symbol', -font => $w->Font(family => 'symbol', size => 180,  encoding => '*', registry => '*'));
 $w->tagConfigure('text', -font => $w->Font(family => 'times'));
 $w->tagConfigure('CODE',-font => $w->Font(family => 'courier', weight => 'bold'));
 $w->tagConfigure('KBD',-font => $w->Font(family => 'courier'));
 $w->tagConfigure('VAR',-font => $w->Font(family => 'helvetica',slant => 'o', weight => 'bold'));
 $w->tagConfigure('B',-font => $w->Font(family => 'times', weight => 'bold' ));
 $w->tagConfigure('H1',-font => $w->Font(family => 'times', weight => 'bold', size => 180));
 $w->tagConfigure('H2',-font => $w->Font(family => 'times', weight => 'bold', size => 140));
 $w->tagConfigure('I',-font => $w->Font(family => 'times',slant => 'i', weight => 'bold' ));
 $w->tagConfigure('BLOCKQUOTE', -font => $w->Font(family => 'helvetica',slant => 'o', weight => 'bold'),
         -lmargin1 => 35, -lmargin2 => 30, -rmargin => 30);
 $w->tagConfigure('ADDRESS', -font => $w->Font(family => 'times',slant => 'i'));
 $w->tagConfigure('HREF',-underline => 1, -font => $w->Font(family => 'times',slant => 'i', weight => 'bold' ));
 $w->tagConfigure('CENTER',-justify => 'center');
 $w->{Configure} = {};
 $w->ConfigSpecs('-showlink' => ['CALLBACK',undef,undef,undef]);
}

1;

__END__

