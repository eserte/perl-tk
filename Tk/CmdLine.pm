package Tk::CmdLine;
require Tk;
use strict;

*motif = \$Tk::strictMotif;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/CmdLine.pm#8$

use vars qw($synchronous %switch $iconic %options %methods @command %config);

$synchronous = 0;
$iconic      = 0;

@command = ();
%options = ();
%config  = (-name => ($0 eq '-e' ? 'pTk' : $0));
$config{'-name'}  =~ s#^.*/##; 

sub arg
{
 my $flag = shift;
 die("Usage: $0 ... $flag <argument> ...\n") unless (@ARGV);
 return shift(@ARGV);
}

sub variable
{
 no strict 'refs';
 my ($flag, $name) = @_;
 my $val = arg($flag);
 push(@command, $flag => $val );
 ${$name} = $val;
}

sub config
{
 my ($flag, $name) = @_;
 my $val = arg($flag);
 push(@command, $flag => $val );
 $config{"-$name"} = $val;
}

sub flag
{
 no strict 'refs';
 my ($flag, $name) = @_;
 push(@command, $flag );
 ${$name} = 1;
}

sub option
{
 my ($flag,$name) = @_;
 my $val = arg($flag);
 push(@command, $flag => $val );
 $options{"*$name"} = $val;
}

sub method
{
 my ($flag,$name) = @_;
 my $val = arg($flag);
 push(@command, $flag => $val );
 $methods{$name} = $val;
}

sub resource
{
 my ($flag,$name) = @_;
 my $val = arg($flag);
 push(@command, $flag => $val );
 ($name,$val) = $val =~ /^([^:\s]+)*\s*:\s*(.*)$/;
 $options{$name} = $val;
}

%switch = ( synchronous  => \&flag,
            screen       => \&config,
            borderwidth  => \&config,
            class        => \&config,
            geometry     => \&method,
            iconposition => \&method,
            name         => \&config,
            motif        => \&flag,
            background   => \&option,
            foreground   => \&option,
            font         => \&option,
            title        => \&config,
            iconic       => \&flag,
            'reverse'    => \&flag,
            xrm          => \&resource,
            bg           => 'background',
            bw           => 'borderwidth',
            fg           => 'foreground',
            fn           => 'font',
            rv           => 'reverse',
            display      => 'screen',
         );

#   -bd color, -bordercolor color
#    -selectionTimeout
#    -xnllanguage language[_territory][.codeset]

sub process
{
 my ($class) = @_;
 while (@ARGV && $ARGV[0] =~ /^-(\w+)$/)
  {
   my $sw = $1;
   my $kind = $switch{$sw};
   last unless defined $kind;
   $kind = $switch{$sw = $kind} unless ref $kind;
   &$kind(shift(@ARGV),$sw); 
  }
}

sub CreateArgs
{
 process();
 $config{'-class'} = "\u$config{'-name'}" unless exists $config{'-class'};
 return \%config;
}

sub Tk::MainWindow::apply_command_line
{
 my $mw = shift;
 my $key;
 foreach $key (keys %options)
  {
   $mw->optionAdd($key => $options{$key},'interactive');
  }
 foreach $key (keys %methods)
  {
   $mw->$key($methods{$key});
  }
 if (delete $methods{'geometry'})
  {
   $mw->positionfrom('user');
   $mw->sizefrom('user'); 
  }
 $mw->Synchronize if $synchronous;
 if ($iconic)
  {
   $mw->iconify; 
   undef $iconic;
  }
 # 
 # Both these are needed to reliably save state
 # but 'hostname' is tricky to do portably.
 # $mw->client(hostname());
 # $mw->protocol('WM_SAVE_YOURSELF' => ['WMSaveYourself',$mw]);
 $mw->command([$0,@command]);
}

1;

__END__

=cut
