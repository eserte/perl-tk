# HList.tcl --
#
# This file defines the default bindings for Tix Hierarchical Listbox widgets.
#
# Copyright (c) 1995 Ioi K Lam
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#--------------------------------------------------------------------------
# tkPriv elements used in this file:
#
# afterId -		Token returned by "after" for autoscanning.
# fakeRelease -		Cancel the ButtonRelease-1 after the user double click
#--------------------------------------------------------------------------
#
# ToDo: shift-up,down keys
proc tixHListBind {} {
    bind TixHList <ButtonPress-1> {
	tixHList::Button-1 %W %x %y %X %Y
    }
    bind TixHList <Shift-ButtonPress-1> {
	tixHList::Shift-Button-1 %W %x %y %X %Y
    }
    bind TixHList <Control-ButtonRelease-1> {;}
    bind TixHList <ButtonRelease-1> {
	if {[%W cget -selectmode] != "dragdrop"} {
	    catch {tkCancelRepeat}
	}
	tixHList::ButtonRelease-1 %W %x %y %X %Y
    }
    bind TixHList <B1-Motion> {
	set tkPriv(x) %x 
	set tkPriv(y) %y
	set tkPriv(X) %X
	set tkPriv(Y) %Y

	tixHList::B1-Motion %W %x %y %X %Y
    }
    bind TixHList <Control-B1-Motion> {
	set tkPriv(x) %x 
	set tkPriv(y) %y
	set tkPriv(X) %X
	set tkPriv(Y) %Y
    }
    bind TixHList <Control-ButtonPress-1> {
	tixHList::Ctrl-Button1 %W %x %y %X %Y
    }
    bind TixHList <Control-Double-ButtonPress-1> {
	tixHList::Ctrl-Button1 %W %x %y %X %Y
    }
    bind TixHList <Double-ButtonPress-1> {
	tixHList::Double1 %W  %x %y %X %Y
    }
    bind TixHList  <B1-Leave> {
	set tkPriv(x) %x 
	set tkPriv(y) %y
	set tkPriv(X) %X
	set tkPriv(Y) %Y

	tixHList::AutoScan %W
    }
    bind TixHList <B1-Enter> {
	if {[%W cget -selectmode] != "dragdrop"} {
	    tkCancelRepeat
	}
    }
    bind TixHList <Up> {
	tixHList:UpDown %W prev
    }
    bind TixHList <Down> {
	tixHList:UpDown %W next
    }
    bind TixHList <Shift-Up> {
	tixHList:Shift-UpDown %W prev
    }
    bind TixHList <Shift-Down> {
	tixHList:Shift-UpDown %W next
    }
    bind TixHList <Left> {
	tixHList:LeftRight %W left
    }
    bind TixHList <Right> {
	tixHList:LeftRight %W right
    }
    bind TixHList <Prior> {
	%W yview scroll -1 pages
    }
    bind TixHList <Next> {
	%W yview scroll 1 pages
    }
    bind TixHList <Return> {
	tixHList:Keyboard-Activate %W 
    }
    bind TixHList <space> {
	tixHList:Keyboard-Browse %W 
    }
}

#----------------------------------------------------------------------
#
#
#			 Key bindings
#
#
#----------------------------------------------------------------------
proc tixHList:Keyboard-Activate {w} {
    set anchor [$w info anchor]

    if {$anchor == ""} {
	return
    }

    if {[$w cget -selectmode] == "single"} {
	$w select clear
	$w select set $anchor
    }

    set command [$w cget -command]
    if {$command != {}} {
	eval $command [list $anchor]
    }
}

proc tixHList:Keyboard-Browse {w} {
    set anchor [$w info anchor]

    if {$anchor == ""} {
	return
    }

    if {[$w cget -selectmode] == "single"} {
	$w select clear
	$w select set $anchor
    }

    set browsecmd [$w cget -browsecmd]
    if {$browsecmd != {}} {
	eval $browsecmd [list $anchor]
    }
}

proc tixHList:LeftRight {w spec} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    set anchor [$w info anchor]
    if {$anchor == ""} {
	set anchor [lindex [$w info children] 0]
    }

    set done 0
    set ent $anchor
    while {!$done} {
	set e $ent
	if {$spec == "left"} {
	    set ent [$w info parent $e]

	    if {$ent == {} || [$w entrycget $ent -state] == "disabled"} {
		set ent [$w info prev $e]
	    }
	} else {
	    set ent [lindex [$w info children $e] 0]

	    if {$ent == {} || [$w entrycget $ent -state] == "disabled"} {
		set ent [$w info next $e]
	    }
	}

	if {$ent == {}} {
	    break
	}
 	if {[$w entrycget $ent -state] != "disabled"} {
	    break
	}
   }

   if {$ent == {}} {
	if {$spec == "left"} {
	    $w xview scroll -1 unit
	} else {
	    $w xview scroll 1 unit
	}
	return
    }

    $w anchor set $ent
    $w see $ent

    if {[$w cget -selectmode] != "single"} {
	$w select clear
	$w selection set $ent

	set browsecmd [$w cget -browsecmd]
	if {$browsecmd != {}} {
	    eval $browsecmd [list $ent]
	}
    }
}

proc tixHList:UpDown {w spec} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    set done 0
    set anchor [$w info anchor]

    if {$anchor == ""} {
	set anchor [lindex [$w info children] 0]

	if {$anchor == {}} {
	    return
	}

	if {[$w entrycget $anchor -state] != "disabled"} {
	    # That's a good anchor
	    set done 1
	} else {
	    # We search for the first non-disabled entry (downward)
	    set spec next
	}
    }

    set ent $anchor

    # Find the prev/next non-disabled entry
    #
    while {!$done} {
	set ent [$w info $spec $ent]
	if {$ent == {}} {
	    break
	}
	if {[$w entrycget $ent -state] == "disabled"} {
	    continue
	}
	if [$w info hidden $ent] {
	    continue
	}
	break
    }

    if {$ent == {}} {
	if {$spec == "prev"} {
	    $w yview scroll -1 unit
	} else {
	    $w yview scroll 1 unit
	}
	return
    } else {
	$w anchor set $ent
	$w see $ent

	if {[$w cget -selectmode] != "single"} {
	    $w select clear
	    $w selection set $ent

	    set browsecmd [$w cget -browsecmd]
	    if {$browsecmd != {}} {
		eval $browsecmd [list $ent]
	    }
	}
    }
}

proc tixHList:Shift-UpDown {w spec} {

    if {[$w cget -selectmode] == "single"} {
	tixHList:UpDown $w $spec
	return
    }
    if {[$w cget -selectmode] == "browse"} {
	tixHList:UpDown $w $spec
	return
    }
    if {[$w info anchor] == {}} {
	tixHList:UpDown $w $spec
	return
    }

    set done 0
    set anchor [$w info anchor]

    global $w:priv:shiftanchor
    if {![info exists $w:priv:shiftanchor]} {
	set $w:priv:shiftanchor $anchor
    }

    set ent [set $w:priv:shiftanchor]
    set done 0

    # Find the prev/next non-disabled entry
    #
    while {!$done} {
	set ent [$w info $spec $ent]
	if {$ent == {}} {
	    break
	}
	if {[$w entrycget $ent -state] == "disabled"} {
	    continue
	}
	if [$w info hidden $ent] {
	    continue
	}
	break

    }

    if {$ent == {}} {
	if {$spec == "prev"} {
	    $w yview scroll -1 unit
	} else {
	    $w yview scroll 1 unit
	}
	return
    } else {
	$w select clear
	$w selection set $anchor $ent
	$w see $ent
	set $w:priv:shiftanchor $ent

	set browsecmd [$w cget -browsecmd]
	if {$browsecmd != {}} {
	    eval $browsecmd [list $ent]
	}
    }
}

#----------------------------------------------------------------------
#
#
#			 Mouse bindings
#
#
#----------------------------------------------------------------------

proc tixHList::GetNearest {w y} {
    set ent [$w nearest $y]

    if {$ent != {}} {
	if {[$w entrycget $ent -state] != "disabled"} {
	    return $ent

	}
    }
    return {}
}

proc tixHList::Button-1 {w x y X Y} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    if [$w cget -takefocus] {
	focus $w
    }

    if {[$w cget -selectmode] == "dragdrop"} {
	tixHList:Send:WaitDrag $w $x $y $X $Y
	return
    }

    set ent [tixHList::GetNearest $w $y]
    if {$ent == {}} {
	return
    }

    set browse 0
    if {$ent != ""} {
	case [$w cget -selectmode] {
	    {single} {
		$w anchor set $ent
	    }
	    {browse} {
		$w anchor set $ent
		$w select clear
		$w select set $ent
		set browse 1
	    }
	    {multiple} {
		$w select clear
		$w anchor set $ent
		$w select set $ent
		set browse 1
	    }
	    {extended} {
		$w anchor set $ent
		$w select clear
		$w select set $ent
		set browse 1
	    }
	}

	if {$browse} {
	    set browsecmd [$w cget -browsecmd]
	    if {$browsecmd != {}} {
		eval $browsecmd [list $ent]
	    }
	}
    }
}

proc tixHList::Shift-Button-1 {w x y X Y} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    set to [tixHList::GetNearest $w $y]
    if {$to == {}} {
	return
    }

    case [$w cget -selectmode] {
	{multiple extended} {
	    set from [$w info anchor]
	    if {$from == {}} {
		$w anchor set $to
		$w select clear
		$w select set $to
	    } else {
		$w select clear
		$w select set $from $to
	    }
	}
    }
}

proc tixHList::ButtonRelease-1 {w x y X Y} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    global tkPriv

    if {[info exists tkPriv(fakeRelease)]} {
	if {$tkPriv(fakeRelease) == $w} {
	    catch {unset tkPriv(fakeRelease)}
	    return
	} else {
	    catch {unset tkPriv(fakeRelease)}
	}
    }

    if {[$w cget -selectmode] == "dragdrop"} {
	tixHList:Send:DoneDrag $w $x $y $X $Y
	return
    }

    set ent [tixHList::GetNearest $w $y]
    if {$ent == {}} {
	return
    }

    if {$x < 0 || $y < 0 || $x > [winfo width $w] || $y > [winfo height $w]} {
	$w select clear

	case [$w cget -selectmode] {
	    {single browse} {
		return
	    }
	}
    } else {
	case [$w cget -selectmode] {
	    {single browse} {
		$w anchor set $ent
		$w select clear
		$w select set $ent
	    }
	    {multiple} {
		$w select set $ent
	    }
	    {extended} {
		$w select set $ent
	    }
	}
    }

    set browsecmd [$w cget -browsecmd]
    if {$browsecmd != {}} {
	eval $browsecmd [list $ent]
    }
}

proc tixHList::Double1 {w x y X Y} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }
    global tkPriv
    set ent [tixHList::GetNearest $w $y]

    if {$ent != ""} {
	if {[$w info anchor] == {}} {
	    $w anchor set $ent
	}
	$w select set $ent
	set command [$w cget -command]
	if {$command != {}} {
	    eval $command [list $ent]
	}
    }

    set tkPriv(fakeRelease) $w
}

proc tixHList::Ctrl-Button1 {w x y X Y} {
    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }

    set ent [tixHList::GetNearest $w $y]

    if {$ent != ""} {
	case [$w cget -selectmode] {
	    {extended} {
		if {[$w info anchor] == {}} {
		    $w anchor set $ent
		}

		if [$w select includes $ent] {
		    $w select clear $ent
		} else {
		    $w select set $ent
		}
		
		set browsecmd [$w cget -browsecmd]
		if {$browsecmd != {}} {
		    eval $browsecmd [list $ent]
		}
	    }
	}
    }
}

# ToDo: The multiple selection is not very efficient when there
#	are a large number of entries. Should only select/de-select
#	those entries who are affected.
# 
#
proc tixHList::B1-Motion {w x y X Y} {
    global tkPriv

    catch {
	uplevel #0 unset $w:priv:shiftanchor
    }
    if {[$w cget -selectmode] == "dragdrop"} {
	tixHList:Send:StartDrag $w $x $y $X $Y
	return
    }

    set ent [tixHList::GetNearest $w $y]

    if {$ent != ""} {
	case [$w cget -selectmode] {
	    {single} {
		$w anchor set $ent
	    }
	    {browse} {
		$w select clear
		$w select set $ent
		$w anchor set $ent
	    }
	    {multiple extended} {
		if {[$w info anchor] == {}} {
		    $w anchor set $ent
		    $w select clear
		    $w select set $ent
		} else {
		    set from [$w info anchor]
		    set to $ent
		    $w select clear

		    $w select set $from $to
		}
	    }
	}
	if {[$w cget -selectmode] != "single"} {
	    set browsecmd [$w cget -browsecmd]
	    if {$browsecmd != {}} {
		eval $browsecmd [list $ent]
	    }
	}
    }
}

# tixHList::AutoScan --
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down.  It scrolls the window up, down, left, or
# right, depending on where the mouse left the window, and reschedules
# itself as an "after" command so that the window continues to scroll until
# the mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The entry window.

proc tixHList::AutoScan {w} {
    global tkPriv
    set x $tkPriv(x)
    set y $tkPriv(y)
    set X $tkPriv(X)
    set Y $tkPriv(Y)

    if {[$w cget -selectmode] == "dragdrop"} {
	return
    }

    if {$y >= [winfo height $w]} {
	$w yview scroll 1 units
    } elseif {$y < 0} {
	$w yview scroll -1 units
    } elseif {$x >= [winfo width $w]} {
	$w xview scroll 2 units
    } elseif {$x < 0} {
	$w xview scroll -2 units
    } else {
	return
    }

    set tkPriv(afterId) [after 50 tixHList::AutoScan $w]
    tixHList::B1-Motion $w $x $y $X $Y
}

#----------------------------------------------------------------------
#
#		    Drag + Drop Bindings
#
#----------------------------------------------------------------------

	     #----------------------------------------#
	     #	          Sending Actions	      #
	     #----------------------------------------#

#----------------------------------------------------------------------
#  tixHList:Send:WaitDrag --
#
#	Sender wait for dragging action
#----------------------------------------------------------------------
proc tixHList:Send:WaitDrag {w x y X Y} {
    global tixPriv

    set ent [tixHList::GetNearest $w $y]
    if {$ent != {}} {
	$w anchor set $ent
	$w select clear
	$w select set $ent
 
	set tixPriv(dd,$w:moved) 0
	set tixPriv(dd,$w:entry) $ent

	set browsecmd [$w cget -browsecmd]
	if {$browsecmd != {} && $ent != {}} {
	    eval $browsecmd [list $ent]
	}
    }
}

proc tixHList:Send:StartDrag {w x y X Y} {
    global tixPriv
    set dd [tixGetDragDropContext $w]

    if {![info exists tixPriv(dd,$w:entry)]} {
	return
    }
    if {$tixPriv(dd,$w:entry) == {}} {
	return
    }

    if {$tixPriv(dd,$w:moved) == 0} {
	$w dragsite set $tixPriv(dd,$w:entry)
	set tixPriv(dd,$w:moved) 1
	$dd config -source $w -command "tixHList:Send:Cmd $w"
	$dd startdrag $X $Y
    } else {
	$dd drag $X $Y
    }
}

proc tixHList:Send:DoneDrag {w x y X Y} {
    global tixPriv
    global moved

    if {![info exists tixPriv(dd,$w:entry)]} {
	return
    }
    if {$tixPriv(dd,$w:entry) == {}} {
	return
    }

    if {$tixPriv(dd,$w:moved) == 1} {
	set dd [tixGetDragDropContext $w]
	$dd drop $X $Y
    }
    $w dragsite clear
    catch {unset tixPriv(dd,$w:moved)}
    catch {unset tixPriv(dd,$w:entry)}
}

proc tixHList:Send:Cmd {w option args} {
    set dragCmd [$w cget -dragcmd]
    if {$dragCmd != {}} {
	return [eval $dragCmd $option $args]
    }

    # Perform the default action
    #
    case "$option" {
	who {
	    return $w
	}
	types {
	    return {data text}
	}
	get {
	    global tixPriv
	    if {[lindex $args 0] == "text"} {
		if {$tixPriv(dd,$w:entry) != {}} {
		    return [$w entrycget $tixPriv(dd,$w:entry) -text]
		}
	    }
	    if {[lindex $args 0] == "data"} {
		if {$tixPriv(dd,$w:entry) != {}} {
		    return [$w entrycget $tixPriv(dd,$w:entry) -data]
		}
	    }
	}
    }
}

	     #----------------------------------------#
	     #	          Receiving Actions	      #
	     #----------------------------------------#
proc tixHList:Rec:DragOver {w sender x y} {
    if {[$w cget -selectmode] != "dragdrop"} {
	return
    }

    set ent [tixHList::GetNearest $w $y]
    if {$ent != {}} {
	$w dropsite set $ent
    } else {
	$w dropsite clear
    }
}

proc tixHList:Rec:DragIn {w sender x y} {
    if {[$w cget -selectmode] != "dragdrop"} {
	return
    }
    set ent [tixHList::GetNearest $w $y]
    if {$ent != {}} {
	$w dropsite set $ent
    } else {
	$w dropsite clear
    }
}

proc tixHList:Rec:DragOut {w sender x y} {
    if {[$w cget -selectmode] != "dragdrop"} {
	return
    }
    $w dropsite clear
}

proc tixHList:Rec:Drop {w sender x y} {
    if {[$w cget -selectmode] != "dragdrop"} {
	return
    }
    $w dropsite clear

    set ent [tixHList::GetNearest $w $y]
    if {$ent != {}} {
	$w anchor set $ent
	$w select clear
	$w select set $ent
    }
 
    set dropCmd [$w cget -dropcmd]
    if {$dropCmd != {}} {
	eval $dropCmd $sender $x $y
	return
    }

    set browsecmd [$w cget -browsecmd]
    if {$browsecmd != {} && $ent != {}} {
	eval $browsecmd [list $ent]
    }
}

tixDropBind TixHList <In>   "tixHList:Rec:DragIn %W %S %x %y"
tixDropBind TixHList <Over> "tixHList:Rec:DragOver %W %S %x %y"
tixDropBind TixHList <Out>  "tixHList:Rec:DragOut %W %S %x %y"
tixDropBind TixHList <Drop> "tixHList:Rec:Drop %W %S %x %y"
