# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Scrolled
{
 my ($parent,$kind,%args) = @_;
 my @args = Tk::Frame->CreateArgs($parent,\%args);
 my $name = delete $args{'Name'};
 push(@args,'Name' => $name) if (defined $name);
 my $cw = $parent->Frame(@args);
 @args = ();
 my $k;
 # Need to consider other 'Frame' configure options...
 foreach $k ('-scrollbars',map($_->[0],$cw->configure))
  {
   push(@args,$k,delete($args{$k})) if (exists $args{$k})
  }
 $cw->ConfigSpecs('-scrollbars' => ['METHOD','scrollbars','Scrollbars','se'],
                  '-background' => ['CHILDREN','background','Background',undef], 
                 );
 my $w  = $cw->$kind(%args);
 %args = @args;
 $cw->AddScrollbars($w);
 $cw->Default("\L$kind" => $w);
 $cw->ConfigDefault(\%args);
 $cw->configure(%args);
 return $cw;
}

1;
