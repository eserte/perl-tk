BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;
use Tk::Font;

BEGIN { plan tests => 13,
        todo => [10]
      };

my $mw = Tk::MainWindow->new;

##
## if there's only one (fixed) or no font family
## then something is wrong. Propably the envirionment
## and not perl/Tks fault.
##
{
    my @fam = ();
    eval { @fam = $mw->fontFamilies; };
    ok($@ eq "");
    ok(@fam>1, 1, "Num. of font families=".scalar @fam)
}
##
## Tk800.003 writes 'ont ...' in warning instead of 'font ...'
## fontActual expects one argument
##  opps,  looks like fault of ptksh
{
  eval { $mw->fontActual; };
  ok(
	( $@ =~ /^wrong # args: should be "font/), 1,
	"Warning should match /^wrong # args: should be \"font/ but was '". $@ . "'"
    );
}
##
## Stephen O. Lidie reported that Tk800.003
## fontMeasure() and fontMeasure(fontname) gives
## SEGV on linux and AIX.
##
{
  my $fontname = ($^O eq 'MSWin32') ? 'ansifixed': 'fixed';
  eval { $mw->fontMeasure; };
  ok(
	($@ ne "") , 1,
	"Opps fontMeasure works without args. Documented to require two"
    );
  eval { $mw->fontMeasure($fontname); };
  ok(
	($@ ne "") , 1,
	"Opps fontMeasure works with one arg. Documented to require two"
    );
  my $num = undef;
  eval { $num = $mw->fontMeasure($fontname, 'Hi'); };
  ok(
	($@ eq "") , 1,
	"Opps fontMeasure works doesn't work with fixed font and a string: ".$@
    );
  ok(
	defined($num) , 1,
	"Opps fontMeasure returned undefined value"
    );
  ok(
	($num > 2), 1,
	"Opps fontMeasure claims string 'Hi' is only $num pixels wide."
    );
  my $l = $mw->Label(-font => $fontname);
  my $name;
  eval { $name = $l->cget('-font') };
  ok(
        "$name", $fontname,
        "cget(-font) returns wrong value."
    );
}

my @fam = $mw->fontFamilies;
foreach my $fam ($mw->fontFamilies)
 {
  print "# $fam\n";
 }

$mw->optionAdd('*Listbox.font','Times -12 bold');
my $lb = $mw->Listbox()->pack;
$lb->insert(end => '0',"\xff","\x{20ac}","\x{0289}");
$lb->update;
my $lf = $lb->cget('-font');
print "# $$lf:",join(',',$mw->fontActual($lf)),"\n";
my %expect = (-family => 'Times',
              -size   => -12, -weight => 'bold',
              -slant  => 'roman');
foreach my $key (sort keys %expect)
 {
  my $val = $mw->fontActual($lf,$key);
  ok($val,qr/$expect{$key}/i,"Value of $key");
 }

my @subfonts = $mw->fontSubfonts($lf);
foreach my $sf (@subfonts)
 {
  print '# ',join(',',@$sf),"\n";
 }


__END__
