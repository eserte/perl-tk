# Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
# Copyright (c) 1999 Nick Ing-Simmons and Greg Bartels. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::TextUndo;

use vars qw($VERSION);
$VERSION = '3.031'; # $Id: //depot/Tk8/Tk/TextUndo.pm#31$

use Tk qw (Ev);
use AutoLoader;

use base qw(Tk::Text);

Construct Tk::Widget 'TextUndo';

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<<Undo>>','undo');
 $mw->bind($class,'<<Redo>>','redo');   

 return $class->SUPER::ClassInit($mw);
}                                      
                                                          

####################################################################
# methods for manipulating the undo and redo stacks.
# no one should directly access the stacks except for these methods.
# everyone else must access the stacks through these methods.
####################################################################
sub ResetUndo
{
 my ($w) = @_;
 delete $w->{UNDO};
 delete $w->{REDO};
}

sub PushUndo
{
 my ($w,$ref) = @_;
 $w->{UNDO} = [] unless (exists $w->{UNDO});
 push(@{$w->{UNDO}},$ref);
}

sub PushRedo
{
 my ($w,$ref) = @_;
 $w->{REDO} = [] unless (exists $w->{REDO});
 push(@{$w->{REDO}},$ref);
}

sub PopUndo
{
 my ($w) = @_;
 my $ret=undef;
 if (defined(($w->{UNDO})))
  {
  return pop(@{$w->{UNDO}});
  }
 else
  { return undef ;}
}

sub PopRedo
{
 my ($w) = @_;
 my $ret=undef;
 if (defined(($w->{REDO})))
  {
  return pop(@{$w->{REDO}});
  }
 else
  { return undef ;}
}

sub ShiftRedo
{
 my ($w) = @_;
 my $ret=undef;
 if (defined(($w->{REDO})))
  {
  return shift(@{$w->{REDO}});
  }
 else
  { return undef ;}
}

sub numberChanges
{
 my ($w) = @_;
 return 0 unless (exists $w->{'UNDO'}) and (defined($w->{'UNDO'}));
 return scalar(@{$w->{'UNDO'}});
}

sub SizeRedo
{
 my ($w) = @_;
 return 0 unless exists $w->{'REDO'};
 return scalar(@{$w->{'REDO'}});
}


sub getUndoAtIndex
{
 my ($w,$index) = @_;
 return undef unless (exists $w->{UNDO});
 return $w->{UNDO}[$index];
}

sub getRedoAtIndex
{
 my ($w,$index) = @_;
 return undef unless (exists $w->{REDO});
 return $w->{REDO}[$index];
}

sub getUndoThatMatches
{
 my ($w,$matching) = @_;
 if (exists $w->{UNDO})
  {
   if (@{$w->{UNDO}})
    {
     my $count=0;
     my $i=0;
     my ($undo_ref, $op);
     do
      {
      $i--;
      $undo_ref = $w->getUndoAtIndex($i);
      $op = $undo_ref->[0];
      if ($op eq 'GlobEnd') {$count--;}
      if ($op eq 'GlobStart') {$count++;}
      }
     while($count and (($i*-1)< @{$w->{UNDO}}) and ($op !~ /$matching/) );
     return $undo_ref;
    }
  }
}

# if the only thing on the stack is globstart and glob end,
#  then delete the globstart/globend entries.
#  -2 globstart
#  -1 globend
# if a single operation is surrounded by globstart and globend,
#  then delete the globstart/globend entries.
#  -3 globstart
#  -2 insert 1.4 z
#  -1 globend
sub CleanUpUndo
{
 my ($w) = @_;
 my ($start_undo, $end_undo, $save_operation);
 $start_undo = $w->getUndoAtIndex(-2);
 if( $start_undo->[0] eq 'GlobStart')
  {
  $end_undo = $w->getUndoAtIndex(-1);
  if( $end_undo->[1] eq $start_undo->[1]) #must be for same operation
   {
   $w->PopUndo;
   $w->PopUndo;
   return;
   }
  }

 $start_undo = $w->getUndoAtIndex(-3);
 if( $start_undo->[0] eq 'GlobStart')
  {
  $end_undo = $w->getUndoAtIndex(-1);
  if( $end_undo->[1] eq $start_undo->[1]) #must be for same operation
   {
   $w->PopUndo;
   $save_operation = $w->PopUndo;
   $w->PopUndo;
   $w->PushUndo($save_operation);
   return;
   }
  }
}

####################################################################
# type "hello there"
# hello there_
# hit UNDO
# hello_
# type "out"
# hello out_
# pressing REDO should not do anything
# pressing UNDO should make "out" disappear.
# pressing UNDO should make "there" reappear.
# pressing UNDO should make "there" disappear.
# pressing UNDO should make "hello" disappear.
#
# if there is anything in REDO stack and
# the OperationMode is normal, (i.e. not in the middle of an ->undo or ->redo)
# then before performing the current operation
# take the REDO stack, and put it on UNDO stack
# such that UNDO/REDO keystrokes will still make logical sense.
#
# call this method at the beginning of any overloaded method
# which adds operations to the undo or redo stacks.
# it will perform all the magic needed to handle the redo stack.
####################################################################
sub CheckForRedoShuffle
{
 my ($w) = @_;
 return unless $w->SizeRedo && $w->OperationMode eq 'normal';
 $w->OperationMode('REDO_MAGIC');
 $w->MarkSelectionsSavePositions;

 # first, go through REDO array from index 0 to end,
 # get inverse, and push into UNDO array.
 my $size_redo = $w->SizeRedo;
 my ($ref, $op, @args, $op_undo, @args_undo, $undo_ref);
 for (my $i=$size_redo-1; $i>=0 ; $i--)
  {
   my ($op,@args) = @{$w->getRedoAtIndex($i)};
   my $op_undo = $op .'_UNDO';
   if ($op eq 'insert')
    {
    $w->$op(@args);                    # do insert now
    }

   $w->PushUndo($w->$op_undo(@args)); #figure out how to undo it and put in UNDO
  }

 # then shift each item off REDO array until empty
 # push each item onto REDO array
 while ($w->SizeRedo)
  {
   $ref = $w->ShiftRedo;
   $w->PushUndo($ref);		# pop off redo stack push onto undo stack
   ($op,@args) = @{$ref};
   $op_undo = $op .'_UNDO';
   ($op_undo,@args_undo) = @{$w->$op_undo(@args)};  # get the undo operation
   $w->$op_undo(@args_undo);   # undo the operation # perform the undo operation.
   if ($op eq 'delete')
    {
    $w->$op(@args); 			# do delete now
    }
  }
 $w->RestoreSelectionsMarkedSaved;

 $w->OperationMode('normal');
}


# sets/returns undo/redo/normal operation mode
sub OperationMode
{
 my ($w,$mode) = @_;
 unless ( exists($w->{'OPERATION_MODE'}) and
         defined($w->{'OPERATION_MODE'}) )
  { $w->{'OPERATION_MODE'}='normal';}

 if (defined($mode))
  {
   $w->{'OPERATION_MODE'}=$mode;
  }
 return $w->{'OPERATION_MODE'};
}

sub AddOperation
{
 my ($w,@operation) = @_;
 my $mode = $w->OperationMode;

 if ($mode eq 'normal')
  {$w->PushUndo([@operation]);}
 elsif ($mode eq 'undo')
  {$w->PushRedo([@operation]);}
 elsif ($mode eq 'redo')
  {$w->PushUndo([@operation]);}
 else
  {die "invalid destination $destination, must be UNDO or REDO";}
}

####################################################################
# dump the undo and redo stacks to the screen.
# used for debug purposes.
sub dump_array
{
 my $w = shift;
 my $array;
 my $ref;
 my $enable;
 print "START OF DUMP\n";

 print "UNDO array is:\n";
 if (defined($w->{UNDO}))
  {
   $array = $w->{UNDO};
   foreach $ref (@$array)
    {
     foreach my $item (@$ref)
      {
       my $local_item= $item;
       $local_item =~ tr/\n/\^/;
       print "$local_item ";
      }
     print "\n";
    }
  }

 print "\n";
 print "REDO array is:\n";
 if (defined($w->{REDO}))
  {
  $array = $w->{REDO};
  foreach $ref (@$array)
   {
   foreach my $item (@$ref)
    {
     my $local_item= $item;
    $local_item =~ tr/\n/\^/;
   print "$local_item ";
    }
   print "\n";
   }
  }
 print "\n";
}


############################################################
############################################################
# these are a group of methods used to indicate the start and end of
# several operations that are to be undo/redo 'ed in a single step.
#
# in other words, "glob" a bunch of operations together.
#
# for example, a search and replace should be undone with a single
# keystroke, rather than one keypress undoes the insert and another
# undoes the delete.
# all other methods should access the count via these methods.
# no other method should directly access the {GLOB_COUNT} value directly
#############################################################
#############################################################
sub addGlobStart	# add it to end of undo list
{
 my ($w, $who) = @_;
 unless (defined($who)) {$who = (caller(1))[3];}
 $w->AddOperation('GlobStart', $who) ;
}

sub addGlobEnd		# add it to end of undo list
{
 my ($w, $who) = @_;
 unless (defined($who)) {$who = (caller(1))[3];}
 $w->AddOperation('GlobEnd',  $who);
}

sub GlobStart
{
 my ($w, $who) = @_;
 unless (defined($w->{GLOB_COUNT})) {$w->{GLOB_COUNT}=0;}
 if ($w->OperationMode eq 'normal')
  { 
   $w->PushUndo($w->GlobStart_UNDO($who));
  }
 $w->{GLOB_COUNT} = $w->{GLOB_COUNT} + 1;
}

sub GlobStart_UNDO
{
 my ($w, $who) = @_;
 $who = 'GlobEnd_UNDO' unless defined($who);
 return ['GlobEnd',$who];
}

sub GlobEnd
{
 my ($w, $who) = @_;
 unless (defined($w->{GLOB_COUNT})) {$w->{GLOB_COUNT}=0;}
 if ($w->OperationMode eq 'normal')
  { 
   $w->PushUndo($w->GlobStart_UNDO($who)); 
  }
 $w->{GLOB_COUNT} = $w->{GLOB_COUNT} - 1;
}

sub GlobEnd_UNDO
{
 my ($w, $who) = @_;
 $who = 'GlobStart_UNDO' unless defined($who);
 return ['GlobStart',$who];
}

sub GlobCount
{
 my ($w,$count) = @_;
 unless ( exists($w->{'GLOB_COUNT'}) and defined($w->{'GLOB_COUNT'}) )
  { 
   $w->{'GLOB_COUNT'}=0;
  }
 if (defined($count))
  {
   $w->{'GLOB_COUNT'}=$count;
  }
 return $w->{'GLOB_COUNT'};
}

####################################################################
# two methods should be used by applications to access undo and redo
# capability, namely, $w->undo; and $w->redo; methods.
# these methods undo and redo the last operation, respectively.
####################################################################
sub undo
{
 my ($w) = @_;
 unless ($w->numberChanges) {$w->bell; return;} # beep and return if empty
 $w->GlobCount(0); #initialize to zero
 $w->OperationMode('undo');
 do
  {
   my ($op,@args) = @{$w->PopUndo};  # get undo operation, convert ref to array
   my $undo_op = $op .'_UNDO';
   $w->PushRedo($w->$undo_op(@args)); # find out how to undo it
   $w->$op(@args);   # do the operation
  } while($w->GlobCount and $w->numberChanges);
 $w->OperationMode('normal');
}

sub redo
{
 my ($w) = @_;
 unless ($w->SizeRedo) {$w->bell; return;} # beep and return if empty
 $w->OperationMode('redo');
 $w->GlobCount(0); #initialize to zero
 do
  {
   my ($op,@args) = @{$w->PopRedo}; # get op from redo stack, convert to list
   my $undo_op = $op .'_UNDO';
   $w->PushUndo($w->$undo_op(@args)); # figure out how to undo operation
   $w->$op(@args); # do the operation
  } while($w->GlobCount and $w->SizeRedo);
 $w->OperationMode('normal');
}


############################################################
# override low level subroutines so that they work with UNDO/REDO capability.
# every overridden subroutine must also have a corresponding *_UNDO subroutine.
# the *_UNDO method takes the same parameters in and returns an array reference
# which is how to undo itself.
# note that the *_UNDO must receive absolute indexes.
# ->insert receives 'markname' as the starting index.
# ->insert must convert 'markname' using $absindex=$w->index('markname')
# and pass $absindex to ->insert_UNDO.
############################################################

sub insert
{
 my $w = shift;
 $w->markSet('insert', $w->index(shift) );
 while(defined($_[0]))
  {
  my $index1 = $w->index('insert');
  my $string = shift;
  my $taglist_ref = shift if defined($_[0]);

  if ($w->OperationMode eq 'normal')
   {
    $w->CheckForRedoShuffle;
    $w->PushUndo($w->insert_UNDO($index1,$string,$taglist_ref));
   }
  $w->markSet('notepos' => $index1);
  $w->SUPER::insert($index1,$string,$taglist_ref);
  $w->markSet('insert', $w->index('notepos'));
  }
}


# possible things to insert:
# carriage return
# single character (not CR)
# single line of characters (not ending in CR)
# single line of characters ending with a CR
# multi-line characters. last line does not end with CR
# multi-line characters, last line does end with CR.
#
# also, note this possible call: ->insert (index, string, tag, string, tag...);
sub insert_UNDO
{
 my $w=shift;
 my $index = shift;
 my $string = shift;
 
 # if more than one string, keep reading strings in (discarding tags)
 # until all strings are read in and $string contains entire text inserted.
 while(defined($_[0]))
  {
  shift;		# discard tag (dont care about them here)
  while(defined($_[0]))
   {
   $string .= shift;	# concatenate strings together.
   }
  }

 # calculate index
 my ($line,$col) = split(/\./,$index);
 if ($string =~ /\n(.*)$/)
  {
   $line += $string =~ tr/\n/\n/;
   $col  = length($1);
  }
 else
  {
   $col += length($string);
  }
 my $end_index = $line .'.'. $col;
 return ['delete', $index, $line.'.'.$col];
}

sub delete
{
 my ($w, $start, $stop) = @_;
 unless(defined($stop))
  { $stop = $start .'+1c'; }
 my $index1 = $w->index($start);
 my $index2 = $w->index($stop);

 if ($w->OperationMode eq 'normal')
  {
   $w->CheckForRedoShuffle;
   $w->PushUndo($w->delete_UNDO($index1,$index2));
  }
 $w->SUPER::delete($index1,$index2);
 $w->SetCursor($index1);
}

sub delete_UNDO
{
 my ($w, $index1, $index2) = @_;

 my @tagSequence = $w->tagSequential($index1, $index2);


 return ['insert',$index1, @tagSequence];
}

###############################################################
# tagSequential:
# get tags in range and return them in a format that
# can be inserted.
# $text->insert('1.0', $string1, [tag1,tag2], $string2, [tag2, tag3]);
# note, have to break tags up into sequential order
# in reference to _all_ tags.
###############################################################


##########################################################
# get the list of tags in sequence by brute force.
# go through every index in range and get tags at that index.
# maintain a list of indexes and tags as you go along.
##########################################################

sub tagSequential
{
 my ($w, $index1, $index2) = @_;
 my $index = $w->index($index1);
 my $last_index =  $w->index($index2);
 # note that $last_index may be equivelent to 'end'
 # which means that index + 1c will never be greater than $last_index
# if ($last_index eq $w->index('end'))
#  {
#  $last_index = $w->index($last_index.' -1c');
#  }

 my @tag_list = $w->tagNames($index);

 # @sequence_list is a list of lists, 
 # each sub list contains a start index, a stop index, and
 # a ref to a third list containing a list of tags that apply to 
 # the given indexes.
 # [
 # ['1.0', '1.7', ['red', 'orange'],
 # ['1.7', '1.10', ['yellow', 'green'],
 # ['1.10', '2.15', ['blue', 'indigo'],
 # ['2.15', '8.0', ['violet'],
 # ]
 my @sequence_list;
 push( @sequence_list, [$index, $index, \@tag_list] );

 do 
  {
  $index = $w->index($index . ' +1c');

  # update the end index
  $sequence_list[-1]->[1] = $index;

  # get tags at index
  my @new_tag_list = $w->tagNames($index);

  # if these tags are different from last tags on sequence list
  unless ( lists_are_identical( $sequence_list[-1]->[2] , \@new_tag_list ) )
    {
    push( @sequence_list, [$index, $index, \@new_tag_list] );
    }
  }
 while($w->compare($index, '<', $last_index) );

 my @return_list;
 foreach my $ref (@sequence_list)
  {
  push(@return_list, $w->get($ref->[0], $ref->[1]));
  push(@return_list, $ref->[2]);
  }

 return @return_list;
}


##########################################
# take ref to two lists
# if lists are identical, return 1
# else return 0;
##########################################
sub lists_are_identical
{
  my ($l1_ref, $l2_ref) = @_;
 
  unless(defined($l1_ref))
   {
   unless(defined($l2_ref))
    {
    return 1; # both undefined.
    }
   }

  return 0 unless (defined($l1_ref)); # one is defined, the other isnt
  return 0 unless (defined($l2_ref)); # one is defined, the other isnt

  return 0 unless (@$l1_ref == @$l2_ref); # not same size

  # check every element in array.
  for (my $i = 0; $i<@$l1_ref; $i++)
   {
   return 0 unless ($l1_ref->[$i] eq $l2_ref->[$i]);
   }

  return 1;
}
  
############################################################
# override subroutines which are collections of low level
# routines executed in sequence.
# wrap a globstart and globend around the SUPER:: version of routine.
############################################################

sub ReplaceSelectionsWith
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::ReplaceSelectionsWith(@_);
 $w->addGlobEnd;
}

sub FindAndReplaceAll
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::FindAndReplaceAll(@_);
 $w->addGlobEnd;
}

sub clipboardCut
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::clipboardCut(@_);
 $w->addGlobEnd;
}

sub clipboardPaste
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::clipboardPaste(@_);
 $w->addGlobEnd;
}

sub clipboardColumnCut
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::clipboardColumnCut(@_);
 $w->addGlobEnd;
}

sub clipboardColumnPaste
{
 my $w = shift;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 $w->SUPER::clipboardColumnPaste(@_);
 $w->addGlobEnd;
}


# Greg: this method is more tightly coupled to the base class
# than I would prefer, but I know of no other way to do it.
sub InsertKeypress
{
 my ($w,$char)=@_;
 return if $char eq '';
 $w->CheckForRedoShuffle;


 my $undo_item = $w->getUndoAtIndex(-1);

 if (
  (defined($undo_item)) and
  ($undo_item->[0] =~ /delete/) and
  ($undo_item->[2] == $w->index('insert')) and
  (length($char) == 1)and
  ($char ne "\n") and
  ($char ne ' ')
  )
  {
    {
    my $save_char_for_overstrike = $w->get('insert');
    #############################################################
    # call SUPER, but pop anything it puts onto destination stack, since
    # we will combine undo for this keypress into the previous one.
    #############################################################
    my $flag = 'InsertKeypress mystic magic token';
    $w->PushUndo([$flag]);
    $w->markSet('notepos' => 'insert');
    $w->SUPER::InsertKeypress($char);
    # pop everything off undo stack until we hit magical mystical token
    do { $undo_item = $w->PopUndo->[0]; }
      while (defined($undo_item) and ($undo_item ne $flag));

    # fix the delete part
    $undo_item = $w->getUndoThatMatches('delete');
    $undo_item->[2] = $w->index('notepos'); # delete start stop

    # if its overstrike mode
    if($w->OverstrikeMode)
     {
     $undo_item = $w->getUndoThatMatches('insert');
     if(defined($undo_item))
      {$undo_item->[2] .= $save_char_for_overstrike; } # insert character_string
     }
    return; # dont do the normal call (below)
    }
  }

 $w->addGlobStart;
 $w->SUPER::InsertKeypress($char);
 $w->addGlobEnd;
 $w->CleanUpUndo;

}

############################################################
sub TextUndoFileProgress
{
 my ($w,$action,$filename,$count) = @_;
 return unless(defined($filename) and defined($count));

 my $popup = $w->{'FILE_PROGRESS_POP_UP'};
 unless (defined($popup))
  {  
   $w->update;                    
   $popup = $w->Toplevel(-title => "File Progress",-popover => $w); 
   $popup->transient($w->toplevel);
   $popup->withdraw;
   $popup->resizable('no','no');
   $popup->Label(-textvariable => \$popup->{ACTION})->pack;
   $popup->Label(-textvariable => \$popup->{FILENAME})->pack;
   $popup->Label(-textvariable => \$popup->{COUNT})->pack;
   $w->{'FILE_PROGRESS_POP_UP'} = $popup;
  }     
 $popup->{ACTION}   = $action;
 $popup->{COUNT}    = "lines: $count"; 
 $popup->{FILENAME} = "Filename: $filename";
 $popup->idletasks; 
 $popup->Popup unless $popup->viewable;
 $popup->update;
 return $popup;
}


sub FileName
{
 my ($w,$filename) = @_;
 if (@_ > 1)
  {
   $w->{'FILENAME'}=$filename;
  }
 return $w->{'FILENAME'};
}

sub ConfirmDiscard
{
 my ($w)=@_;
 if ($w->numberChanges)
  {
   my $ans = $w->messageBox(-icon    => 'warning',
                            -type => YesNoCancel, -default => 'Yes',
                            -message =>
"The text has been modified without being saved.
Save edits?");
   return 0 if $ans eq 'Cancel';
   return 0 if ($ans eq 'Yes' && !$w->Save);
  }
 return 1;
}

################################################################################
# if the file has been modified since being saved, a pop up window will be
# created, asking the user to confirm whether or not to exit.
# this allows the user to return to the application and save the file.
# the code would look something like this:
#
# if ($w->user_wants_to_exit)
#  {$w->ConfirmExit;}
#
# it is also possible to trap attempts to delete the main window.
# this allows the ->ConfirmExit method to be called when the main window
# is attempted to be deleted.
#
# $mw->protocol('WM_DELETE_WINDOW'=>
#  sub{$w->ConfirmExit;});
#
# finally, it might be desirable to trap Control-C signals at the
# application level so that ->ConfirmExit is also called.
#
# $SIG{INT}= sub{$w->ConfirmExit;};
#
################################################################################

sub ConfirmExit
{
 my ($w) = @_;
 $w->toplevel->destroy if $w->ConfirmDiscard;
}

sub Save
{
 my ($w,$filename) = @_;
 $filename = $w->FileName unless defined $filename;
 return $w->FileSaveAsPopup unless defined $filename;
 local *FILE;
 if (open(FILE,">$filename"))
  {
   my $status;
   my $count=0;
   my $index = '1.0';
   my $progress;
   while ($w->compare($index,'<','end'))
    {
#    my $end = $w->index("$index + 1024 chars");
     my $end = $w->index("$index  lineend +1c");
     print FILE $w->get($index,$end);
     $index = $end;
     if (($count++%1000) == 0)
      { 
       $progress = $w->TextUndoFileProgress (Saving => $filename,$count);
      }
    }
   $progress->withdraw if defined $progress;
   if (close(FILE))
    {
     $w->ResetUndo;
     $w->FileName($filename);
     return 1;
    }
  }
 else
  {
   $w->BackTrace("Cannot open $filename:$!");
  }          
 return 0;
}

sub Load
{
 my ($w,$filename) = @_;
 $filename = $w->FileName unless (defined($filename));
 return 0 unless defined $filename;
 local *FILE;
 if (open(FILE,"<$filename"))
  {
   $w->MainWindow->Busy;
   $w->EmptyDocument;
   my $count=1;
   my $progress;
   while (<FILE>)
    {
     $w->SUPER::insert('end',$_);
     if (($count++%1000) == 0)
      { 
       $progress = $w->TextUndoFileProgress (Loading => $filename,$count);
      }
    }
   close(FILE);
   $progress->withdraw if defined $progress;
   $w->markSet('insert' => '1.0');
   $w->FileName($filename);
   $w->MainWindow->Unbusy;
  }
 else
  {
   $w->BackTrace("Cannot open $filename:$!");
  }
}

sub IncludeFile
{
 my ($w,$filename) = @_;
 unless (defined($filename))
  {$w->BackTrace("filename not specified"); return;}
 $w->CheckForRedoShuffle;
 if (open(FILE,"<$filename"))
  {
   $w->Busy;
   my $count=1;
   $w->addGlobStart;
   my $progress;
   while (<FILE>)
    {
     $w->insert('insert',$_);
     if (($count++%1000) == 0)
      {
       $progress = $w->TextUndoFileProgress (Including => $filename,$count);
      }
    }
   $progress->withdraw if defined $progress;
   $w->addGlobEnd;
   close(FILE);
   $w->Unbusy;
  }
 else
  {
   $w->BackTrace("Cannot open $filename:$!");
  }
}

# clear document without pushing it into UNDO array, (use SUPER::delete)
# (using plain delete(1.0,end) on a really big document fills up the undo array)
# and then clear the Undo and Redo stacks.
sub EmptyDocument
{
 my ($w) = @_;
 $w->SUPER::delete('1.0','end');
 $w->ResetUndo;
 $w->FileName(undef);
}

sub ConfirmEmptyDocument
{
 my ($w)=@_;
 $w->EmptyDocument if $w->ConfirmDiscard;
}

sub FileMenuItems
{
 my ($w) = @_;
 return [
   ["command"=>'Open',    -command => sub{$w->FileLoadPopup;}],
   ["command"=>'Save',    -command => sub{$w->Save} ],
   ["command"=>'Save As', -command => sub{$w->FileSaveAsPopup;}],
   ["command"=>'Include', -command => sub{$w->IncludeFilePopup;}],
   ["command"=>'Clear',   -command => sub{$w->ConfirmEmptyDocument;}],
   "-",@{$w->SUPER::FileMenuItems}
  ]
}

sub EditMenuItems
{
 my ($w) = @_;

 return [
    ["command"=>'Undo', -command => sub{$w->undo;}],
    ["command"=>'Redo', -command => sub{$w->redo;}],
     "-",@{$w->SUPER::EditMenuItems}
  ];
}

sub CreateFileSelect
{
 my $w = shift;
 my $k = shift;
 my $name = $w->FileName;
 my @types = (['All Files', '*']);
 my $dir   = undef;
 if (defined $name)
  {
   require File::Basename;
   my $sfx;
   ($name,$dir,$sfx) = File::Basename::fileparse($name,'\..*');
   if (defined($sfx) && length($sfx))
    {
     unshift(@types,['Similar Files',[$sfx]]);
     $name .= $sfx;
    }
  }
 return $w->$k(-initialdir  => $dir, -initialfile => $name,
               -filetypes => \@types, @_);
}

sub FileLoadPopup
{
 my ($w)=@_;
 my $name = $w->CreateFileSelect('getOpenFile',-title => 'File Load');
 return $w->Load($name) if defined($name) and length($name);
 return 0;
}

sub IncludeFilePopup
{
 my ($w)=@_;
 my $name = $w->CreateFileSelect('getOpenFile',-title => 'File Include');
 return $w->IncludeFile($name) if defined($name) and length($name);
 return 0;
}

sub FileSaveAsPopup
{
 my ($w)=@_;
 my $name = $w->CreateFileSelect('getSaveFile',-title => 'File Save As');
 return $w->Save($name) if defined($name) and length($name);
 return 0;
}


sub MarkSelectionsSavePositions
{
 my ($w)=@_;
 $w->markSet('MarkInsertSavePosition','insert');
 my @ranges = $w->tagRanges('sel');
 my $range_total = @ranges;
 for (my $i=0; $i<$range_total; $i++)
  {
   $w->markSet( 'MarkSelectionsSavePositions_'.$i, $ranges[$i] ); 
  }
}

sub RestoreSelectionsMarkedSaved
{
 my ($w)=@_;
 my $i = 0;
 my %mark_hash;
 foreach my $mark ($w->markNames)
  {
   $mark_hash{$mark}=1;
  }
 while(1)
  {
   my $markstart = 'MarkSelectionsSavePositions_'.$i++;
   last unless(exists($mark_hash{$markstart}));
   my $indexstart = $w->index($markstart);
   my $markend = 'MarkSelectionsSavePositions_'.$i++;
   last unless(exists($mark_hash{$markend}));
   my $indexend = $w->index($markend);
   $w->tagAdd('sel',$indexstart, $indexend);
   $w->markUnset($markstart, $markend);
  }
 $w->markSet('insert','MarkInsertSavePosition');
}

####################################################################
# selected lines may be discontinous sequence.
sub SelectedLineNumbers
{
 my ($w) = @_;
 my @ranges = $w->tagRanges('sel');
 my @selection_list;
 while (@ranges)
  {
   my ($first) = split(/\./,shift(@ranges));
   my ($last) = split(/\./,shift(@ranges));
   # if previous selection ended on the same line that this selection starts,
   # then fiddle the numbers so that this line number isnt included twice.
   if (defined($selection_list[-1]) and ($first == $selection_list[-1])) 
    {
     # if this selection ends on the same line its starts, then skip this sel
     next if ($first == $last);
     $first++; # count this selection starting from the next line.
    }
   push(@selection_list, $first .. $last);
  }
 return @selection_list;
}

sub insertStringAtStartOfSelectedLines
{
 my ($w,$insert_string)=@_;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 foreach my $line ($w->SelectedLineNumbers)
  {
   $w->insert($line.'.0', $insert_string);
  }
 $w->addGlobEnd;
 $w->CleanUpUndo;
}

sub deleteStringAtStartOfSelectedLines
{
 my ($w,$insert_string)=@_;
 $w->CheckForRedoShuffle;
 $w->addGlobStart;
 my $length = length($insert_string);
 foreach my $line ($w->SelectedLineNumbers)
  {
   my $start = $line.'.0';
   my $end   = $line.'.'.$length;
   my $current_text = $w->get($start, $end);
   next unless ($current_text eq $insert_string);
   $w->delete($start, $end);
  }
 $w->addGlobEnd;
 $w->CleanUpUndo;
}

1;
__END__

