package Tk::DirTree;
# DirTree -- TixDirTree widget
#
# Derived from DirTree.tcl in Tix 4.1
#
# Chris Dean <ctdean@cogit.com>

use vars qw($VERSION);
$VERSION = '3.011'; # $Id: //depot/Tk8/Tixish/DirTree.pm#11$

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
 my $cwd = getcwd();
 if (chdir($path))
  {
   $path = getcwd();
   chdir($cwd) || die "Cannot cd back to $cwd:$!";
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
        my $dir = join( "/", @dirs );
        $w->add_to_tree( $dir, $name, $parent ) 
            unless $w->infoExists( $dir );
        $parent = $dir;
    }

    $w->opencmd( $parent );
    $w->setmode( $parent, "close" );
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

