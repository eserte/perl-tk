package Tk::Web;

require Tk::HTMLText;
require LWP::Debug;
require LWP::Protocol::http;
require LWP::UserAgent;
use Carp;
use Tk::Pretty;
use strict qw(vars subs);

@Tk::Web::ISA = qw(Tk::HTMLText);

%Tk::Web::Loading = ();
%Tk::Web::Image   = ();

sub classinit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<b>','Back');
 return $class->InheritThis($mw);
}

sub LoadImage
{
 my ($w,$url) = @_;
 my $name = $url->as_string;
 print "Loading $name\n";    
 my $request  = new HTTP::Request('GET', $url);
 my $file = ".tempimage";                  
 my $response = $w->UserAgent->request($request, $file);
 my $image = undef;                        
 if ($response->isSuccess)                 
  {                                        
   eval { $image = $w->Pixmap(-file => $file) };
   eval { $image = $w->Bitmap(-file => $file) } if ($@);
   eval { $image = $w->Photo(-file => $file)  } if ($@);
   if ($@)                                 
    {                                      
     warn "$@";                            
    }                                      
   unlink($file);                          
  }                                        
 $Tk::Web::Image{$name} = $image;
 my $l;
 while ($l = shift(@{$Tk::Web::Loading{$name}}))
  {
   $l->configure(-image => $image);
  }
 delete $Tk::Web::Loading{$name};
 $w->update;
}

sub FindImage
{
 my ($w,$src,$l) = @_;
 my $base = $w->url;
 my $url  = URI::URL->new($src,$base)->abs;
 my $name = $url->as_string;
 if (defined $Tk::Web::Image{$name})
  {
   $l->configure(-image => $Tk::Web::Image{$name});
  }
 elsif (exists $Tk::Web::Image{$name})
  {
   # failed in the past 
  }
 else
  {
   unless (exists $Tk::Web::Loading{$name})
    {
     $Tk::Web::Loading{$name} = [];
     $w->DoWhenIdle([$w,'LoadImage',$url]); 
    }
   push(@{$Tk::Web::Loading{$name}},$l); 
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
 $w->InheritThis($args);
 my $ua = $w->UserAgent(LWP::UserAgent->new);
 $w->{'BACK'} = [];
}
                           
sub SetBindtags
{
 my ($w) = @_;
 $w->bindtags([$w,$w->toplevel,ref $w,'all']);
}

sub Tk::HTML::HREF
{
 &Tk::Pretty::PrintArgs;
 my ($w,$method,$what,$content) = @_;
 my $base = $w->url;
 push(@{$w->{BACK}},$base);
 my $url = URI::URL->new($what,$base);
 $w->url($method,$url,$content);
}

sub Back
{
 my ($w) = @_;
 if (@{$w->{BACK}})
  {
   $w->url(pop(@{$w->{BACK}}));
  }
 $w->break;
}

sub url
{
 my ($w,$method,$url,$content) = @_;
 my $var = \$w->{'-url'};
 if (@_ > 1)
  {
   $url = $url->abs;
   print "Using ",$url->as_string,"\n";
   $$var = $url;
   $w->Busy;
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
   if ($response->isSuccess)
    {
     my $type = $response->header('Content-type');
     $html = $response->content;
     $html = "<H1> Empty! </H1>" unless (defined $html);
     if (!defined $type || $type !~ /\bhtml\b/i)
      {
       if ($html =~ /^%!PS/)
        {
         $html = "<H1> PostScript! </H1>";
        }
       if ($html !~ m#^\s*</?(!|\w+)#)
        {
         $html =~ s/([\w\s])/'&#'.ord($1).';'/eg;
         $html = "<PRE>$html</PRE>" 
        }
      }
    }
   else
    {
     $html = $response->errorAsHTML;
    }
   $w->html($html);
   $w->Unbusy;
  }
 return $$var;
}

1;
