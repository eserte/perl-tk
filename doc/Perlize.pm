package Perlize;
use Carp;


use vars qw($VERSION);
$VERSION = '2.004'; # $Id: //depot/Tk/doc/Perlize.pm#4$

sub widget
{
 $$var = '$widget' unless (defined $$var);
 return '\fI'.$$var;
}

sub method
{
 my ($meth,$arg) = @_;
 $$var = '$toplevel' if (!defined($$var) && $meth =~ /\bwm\b/);
 $$var = '$widget' unless (defined $$var);
 my $result = widget().'->\fB';
 $meth =~ s/^\s*(wm|winfo)?\b\s*//;
 my @names  = split(/\s+/,$meth);
 $result .= shift(@names);
 while (@names)
  {
   my $cmd = shift(@names);
   $result .= "\u$cmd";
  }
 if (defined $arg)
  {
   my $nl = $arg =~ /\n$/;
   $arg =~ s/(\\f[IR])(\s+)/$2$1/g;
   $arg =~ s/^\s+//;
   $arg =~ s/^\\fR\s*//;
   $arg =~ s/\s+$//;
   $arg =~ s/\s*\\fR$//;
   if (length $arg)
    {
     # print STDERR "'$arg'\n" if ($meth =~ /configure/);
     $result .= '\fR(';
     my @arg = split(/\s+/,$arg);
     $result .= join(', ',@arg);
     $result .= '\fR)';
    }
   else
    {
     $result .= '\fR';
    }
   $result .= "\n" if ($nl);
  }
 return $result;
}

sub define
{
 my ($kind,$args) = @_;
 $$var = '$'."\L$kind";
 # print STDERR "define \u$kind\n";
 return widget().'\fR = \fI$parent\fR->\fB'."\u$kind".'\fR('.$args.'\fR);';
}

sub option
{
 my ($name,$val) = @_;
 $val =~ s/pathName/\$widget/;
 return "\\fB\\$name\\fR => \\fI$val\\fR";
}

sub munge ($$)
{
 local ($_,$var) = @_;
 confess "Not a reference $var" unless (ref($var) eq 'SCALAR'); 
 # s/(\\f[A-Z])(\.\w+)+\b/$1\pathName/g;
 s/^\.SH\s+"WIDGET\s+COMMAND"/.SH "WIDGET METHODS"/;
 s/^Command-Line\s*Switch:/Configure Option:/;
 s/"Tk\s+Built-In\s+Commands"/"Tk Generic Methods"/;
 s/\bwidget\s+command/method/;
 s/new\s+Tcl\s+command/widget object/;
 s/Tcl\s+script/Callback/;
 s/Tcl\s+list/array/;
 s/\b([Ss]ee\s+\\fB)Tk_ConfigureInfo(\\fR)/$1configure$2/g;

 s/\\fIpathName\s+option\s+\\fR(\?\\fI(arg\s+)+\.\.\.\\fR\?)/&widget()."\\fR->\\fBmethod\\fR($1)"/e;

 s/\\fB\\(-[a-z]\w+)\s+\\fI(\w+)\\fR/&option($1,$2)/eg;
 s/\\fB([a-zA-Z]+\b)(\s|\\fI)*\\fI\s*pathName\s*(\\fR\?\\fIoptions\\fR\?)/&define($1,$3)/e;

 if (/-displayof\b/)
  {
   s/(\\f[IBR])?[\s\?]*\\?-displayof\s*(\\f[IBR])?[\s\?]*\\fIwindow\s*(\\f[IBR])?[\s\?]*/ \\fIwindow\\fR /;
  }
 elsif (/window\b/)       
  {
   s/\\fBselection/\\fBSelection/; 
   s/(\\fBSelection([\w\s]+))(.*)(\\fIwindow\\fR)/$1$4$3?/; 
   s/\\fB([\w\s]+)\\fIwindow\s*((\\f[BIR](\\-)?[\w\s\?\.-]+)*)/&method($1,$2)/eg;
   s/\\f[IB]window\b/\$widget/g;
  }
 if (/pathName/)
  {
   s/\\f[IB]pathName\s*\\fB([\w\s]+)((\\f[BIR][\w\s\?\.-]+)*)/&method($1,$2)/eg;
   s/\\f[IB]pathName\b/\$widget/g;
  }
 return $_;
}

1;
