package Tk::DragDrop::Rect;

sub NewDrag
{
 my ($class,$widget) = @_;
}

sub Enter
{
 my ($site,$token,$event) = @_;
 $token->configure(-relief => 'sunken');
 $token->{'Over'} = $site;
}

sub Leave
{
 my ($site,$token,$event) = @_;
 $token->configure(-relief => 'flat');
 delete $token->{'Over'};
}

sub Motion
{
 my ($site,$token,$event) = @_;
}

sub Drop
{
 my ($site,$win,$seln,$event) = @_;
}

sub Over
{
 my ($site,$X,$Y) = @_;
 my $x = $site->X;
 my $y = $site->Y;
 my $val = ($X >= $x && $X < ($x + $site->width) && 
         $Y >= $y && $Y < ($y + $site->height));
 # print "Over ",$site->Show," $X,$Y => $val\n";
 return $val;
}

sub Match
{
 my ($site,$other) = @_;
 return 0 unless (defined $other);
 return 1 if ($site == $other);
 return 0 unless (ref($site) eq ref($other)); 
 for ("$site")
  {
   if (/ARRAY/)
    {
     my $i;   
     return 0 unless (@$site == @$other); 
     for ($i = 0; $i < @$site; $i++)
      {       
       return 0 unless ($site->[$i] == $other->[$i]);
      }       
     return 1;
    }
   elsif (/SCALAR/)
    {
     return $site == $other;
    }
   elsif (/HASH/)
    {
     my $key;
     foreach $key (keys %$site)
      {
       return 0 unless ($other->{$key} == $site->{$key});
      }
     foreach $key (keys %$other)
      {
       return 0 unless ($other->{$key} == $site->{$key});
      }
     return 1;
    }
   return 0;
  }
 return 0;
}


1;
