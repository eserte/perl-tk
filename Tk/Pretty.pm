package Tk::Pretty;
require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(pretty PrintArgs);

sub pretty_list
{
 join(',',map(&pretty($_),@_));
}

sub pretty
{
 return pretty_list(@_) if (@_ > 1);
 my $obj = shift;
 return "undef" unless defined($obj);
 my $type = "$obj";
 return $type if ($type =~ /=HASH/ && exists($obj->{"_Tcl_CmdInfo_\0"}));
 my $result = "";
 if (ref $obj)
  {
   my $class;    
   if ($type =~ /^([^=]+)=(.*)$/)
    {            
     $class = $1;
     $type  = $2;
     $result .= "bless(";
    }            
   if ($type =~ /^ARRAY/)
    {            
     $result .= "[";
     $result .= pretty_list(@$obj);
     $result .= "]";
    }            
   elsif ($type =~ /^HASH/)
    {            
     $result .= "{";
     if (%$obj)
      {
       while (($key,$value) = each %$obj)
        {            
         $result .= $key . "=>" . pretty($value) . ",";
        }            
       chop($result);
      }
     $result .= "}";
    }            
   elsif ($type =~ /^REF/)
    {            
     $result .= "\\" . pretty($$obj);
    }            
   elsif ($type =~ /^SCALAR/)
    {            
     $result .= pretty($$obj);
    }            
   else          
    {            
     $result .= $type;
    }            
   $result .= ",$class)" if (defined $class);
  }
 else
  {
   if ($obj =~ /^-?[0-9]+(.[0-9]*(e[+-][0-9]+)?)?$/ ||
       $obj =~ /^[A-Z_][A-Za-z_0-9]*$/ ||
       $obj =~ /^[a-z_][A-Za-z_0-9]*[A-Z_][A-Za-z_0-9]*$/
      )
    {
     $result .= $obj;
    }
   else
    {
     $result .= "'" . $obj . "'";
    }
  }
 return $result;
}

sub PrintArgs
{
 my $name = (caller(1))[3];
 print "$name(",pretty(@_),")\n";
}

1;
