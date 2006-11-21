BEGIN { $|=1; $^W=1; }
use strict;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

use Tk;
use Tk::Font;
use Getopt::Long;

plan tests => 20;

my $v;
GetOptions("v" => \$v)
    or die "usage: $0 [-v]";

my $mw = Tk::MainWindow->new;
$mw->geometry("+10+10");

##
## if there's only one (fixed) or no font family
## then something is wrong. Propably the envirionment
## and not perl/Tks fault.
##
{
    my @fam = ();
    eval { @fam = $mw->fontFamilies; };
    is($@, "", "fontFamilies");
    cmp_ok(@fam,">",1, "Num. of font families=".scalar @fam);
}
##
## Tk800.003 writes 'ont ...' in warning instead of 'font ...'
## fontActual expects one argument
##  opps,  looks like fault of ptksh
{
  eval { $mw->fontActual; };
  like($@, qr/^wrong # args: should be "font/,
       "fontActual without font error");
}
##
## Stephen O. Lidie reported that Tk800.003
## fontMeasure() and fontMeasure(fontname) gives
## SEGV on linux and AIX.
##
{
  my $fontname = ($^O eq 'MSWin32') ? 'ansifixed': 'fixed';
  eval { $mw->fontMeasure; };
  isnt($@, "", "fontMeasure documented to require two args, not zero");
  eval { $mw->fontMeasure($fontname); };
  isnt($@, "", "fontMeasure documented to require two args, not one");
  my $num = undef;
  eval { $num = $mw->fontMeasure($fontname, 'Hi'); };
  is($@, "", "fontMeasure works with fixed font and a string");
  ok(defined $num);
  cmp_ok($num, ">=", 2, "fontMeasure value is large enough");
  my $l = $mw->Label(-font => $fontname);
  my $name;
  eval { $name = $l->cget('-font') };
  is("$name", $fontname, "cget(-font) returns same fontname");
}

my @fam = $mw->fontFamilies;
if ($v)
 {
  diag "Font families:";
  foreach my $fam (@fam)
   {
    diag "* $fam";
   }
 }

SKIP:
 {
  skip("Times not available", 4)
      if !grep { /^times$/i } @fam;

  $mw->optionAdd('*Listbox.font','Times -12 bold');
  my $lb = $mw->Listbox()->pack;
  $lb->insert(end => '0',"\xff","\x{20ac}","\x{0289}");
  $lb->update;
  my $lf = $lb->cget('-font');
  diag "Font attributes: $$lf:" . join(',',$mw->fontActual($lf))
      if $v;
  my %expect = (-family => 'Times',
		-size   => -12, -weight => 'bold',
		-slant  => 'roman');
  foreach my $key (sort keys %expect)
   {
    my $val = $mw->fontActual($lf,$key);
    like($val, qr{\Q$expect{$key}}i, "Value of $key from fontActual");
   }

  my @subfonts = $mw->fontSubfonts($lf);
  if ($v)
   {
    diag "Subfonts of $$lf:";
    foreach my $sf (@subfonts)
     {
      diag '* ' . join(',',@$sf);
     }
   }
 }

{
 # This caused core dumps with Xft version of Perl/Tk
 my $l = $mw->Label(-font => '-*-*-bold-r-*--12-*-*-*-*-*-*-*');
 $l->destroy;
 pass("Core dump check (especially for XFT)");
}

{
 # This caused core dumps with Perl/Tk 804.027
 eval { $mw->fontMeasure(undef, -ascent)};
 like($@, qr{Cannot use undef as font object},
      "Core dump check with undef font object");

 eval { $mw->fontConfigure(undef) };
 like($@, qr{Cannot use undef as font object});

 eval { $mw->fontActual(undef) };
 like($@, qr{Cannot use undef as font object});
}

{
 my $l = $mw->Label;
 my $f = $l->cget(-font);
 isa_ok($f, 'Tk::Font');
 my $ascent = $f->measure(-ascent);
 ok(defined $ascent, "Got ascent from measure");
 eval { $f->actual(undef,undef) };
 like($@, qr{\Qwrong # args: should be "font actual font},
      "Does not get error about undef font object");
}

__END__
