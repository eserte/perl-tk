package Tk::CmdLine;
require Tk;
use strict;

*motif = \$Tk::strictMotif;


use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/Tk/CmdLine.pm#3$

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

=head1 NAME

Tk::CmdLine - Process standard X11 command line options

=head1 SYNOPSIS

use Tk::CmdLine;

=head1 DESCRIPTION

The X11R5 man page for X11 says :

"Most X programs attempt to use the same  names  for  command
line  options  and arguments.  All applications written with
the X Toolkit Intrinsics automatically accept the  following
options: ..."

This module implemements these command line options for perl/Tk 
applications.

The options which are processed are :

=over 4

=item     -display display

This option specifies the name of the  X  server  to
use.


=item     -geometry geometry

This option specifies the initial size and  location
of the I<first> MainWindow.

=item     -bg color, -background color

Either option specifies the color  to  use  for  the
window background.

=item     -bd color, -bordercolor color

Either option specifies the color  to  use  for  the
window border.

=item     -bw number, -borderwidth number

Either option specifies the width in pixels  of  the
window border.

=item     -fg color, -foreground color

Either option specifies the color to use for text or
graphics.

=item     -fn font, -font font

Either option specifies the font to use for display-
ing text.

=item     -iconic

This option indicates that  the  user  would  prefer
that  the  application's  windows  initially  not be
visible as if the windows had be immediately  iconi-
fied by the user.  Window managers may choose not to
honor the application's request.

=item     -name

This option specifies the name under which resources
for the application should be found.  This option is
useful in shell aliases to distinguish between invo-
cations  of  an  application,  without  resorting to
creating links to alter the executable file name.

=item     -rv, -reverse

Either option  indicates  that  the  program  should
simulate  reverse  video if possible, often by swap-
ping the foreground and background colors.  Not  all
programs  honor  this or implement it correctly.  It
is usually only used on monochrome displays.

B<Tk::CmdLine Ignores this option.>

=item     +rv

This option indicates that the  program  should  not
simulate reverse video. This is used to override any
defaults since reverse  video  doesn't  always  work
properly.

B<Tk::CmdLine Ignores this option.>

=item     -selectionTimeout

This option specifies the  timeout  in  milliseconds
within  which  two  communicating  applications must
respond to one another for a selection request.

B<Tk::CmdLine Ignores this option.>

=item     -synchronous

This option indicates that requests to the X  server
should  be  sent synchronously, instead of asynchro-
nously.  Since Xlib normally buffers requests to the
server,  errors  do  not  necessarily  get  reported
immediately after they occur.  This option turns off
the   buffering  so  that  the  application  can  be
debugged.  It should never be used  with  a  working
program.

=item     -title string

This option specifies the title to be used for  this
window.   This  information  is  sometimes used by a
window manager to provide some sort of header  iden-
tifying the window.

=item     -xnllanguage language[_territory][.codeset]

This option specifies the language,  territory,  and
codeset  for  use  in  resolving  resource and other
filenames.

B<Tk::CmdLine Ignores this option.>

=item     -xrm resourcestring

This option specifies a resource name and  value  to
override  any  defaults.  It is also very useful for
setting resources that don't have  explicit  command
line arguments.

The I<resourcestring> is of the form C<name:value>, that is (the first) ':' 
is the used to determine which part is name and which part is value.
The name/value pair is entered into the options database with C<optionAdd>
(for each MainWindow configd), with "interactive" priority.

=back 4

=cut
