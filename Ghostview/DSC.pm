package DSC;
use Tk::Pretty;

sub new
{
 my $package = shift;
 my $gs      = shift;
 my $file    = shift;
 my %hash    = ();
 my @label   = ();
 my @posn    = ();
 my %page    = ();
 my $page   = -1;
 my $nested = 0;
 open($file,"<$file") || die "Cannot open $file:$!";
 print STDERR "Reading $file ...\n";
 my $posn = tell($file);
 $hash{'LabelLen'} = 0;
 $hash{'FH'}    = \*{$file};
 $hash{'Page'}  = \%page;
 $hash{'Posn'}  = \@posn;
 $hash{'Label'} = \@label;
 $hash{'Contents'} = \%Contents;
 my $doc = bless \%hash,$package;
 while (<$file>)
  {
   if (/^%%([^:]+):\s*(.*)$/)
    {
     my $key  = $1;
     my $text = $2;
     $text =~ s/\s+$//; 
     $nested++ if ($key eq 'BeginDocument');
     next if $nested; 
     next if ($text =~ /\(atend\)/);
     if ($key eq 'Page')
      {
       ($label,$num) = $text =~ /^(\S*)\s+(\d+)$/;
       $num = $text =~ /^(\d+)$/ if (!defined $num);
       $label = $num unless (defined $label);
       if (defined $num)
        {
         $page++;
         $posn[$page]   = $posn;
         $label[$page]  = $label;
         $page{$label}  = $page;
         $hash{'LabelLen'} = length($label) if (length($label) > $hash{'LabelLen'});
        }
       else
        {
         warn "($label,$num) Bad $_";
        }
      }
     elsif ($key eq 'BoundingBox')
      {
       $gs->BoundingBox(split(/\s+/,$text));
      }
     elsif ($key eq 'Orientation')
      {
       $gs->Orientation($text);
      }
     else
      {
       $hash{$key} = $text unless ($text =~ /\(atend\)/);
      }
    }
   elsif (/^%%([^:]+\S)\s*$/)
    {
     if ($1 eq 'EndDocument') 
      {
       $nested--;
      }
     else
      {
       $hash{$1} = $posn unless ($nested || /Page/);
      }
    }
   elsif (/^%@\s+\d+\s+(\w+)\s+([^\t]*)\t(.*)$/)
    {
     my $kind = $Contents{$1}; 
     my $len2  = length($2);
     my $len3  = length($3);
     if (defined $kind)
      {
       $Contents{$1.'#Llen'} = $len2 if ($len2 > $Contents{$1.'#Llen'});
       $Contents{$1.'#Tlen'} = $len3 if ($len3 > $Contents{$1.'#Tlen'});
      }
     else
      {
       $Contents{$1} = $kind = [];
       $Contents{$1.'#Llen'} = $len2;
       $Contents{$1.'#Tlen'} = $len3;
      }
     push(@$kind,[$2,$3,$page]);
    }
   $posn = tell($file);
  }
 $page++;
 print STDERR "$page Pages\n";
 return $doc;
}

sub Contents { shift->{'Contents'} }

sub CopyTill
{my $doc   = shift;
 my $out   = shift;
 my $posn  = shift;
 my $start = shift;
 my $fh = $doc->{'FH'};
 if (defined ($posn))
  {
   my $nested = 0;
   my $fh = $doc->{'FH'};
   seek($fh,$posn,0) || die "Cannot seek $$fh to $posn:$!";
   local $_ = <$fh>;
   die "$_" unless (/^%/ && /$start/);
   COPY:
   while (1)
    {
     $nested++ if (/^%%BeginDocument/);
     $nested-- if (/^%%EndDocument/);
     $out->Postscript($_);
     $_ = <$fh>;
     last COPY if (!defined $_);
     foreach $term (@_)
      {
       last COPY if (!$nested && /^%%$term/);
      }
    } 
  }
 else
  {
   die "No posn for $start";  
  }
}

sub SendPage
{my $doc = shift;
 my $out = shift;
 my $num;
 foreach $page (@_)
  {
   my $posn = $doc->{'Posn'}[$page];
   $doc->CopyTill($out,$posn,"^%%Page:",'Page:','Trailer');
  }
}

sub CopySection
{
 my $doc = shift;
 my $out = shift;
 my $key = shift;
 my $start = 'Begin'.$key;
 my $end   = 'End'.$key;
 my $posn = $doc->{$start};
 if (defined $posn)
  {
   $doc->CopyTill($out,$posn,"^%%$start",$end,'Page:','Trailer');
  }
 else
  {
   warn "No $start:" . pretty($doc);
  }
}

1;
