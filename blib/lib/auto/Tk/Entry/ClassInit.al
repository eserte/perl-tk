# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

#
# Bind --
# This procedure is invoked the first time the mouse enters an
# entry widget or an entry widget receives the input focus. It creates
# all of the class bindings for entries.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.
sub ClassInit
{
 my ($class,$mw) = @_;
 # Standard Motif bindings:
 $mw->bind($class,"<1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $w->Button1($Ev->x);
              $w->SelectionClear;
             });

 $mw->bind($class,"<B1-Motion>",['MouseSelect',Ev("x")]);

 $mw->bind($class,"<Double-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "word";
              $w->MouseSelect($Ev->x);
              eval {local $SIG{__DIE__}; $w->icursor("sel.first") }
             } ) ;
 $mw->bind($class,"<Triple-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "line";
              $w->MouseSelect($Ev->x);
              $w->icursor(0)
             } ) ;
 $mw->bind($class,"<Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "char";
              $w->selection("adjust","@" . $Ev->x)
             } ) ;
 $mw->bind($class,"<Double-Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "word";
              $w->MouseSelect($Ev->x)
             } ) ;
 $mw->bind($class,"<Triple-Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "line";
              $w->MouseSelect($Ev->x)
             } ) ;
 $mw->bind($class,"<B1-Leave>",['AutoScan',Ev("x")]);
 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<ButtonRelease-1>",'CancelRepeat');
 $mw->bind($class,"<Control-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $w->icursor("@" . $Ev->x)
             } ) ;
 $mw->bind($class,"<Left>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->index("insert")-1)
             } ) ;
 $mw->bind($class,"<Right>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->index("insert")+1)
             } ) ;
 $mw->bind($class,"<Shift-Left>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->index("insert")-1);
             } ) ;
 $mw->bind($class,"<Shift-Right>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->index("insert")+1);
             } ) ;
 $mw->bind($class,"<Control-Left>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->wordstart)
             } ) ;
 $mw->bind($class,"<Control-Right>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->wordend)
             } ) ;
 $mw->bind($class,"<Shift-Control-Left>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $w->KeySelect($w->wordstart) ;
             } ) ;
 $mw->bind($class,"<Shift-Control-Right>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->wordend) ;
             } ) ;
 $mw->bind($class,"<Home>",['SetCursor',0]);
 $mw->bind($class,"<Shift-Home>",
             sub
             {
              my $w = shift;
              $w->KeySelect(0);
             } ) ;
 $mw->bind($class,"<End>",['SetCursor',"end"]);
 $mw->bind($class,"<Shift-End>",
             sub
             {
              my $w = shift;
              $w->KeySelect("end");
             } ) ;
 $mw->bind($class,"<Delete>",
             sub
             {
              my $w = shift;
              if ($w->selection("present"))
               {
                $w->deleteSelected
               }
              else
               {
                $w->delete("insert")
               }
             } ) ;

 $mw->bind($class,"<BackSpace>","Backspace");

 $mw->bind($class,"<Control-space>",
             sub
             {
              my $w = shift;
              $w->selection("from","insert")
             } ) ;
 $mw->bind($class,"<Select>",
             sub
             {
              my $w = shift;
              $w->selection("from","insert")
             } ) ;
 $mw->bind($class,"<Control-Shift-space>",
             sub
             {
              my $w = shift;
              $w->selection("adjust","insert")
             } ) ;
 $mw->bind($class,"<Shift-Select>",
             sub
             {
              my $w = shift;
              $w->selection("adjust","insert")
             } ) ;
 $mw->bind($class,"<Control-slash>",
             sub
             {
              my $w = shift;
              $w->selection("range",0,"end")
             } ) ;
 $mw->bind($class,"<Control-backslash>",'SelectionClear');

 $class->clipboardKeysyms($mw,"F16","F20","F18");

 $mw->bind($class,"<KeyPress>", ['Insert',Ev(A)]);

 # Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
 # Otherwise, if a widget binding for one of these is defined, the
 # <KeyPress> class binding will also fire and insert the character,
 # which is wrong.  Ditto for Escape, Return, and Tab.

 $mw->bind($class,'<Alt-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Meta-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Control-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Escape>' ,'NoOp');
 $mw->bind($class,'<Return>' ,'NoOp');
 $mw->bind($class,'<Tab>' ,'NoOp');

 $mw->bind($class,"<Insert>",
             sub
             {
              my $w = shift;
              eval {local $SIG{__DIE__}; $w->Insert($w->SelectionGet)}
             } ) ;
 # Additional emacs-like bindings:
 if (!$Tk::strictMotif)
  {
   $mw->bind($class,"<Control-a>",['SetCursor',0]);
   $mw->bind($class,"<Control-b>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->index("insert")-1)
               } ) ;
   $mw->bind($class,"<Control-d>",['delete','insert']);
   $mw->bind($class,"<Control-e>",['SetCursor',"end"]);
   $mw->bind($class,"<Control-f>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->index("insert")+1)
               } ) ;
   $mw->bind($class,"<Control-h>","Backspace");
   $mw->bind($class,"<Control-k>",["delete","insert","end"]);

   $mw->bind($class,"<Control-t>",'Transpose');

   $mw->bind($class,"<Meta-b>",['SetCursor',Ev('wordstart')]);
   $mw->bind($class,"<Meta-d>",
               sub
               {
                my $w = shift;
                $w->delete("insert",$w->wordend)
               } ) ;
   $mw->bind($class,"<Meta-f>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->wordend)
               } ) ;
   $mw->bind($class,"<Meta-BackSpace>",
               sub
               {
                my $w = shift;
                $w->delete($w->wordstart ,"insert")
               } ) ;
   $class->clipboardKeysyms($mw,"Meta-w","Control-w","Control-y");
   # A few additional bindings of my own.
   $mw->bind($class,"<Control-v>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                eval
                 {local $SIG{__DIE__};
                  $w->insert("insert",$w->SelectionGet);
                  $w->SeeInsert;
                 }
               } ) ;
   $mw->bind($class,"<Control-w>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                $w->delete($w->wordstart ,"insert")
               } ) ;
   $mw->bind($class,"<2>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                $w->scan("mark",$Ev->x);
                $Tk::x = $Ev->x;
                $Tk::y = $Ev->y;
                $Tk::mouseMoved = 0
               } ) ;
   $mw->bind($class,"<B2-Motion>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                if (abs(($Ev->x-$Tk::x)) > 2)
                 {
                  $Tk::mouseMoved = 1
                 }
                $w->scan("dragto",$Ev->x)
               } ) ;
   $mw->bind($class,"<ButtonRelease-2>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                if (!$Tk::mouseMoved)
                 {
                  eval
                   {local $SIG{__DIE__};
                    $w->insert("insert",$w->SelectionGet);
                    $w->SeeInsert;
                   }
                 }
               } )
  }
 return $class;
}

1;
