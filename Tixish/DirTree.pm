package Tk::DirTree;
# DirTree -- TixDirTree widget
#
# Derived from DirTree.tcl in Tix 4.1
#
# Chris Dean <ctdean@cogit.com>

use vars qw($VERSION);
$VERSION = '4.009'; # $Id: //depot/Tkutf8/Tixish/DirTree.pm#9 $

use Tk;
use Tk::Derived;
use Tk::Tree;
use Cwd;
use DirHandle;

use base  qw(Tk::Derived Tk::Tree);
use strict;

Construct Tk::Widget 'DirTree';


sub Populate {
    my( $cw, $args ) = @_;

    $cw->SUPER::Populate( $args );

    $cw->ConfigSpecs(
        -dircmd         => [qw/CALLBACK dirCmd DirCmd DirCmd/],
        -showhidden     => [qw/PASSIVE showHidden ShowHidden 0/],
        -image          => [qw/PASSIVE image Image folder/],
        -directory      => [qw/SETMETHOD directory Directory ./],
        -value          => '-directory' );

    $cw->configure( -separator => '/', -itemtype => 'imagetext' );
}

sub DirCmd {
    my( $w, $dir, $showhidden ) = @_;

    my $h = DirHandle->new( $dir ) or return();
    my @names = grep( $_ ne '.' && $_ ne '..', $h->read );
    @names = grep( ! /^[.]/, @names ) unless $showhidden;
    return( @names );
}

*dircmd = \&DirCmd;

sub fullpath
{
 my ($path) = @_;
 my $cwd = getcwd();
 if (CORE::chdir($path))
  {
   $path = getcwd();
   CORE::chdir($cwd) || die "Cannot cd back to $cwd:$!";
  }
 else
  {
   warn "Cannot cd to $path:$!"
  }
 return $path;
}

sub directory
{
    my ($w,$key,$val) = @_;
    # We need a value for -image, so its being undefined
    # is probably caused by order of handling config defaults
    # so defer it.
    $w->afterIdle([$w, 'set_dir' => $val]);
}

sub set_dir {
    my( $w, $val ) = @_;
    my $fulldir = fullpath( $val );

    my $parent = '/';
    if ($^O eq 'MSWin32')
     {
      if ($fulldir =~ s/^([a-z]:)//i)
       {
        $parent = $1;
       }
     }
    $w->add_to_tree( $parent, $parent)  unless $w->infoExists($parent);

    my @dirs = ($parent);
    foreach my $name (split( /[\/\\]/, $fulldir )) {
        next unless length $name;
        push @dirs, $name;
        my $dir = join( '/', @dirs );
	$dir =~ s|^//|/|;
        $w->add_to_tree( $dir, $name, $parent )
            unless $w->infoExists( $dir );
        $parent = $dir;
    }

    $w->OpenCmd( $parent );
    $w->setmode( $parent, 'close' );
}
*chdir = \&set_dir;


sub OpenCmd {
    my( $w, $dir ) = @_;

    my $parent = $dir;
    $dir = '' if $dir eq '/';
    foreach my $name ($w->dirnames( $parent )) {
        next if ($name eq '.' || $name eq '..');
        my $subdir = "$dir/$name";
        next unless -d $subdir;
        if( $w->infoExists( $subdir ) ) {
            $w->show( -entry => $subdir );
        } else {
            $w->add_to_tree( $subdir, $name, $parent );
        }
    }
}

*opencmd = \&OpenCmd;

sub add_to_tree {
    my( $w, $dir, $name, $parent ) = @_;

    my $image = $w->Getimage( $w->cget('-image') );
    my $mode = 'none';
    $mode = 'open' if $w->has_subdir( $dir );

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
        next if ($name eq '.' || $name eq '..');
        next if ($name =~ /^\.+$/);
        return( 1 ) if -d "$dir/$name";
    }
    return( 0 );
}

sub dirnames {
    my( $w, $dir ) = @_;
    my @names = $w->Callback( '-dircmd', $dir, $w->cget( '-showhidden' ) );
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

