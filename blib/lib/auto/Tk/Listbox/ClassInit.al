# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

sub ClassInit
{
 my ($class,$mw) = @_;

 # Standard Motif bindings:
 $mw->bind($class,"<1>",['BeginSelect',Ev('index',Ev('@'))]);
 $mw->bind($class,"<B1-Motion>",['Motion',Ev('index',Ev('@'))]);
 $mw->bind($class,"<ButtonRelease-1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->CancelRepeat;
		$w->activate($Ev->xy);
	       }
	      )
 ;
 $mw->bind($class,"<Shift-1>",['BeginExtend',Ev('index',Ev('@'))]);
 $mw->bind($class,"<Control-1>",['BeginToggle',Ev('index',Ev('@'))]);

 $mw->bind($class,"<B1-Leave>",['AutoScan',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<Up>",['UpDown',-1]);
 $mw->bind($class,"<Shift-Up>",['ExtendUpDown',-1]);
 $mw->bind($class,"<Down>",['UpDown',1]);
 $mw->bind($class,"<Shift-Down>",['ExtendUpDown',1]);

 $mw->XscrollBind($class); 
 $mw->PriorNextBind($class); 

 $mw->bind($class,"<Control-Home>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate(0);
		$w->see(0);
		$w->selectionClear(0,"end");
		$w->selectionSet(0)
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-Home>",['DataExtend',0]);
 $mw->bind($class,"<Control-End>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate("end");
		$w->see("end");
		$w->selectionClear(0,"end");
		$w->selectionSet('end')
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-End>",['DataExtend','end']);
 $class->clipboardKeysyms($mw,"F16");
 $mw->bind($class,"<space>",['BeginSelect',Ev('index','active')]);
 $mw->bind($class,"<Select>",['BeginSelect',Ev('index','active')]);
 $mw->bind($class,"<Control-Shift-space>",['BeginExtend',Ev('index','active')]);
 $mw->bind($class,"<Shift-Select>",['BeginExtend',Ev('index','active')]);
 $mw->bind($class,"<Escape>",'Cancel');
 $mw->bind($class,"<Control-slash>",'SelectAll');
 $mw->bind($class,"<Control-backslash>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		if ($w->cget("-selectmode") ne "browse")
		 {
		  $w->selectionClear(0,"end");
		 }
	       }
	      )
 ;
 # Additional Tk bindings that aren't part of the Motif look and feel:
 $mw->bind($class,"<2>",['scan','mark',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B2-Motion>",['scan','dragto',Ev('x'),Ev('y')]);
 return $class;
}

1;
