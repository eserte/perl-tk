package Tk::UserAgent;
require Tk;
require Tk::LabEntry;
#use LWP::IO();
#use Tk::HTML::IO();
#use LWP::TkIO();
use LWP();
@ISA = qw(LWP::UserAgent);
use strict;
use Tk::Pretty;

#LWP::Debug::level('+');

sub Widget
{
 shift->_elem('Tk::Widget',  @_)
}

sub DESTROY {} 

sub get_basic_credentials
{
 # print 'get_basic_credentials(',join(',',@_),")\n";
 my ($ua,$realm,$uri) = @_;
 my $netloc = $uri->netloc;
 my ($user,$passwd) = $ua->SUPER::get_basic_credentials($realm,$uri);
 unless (defined $user and defined $passwd) 
  {
   my $w  = $ua->Widget;
   my $mw = (defined $w) ? $w->Toplevel(-popover => $w) : MainWindow->new;
   $mw->withdraw;
   $user  = $uri->user;
   $user  = $ENV{'USER'} unless (defined $user);
   $passwd = $uri->password;
   $passwd = "" unless (defined $passwd);
   $mw->title($uri);
   $mw->Label(-text => "Credentials for\n$realm\n$netloc")->pack; 
   my $e = $mw->LabEntry(-label => 'Userid :',-labelPack => [-side => 'left'], -textvariable => \$user)->pack;
   $e = $mw->LabEntry(-label => 'Passwd :', -labelPack => [-side => 'left'], -show => '*', -textvariable => \$passwd)->pack;
   $e->bind('<Return>',[$mw,'destroy']);
   $mw->Button(-text => 'Ok',     -command => ['destroy',$mw])->pack(-side => 'left');
   $mw->Button(-text => 'Cancel', -command => sub { $user = $passwd = undef; $mw->destroy } )->pack(-side => 'right');
   $e->Subwidget('entry')->focus;
   $mw->update;    
   $mw->raise;     
   $mw->Popup(-overanchor => 'n', -popanchor => 'n');
   eval { $mw->grab } ;
   $mw->waitWindow;
   $ua->credentials($netloc,$realm,$user,$passwd);
  }
 return ($user,$passwd);
}

package Tk::Web;

require Tk::HTML;

use Carp;
use Tk::Pretty;
use strict qw(vars subs);
use AutoLoader;

@Tk::Web::ISA = qw(Tk::HTML);
Tk::Widget->Construct('Web');

my %Loading = ();
my %Image   = ();

my %iHandler = ( gif => 'Photo', 'x-xbitmap' => 'Bitmap');

$iHandler{jpeg} = 'Photo' if (Tk->findINC('JPEG.pm'));

my $filename = "image0000";

sub LoadImage
{
 my ($w,$url) = @_;
 my $name = $url->as_string;
 my $file = '.'.++$filename;
 print "Loading $name to $file\n";    
 my $request  = new HTTP::Request('GET', $url);
 my $response = $w->UserAgent->request($request, $file);
 my $image = undef;                        
 my $format;
 if ($response->is_success)                 
  {                                        
   my $type = $response->header('Content-type');
   my @try  = qw(Pixmap Bitmap Photo);
   if (defined $type)
    {
     if ($type =~ m#image/(\w+)# && exists($iHandler{$1}))
      {
       $format = $1;
       @try = ($iHandler{$format});
      }
     else
      {
       print "$name:$type\n";
      }
    }
   foreach $type (@try)
    {
     my @args = (-file => $file);
     eval "require Tk::$type;";
     if ($type eq 'Photo')
      {
       eval "require Tk::JPEG;" if ($format eq 'jpeg');
       unshift(@args,'-format' => $format);
      }
     eval { $image = $w->$type(@args)};
     last unless ($@);
    }
   warn "$@" if ($@);
   unlink($file);                          
  }                                        
 else
  {
   print "$name:",$response->as_string;
  }
 $Image{$name} = $image;
 my $l;
 while ($l = shift(@{$Loading{$name}}))
  {
   $l->configure(-image => $image) if ($l->IsWidget);
  }
 delete $Loading{$name};
 # $w->updateWidgets;
}

sub FindImage
{
 my ($w,$src,$l) = @_;
 my $base = $w->url;
 my $url  = URI::URL->new($src,$base)->abs;
 my $name = $url->as_string;
 if (defined $Image{$name})
  {
   $l->configure(-image => $Image{$name});
  }
 elsif (exists $Image{$name})
  {
   # failed in the past 
  }
 else
  {
   unless (exists $Loading{$name})
    {
     $Loading{$name} = [];
     # $w->updateWidgets;
     $w->DoWhenIdle([$w,'LoadImage',$url]); 
    }
   push(@{$Loading{$name}},$l); 
  }
}

sub UserAgent
{
 my ($w,$ua) = @_;
 if (@_ > 1)
  {
   $w->{'UserAgent'} = $ua;
  }
 return $w->{'UserAgent'};
}

sub InitObject
{
 my ($w,$args) = @_;
 $w->SUPER::InitObject($args);
 my $ua = $w->UserAgent(Tk::UserAgent->new);
 $ua->Widget($w);
 $ua->env_proxy;
 $w->{'BACK'}    = [];
 $w->{'FORWARD'} = [];
 $w->ConfigSpecs('-url' => ['METHOD','url','Url',undef],
                 '-urlcommand' => ['CALLBACK',undef,undef,undef]
                );
}
                           
sub SetBindtags
{
 my ($w) = @_;
 $w->bindtags([$w,$w->toplevel,ref $w,'all']);
}

sub context
{
 my $w = shift;
 if (@_)
  {
   croak("Bad context " . join(',',@_)) unless (@_ == 1 && ref $_[0] eq 'ARRAY');
   my ($url,$base,$html,$top) = @{$_[0]};
   $w->{-url}   = $url;
   $w->{'base'} = $base;
   $w->html($html);
   $w->yview(moveto => $top);
   $w->Callback(-urlcommand => $url->as_string);
  }
 return [$w->url,$w->base,$w->html,$w->yview];
}

sub HREF
{
 my ($w,$what,$method,$content) = @_;
 my $base = $w->url;
 push(@{$w->{BACK}},$w->context);
 my $url = URI::URL->new($what,$base);
 $w->url($url,$method,$content);
}

my %cache = ();

sub getHTML
{
 my ($w,$url,$method,$content) = @_;
 $method = 'GET' unless (defined $method);
 if ($method eq 'GET')
  {
   my $str = $url->as_string;
   return $cache{$str} if (exists $cache{$str});
  }
 print "Requesting ",$url->as_string,"\n";
 my ($request, $head);
 if (defined $w->{'-header'}) 
  {
   $head = new HTTP::Headers(%{$w->{'-header'}});
  } 
 else 
  {
   $head = new HTTP::Headers;
  }
 if (defined $content) 
  {
   $head->header('Content-type' => 'application/x-www-form-urlencoded');
   $request  = new HTTP::Request($method, $url, $head, $content);
  } 
 else  
  {
   $request  = new HTTP::Request($method, $url, $head);
  }
 my $response = $w->UserAgent->request($request, undef, undef);
 my $html; 
 if ($response->is_success)
  {
   return undef if $response->code == &HTTP::Status::RC_NO_CONTENT;
   my $type = $response->header('Content-type');
   $html = $response->content;
   $html = "<H1> Empty! </H1>" unless (defined $html);
   if (!defined $type || $type !~ /\bhtml\b/i)
    {
     print $url->as_string," is ",$type,"\n";
     if ($type =~ m#(audio|application)/.*#i)
      {
       $html = "<H1> $type </H1>";
      }
     elsif ($type =~ m#image/.*#i)
      {
       $html = '<H1><IMG SRC="'.$url->as_string."\"> $type </H1>";
      }
     else
      {
       if ($html =~ /^%!PS/)
        {
         $html = "<H1> PostScript! </H1>";
        }
       if ($html !~ m#^\s*</?(!|\w+)#)
        {
         $html =~ s/([^\w\s])/'&#'.ord($1).';'/eg;
         $html = "<PRE>$html</PRE>" 
        }
      }
    }
   if ($method eq 'GET')
    {
     $html = $w->parse($html);       
     $cache{$url->as_string} = $html 
    }
  }
 else
  {
   $html = $response->error_as_HTML;
  }
 return $html;
}

sub base 
{
 my ($w,$text) = @_;
 my $var = \$w->{'base'};
 $$var   = URI::URL->newlocal unless (defined $$var);
 if (@_ > 1)
  {
   $$var = URI::URL->new($text,$w->base);
  }
 return $$var;
}

sub url
{
 my ($w,$url,$method,$content) = @_;
 my $var = \$w->{'-url'};
 if (@_ > 1)
  {
   $w->Busy;
   unless (ref $url)
    {
     $url = URI::URL->new($url,$w->base);
    }
   $url = $url->abs;
   my $frag = $url->frag;
   $url->frag(undef) if (defined $frag);
   my $html = $w->getHTML($url,$method,$content);
   if (defined $html)
    {
     $$var = $url;
     my @args = ();
     if (defined $frag)
      {
       $url->frag($frag);
       push(@args,$frag);
      }
     $w->Callback(-urlcommand => $url->as_string);
     $w->html($html,@args); 
    }
   $w->Unbusy;
  }
 return $$var;
}

1;

__END__

sub TextPopup
{
 my ($w,$kind,$text) = @_;
 my $t   = $w->MainWindow->Toplevel;
 my $url = $w->url;
 $t->title("$kind : ".$url->as_string);
 my $tx = $t->Scrolled('Text',-wrap => 'none')->pack(-expand => 1, -fill => 'both');
 $tx->insert('end',$text);
}

sub ShowSource
{
 my ($w) = @_;
 $w->TextPopup(Source => $w->html->{'_source_'});
}

sub ShowHTML
{
 my ($w) = @_;
 $w->TextPopup(HTML => $w->html->as_HTML);
}



sub Open
{
 my ($w) = @_;
 unless (exists $w->{'Open'})
  {
   my $t = $w->toplevel;
   my $o = $w->toplevel->Toplevel(-popover => $w, -popanchor => 'n', -overanchor => 'n');
   $o->withdraw;
   $o->transient($t);
   $o->protocol(WM_DELETE_WINDOW => [withdraw => $o]);
   $w->{'Open'} = $o;
   $o->{'url'}  = $w->url;
   my $e = $o->LabEntry(-label => 'Location :',-labelPack => [ -side => 'left'],
                -textvariable => \$o->{'url'}, -width => length($o->{'url'}))->pack(-fill => 'x');
   my $b = $o->Button(-text => 'Open', 
                      -command =>  sub {  $o->withdraw ; $w->HREF('GET',$o->{'url'}) } 
                     )->pack(-side => 'left',-anchor => 'w', -fill => 'x');
   $e->bind('<Return>',[$b => 'invoke']); 
   $o->Button(-text => 'Clear', -command => sub { $o->{'url'} = "" })->pack(-side => 'left',-anchor => 'c', -fill => 'x');
   $o->Button(-text => 'Current', -command => sub { $o->{'url'} = $w->url })->pack(-side => 'left',-anchor => 'c', -fill => 'x');
   $o->Button(-text => 'Cancel', -command => [ withdraw => $o ])->pack(-side => 'right',-anchor => 'e',-fill => 'x');
   $e->focus;
  }
 my $o = $w->{'Open'};
 $o->{'url'}  = $w->url;
 $o->Popup;
}

sub SaveAs
{

}

sub Home
{

}

sub Stop
{

}

sub Print
{

}

sub Reload
{

}

sub Find
{

}

sub Back
{
 my ($w) = @_;
 if (@{$w->{BACK}})
  {
   unshift(@{$w->{FORWARD}},$w->context);
   $w->context(pop(@{$w->{BACK}}));
  }
 $w->break;
}

sub Forward
{
 my ($w) = @_;
 if (@{$w->{FORWARD}})
  {
   unshift(@{$w->{BACK}},$w->context);
   $w->context(shift(@{$w->{FORWARD}}));
  }
 $w->break;
}


