package Tk::HTML::Handler;
require HTML::Parse;
require Tk::HTML::Form;

use strict;
use Carp;

delete $HTML::Element::OVERLOAD{'""'};

use vars qw($VERSION $AUTOLOAD);
$VERSION = '2.007'; # $Id: //depot/Tk/HTML/HTML/Handler.pm#7$

sub HTML::Element::enclosing
{
 my $self = shift;
 my $must = shift;
 my $p = $self;
 while (defined $p) 
  {
   my $ptag = $p->{'_tag'};
   for (@_) 
    {
     return $p if $ptag eq $_;
    }
   $p = $p->{'_parent'};
  }
 Carp::croak $self->tag . " is not in ".join(' ',@_) if ($must);
 return undef;
}

my %FontTag = ('CITE' => 'I', 'STRONG' => 'B', 'EM' => 'B', 
                      'TT' => 'KBD', 'SAMP' => 'CODE');

BEGIN 
{
 no strict 'refs';
 my $tag; 
 foreach $tag (qw(b i samp code kbd strong em var cite dfn tt))
  {
   *{"$tag"} = \&FontTag;
  }

 foreach $tag (qw(address html blink))
  {
   *{"$tag"} = \&DoesNothing;
  }

 foreach $tag (qw(dl ul menu dir ol))
  {
   *{"$tag"} = \&List;
  }

 foreach $tag (1..6)
  {
   *{"h$tag"} = \&Heading;
  }

 foreach $tag (qw(tagAdd insert))
  {
   *{"$tag"} = sub { shift->{widget}->$tag(@_) };
  }
}
 

*th   = \&td;
*link = \&a;

sub AUTOLOAD
{
 my $what = $AUTOLOAD;
 # print "AUTOLOAD:$what\n";
 my($package,$method) = ($what =~ /^(.*)::([^:]*)$/);
 warn "Don't know how to $method";
 if (@_ > 2 && ref($_[2]))
  {
   print $_[2]->as_HTML,"\n";
  }
 else
  {
   print "$what(",join(',',@_),")\n";
  }
 *{"$what"} = sub { return 1 };
 goto &$what;
}

use strict;

sub Widget { shift->{widget} }

sub DESTROY { }

sub new
{
 my ($class,%args) = @_;
 my $w = $args{widget};
 $w->delete('0.0','end');
 $args{NL}   = 2;
 $args{BODY} = 1;
 $args{Count} = 0;
 $args{'List'} = [];
 $args{'FORM'}   = []; # all forms defined for this document
 $args{'Text'}   = []; # Current place to send Text
 $args{'Option'} = []; # Current place to send Option
 return bless \%args,$class;
}

sub CurrentForm
{
 my ($w,$f) = @_;
 if (@_ > 1)
  {
   $w->{'CurrentForm'} = $f;
  }
 return $w->{'CurrentForm'};
}

sub GenTag
{
 my $w = shift;
 my $prefix = shift;
 my $tag = $prefix . ++$w->{Count};
 $w->{'GenTag'} = [] unless (exists $w->{'GenTag'});
 push(@{$w->{'GenTag'}},$tag);
 $w->{widget}->tagConfigure($tag,@_) if (@_);
 return $tag;
}

sub TextHandler
{
 my $w = shift;
 if (@_)
  {
   push(@{$w->{'Text'}},Tk::Callback->new(@_));
  }
 else
  {
   return (@{$w->{'Text'}}) ? $w->{'Text'}[-1] : undef;
  }
}

sub nl
{
 my ($w,$n) = @_;
 while ($w->{'NL'} < $n)
  {
   $w->insert('insert',"\n");
   $w->{'NL'}++;
  }
}

sub ElemTag
{
 my ($w,$elem) = @_;
 my $tag = uc $elem->tag;
 $w->tagAdd($tag,$elem->{'_Start_'},$elem->{'_End_'});
}

sub FontTag
{
 my ($w,$f,$elem) = @_;
 if (!$f)
  {
   my $tag = uc $elem->tag;
   $tag = $FontTag{$tag} if (exists $FontTag{$tag});
   $w->tagAdd($tag,$elem->{'_Start_'},$elem->{'_End_'});
  }
 return $f;
}

sub meta
{
 my ($w,$f,$elem) = @_;
 return 0;
}

sub font
{
 my ($w,$f,$elem) = @_;
 # print format_attr($elem),"\n" if ($f);
 return $f;
}

sub nobr
{
 my ($w,$f,$elem) = @_;
 print format_attr($elem),"\n" if ($f);
 return $f;
}

sub body
{
 my ($w,$f,$elem) = @_;
 $w->{'BODY'} = 1;
 return $w;
}

sub script
{
 my ($w,$f,$elem) = @_;
 $w->{'BODY'} = 0;
 return $w;
}

sub bgsound
{
 my ($w,$f,$elem) = @_;
 return 0;
}

sub head
{
 my ($w,$f,$elem) = @_;
 $w->{'BODY'} = 0;
 return $w;
}

sub a
{
 my ($h,$f,$elem) = @_;
 if (!$f)
  {
   my $w = $h->{widget};
   my $href = $elem->attr('href');
   my $name = $elem->attr('name');
   if ($href)
    {
     my $tag  = $h->GenTag('HREF',-underline => 1);
     $w->tagAdd($tag,$elem->{'_Start_'},$elem->{'_End_'});
     $w->tagBind($tag,'<Button-1>',[$w,'HREF',$href,'GET']);
     $w->tagBind($tag,'<Enter>',[$w,'Callback','-showlink',$href]);
    }
   if ($name)
    {
     $w->tagAdd($name,$elem->{'_Start_'},$elem->{'_End_'});
     push(@{$h->{'GenTag'}},$name);
    }
  }
 return $f;
}

sub li
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   my $list = $elem->enclosing(1,qw(ul ol dir menu));
   if ($list->tag eq 'ol')
    {
     my $n = ++$list->{Num};
     $w->insert('insert',"\n $n. ");
    }
   else
    {
     # $w->insert('insert',"\n \xA8 ",['symbol']);
     $w->insert('insert',"\n \xB7 ",['symbol']);
    }
  }
 return $w;
}

sub dt
{
 my ($w,$f,$elem) = @_;
 $w->nl(1+$f);
 return $w;
}

sub dd
{
 my ($w,$f,$elem) = @_;
 $w->nl(1);
 return $w;
}


sub tr_grid
{
 my ($w,$f,$elem) = @_;
 my $table = $elem->enclosing(1,'table');
 if ($f)
  {
   $table->{Col} = 0;
  }
 else
  {
   # print format_attr($elem),"\n";
   $table->{Row}++;
  }
 return $w;
} 

sub p
{
 my ($w,$f,$elem) = @_;
 $w->{'BODY'} = 1;
 $w->nl(2);
 return $w;
}

sub br
{
 my ($w,$f,$elem) = @_;
 return 0 unless $f;
 $w->{'BODY'} = 1;
 if (@{$w->{'Text'}})
  {
   $w->{'Text'}[-1]->Call("\n");
  }
 else
  {
   $w->nl(1);
  }
 return $w;
}

sub hr
{
 my ($h,$f,$elem) = @_;
 return 0 unless $f;
 my $w = $h->{widget};
 my $r = $w->Frame(-height => 2, 
                   -width => $w->cget('-width')*140,
                   -borderwidth => 1, -relief => 'sunken',
                  );
 $h->nl(1);
 $w->window('create','insert','-window' => $r, -pady => 0, -padx => 0);
 $h->{NL} = 0;
 $h->{'BODY'} = 1;
 $h->nl(1);
 return $f;
}

sub DeEscape
{
 my ($var,$text) = @_;
 $$var .= HTML::Entities::decode($text);
}

sub td_grid
{
 my ($h,$f,$elem) = @_;
 my $table = $elem->enclosing(1,'table');
 if ($f)
  {
   $elem->{Text} = "";
   $h->TextHandler([\&DeEscape,\$elem->{Text}]);
  }
 else
  {
   my $tw = $table->{widget};
   my @elem = ();
   my $al = $elem->{ALIGN};
   if (defined $al)
    {
     push(@elem,-justify => 'right',-anchor => 'e') if ($al =~ /RIGHT/i);
    }
   my $widget = $elem->{'widget'};
   unless (defined $widget)
    {
     $widget = $tw->Label(-relief => 'ridge',@elem, -text => $elem->{Text},
                                config($elem,              
                                -background => 'bgcolor'));
    }
   $widget->grid(-in => $tw, -row => $table->{Row}, -column => $table->{Col},
                 config($elem,
                        -rowspan => 'rowspan',
                        -columnspan => 'colspan'), -sticky => 'nsew');
   pop(@{$h->{'Text'}});
   $table->{Col}++;
  }
 return $f;
} 



sub broken_td
{
 my ($h,$f,$elem) = @_;
 my $row   = $elem->enclosing(1,'tr');
 my $table = $row->enclosing(1,'table');
 my $tw = $table->{widget};
 if ($f)
  {
   my $w = $h->{'widget'};
   $elem->{'widget'} = $w;
#  my $class = ref($w);
#  my @args = ();
#  foreach my $opt ($w->configure)
#   {
#    if (@$opt != 2)
#     {
#      my $val = $opt->[-1];
#      my $def = $opt->[-2];
#      push(@args,$opt->[0],$val) if defined($val) && (!defined($def) || $val ne $def);
#     }
#   }
#  print join(' ','New:',@args),"\n";
#  print format_attr($elem),"\n";
   my @elem = ();
   my $al = $elem->attr('align');
   if (defined $al)
    {
     push(@elem,-justify => 'right',-anchor => 'e') if ($al =~ /RIGHT/i);
    }
   my $widget = Tk::HTML->new($tw, -relief => 'ridge',@elem, 
                              config($elem,
                              -background => 'bgcolor'), 
                              -width => 0, -height => 0);
   $widget->grid(-in => $tw, -row => $table->{Row}, -column => $table->{Col},
                 config($elem,
                        -rowspan => 'rowspan',
                        -columnspan => 'colspan'), -sticky => 'nsew');
   $h->{'widget'} = $widget;
  }
 else
  {
   my $widget = $h->{'widget'};
   # $widget->GeometryRequest(0,0);
   $h->{'widget'} = $elem->{widget};
   $table->{Col}++;
  }
 return $f;
} 

sub format_attr
{
 my $elm = shift;
 my $str = '<'.$elm->tag.' ';
 my $sep = '';
 my @list = %$elm;
 while (@list)
  {
   my ($key,$val) = splice(@list,0,2);
   next if $key =~ /^_/;
   $str .= "$sep$key=\"$val\"";
   $sep = ', ';
  }
 return $str . '>';
}

sub config
{
 my $elem = shift;
 my @args;
 while (@_)
  {
   my ($opt,$attr) = splice(@_,0,2);
   my $val = $elem->attr($attr);
   push(@args,$opt => $val) if defined $val;
  }
 return @args;
}

sub table
{
 my ($h,$f,$elem) = @_;
 return $f;
}

sub td
{
 my ($h,$f,$elem) = @_;
 return $f;
}

sub tr
{
 my ($h,$f,$elem) = @_;
 return $h->br($f,$elem)
}

sub table_grid
{
 my ($h,$f,$elem) = @_;
 if ($f)
  {
   my $w = $h->Widget;
   $elem->{widget} = $w->Frame(config($elem,-width => 'width',
                                      -height => 'height'));
   $elem->{Row} = 0;
   $elem->{Col} = 0;
   $w->window('create','insert',-window => $elem->{widget});
   # print format_attr($elem),"\n";
  }
 else
  {
  }
 return $h;
}

sub form
{
 my ($w,$f,$form) = @_;
 $w->{'BODY'} = 1;
 if ($f)
  {
   $form->{OldForm} = $w->CurrentForm;
   bless $form,'Tk::HTML::Form';
   push(@{$w->{'FORM'}},$form);
   $form->{'Values'}  = [];
   $form->{'Owner'} = $w;
   $w->CurrentForm($form);
  }
 else
  {
   my $what;
   my @val = ();
   foreach $what (@{$form->{'Values'}})
    {
     my $val = $what->[1];
     if (ref($val))
      {
       $val = $val->Call();
      }
     push(@val,$val);
    }
   $form->{'Reset'} = \@val;
   $w->CurrentForm(delete $form->{OldForm});
  }
 $w->nl(1);
 return $w;
}

sub input 
{
 my($w,$f,$elem) = @_;
 return 0 unless $f;
 my $form = $w->CurrentForm;
 my $type = $elem->attr('type');
 $elem->attr(type => ($type = 'TEXT')) unless (defined $type);
 $type = "\U$type";
 $form->$type($elem);
 return $w;
}

sub option 
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   push(@{$w->{'option'}},$elem);
  }
 else
  {
   pop(@{$w->{'option'}});
  }
 return $f;
}

sub OptionText
{
 my ($h,$mb,$text) = @_;
 my $elem = $h->{'option'}[-1];
 if (defined $elem)
  {
   my $val = $elem->attr('value');
   $text =~ s/^\s+//;
   $text =~ s/\s+$//;
   $elem->attr('value' => $text) unless ($val);
   if ($elem->attr('value') ne $text)                         
    {                                                     
     $mb->{'FORM_MAP'} = {} unless (exists $mb->{'FORM_MAP'});
     $mb->{'FORM_MAP'}{$text} = $elem->attr('value');
    }                                                     
   $mb->options([$text]);                                 
   $mb->setOption($text) if ($elem->attr('selected'));
  }
 else
  {
   confess "$text outside option";
  }
}

sub MultipleText
{
 my ($h,$lb,$text) = @_;
 $text =~ s/^\s+//;
 $text =~ s/\s+$//;
 my $elem = $h->{'option'}[-1];
 if (defined $elem)
  {
   my $index = $lb->index('end');
   $elem = {} unless (defined $elem);
   $elem->{'VALUE'} = $text unless (exists $elem->{'VALUE'});
   if ($elem->{'VALUE'} ne $text)
    {                        
     $lb->{'FORM_MAP'} = [] unless (exists $lb->{'FORM_MAP'});
     $lb->{'FORM_MAP'}[$index] = $elem->{'VALUE'};
    }                        
   $lb->insert($index,$text);
   $lb->selection('set',$index) if (defined $elem->{'SELECTED'});
  }
 else
  {
   confess "$text outside option";
  }
}

sub select 
{
 my($h,$f,$elem) = @_;
 if ($f) 
  {
   $h->{NL} = 0;
   my $w = $h->Widget;
   my $form = $h->CurrentForm;
   $h->{'option'} = [];
   if ($elem->attr('multiple') || (defined $elem->{'size'} && $elem->{'size'} > 1)) 
    {
     my $size = $elem->attr('size');
     $size = 15 unless ($size);
     my $e = $w->Scrolled('Listbox',-height => $size,-scrollbars => 'e');
     $e->configure(-selectmode => 'multiple') if $elem->attr('multiple');
     $w->window('create','insert',-window => $e);
     if (defined $form)
      {
       my $var = $form->Variable($elem);
       $$var   = Tk::Callback->new([\&Tk::HTML::Form::MultipleValue,$e]);
      }
     $h->TextHandler([\&MultipleText,$h,$e]);
    } 
   else 
    {
     my $buttonvar = "__not__";
     my $mb = $w->Optionmenu(-textvariable => \$buttonvar,-relief => 'raised');
     $w->window('create','insert',-window => $mb);
     if (defined $form)
      {
       my $var = $form->Variable($elem);
       $$var   = Tk::Callback->new([\&Tk::HTML::Form::OptionValue,$mb,\$buttonvar]);
      }
     $h->TextHandler([\&OptionText,$h,$mb]);
    }
  } 
 else 
  {
   pop(@{$h->{'Text'}});
   delete $h->{'option'};
  }
 return $f;
}

sub textarea 
{
  my($h,$f,$elem) = @_;
  if ($f) 
   {
    my $rows = $elem->attr('rows') || 20;
    my $cols = $elem->attr('cols') || 12;
    my $form = $h->CurrentForm;
    my $w = $h->Widget;
    $elem->{'NAME'} = '__inconnu__' if ! defined $elem->{'NAME'};
    my $t = $w->Scrolled('Text',-wrap => 'none',  -relief => 'sunken', -scrollbars => 'se',
                          -width => $cols, -height => $rows);
    $w->{'textarea'} = $t;
    if (defined $form)
     {
      my $var = $form->Variable($elem);
      $$var   = Tk::Callback->new([$t,'Contents']);
     }
    $w->window('create','insert',-window => $t);
    $h->{NL} = 0;
    $h->TextHandler([$t,'insert','end']);
   } 
  else 
   {
    pop(@{$h->{'Text'}});
   }
 return $f;
}
  
sub base 
{
 print STDERR "base(",join(',',@_),")\n";
 my($h,$f,$elem) = @_;
 $h->{'BODY'} = 0;
 print STDERR "base elem=$elem\n";
 my $w = $h->Widget;
 $w->configure(-base => $elem->attr('href'));
 return 1
}

sub isindex 
{
 my($h,$f,$elem) = @_;
 $h->{'BODY'} = 0;
 if ($f)
  {
   my $w = $h->{widget};
   $h->hr($f,$elem);
   $w->insert('end','This is a searchable index, enter keyword(s) : ');
   my $e = $w->Entry;
   $e->bind('<Return>',[$w,'call_ISINDEX',$e]);
   $w->window('create','end',-window => $e);
   $h->{NL} = 0;    
   $h->hr($f,$elem);
  }
 return $f;
}

sub img
{
 my ($h,$f,$elem) = @_;
 return 0 unless $f;
 my $w = $h->{widget};
 my $alt = $elem->attr('alt') || ">>Missing IMG<<";
 my $al = $elem->attr('align');
 my @al = (-align => 'baseline');
 if (defined $al)
  {
   my $al = "\U$al";
   if ($al eq "MIDDLE")
    {
     @al = (-align => 'center') 
    }
   elsif ($al eq "BOTTOM")
    {
     @al = (-align => 'baseline') 
    }
   elsif ($al eq "TOP")
    {
     @al = (-align => 'top') 
    }
   else
    {
     print "Align '$al'?\n";
    }
  }
 my $l = $w->Label(-text => $alt);
 my $td = $elem->enclosing(0,qw(td th));
 if ($td && 0)
  {
   $td->{'widget'} = $l;
  }
 else
  {
   $w->window('create','insert','-window' => $l, @al);
   $h->{NL} = 0;                
  }
 my $src = $elem->attr('src');
 $w->FindImage($src,$l) if ($src);
 my $a = $elem->enclosing(0,'a');
 if ($a || $elem->attr('image'))
  {
   $l->configure('-cursor' => "top_left_arrow", -borderwidth => 3, -relief => 'raised');
   if ($elem->attr('ismap') && $a)
    {
     $l->bind('<1>',[$w,'IMG_CLICK',$l,'ISMAP',$a->attr('href')]);
    } 
   elsif ($elem->attr('image'))
    {
     $l->bind('<1>',[$w,'IMG_CLICK',$l,'IMAGE',$f,$elem->attr('name')]);
    } 
   elsif ($a)
    {
     $l->bind('<1>',[$w,'IMG_CLICK',$l,'AREF',$a->attr('href')]);
    }
  }
 return $f;
}

sub title
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   $w->{TITLE} = "";
   $w->TextHandler(sub { $w->{TITLE} .= shift });
   $w->{'BODY'} = 0;
  }
 else
  {
   $w->{widget}->toplevel->title($w->{TITLE});
   pop(@{$w->{'Text'}});
  }
 return $w;
}

sub Heading
{
 my ($w,$f,$elem) = @_;
 $w->nl(2);
 if (!$f)
  {
   my $tag = uc $elem->tag;
   my $align = $elem->attr('align');
   $w->{widget}->tagConfigure($tag,-justify => lc($align)) if ($align);
   $w->ElemTag($elem);
  }
 return $w;
}

sub blockquote
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   $w->nl(1);
  }
 else
  {
   $w->ElemTag($elem);
   $w->nl(1);
  }
 return $w;
}

sub center
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   $w->nl(1);
  }
 else
  {
   $w->ElemTag($elem);
   $w->nl(1);
  }
 return $w;
}

sub DoesNothing
{
 my ($w,$f,$elem) = @_;
 return $f;
}

sub pre
{
 my ($h,$f,$elem) = @_;
 $h->{'PRE'} = $f;
 if (!$f)
  {
   $h->tagAdd('CODE',$elem->{'_Start_'},$elem->{'_End_'});
  }
 return $f;
}



sub List
{
 my ($w,$f,$elem) = @_;
 if ($f)
  {
   $elem->{Num} = 0;
   push(@{$w->{'List'}},['LI' . $elem->tag,0,$elem->{'_Start_'}]);
   my $depth = @{$w->{'List'}};
   if ($depth > 1) 
    {
     my $len = ($depth - 1) * 20;
     my $tag = $w->GenTag($elem->tag . "temp",
                          -lmargin1 => $len, 
                          -lmargin2 => $len,
                          -rmargin => $len);
     $w->tagAdd($tag,${${$w->{'List'}}[$depth-2]}[2],${${$w->{'List'}}[$depth-1]}[2]);
    }
  }
 else
  {
   my $depth = @{$w->{'List'}};
   if ($depth > 1) 
    {
     ${${$w->{'List'}}[$depth - 2]}[2] = $elem->{'_End_'};
     my $len = $depth * 20;
     my $tag = $w->GenTag($elem->tag,
                          -lmargin1 => $len, 
                          -lmargin2 => $len,
                          -rmargin => $len);
     $w->tagAdd($tag,${${$w->{'List'}}[$depth - 1]}[2],$elem->{'_End_'});
    }
   pop(@{$w->{'List'}});
  }
 return $f;
}

sub traverse
{
 my ($h,$elem,$start,$depth) = @_;
 my $e = ($start) ? '' : '/';
 # print ' 'x$depth," ",(ref $elem) ? "<$e".$elem->tag.'>' : $elem,"\n";
 if (ref $elem)
  {
   my $tag = $elem->tag;
   my $posn = $h->{widget}->index('insert');
   if ($start)
    {
     $elem->{'_Start_'} = $posn;
    }
   else
    {
     $elem->{'_End_'} = $posn;
    }
   return $h->$tag($start,$elem);
  }
 else
  {
   my $text = $elem;
   if (defined(substr($text,0,1)))
    {
     if (@{$h->{'Text'}})
      {
       $h->{'Text'}[-1]->Call($text);
      }
     else
      {
       return 0 unless ($h->{'BODY'});
       unless ($h->{'PRE'})
        {
         $text =~ s/\n/ /mg;
         $text =~ s/^\s+//g;
         $text =~ s/\s\s+/ /g;
         $text =~ s/\s+$//g;
        }
       $text = HTML::Entities::decode($text);
       if (length(substr($text,0,1)))
        {
         my $w = $h->{'widget'};
         $w->insert('insert',' ',qw(text)) unless ($h->{NL});
         $w->insert('insert',$text,qw(text));
         $h->{NL} = 0;                
         $h->{NL} = 1 if ($text =~ /\n$/);
        }
      }
    }
   return 1;
  }
}


