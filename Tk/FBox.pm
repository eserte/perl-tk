# -*- perl -*-
#
# tkfbox.tcl --
#
#       Implements the "TK" standard file selection dialog box. This
#       dialog box is used on the Unix platforms whenever the tk_strictMotif
#       flag is not set.
#
#       The "TK" standard file selection dialog box is similar to the
#       file selection dialog box on Win95(TM). The user can navigate
#       the directories by clicking on the folder icons or by
#       selecting the "Directory" option menu. The user can select
#       files by clicking on the file icons or by entering a filename
#       in the "Filename:" entry.
#
# Copyright (c) 1994-1996 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Translated to perk/Tk by Slaven Rezic <eserte@cs.tu-berlin.de>.
#

#----------------------------------------------------------------------
#
#		      F I L E   D I A L O G
#
#----------------------------------------------------------------------
# tkFDialog --
#
#	Implements the TK file selection dialog. This dialog is used when
#	the tk_strictMotif flag is set to false. This procedure shouldn't
#	be called directly. Call tk_getOpenFile or tk_getSaveFile instead.
#

package Tk::FBox;
require Tk::Toplevel;

use strict;
use vars qw($VERSION $updirImage $folderImage $fileImage);

$VERSION = '3.011'; # $Id: //depot/Tk8/Tk/FBox.pm#11 $

use base qw(Tk::Toplevel);

Construct Tk::Widget 'FBox';

my $selectFilePath;
my $selectFile;
my $selectPath;

sub import {
    if (defined $_[1] and $_[1] eq 'as_default') {
	local $^W = 0;
	package Tk;
	*FDialog      = \&Tk::FBox::FDialog;
	*MotifFDialog = \&Tk::FBox::FDialog;
    }
}

sub Populate {
    my($w, $args) = @_;

    require Tk::IconList;
    require File::Basename;
    require Cwd;

    $w->SUPER::Populate($args);

    # f1: the frame with the directory option menu
    my $f1 = $w->Frame;
    my $lab = $f1->Label(-text => 'Directory:', -underline => 0);
    $w->{'dirMenu'} = my $dirMenu =
      $f1->Optionmenu(-textvariable => \$w->{'selectPath'},
		      -command => ['SetPath', $w]);
    my $upBtn = $f1->Button;
    if (!defined $updirImage) {
	$updirImage = $w->Bitmap(-data => <<EOF);
#define updir_width 28
#define updir_height 16
static char updir_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x80, 0x1f, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00,
   0x20, 0x40, 0x00, 0x00, 0xf0, 0xff, 0xff, 0x01, 0x10, 0x00, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x07, 0x00, 0x01, 0x90, 0x0f, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01,
   0x10, 0xfe, 0x07, 0x01, 0x10, 0x00, 0x00, 0x01, 0x10, 0x00, 0x00, 0x01,
   0xf0, 0xff, 0xff, 0x01};
EOF
    }
    $upBtn->configure(-image => $updirImage);
    $dirMenu->configure(-takefocus => 1, -highlightthickness => 2);
    $upBtn->pack(-side => 'right', -padx => 4, -fill => 'both');
    $lab->pack(-side => 'left', -padx => 4, -fill => 'both');
    $dirMenu->pack(-expand => 'yes', -fill => 'both', -padx => 4);

    $w->{'icons'} = my $icons =
      $w->IconList(-browsecmd => ['ListBrowse', $w],
		   -command   => ['ListInvoke', $w]);

    # f2: the frame with the OK button and the "file name" field
    my $f2 = $w->Frame(-bd => 0);
    my $f2_lab = $f2->Label(-text => 'File name:', -anchor => 'e',
			    -width => 14, -underline => 5, -pady => 0);
    $w->{'ent'} = my $ent = $f2->Entry;

    # The font to use for the icons. The default Canvas font on Unix
    # is just deviant.
    $w->{'icons'}{'font'} = $ent->cget(-font);

    # f3: the frame with the cancel button and the file types field
    my $f3 = $w->Frame(-bd => 0);

    # The "File of types:" label needs to be grayed-out when
    # -filetypes are not specified. The label widget does not support
    # grayed-out text on monochrome displays. Therefore, we have to
    # use a button widget to emulate a label widget (by setting its
    # bindtags)
    $w->{'typeMenuLab'} = my $typeMenuLab = $f3->Button
      (-text => 'Files of type:',
       -anchor  => 'e',
       -width => 14,
       -underline => 9,
       -bd => $f2_lab->cget(-bd),
       -highlightthickness => $f2_lab->cget(-highlightthickness),
       -relief => $f2_lab->cget(-relief),
       -padx => $f2_lab->cget(-padx),
       -pady => $f2_lab->cget(-pady),
      );
    $typeMenuLab->bindtags([$typeMenuLab, 'Label',
			    $typeMenuLab->toplevel, 'all']);
    $w->{'typeMenuBtn'} = my $typeMenuBtn =
      $f3->Menubutton(-indicatoron => 1, -tearoff => 0);
    $typeMenuBtn->configure(-takefocus => 1,
			    -highlightthickness => 2,
			    -relief => 'raised',
			    -bd => 2,
			    -anchor => 'w',
			   );

    # the okBtn is created after the typeMenu so that the keyboard traversal
    # is in the right order
    $w->{'okBtn'} = my $okBtn = $f2->Button
      (-text => 'OK',
       -underline => 0,
       -width => 6,
       -default => 'active',
       -pady => 3,
      );
    my $cancelBtn = $f3->Button
      (-text => 'Cancel',
       -underline => 0,
       -width => 6,
       -default => 'normal',
       -pady => 3,
      );

    # pack the widgets in f2 and f3
    $okBtn->pack(-side => 'right', -padx => 4, -anchor => 'e');
    $f2_lab->pack(-side => 'left', -padx => 4);
    $ent->pack(-expand => 'yes', -fill => 'x', -padx => 2, -pady => 0);
    $cancelBtn->pack(-side => 'right', -padx => 4, -anchor => 'w');
    $typeMenuLab->pack(-side => 'left', -padx => 4);
    $typeMenuBtn->pack(-expand => 'yes', -fill => 'x', -side => 'right');

    # Pack all the frames together. We are done with widget construction.
    $f1->pack(-side => 'top', -fill => 'x', -pady => 4);
    $f3->pack(-side => 'bottom', -fill => 'x');
    $f2->pack(-side => 'bottom', -fill => 'x');
    $icons->pack(-expand => 'yes', -fill => 'both', -padx => 4, -pady => 1);

    # Set up the event handlers
    $ent->bind('<Return>',[$w,'ActivateEnt']);
    $upBtn->configure(-command => ['UpDirCmd', $w]);
    $okBtn->configure(-command => ['OkCmd', $w]);
    $cancelBtn->configure(-command, ['CancelCmd', $w]);

    $w->bind('<Alt-d>',[$dirMenu,'focus']);
    $w->bind('<Alt-t>',sub  {
                             if ($typeMenuBtn->cget(-state) eq 'normal') {
                             $typeMenuBtn->focus;
                             } });
    $w->bind('<Alt-n>',[$ent,'focus']);
    $w->bind('<KeyPress-Escape>',[$cancelBtn,'invoke']);
    $w->bind('<Alt-c>',[$cancelBtn,'invoke']);
    $w->bind('<Alt-o>',['InvokeBtn','Open']);
    $w->bind('<Alt-s>',['InvokeBtn','Save']);
    $w->protocol('WM_DELETE_WINDOW', ['CancelCmd', $w]);

    # Build the focus group for all the entries
    $w->FG_Create;
    $w->FG_BindIn($ent, ['EntFocusIn', $w]);
    $w->FG_BindOut($ent, ['EntFocusOut', $w]);

    $w->SetPath(Cwd::cwd());

    $w->ConfigSpecs(-defaultextension => ['PASSIVE', undef, undef, undef],
		    -filetypes        => ['PASSIVE', undef, undef, undef],
		    -initialdir       => ['PASSIVE', undef, undef, undef],
		    -initialfile      => ['PASSIVE', undef, undef, undef],
		    -title            => ['PASSIVE', undef, undef, undef],
		    -type             => ['PASSIVE', undef, undef, 'open'],
		    -filter           => ['PASSIVE', undef, undef, '*'],
		    -force            => ['PASSIVE', undef, undef, 0],
		   );

    $w;
}


sub Show {
    my $w = shift;

    $w->configure(@_);

    $w->transient($w->Parent);

    # set the default directory and selection according to the -initial
    # settings
    {
	my $initialdir = $w->cget(-initialdir);
	if (defined $initialdir) {
	    if (-d $initialdir) {
		$w->{'selectPath'} = $initialdir;
	    } else {
		$w->Error("\"$initialdir\" is not a valid directory");
	    }
	}
	$w->{'selectFile'} = $w->cget(-initialfile);
    }

    # Initialize the file types menu
    my $typeMenuBtn = $w->{'typeMenuBtn'};
    my $typeMenuLab = $w->{'typeMenuLab'};
    if (defined $w->cget('-filetypes')) {
	my(@filetypes) = GetFileTypes($w->cget('-filetypes'));
	my $typeMenu = $typeMenuBtn->cget(-menu);
	$typeMenu->delete(0, 'end');
	foreach my $ft (@filetypes) {
	    my $title  = $ft->[0];
	    my $filter = join(' ', @{ $ft->[1] });
	    $typeMenuBtn->command
	      (-label => $title,
	       -command => ['SetFilter', $w, $title, $filter],
	      );
	}
	$w->SetFilter($filetypes[0]->[0], join(' ', @{ $filetypes[0]->[1] }));
	$typeMenuBtn->configure(-state => 'normal');
	$typeMenuLab->configure(-state => 'normal');
    } else {
	$w->configure(-filter => '*');
	$typeMenuBtn->configure(-state => 'disabled',
				-takefocus => 0);
	$typeMenuLab->configure(-state => 'disabled');
    }
    $w->UpdateWhenIdle;

    # Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.
    $w->withdraw;
    $w->idletasks;
    my $x = $w->screenwidth / 2 - $w->reqwidth / 2 - $w->parent->vrootx;
    my $y = $w->screenheight / 2 - $w->reqheight / 2 - $w->parent->vrooty;
    $w->geometry($w->reqwidth .'x'. $w->reqheight);

    {
	my $title = $w->cget(-title);
	if (!defined $title) {
	    $title = ($w->cget(-type) eq 'open' ? 'Open' : 'Save As');
	}
	$w->title($title);
    }

    $w->deiconify;
    # Set a grab and claim the focus too.
    my $oldFocus = $w->focusCurrent;
    my $oldGrab = $w->grabCurrent;
    my $grabStatus = $oldGrab->grabStatus if ($oldGrab);
    $w->grab;
    my $ent = $w->{'ent'};
    $ent->focus;
    $ent->delete(0, 'end');
    $ent->insert(0, $w->{'selectFile'});
    $ent->selectionFrom(0);
    $ent->selectionTo('end');
    $ent->icursor('end');

    # 8. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.
    $w->waitVariable(\$selectFilePath);
    eval {
	$oldFocus->focus if $oldFocus;
    };
    $w->grabRelease;
    $w->withdraw;
    if ($oldGrab) {
	if ($grabStatus eq 'global') {
	    $oldGrab->grabGlobal;
	} else {
	    $oldGrab->grab;
	}
    }
    return $selectFilePath;
}

# tkFDialog_UpdateWhenIdle --
#
#	Creates an idle event handler which updates the dialog in idle
#	time. This is important because loading the directory may take a long
#	time and we don't want to load the same directory for multiple times
#	due to multiple concurrent events.
#
sub UpdateWhenIdle {
    my $w = shift;
    if (exists $w->{'updateId'}) {
	return;
    } else {
	$w->{'updateId'} = $w->after('idle', [$w, 'Update']);
    }
}

# tkFDialog_Update --
#
#	Loads the files and directories into the IconList widget. Also
#	sets up the directory option menu for quick access to parent
#	directories.
#
sub Update {
    my $w = shift;
    my $dataName = $w->name;

    # This proc may be called within an idle handler. Make sure that the
    # window has not been destroyed before this proc is called
    if (!Tk::Exists($w) || $w->class ne 'FBox') {
	return;
    } else {
	delete $w->{'updateId'};
    }
    unless (defined $folderImage) {
	require Tk::Pixmap;
	$folderImage = $w->Pixmap(-file => Tk->findINC('folder.xpm'));
	$fileImage   = $w->Pixmap(-file => Tk->findINC('file.xpm'));
    }
    my $folder = $folderImage;
    my $file   = $fileImage;
    my $appPWD = Cwd::cwd();
    if (!chdir $w->{'selectPath'}) {
	# We cannot change directory to $data(selectPath). $data(selectPath)
	# should have been checked before tkFDialog_Update is called, so
	# we normally won't come to here. Anyways, give an error and abort
	# action.
	$w->messageBox(-type => 'OK',
		       -message => 'Cannot change to the directory "' .
		       $w->{'selectPath'} . "\".\nPermission denied.",
		       -icon => 'warning',
		      );
	chdir $appPWD;
	return;
    }

    # Turn on the busy cursor. BUG?? We haven't disabled X events, though,
    # so the user may still click and cause havoc ...
    my $ent = $w->{'ent'};
    my $entCursor = $ent->cget(-cursor);
    my $dlgCursor = $w->cget(-cursor);
    $ent->configure(-cursor => 'watch');
    $w->configure(-cursor => 'watch');
    $w->idletasks;
    my $icons = $w->{'icons'};
    $icons->DeleteAll;

    # Make the dir & file list
    my $flt = join('|', split(' ', $w->cget(-filter)) );
    $flt =~ s!([\.\+])!\\$1!g;
    $flt =~ s!\*!.*!g;
    if( opendir( FDIR,  Cwd::cwd() )) {
      my @files;
        foreach my $f (sort { lc($a) cmp lc($b) } readdir FDIR) {
          next if $f eq '.' or $f eq '..';
          if (-d $f) { $icons->Add($folder, $f); }
          elsif( $f =~ m!$flt$! ) { push( @files, $f ); } 
	}
      closedir( FDIR );
      foreach my $f ( @files ) { $icons->Add($file, $f); }
    }

    $icons->Arrange;

    # Update the Directory: option menu
    my @list;
    my $dir = '';
    foreach my $subdir (TclFileSplit($w->{'selectPath'})) {
	$dir = TclFileJoin($dir, $subdir);
	push @list, $dir;
    }
    my $dirMenu = $w->{'dirMenu'};
    $dirMenu->options([]);
    my $var = $w->{'selectPath'};
    $dirMenu->addOptions(@list);
    $w->{'selectPath'} = $var; # workaround

    # Restore the PWD to the application's PWD
    chdir $appPWD;

    # turn off the busy cursor.
    $ent->configure(-cursor => $entCursor);
    $w->configure(-cursor =>  $dlgCursor);
}

# tkFDialog_SetPathSilently --
#
# 	Sets data(selectPath) without invoking the trace procedure
#
sub SetPathSilently {
    my($w, $path) = @_;

    $w->{'selectPath'} = $path;
}

# This proc gets called whenever data(selectPath) is set
#
sub SetPath {
    my $w = shift;
    $w->{'selectPath'} = $_[0] if @_;
    $w->UpdateWhenIdle;
}

# This proc gets called whenever data(filter) is set
#
sub SetFilter {
    my($w, $title, $filter) = @_;
    $w->configure(-filter => $filter);
    $w->{'typeMenuBtn'}->configure(-text => $title,
				   -indicatoron => 1);
    $w->{'icons'}->Subwidget('sbar')->set(0.0, 0.0);
    $w->UpdateWhenIdle;
}

# tkFDialogResolveFile --
#
#	Interpret the user's text input in a file selection dialog.
#	Performs:
#
#	(1) ~ substitution
#	(2) resolve all instances of . and ..
#	(3) check for non-existent files/directories
#	(4) check for chdir permissions
#
# Arguments:
#	context:  the current directory you are in
#	text:	  the text entered by the user
#	defaultext: the default extension to add to files with no extension
#
# Return value:
#	[list $flag $directory $file]
#
#	 flag = OK	: valid input
#	      = PATTERN	: valid directory/pattern
#	      = PATH	: the directory does not exist
#	      = FILE	: the directory exists but the file doesn't
#			  exist
#	      = CHDIR	: Cannot change to the directory
#	      = ERROR	: Invalid entry
#
#	 directory      : valid only if flag = OK or PATTERN or FILE
#	 file           : valid only if flag = OK or PATTERN
#
#	directory may not be the same as context, because text may contain
#	a subdirectory name
#
sub ResolveFile {
    my($context, $text, $defaultext) = @_;
    my $appPWD = Cwd::cwd();
    my $path = JoinFile($context, $text);
    $path = "$path$defaultext" if ($path !~ /\..+$/) and defined $defaultext;
    # Cannot just test for existance here as non-existing files are
    # not an error for getSaveFile type dialogs.
    # return ('ERROR', $path, "") if (!-e $path);
    my($directory, $file, $flag);
    if (-e $path) {
	if (-d $path) {
	    if (!chdir $path) {
		return ('CHDIR', $path, '');
	    }
	    $directory = Cwd::cwd();
	    $file = '';
	    $flag = 'OK';
	    chdir $appPWD;
	} else {
	    my $dirname = File::Basename::dirname($path);
	    if (!chdir $dirname) {
		return ('CHDIR', $dirname, '');
	    }
	    $directory = Cwd::cwd();
	    $file = File::Basename::basename($path);
	    $flag = 'OK';
	    chdir $appPWD;
	}
    } else {
	my $dirname = File::Basename::dirname($path);
	if (-e $dirname) {
	    if (!chdir $dirname) {
		return ('CHDIR', $dirname, '');
	    }
	    $directory = Cwd::cwd();
	    $file = File::Basename::basename($path);
	    if ($file =~ /[*?]/) {
		$flag = 'PATTERN';
	    } else {
		$flag = 'FILE';
	    }
	    chdir $appPWD;
	} else {
	    $directory = $dirname;
	    $file = File::Basename::basename($path);
	    $flag = 'PATH';
	}
    }
    return ($flag,$directory,$file);
}

# Gets called when the entry box gets keyboard focus. We clear the selection
# from the icon list . This way the user can be certain that the input in the
# entry box is the selection.
#
sub EntFocusIn {
    my $w = shift;
    my $ent = $w->{'ent'};
    if ($ent->get ne '') {
	$ent->selectionFrom(0);
	$ent->selectionTo('end');
	$ent->icursor('end');
    } else {
	$ent->selectionClear;
    }
    $w->{'icons'}->Unselect;
    my $okBtn = $w->{'okBtn'};
    if ($w->cget(-type) eq 'open') {
	$okBtn->configure(-text => 'Open');
    } else {
	$okBtn->configure(-text => 'Save');
    }
}

sub EntFocusOut {
    my $w = shift;
    $w->{'ent'}->selectionClear;
}

# Gets called when user presses Return in the "File name" entry.
#
sub ActivateEnt {
    my $w = shift;
    my $ent = $w->{'ent'};
    my $text = $ent->get;
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    my($flag, $path, $file) = ResolveFile($w->{'selectPath'}, $text,
					  $w->cget(-defaultextension));
    if ($flag eq 'OK') {
	if ($file eq '') {
	    # user has entered an existing (sub)directory
	    $w->SetPath($path);
	    $ent->delete(0, 'end');
	} else {
	    $w->SetPathSilently($path);
	    $w->{'selectFile'} = $file;
	    $w->Done;
	}
    } elsif ($flag eq 'PATTERN') {
	$w->SetPath($path);
	$w->configure(-filter => $file);
    } elsif ($flag eq 'FILE') {
	if ($w->cget(-type) eq 'open') {
	    $w->messageBox(-icon => 'warning',
			   -type => 'OK',
			   -message => 'File \"' . TclFileJoin($path, $file)
			   . '" does not exist.');
	    $ent->selection('from', 0);
	    $ent->selection('to', 'end');
	    $ent->icursor('end');
	} else {
	    $w->SetPathSilently($path);
	    $w->{'selectFile'} = $file;
	    $w->Done;
	}
    } elsif ($flag eq 'PATH') {
	$w->messageBox(-icon => 'warning',
		       -type => 'OK',
		       -message => "Directory \'$path\' does not exist.");
	$ent->selection('from', 0);
	$ent->selection('to', 'end');
	$ent->icursor('end');
    } elsif ($flag eq 'CHDIR') {
	$w->messageBox(-type => 'OK',
		       -message => "Cannot change to the directory \"$path\".\nPermission denied.",
		       -icon => 'warning');
	$ent->selection('from', 0);
	$ent->selection('to', 'end');
	$ent->icursor('end');
    } elsif ($flag eq 'ERROR') {
	$w->messageBox(-type => 'OK',
		       -message => "Invalid file name \"$path\".",
		       -icon => 'warning');
	$ent->selection('from', 0);
	$ent->selection('to', 'end');
	$ent->icursor('end');
    }
}

# Gets called when user presses the Alt-s or Alt-o keys.
#
sub InvokeBtn {
    my($w, $key) = @_;
    my $okBtn = $w->{'okBtn'};
    $okBtn->invoke if ($okBtn->cget(-text) eq $key);
}

# Gets called when user presses the "parent directory" button
#
sub UpDirCmd {
    my $w = shift;
    $w->SetPath(File::Basename::dirname($w->{'selectPath'}))
      unless ($w->{'selectPath'} eq '/');
}

# Join a file name to a path name. The "file join" command will break
# if the filename begins with ~
sub JoinFile {
    my($path, $file) = @_;
    if ($file =~ /^~/) {
	TclFileJoin($path, "./$file");
    } else {
	TclFileJoin($path, $file);
    }
}

# XXX replace with File::Spec when perl/Tk depends on 5.005
sub TclFileJoin {
    my $path = '';
    foreach (@_) {
	if (m|^/|) {
	    $path = $_;
	} elsif (m|^~([^/]+)(.*)|) {
	    $path = (eval { (getpwnam($1))[7] } || $ENV{'HOME'} || '') . $2;
	} elsif ($path eq '/' or $path eq '') {
	    $path .= $_;
	} else {
	    $path .= "/$_";
	}
    }
    $path;
}

sub TclFileSplit {
    my $path = shift;
    my @comp;
    $path =~ s|/+|/|g; # strip multiple slashes
    if ($path =~ m|^/|) {
	push @comp, '/';
	$path = substr($path, 1);
    }
    push @comp, split /\//, $path;
    @comp;
}

# Gets called when user presses the "OK" button
#
sub OkCmd {
    my $w = shift;
    my $text = $w->{'icons'}->Get;
    if (defined $text and $text ne '') {
	my $file = JoinFile($w->{'selectPath'}, $text);
	if (-d $file) {
	    $w->ListInvoke($text);
	    return;
	}
    }
    $w->ActivateEnt;
}

# Gets called when user presses the "Cancel" button
#
sub CancelCmd {
    my $w = shift;
    undef $selectFilePath;
}

# Gets called when user browses the IconList widget (dragging mouse, arrow
# keys, etc)
#
sub ListBrowse {
    my($w, $text) = @_;
    return if ($text eq '');
    my $file = JoinFile($w->{'selectPath'}, $text);
    my $ent = $w->{'ent'};
    my $okBtn = $w->{'okBtn'};
    unless (-d $file) {
	$ent->delete(0, 'end');
	$ent->insert(0, $text);
	if ($w->cget(-type) eq 'open') {
	    $okBtn->configure(-text => 'Open');
	} else {
	    $okBtn->configure(-text => 'Save');
	}
    } else {
	$okBtn->configure(-text => 'Open');
    }
}

# Gets called when user invokes the IconList widget (double-click,
# Return key, etc)
#
sub ListInvoke {
    my($w, $text) = @_;
    return if ($text eq '');
    my $file = JoinFile($w->{'selectPath'}, $text);
    if (-d $file) {
	my $appPWD = Cwd::cwd();
	if (!chdir $file) {
	    $w->messageBox(-type => 'OK',
			   -message => "Cannot change to the directory \"$file\".\nPermission denied.",
			   -icon => 'warning');
	} else {
	    chdir $appPWD;
	    $w->SetPath($file);
	}
    } else {
	$w->{'selectFile'} = $file;
	$w->Done;
    }
}

# tkFDialog_Done --
#
#	Gets called when user has input a valid filename.  Pops up a
#	dialog box to confirm selection when necessary. Sets the
#	tkPriv(selectFilePath) variable, which will break the "tkwait"
#	loop in tkFDialog and return the selected filename to the
#	script that calls tk_getOpenFile or tk_getSaveFile
#
sub Done {
    my $w = shift;
    my $_selectFilePath = (@_) ? shift : '';
    if ($_selectFilePath eq '') {
	$_selectFilePath = JoinFile($w->{'selectPath'}, $w->{'selectFile'});
	if (-e $_selectFilePath and
	    $w->cget(-type) eq 'save' and
	    !$w->cget(-force)) {
	    my $reply = $w->messageBox
	      (-icon => 'warning',
	       -type => 'YesNo',
	       -message => "File \"$_selectFilePath\" already exists.\nDo you want to overwrite it?");
	    return unless (lc($reply) eq 'yes');
	}
    }
    $selectFilePath = ($_selectFilePath ne '' ? $_selectFilePath : undef);
}

sub FDialog {
    my $cmd = shift;
    if ($cmd =~ /Save/) {
	push @_, -type => 'save';
    }
    Tk::DialogWrapper('FBox', $cmd, @_);
}

# tkFDGetFileTypes --
#
#       Process the string given by the -filetypes option of the file
#       dialogs. Similar to the C function TkGetFileFilters() on the Mac
#       and Windows platform.
#
sub GetFileTypes {
    my $in = shift;
    my %fileTypes;
    foreach my $t (@$in) {
        if (@$t < 2  || @$t > 3) {
	    require Carp;
	    Carp::croak("bad file type \"$t\", should be \"typeName [extension ?extensions ...?] ?[macType ?macTypes ...?]?\"");
        }
	push @{ $fileTypes{$t->[0]} }, (ref $t->[1] eq 'ARRAY'
					? @{ $t->[1] }
					: $t->[1]);
    }

    my @types;
    my %hasDoneType;
    my %hasGotExt;
    foreach my $t (@$in) {
        my $label = $t->[0];
        my @exts;

        next if (exists $hasDoneType{$label});

        my $name = "$label (";
	my $sep = '';
        foreach my $ext (@{ $fileTypes{$label} }) {
            next if ($ext eq '');
            $ext =~ s/^\./*./;
            if (!exists $hasGotExt{$label}->{$ext}) {
                $name .= "$sep$ext";
                push @exts, $ext;
                $hasGotExt{$label}->{$ext}++;
            }
            $sep = ',';
        }
        $name .= ')';
        push @types, [$name, \@exts];

        $hasDoneType{$label}++;
    }

    return @types;
}

1;

