package Tk::CmdLine; # -*-Perl-*-

#/----------------------------------------------------------------------------//
#/ Module: Tk/CmdLine.pm
#/
#/ Purpose:
#/
#/   Process standard X11 command line options and set initial resources.
#/
#/ Author: ????                      Date: ????
#/
#/ History: SEE POD
#/----------------------------------------------------------------------------//

use vars qw($VERSION);
$VERSION = '4.004'; # $Id: //depot/Tkutf8/Tk/CmdLine.pm#4 $

use 5.004;

use strict;

use Config;

my $OBJECT = undef; # define the current object

#/----------------------------------------------------------------------------//
#/ Constructor
#/   Returns the object reference.
#/----------------------------------------------------------------------------//

sub new # Tk::CmdLine::new()
{
    my $this  = shift(@_);
    my $class = ref($this) || $this;

    my $name = 'pTk';
    $name = $1 if (($0 =~ m/(?:^|[\/\\])([\w-]+)(?:\.\w+)?$/) && ($1 ne '-e'));

    my $self = {
        name        => $name,
        config      => { -name => $name },
        options     => {},
        methods     => {},
        command     => [],
        synchronous => 0,
        iconic      => 0,
        motif       => ($Tk::strictMotif || 0),
        resources   => {} };

    return bless($self, $class);
}

#/----------------------------------------------------------------------------//
#/ Process the arguments in a given array or in @ARGV.
#/   Returns the object reference.
#/----------------------------------------------------------------------------//

sub Argument_ # Tk::CmdLine::Argument_($flag) # private method
{
    my $self = shift(@_);
    my $flag = shift(@_);
    unless ($self->{offset} < @{$self->{argv}})
    {
        die 'Usage: ', $self->{name}, ' ... ', $flag, " <argument> ...\n";
    }
    return splice(@{$self->{argv}}, $self->{offset}, 1);
}

sub Config_ # Tk::CmdLine::Config_($flag, $name) # private method
{
    my $self = shift(@_);
    my ($flag, $name) = @_;
    my $val = $self->Argument_($flag);
    push(@{$self->{command}}, $flag, $val);
    $self->{config}->{"-$name"} = $val;
}

sub Flag_ # Tk::CmdLine::Flag_($flag, $name) # private method
{
    my $self = shift(@_);
    my ($flag, $name) = @_;
    push(@{$self->{command}}, $flag);
    $self->{$name} = 1;
}

sub Option_ # Tk::CmdLine::Option_($flag, $name) # private method
{
    my $self = shift(@_);
    my ($flag, $name) = @_;
    my $val = $self->Argument_($flag);
    push(@{$self->{command}}, $flag, $val);
    $self->{options}->{"*$name"} = $val;
}

sub Method_ # Tk::CmdLine::Method_($flag, $name) # private method
{
    my $self = shift(@_);
    my ($flag, $name) = @_;
    my $val = $self->Argument_($flag);
    push(@{$self->{command}}, $flag, $val);
    $self->{methods}->{$name} = $val;
}

sub Resource_ # Tk::CmdLine::Resource_($flag, $name) # private method
{
    my $self = shift(@_);
    my ($flag, $name) = @_;
    my $val = $self->Argument_($flag);
    if ($val =~ /^([^!:\s]+)*\s*:\s*(.*)$/)
    {
        push(@{$self->{command}}, $flag, $val);
        $self->{options}->{$1} = $2;
    }
}

my %Method = (
    background   => 'Option_',
    bg           => 'background', # alias
    class        => 'Config_',
    display      => 'screen',     # alias
    fg           => 'foreground', # alias
    fn           => 'font',       # alias
    font         => 'Option_',
    foreground   => 'Option_',
    geometry     => 'Method_',
    iconic       => 'Flag_',
    iconposition => 'Method_',
    motif        => 'Flag_',
    name         => 'Config_',
    screen       => 'Config_',
    synchronous  => 'Flag_',
    title        => 'Config_',
    xrm          => 'Resource_'
);

sub SetArguments # Tk::CmdLine::SetArguments([@argument])
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object
    $self->{argv}   = (@_ ? [ @_ ] : \@ARGV);
    $self->{offset} = 0; # its existence will denote that this method has been called

    my @option = ();

    while ($self->{offset} < @{$self->{argv}})
    {
        last if ($self->{argv}->[$self->{offset}] eq '--');
        unless (
            (($self->{argv}->[$self->{offset}] =~ /^-{1,2}(\w+)$/)  && (@option = $1)) ||
            (($self->{argv}->[$self->{offset}] =~ /^--(\w+)=(.*)$/) && (@option = ($1, $2))))
        {
            ++$self->{offset};
            next;
        }

        next if (!exists($Method{$option[0]}) && ++$self->{offset});

        $option[0] = $Method{$option[0]} if exists($Method{$Method{$option[0]}});

        my $method = $Method{$option[0]};

        if (@option > 1) # replace --<option>=<value> with <value>
        {
            $self->{argv}->[$self->{offset}] = $option[1];
        }
        else # remove the argument
        {
            splice(@{$self->{argv}}, $self->{offset}, 1);
        }

        $self->$method(('-' . $option[0]), $option[0]);
    }

    $self->{config}->{-class} ||= ucfirst($self->{config}->{-name});

    delete($self->{argv}); # no longer needed

    return $self;
}

use vars qw(&process); *process = \&SetArguments; # alias to keep old code happy

#/----------------------------------------------------------------------------//
#/ Get a list of the arguments that have been processed by SetArguments().
#/   Returns an array.
#/----------------------------------------------------------------------------//

sub GetArguments # Tk::CmdLine::GetArguments()
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done

    return @{$self->{command}};
}

#/----------------------------------------------------------------------------//
#/ Get the value of a configuration option (default: -class).
#/   Returns the option value.
#/----------------------------------------------------------------------------//

sub cget # Tk::CmdLine::cget([$option])
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object
    my $option = shift(@_) || '-class';

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done

    return (exists($self->{config}->{$option}) ? $self->{config}->{$option} : undef);
}

#/----------------------------------------------------------------------------//

sub CreateArgs # Tk::CmdLine::CreateArgs()
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done

    return $self->{config};
}

#/----------------------------------------------------------------------------//

sub Tk::MainWindow::apply_command_line
{
    my $mw = shift(@_);

    my $self = ($OBJECT ||= __PACKAGE__->new());

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done

    foreach my $priority (keys(%{$self->{resources}}))
    {
        foreach my $resource (@{$self->{resources}->{$priority}})
        {
            $mw->optionAdd(@{$resource}, $priority);
        }
    }

    foreach my $key (keys(%{$self->{options}}))
    {
        $mw->optionAdd($key => $self->{options}->{$key}, 'interactive');
    }

    foreach my $key (keys(%{$self->{methods}}))
    {
        $mw->$key($self->{methods}->{$key});
    }

    if ($self->{methods}->{geometry})
    {
        if ($self->{methods}->{geometry} =~ /[+-]\d+[+-]\d+/)
        {
            $mw->positionfrom('user');
        }
        if ($self->{methods}->{geometry} =~ /\d+x\d+/)
        {
            $mw->sizefrom('user');
        }
        delete $self->{methods}->{geometry}; # XXX needed?
    }

    $mw->Synchronize() if $self->{synchronous};

    if ($self->{iconic})
    {
        $mw->iconify();
        $self->{iconic} = 0;
    }

    $Tk::strictMotif = ($self->{motif} || 0);

    # Both these are needed to reliably save state
    # but 'hostname' is tricky to do portably.
    # $mw->client(hostname());
    $mw->protocol('WM_SAVE_YOURSELF' => ['WMSaveYourself',$mw]);
    $mw->command([ $self->{name}, @{$self->{command}} ]);
}

#/----------------------------------------------------------------------------//
#/ Set the initial resources.
#/   Returns the object reference.
#/----------------------------------------------------------------------------//

sub SetResources # Tk::CmdLine::SetResources((\@resource | $resource) [, $priority])
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done
    return $self unless @_;

    my $data      = shift(@_);
    my $priority  = shift(@_) || 'userDefault';

    $self->{resources}->{$priority} = [] unless exists($self->{resources}->{$priority});

    foreach my $resource ((ref($data) eq 'ARRAY') ? @{$data} : $data)
    {
        if (ref($resource) eq 'ARRAY') # resources in [ <pattern>, <value> ] format
        {
            push(@{$self->{resources}->{$priority}}, [ @{$resource} ])
                if (@{$resource} == 2);
        }
        else # resources in resource file format
        {
            push(@{$self->{resources}->{$priority}}, [ $1, $2 ])
                if ($resource =~ /^([^!:\s]+)*\s*:\s*(.*)$/);
        }
    }

    return $self;
}

#/----------------------------------------------------------------------------//
#/ Load initial resources from one or more files (default: $XFILESEARCHPATH with
#/ priority 'startupFile' and $XUSERFILESEARCHPATH with priority 'userDefault').
#/   Returns the object reference.
#/----------------------------------------------------------------------------//

sub LoadResources # Tk::CmdLine::LoadResources([%options])
{
    my $self = (@_ # define the object as necessary
        ? ((ref($_[0]) eq __PACKAGE__)
            ? shift(@_)
            : (($_[0] eq __PACKAGE__) ? shift(@_) : 1) && ($OBJECT ||= __PACKAGE__->new()))
        : ($OBJECT ||= __PACKAGE__->new()));
    $OBJECT = $self; # update the current object

    $self->SetArguments() unless exists($self->{offset}); # set arguments if not yet done

    my %options = @_;

    my @file = ();
    my $echo = (exists($options{-echo})
        ? (defined($options{-echo}) ? $options{-echo} : \*STDOUT) : undef);

    unless (%options && (exists($options{-file}) || exists($options{-symbol})))
    {
        @file = (
            { -symbol => 'XFILESEARCHPATH',     -priority => 'startupFile' },
            { -symbol => 'XUSERFILESEARCHPATH', -priority => 'userDefault' } );
    }
    else
    {
        @file = { %options };
    }

    my $delimiter = (($^O eq 'MSWin32') ? ';' : ':');

    foreach my $file (@file)
    {
        my $fileSpec = $file->{-spec} = undef;
        if (exists($file->{-symbol}))
        {
            my $xpath = undef;
            if ($file->{-symbol} eq 'XUSERFILESEARCHPATH')
            {
                $file->{-priority} ||= 'userDefault';
                foreach my $symbol (qw(XUSERFILESEARCHPATH XAPPLRESDIR HOME))
                {
                    last if (exists($ENV{$symbol}) && ($xpath = $ENV{$symbol}));
                }
                next unless defined($xpath);
            }
            else
            {
                $file->{-priority} ||= (($file->{-symbol} eq 'XFILESEARCHPATH')
                    ? 'startupFile' : 'userDefault');
                next unless (
                    exists($ENV{$file->{-symbol}}) && ($xpath = $ENV{$file->{-symbol}}));
            }

            unless (exists($self->{translation}))
            {
                $self->{translation} = {
                    '%l' => '',                       # ignored
                    '%C' => '',                       # ignored
                    '%S' => '',                       # ignored
                    '%L' => ($ENV{LANG} || 'C'),      # language
                    '%T' => 'app-defaults',           # type
                    '%N' => $self->{config}->{-class} # filename
                };
            }

            my @postfix = map({ $_ . '/' . $self->{config}->{-class} }
                ('/' . $self->{translation}->{'%L'}), '');

            ITEM: foreach $fileSpec (split($Config{path_sep}, $xpath))
            {
                if ($fileSpec =~ s/(%[A-Za-z])/$self->{translation}->{$1}/g) # File Pattern
                {
                    if (defined($echo) && ($file->{-symbol} ne 'XFILESEARCHPATH'))
                    {
                        print $echo 'Checking ', $fileSpec, "\n";
                    }
                    next unless ((-f $fileSpec) && (-r _) && (-s _));
                    $file->{-spec} = $fileSpec;
                    last;
                }
                else # Directory - Check for <Directory>/$LANG/<Class>, <Directory>/<CLASS>
                {
                    foreach my $postfix (@postfix)
                    {
                        my $fileSpec2 = $fileSpec . $postfix;
                        if (defined($echo) && ($file->{-symbol} ne 'XFILESEARCHPATH'))
                        {
                            print $echo 'Checking ', $fileSpec2, "\n";
                        }
                        next unless ((-f $fileSpec2) && (-r _) && (-s _));
                        $file->{-spec} = $fileSpec2;
                        last ITEM;
                    }
                }
            }
        }
        elsif (exists($file->{-file}) && ($fileSpec = $file->{-file}))
        {
            print $echo 'Checking ', $fileSpec, "\n" if defined($echo);
            next unless ((-f $fileSpec) && (-r _) && (-s _));
            $file->{-spec} = $fileSpec;
        }
    }

    foreach my $file (@file)
    {
        next unless defined($file->{-spec});
        local *SPEC;
        next unless open(SPEC,$file->{-spec});
        print $echo ' Loading ', $file->{-spec}, "\n" if defined($echo);

        my $resource     = undef;
        my @resource     = ();
        my $continuation = 0;

        while (defined(my $line = <SPEC>))
        {
            chomp($line);
            next if ($line =~ /^\s*$/); # skip blank lines
            next if ($line =~ /^\s*!/); # skip comments
            $continuation = ($line =~ s/\s*\\$/ /); # search for trailing backslash
            unless (defined($resource)) # it is the first line
            {
                $resource = $line;
            }
            else # it is a continuation line
            {
                $line =~ s/^\s*//; # remove leading whitespace
                $resource .= $line;
            }
            next if $continuation;
            push(@resource, [ $1, $2 ]) if ($resource =~ /^([^:\s]+)*\s*:\s*(.*)$/);
            $resource = undef;
        }

        close(SPEC);

        if (defined($resource)) # special case - EOF after line with trailing backslash
        {
            push(@resource, [ $1, $2 ]) if ($resource =~ /^([^:\s]+)*\s*:\s*(.*)$/);
        }

        $self->SetResources(\@resource, $file->{-priority}) if @resource;
    }

    return $self;
}

#/----------------------------------------------------------------------------//

1;

__END__

=cut

=head1 NAME

Tk::CmdLine - Process standard X11 command line options and set initial resources

=for pm Tk/CmdLine.pm

=for category Creating and Configuring Widgets

=head1 SYNOPSIS

  Tk::CmdLine::SetArguments([@argument]);

  my $value = Tk::CmdLine::cget([$option]);

  Tk::CmdLine::SetResources((\@resource | $resource) [, $priority]);

  Tk::CmdLine::LoadResources(
      [ -symbol   => $symbol     ]
      [ -file     => $fileSpec   ]
      [ -priority => $priority   ]
      [ -echo     => $fileHandle ] );

=head1 DESCRIPTION

Process standard X11 command line options and set initial resources.

The X11R5 man page for X11 says: "Most X programs attempt to use the same names
for command line options and arguments. All applications written with the
X Toolkit Intrinsics automatically accept the following options: ...".
This module processes these command line options for perl/Tk applications
using the C<SetArguments>() function.

This module can optionally be used to load initial resources explicitly via
function C<SetResources>(), or from specified files (default: the standard X11
application-specific resource files) via function C<LoadResources>().

=head2 Command Line Options

=over 4

=item B<-background> I<Color> | B<-bg> I<Color>

Specifies the color to be used for the window background.

=item B<-class> I<Class>

Specifies the class under which resources for the application should be found.
This option is useful in shell aliases to distinguish between invocations
of an application, without resorting to creating links to alter the executable
file name.

=item B<-display> I<Display> | B<-screen> I<Display>

Specifies the name of the X server to be used.

=item B<-font> I<Font> | B<-fn> I<Font>

Specifies the font to be used for displaying text.

=item B<-foreground> I<Color> | B<-fg> I<Color>

Specifies the color to be used for text or graphics.

=item B<-geometry> I<Geometry>

Specifies the initial size and location of the I<first>
L<MainWindow|Tk::MainWindow>.

=item B<-iconic>

Indicates that the user would prefer that the application's windows initially
not be visible as if the windows had been immediately iconified by the user.
Window managers may choose not to honor the application's request.

=item B<-motif>

Specifies that the application should adhere as closely as possible to Motif
look-and-feel standards. For example, active elements such as buttons and
scrollbar sliders will not change color when the pointer passes over them.

=item B<-name> I<Name>

Specifies the name under which resources for the application should be found.
This option is useful in shell aliases to distinguish between invocations
of an application, without resorting to creating links to alter the executable
file name.

=item B<-synchronous>

Indicates that requests to the X server should be sent synchronously, instead of
asynchronously. Since Xlib normally buffers requests to the server, errors do
do not necessarily get reported immediately after they occur. This option turns
off the buffering so that the application can be debugged. It should never
be used with a working program.

=item B<-title> I<TitleString>

This option specifies the title to be used for this window. This information is
sometimes used by a window manager to provide some sort of header identifying
the window.

=item B<-xrm> I<ResourceString>

Specifies a resource pattern and value to override any defaults. It is also
very useful for setting resources that do not have explicit command line
arguments.

The I<ResourceString> is of the form E<lt>I<pattern>E<gt>:E<lt>I<value>E<gt>,
that is (the first) ':' is used to determine which part is pattern and which
part is value. The (E<lt>I<pattern>E<gt>, E<lt>I<value>E<gt>) pair is entered
into the options database with B<optionAdd> (for each
L<MainWindow|Tk::MainWindow> configured), with I<interactive> priority.

=back

=head2 Initial Resources

There are several mechanism for initializing the resource database to be used
by an X11 application. Resources may be defined in a $C<HOME>/.Xdefaults file,
a system application defaults file (e.g.
/usr/lib/X11/app-defaults/E<lt>B<CLASS>E<gt>),
or a user application defaults file (e.g. $C<HOME>/E<lt>B<CLASS>E<gt>).
The Tk::CmdLine functionality for setting initial resources concerns itself
with the latter two.

Resource files contain data lines of the form
E<lt>I<pattern>E<gt>:E<lt>I<value>E<gt>.
They may also contain blank lines and comment lines (denoted
by a ! character as the first non-blank character). Refer to L<option|Tk::option>
for a description of E<lt>I<pattern>E<gt>:E<lt>I<value>E<gt>.

=over 4

=item System Application Defaults Files

System application defaults files may be specified via environment variable
$C<XFILESEARCHPATH> which, if set, contains a list of file patterns
(joined using the OS-dependent path delimiter, e.g. colon on B<UNIX>).

=item User Application Defaults Files

User application defaults files may be specified via environment variables
$C<XUSERFILESEARCHPATH>, $C<XAPPLRESDIR> or $C<HOME>.

=back

=head1 METHODS

=over 4

=item B<SetArguments> - Tk::CmdLine::SetArguments([@argument])

Extract the X11 options contained in a specified array (@ARGV by default).

  Tk::CmdLine::SetArguments([@argument])

The X11 options may be specified using a single dash I<-> as per the X11
convention, or using two dashes I<--> as per the POSIX standard (e.g.
B<-geometry> I<100x100>, B<-geometry> I<100x100> or B<-geometry=>I<100x100>).
The options may be interspersed with other options or arguments.
A I<--> by itself terminates option processing.

By default, command line options are extracted from @ARGV the first time
a MainWindow is created. The Tk::MainWindow constructor indirectly invokes
C<SetArguments>() to do this.

=item B<GetArguments> - Tk::CmdLine::GetArguments()

Get a list of the X11 options that have been processed by C<SetArguments>().
(C<GetArguments>() first invokes C<SetArguments>() if it has not already been invoked.)

=item B<cget> - Tk::CmdLine::cget([$option])

Get the value of a configuration option specified via C<SetArguments>().
(C<cget>() first invokes C<SetArguments>() if it has not already been invoked.)

  Tk::CmdLine::cget([$option])

The valid options are: B<-class>, B<-name>, B<-screen> and B<-title>.
If no option is specified, B<-class> is implied.

A typical use of C<cget>() might be to obtain the application class in order
to define the name of a resource file to be loaded in via C<LoadResources>().

  my $class = Tk::CmdLine::cget(); # process command line and return class

=item B<SetResources> - Tk::CmdLine::SetResources((\@resource | $resource) [, $priority])

Set the initial resources.

  Tk::CmdLine::SetResources((\@resource | $resource) [, $priority])

A single resource may be specified using a string of the form
'E<lt>I<pattern>E<gt>:E<lt>I<value>E<gt>'. Multiple resources may be specified
by passing an array reference whose elements are either strings of the above
form, and/or anonymous arrays of the form [ E<lt>I<pattern>E<gt>,
E<lt>I<value>E<gt> ]. The optional second argument specifies the priority,
as defined in L<option|Tk::option>, to be associated with the resources
(default: I<userDefault>).

Note that C<SetResources>() first invokes C<SetArguments>() if it has not already
been invoked.

=item B<LoadResources> - Tk::CmdLine::LoadResources([%options])

Load initial resources from one or more files.

  Tk::CmdLine::LoadResources(
      [ -symbol   => $symbol     ]
      [ -file     => $fileSpec   ]
      [ -priority => $priority   ]
      [ -echo     => $fileHandle ] );

[ B<-symbol> =E<gt> $symbol ] specifies the name of an environment variable
that, if set, defines a list of one or more directories and/or file patterns
(joined using the OS-dependent path delimiter, e.g. colon on B<UNIX>).
$C<XUSERFILESEARCHPATH> is a special case.
If $C<XUSERFILESEARCHPATH> is not set, $C<XAPPLRESDIR> is checked instead.
If $C<XAPPLRESDIR> is not set, $C<HOME> is checked instead.

An item is identified as a file pattern if it contains one or more /%[A-Za-z]/
patterns. Only patterns B<%L>, B<%T> and B<%N> are currently recognized. All
others are replaced with the null string. Pattern B<%L> is translated into
$C<LANG>. Pattern B<%T> is translated into I<app-defaults>. Pattern B<%N> is
translated into the application class name.

Each file pattern, after substitutions are applied, is assumed to define a
FileSpec to be examined.

When a directory is specified, FileSpecs
E<lt>B<DIRECTORY>E<gt>/E<lt>B<LANG>E<gt>/E<lt>B<CLASS>E<gt>
and E<lt>B<DIRECTORY>E<gt>/E<lt>B<CLASS>E<gt> are defined, in that order.

[ B<-file> =E<gt> $fileSpec ] specifies a resource file to be loaded in.
The file is silently skipped if if does not exist, or if it is not readable.

[ B<-priority> =E<gt> $priority ] specifies the priority, as defined in
L<option|Tk::option>, to be associated with the resources
(default: I<userDefault>).

[ B<-echo> =E<gt> $fileHandle ] may be used to specify that a line should be
printed to the corresponding FileHandle (default: \*STDOUT) everytime a file
is examined / loaded.

If no B<-symbol> or B<-file> options are specified, C<LoadResources>()
processes symbol $C<XFILESEARCHPATH> with priority I<startupFile> and
$C<XUSERFILESEARCHPATH> with priority I<userDefault>.
(Note that $C<XFILESEARCHPATH> and $C<XUSERFILESEARCHPATH> are supposed to
contain only patterns. $C<XAPPLRESDIR> and $C<HOME> are supposed to be a single
directory. C<LoadResources>() does not check/care whether this is the case.)

For each set of FileSpecs, C<LoadResources>() examines each FileSpec to
determine if the file exists and is readable. The first file that meets this
criteria is read in and C<SetResources>() is invoked.

Note that C<LoadResources>() first invokes C<SetArguments>() if it has not already
been invoked.

=back

=head1 NOTES

This module is an object-oriented module whose methods can be invoked as object
methods, class methods or regular functions. This is accomplished via an
internally-maintained object reference which is created as necessary, and which
always points to the last object used. C<SetArguments>(), C<SetResources>() and
C<LoadResources>() return the object reference.

=head1 EXAMPLES

=over

=item 1

@ARGV is processed by Tk::CmdLine at MainWindow creation.

  use Tk;

  # <Process @ARGV - ignoring all X11-specific options>

  my $mw = MainWindow->new();

  MainLoop();

=item 2

@ARGV is processed by Tk::CmdLine before MainWindow creation.
An @ARGV of (--geometry=100x100 -opt1 a b c -bg red)
is equal to (-opt1 a b c) after C<SetArguments>() is invoked.

  use Tk;

  Tk::CmdLine::SetArguments(); # Tk::CmdLine->SetArguments() works too

  # <Process @ARGV - not worrying about X11-specific options>

  my $mw = MainWindow->new();

  MainLoop();

=item 3

Just like 2) except that default arguments are loaded first.

  use Tk;

  Tk::CmdLine::SetArguments(qw(-name test -iconic));
  Tk::CmdLine::SetArguments();

  # <Process @ARGV - not worrying about X11-specific options>

  my $mw = MainWindow->new();

  MainLoop();

=item 4

@ARGV is processed by Tk::CmdLine before MainWindow creation.
Standard resource files are loaded in before MainWindow creation.

  use Tk;

  Tk::CmdLine::SetArguments();

  # <Process @ARGV - not worrying about X11-specific options>

  Tk::CmdLine::LoadResources();

  my $mw = MainWindow->new();

  MainLoop();

=item 5

@ARGV is processed by Tk::CmdLine before MainWindow creation.
Standard resource files are loaded in before MainWindow creation
using non-default priorities.

  use Tk;

  Tk::CmdLine::SetArguments();

  # <Process @ARGV - not worrying about X11-specific options>

  Tk::CmdLine::LoadResources(-echo => \*STDOUT,
      -priority => 65, -symbol => 'XFILESEARCHPATH' );
  Tk::CmdLine::LoadResources(-echo => \*STDOUT,
      -priority => 75, -symbol => 'XUSERFILESEARCHPATH' );

  my $mw = MainWindow->new();

  MainLoop();

=item 6

@ARGV is processed by Tk::CmdLine before MainWindow creation.
Standard resource files are loaded in before MainWindow creation.
Individual resources are also loaded in before MainWindow creation.

  use Tk;

  Tk::CmdLine::SetArguments();

  # <Process @ARGV - not worrying about X11-specific options>

  Tk::CmdLine::LoadResources();

  Tk::CmdLine::SetResources( # set a single resource
      '*Button*background: red',
      'widgetDefault' );

  Tk::CmdLine::SetResources( # set multiple resources
      [ '*Button*background: red', '*Button*foreground: blue' ],
      'widgetDefault' );

  my $mw = MainWindow->new();

  MainLoop();

=back

=head1 ENVIRONMENT

=over 4

=item B<HOME> (optional)

Home directory which may contain user application defaults files as
$C<HOME>/$C<LANG>/E<lt>B<CLASS>E<gt> or $C<HOME>/E<lt>B<CLASS>E<gt>.

=item B<LANG> (optional)

The current language (default: I<C>).

=item B<XFILESEARCHPATH> (optional)

List of FileSpec patterns
(joined using the OS-dependent path delimiter, e.g. colon on B<UNIX>)
used in defining system application defaults files.

=item B<XUSERFILESEARCHPATH> (optional)

List of FileSpec patterns
(joined using the OS-dependent path delimiter, e.g. colon on B<UNIX>)
used in defining user application defaults files.

=item B<XAPPLRESDIR> (optional)

Directory containing user application defaults files as
$C<XAPPLRESDIR>/$C<LANG>/E<lt>B<CLASS>E<gt> or
$C<XAPPLRESDIR>/E<lt>B<CLASS>E<gt>.

=back

=head1 SEE ALSO

L<MainWindow|Tk::MainWindow>
L<option|Tk::option>

=head1 HISTORY

=over 4

=item *

1999.03.04 Ben Pavon E<lt>ben.pavon@hsc.hac.comE<gt>

Rewritten as an object-oriented module.

Allow one to process command line options in a specified array (@ARGV by default).
Eliminate restrictions on the format and location of the options within the array
(previously the X11 options could not be specified in POSIX format and had to be
at the beginning of the array).

Added the C<SetResources>() and C<LoadResources>() functions to allow the definition
of resources prior to MainWindow creation.

=item *

2000.08.31 Ben Pavon E<lt>ben.pavon@hsc.hac.comE<gt>

Added the C<GetArguments>() method which returns the list of arguments that
have been processed by C<SetArguments>().

Modified C<LoadResources>() to split the symbols using the OS-dependent
path delimiter defined in the B<Config> module.

Modified C<LoadResources>() to eliminate a warning message when processing
patterns B<%l>, B<%C>, B<%S>.

=back

=cut

