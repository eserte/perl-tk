package Tk::DirTree;
# DirTree -- TixDirTree widget
#
# Derived from DirTree.tcl in Tix 4.1
#
# Chris Dean <ctdean@cogit.com>

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tixish/DirTree.pm#8$

use Tk;
use Tk::Derived;
use Tk::Tree;
use Cwd;
use DirHandle;

@ISA = qw(Tk::Derived Tk::Tree);
use strict;

Construct Tk::Widget 'DirTree';

sub Populate {
    my( $cw, $args ) = @_;

    $cw->SUPER::Populate( $args );

    $cw->ConfigSpecs(
        -dircmd         => [qw/CALLBACK dirCmd DirCmd/, 
                            sub { $cw->dircmd( @_ ) } ], 
        -showhidden     => [qw/PASSIVE showHidden ShowHidden 0/], 
        -directory      => [qw/SETMETHOD directory Directory ./],
        -value          => "-directory" );

    $cw->configure( -separator => '/', -itemtype => 'imagetext' );
    $args->{-opencmd} = sub { $cw->opencmd( @_ ) };
}

sub dircmd {
    my( $w, $dir, $showhidden ) = @_;

    my $h = DirHandle->new( $dir ) or return();
    my @names = grep( $_ ne "." && $_ ne "..", $h->read );
    @names = grep( ! /^[.]/, @names ) unless $showhidden;
    return( @names );
}

sub fullpath
{
 my ($path) = @_;
 my $cwd = getcwd;
 if (chdir($path))
  {
   $path = getcwd;
   chdir($cwd);
  }
 else
  {
   warn "Cannot cd to $path:$!"
  }
 return $path;
}

sub directory {
    my ($w,$key,$val) = @_;
    return( $w->chdir( $val ) );
}

sub chdir {
    my( $w, $val ) = @_;
    my $fulldir = fullpath( $val );
    
    $w->add_to_tree( "/", "/" )  unless $w->infoExists( "/" );
    
    my $parent = "/";
    my @dirs = ("");
    foreach my $name (split( "/", $fulldir )) {
        next unless length $name;
        push @dirs, $name;
        my $dir = join( "/", @dirs );
        $w->add_to_tree( $dir, $name, $parent ) 
            unless $w->infoExists( $dir );
        $parent = $dir;
    }

    $w->opencmd( $fulldir );
    $w->setmode( $fulldir, "close" );
}

sub opencmd {
    my( $w, $dir ) = @_;

    my $parent = $dir;
    $dir = "" if $dir eq "/";
    foreach my $name ($w->dirnames( $parent )) {
        next if ($name eq "." || $name eq "..");
        my $subdir = "$dir/$name";
        next unless -d $subdir;
        if( $w->infoExists( $subdir ) ) {
            $w->show( -entry => $subdir );
        } else {
            $w->add_to_tree( $subdir, $name, $parent );
        }
    }
}

sub add_to_tree {
    my( $w, $dir, $name, $parent ) = @_;
    my $image = $w->Getimage( "folder" );
    my $mode = "none";
    $mode = "open" if $w->has_subdir( $dir );

    my @args = (-image => $image, -text => $name);
    if( $parent ) {             # Add in alphabetical order.
        foreach my $sib ($w->infoChildren( $parent )) {
            if( $sib gt $dir ) {
                push @args, (-before => $sib);
                last;
            }
        }
    }

    $w->add( $dir, @args );
    $w->setmode( $dir, $mode );
}

sub has_subdir {
    my( $w, $dir ) = @_;
    foreach my $name ($w->dirnames( $dir )) {
        next if ($name eq "." || $name eq "..");
        next if ($name =~ /^\.+$/);
        return( 1 ) if -d "$dir/$name";
    }
    return( 0 );
}

sub dirnames {
    my( $w, $dir ) = @_;
    my @names = $w->Callback( "-dircmd", $dir, $w->cget( "-showhidden" ) );
    return( @names );
}

__END__

#  Copyright (c) 1996, Expert Interface Technologies
#  See the file "license.terms" for information on usage and redistribution
#  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#  
#  The file man.macros and some of the macros used by this file are
#  copyrighted: (c) 1990 The Regents of the University of California.
#               (c) 1994-1995 Sun Microsystems, Inc.
#  The license terms of the Tcl/Tk distrobution are in the file
#  license.tcl.

=head1 NAME

Tk::DirTree - Create and manipulate DirTree widgets

=for category Tix Extensions

=head1 SYNOPSIS

    use Tk::DirTree;

    $dirtree = $parent->DirTree(?options?);

=head1 SUPER-CLASS

The B<DirTree> class is derived from the B<Tree> class and inherits
all the commands, options and subwidgets of its super-class.

=head1 STANDARD OPTIONS

B<Tree> supports all the standard options of a Tree widget.  See
L<options> for details on the standard options.

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item Name:		B<browseCmd>

=item Class:		B<BrowseCmd>

=item Switch:		B<-browsecmd>

Specifies a command to call whenever the user browses on a directory
(usually by single-clicking on the name of the directory). The command
is called with one argument, the complete pathname of the directory.

=back 

=over 4

=item Name:		B<command>

=item Class:		B<Command>

=item Switch:		B<-command>

Specifies the command to be called when the user activates on a directory
(usually by double-clicking on the name of the directory). The command
is called with one argument, the complete pathname of the directory.

=back 

=over 4

=item Name:		B<dircmd>

=item Class:		B<DirCmd>

=item Switch:		B<-dircmd>

Specifies the command to be called when a directory listing is needed
for a particular directory. If this option is not specified, by
default the DirTree widget will attempt to read the directory as a
Unix directory. On special occasions, the application programmer may
want to supply a special method for reading directories: for example,
when he needs to list remote directories. In this case, the B<-dircmd>
option can be used. The specified command accepts two arguments: the
first is the name of the directory to be listed; the second is a
Boolean value indicating whether hidden sub-directories should be
listed. This command returns a list of names of the sub-directories of
this directory. For example:

    sub read_dir {
        my( $dir, $showhidden ) = @_;
        return( qw/DOS NORTON WINDOWS/ ) if $dir eq "C:\\";
        return();
    }

=back 

=over 4

=item Name:		B<showHidden>

=item Class:		B<ShowHidden>

=item Switch:		B<-showhidden>

Specifies whether hidden directories should be shown. By default, a
directory name starting with a period "." is considered as a hidden
directory. This rule can be overridden by supplying an alternative
B<-dircmd> option.

=back 

=over 4

=item Name:		B<directory>

=item Class:		B<Directory>

=item Switch:		B<-directory>

=item Alias:		B<-value>

Specifies the name of the current directory to be displayed in the
DirTree widget.

=back 

=head1 DESCRIPTION

The B<DirTree> command creates a new window (given by the $widget
argument) and makes it into a DirTree widget.  Additional options,
described above, may be specified on the command line or in the
option database to configure aspects of the DirTree such as its
cursor and relief.  The DirTree widget displays a list view of a
directory, its previous directories and its sub-directories. The
user can choose one of the directories displayed in the list or
change to another directory.

=head1 WIDGET COMMANDS

The B<DirTree> command creates a widget object whose name is the same
as the path name of the DirTree's window.  This command may be used to
invoke various operations on the widget. It has the following general
form:

 I<$widget>-E<gt>B<method>(?I<arg arg ...>?)

I<PathName> is the name of the command, which is the same as the
DirTree widget's path name. I<Option> and the I<arg>s determine the
exact behavior of the command. The following commands are possible
for DirTree widgets:

=over 4

=item I<$widget-E<gt>>B<cget>(I<option>)

Returns the current value of the configuration option given by
I<option>. I<Option> may have any of the values accepted by the
B<DirTree> command.

=item I<$widget-E<gt>>B<chdir>(I<dir>)

Change the current directory to I<dir>.

=item I<$widget-E<gt>>B<configure>(?I<option>?, I<?value, option, value, ...>?)

Query or modify the configuration options of the widget.  If
no I<option> is specified, returns a list describing all of the
available options for $widget (see B<configure> for information on the
format of this list). If I<option> is specified with no I<value>, then
the command returns a list describing the one named option (this list
will be identical to the corresponding sublist of the value returned
if no I<option> is specified).  If one or more I<option-value> pairs
are specified, then the command modifies the given widget option(s) to
have the given value(s); in this case the command returns an empty
string.  I<Option> may have any of the values accepted by the
B<DirTree> command.

=back 

=head1 BINDINGS

The mouse and keyboard bindings of the DirTree widget are the same as
the bindings of the Tree widget.

=head1 KEYWORDS

Tix(n)

=head1 SEE ALSO

Tk::HList, Tk::Tree, Tix(n)

=head1 AUTHOR

Perl/TK version by Chris Dean <ctdean@cogit.com>.  Original Tcl/Tix
version by Ioi Kim Lam.

