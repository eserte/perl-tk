package Tk::HTML::Form;
use AutoLoader;
use Carp;
@ISA = qw(AutoLoader HTML::Element);

*SUBMIT = \&Button;
*RESET  = \&Button;
*PASSWORD = \&TEXT;

use strict;

sub encode 
{
 my $class = shift;
 my $a = shift;
 $a =~ s/\n/\015\012/gm;
 $a =~ s/([^0-9A-Za-z ])/sprintf('%%%02X',ord($1))/egm;
 $a =~ s/ /+/gm;
 return $a;
}

sub Owner
{
 return shift->{'Owner'};
}

sub Variable
{
 my ($form,$elem) = @_;
 my $name = $elem->attr('NAME');
 my @pair = ($name,undef);
 push(@{$form->{'Values'}},\@pair);
 return \$pair[1];
}

sub Reset
{
 my ($f) = @_;
 my ($a,$b);
 my $r = $f->{'Reset'};
 my $v = $f->{'Values'};
 my $i;
 for ($i= 0; $i < @$v; $i++)
  {
   if (ref($v->[$i][1]))
    {
     $v->[$i][1]->Call($r->[$i]);
    }
   else
    {
     $v->[$i][1] = $r->[$i];
    }
  }
}

sub link_text 
{
  my($f,$e) = @_;
  my @t = @{$f->{'LINKED_TEXT'}};
  my $i;
  for($i=0;$i<=$#t;$i++) 
   {
    last if $t[$i] == $e;
   }
  $i++;
  $i = 0 if $i > $#t;
  $t[$i]->focus();
}

sub TEXT
{
 my ($form,$elem) = @_;
 my $h = $form->Owner;
 my $w = $h->Widget;
 my $var = $form->Variable($elem);
 $$var= $elem->attr('VALUE');
 my $e = $w->Entry(-relief => 'sunken', -textvariable => $var );
 push(@{$form->{'LINKED_TEXT'}},$e);
 $e->bind('<Return>' => [$form,'link_text',$e]);
 my $size = $elem->attr('size'); 
 $e->configure(-width => $size) if ($size);
 $e->configure(-show => '*') if ($elem->attr('type') =~ /PASSWORD/i);
 $w->window('create','insert',-window => $e);
 $h->{NL} = 0;                
}


sub Button
{
 my ($form,$elem) = @_;
 my $h = $form->Owner;
 my $w = $h->Widget;
 my $type = $elem->attr('type');
 my $method = "\u\L$type";
 my $text = $elem->attr('value'); 
 $text   = $method unless (defined $text);
 if ($elem->attr('name'))
  {
   my $var = $form->Variable($elem);
   $$var = $elem->attr('value');
  }
 my $e = $w->Button(-text => $text, -command => [$form,$method]);
 $w->window('create','insert',-window => $e);
 $h->{NL} = 0;                
}

sub CHECKBOX
{
 my ($form,$elem) = @_;
 my $h = $form->Owner;
 my $w = $h->Widget;
 my $var = $form->Variable($elem);
 $elem->{'value'} = 1 unless (defined $elem->{'value'});
 ${$var} = ($elem->attr('checked')) ?$elem->attr('value'): undef;
 my $e = $w->Checkbutton(-variable => $var, -onvalue => $elem->attr('value'), -offvalue => undef);
 $w->window('create','insert',-window => $e);
 $h->{NL} = 0;                
}

sub RadioValue
{
 my ($bv,$val) = @_;
 $$bv = $val if (@_ > 1);
 return $$bv;
}

sub RADIO
{
 my ($form,$elem) = @_;
 my $h = $form->Owner;
 my $w = $h->Widget;
 $form->{'RadioVars'} = {} unless (exists $form->{'RadioVars'});
 my $name = $elem->attr('NAME');
 $name = '__NONAME__' unless (defined $name);
 unless (exists $form->{'RadioVars'}{$name})
  {
   my $var = $form->Variable($elem);
   $$var = Tk::Callback->new([\&RadioValue,\$form->{'RadioVars'}{$name}]);
  }
 my $bv = \$form->{'RadioVars'}{$name};
 $$bv = $elem->attr('VALUE') if (defined $elem->attr('SELECTED'));
 my $e = $w->Radiobutton(-variable => $bv, -value => $elem->attr('VALUE'));
 $w->window('create','insert',-window => $e);
 $h->{NL} = 0;                
}

sub HIDDEN
{
 my ($form,$elem) = @_;
 my $var = $form->Variable($elem);
 $$var = $elem->attr('VALUE');  
}

sub IMAGE
{
 my ($form,$elem) = @_;
 my $h = $form->Owner;
 my $n = $elem->attr('NAME');
 if($elem->attr('name') && $elem->attr('src')) 
  {
   $elem->attr(image => $form);
   $h->img($form,$elem);
  }
}

sub OptionValue
{
 my ($mb,$var) = @_;
 my $val = $$var;
 if (exists $mb->{FORM_MAP})
  {
   $val = $mb->{FORM_MAP}{$val} if (exists $mb->{FORM_MAP}{$val});
  }
 return $val;
}

sub MultipleValue
{
 my ($lb,$name) = @_;
 my $index;
 my @val = ();
 foreach $index ($lb->curselection)
  {
   if (exists $lb->{FORM_MAP} && defined $lb->{FORM_MAP}[$index])
    {
     push(@val, $lb->{FORM_MAP}[$index]);
    }
   else
    {
     push(@val, $lb->get($index));
    }
  }
 return @val;
}

sub Submit
{
 my($f) = shift;
 my @query = @_;
 my $h = $f->Owner;
 my $w = $h->Widget;
 my $action = $f->attr('action');
 my $method = $f->attr('method');
 $method = 'GET' unless (defined $method);
 $action = ''    unless (defined $action);
 my $what;
 foreach $what (@{$f->{'Values'}})
  {
   my ($a,$b) = @$what;
   my @val = (ref $b) ? $b->Call : $b;
   foreach $b (@val)
    {
     push(@query,"$a=" . $f->encode($b)) if (defined $b); 
    }
  }
 my $query = join('&',@query); 
 if ($method eq "POST") 
  {
   $w->HREF($action,$method,$query);
  } 
 else 
  {
   $w->HREF("$action?$query",$method);
  }
}

1;
__END__


