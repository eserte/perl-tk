# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 56 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/bindRdOnly.al)"
sub bindRdOnly
{

 my ($class,$mw) = @_;

 # Standard Motif bindings:
 $mw->bind($class,"<1>",['Button1',Ev('x'),Ev('y')]);
 $mw->bind($class,"<Meta-B1-Motion>",'NoOp');
 $mw->bind($class,"<Meta-1>",'NoOp');
 $mw->bind($class,'<Alt-KeyPress>','NoOp');
 $mw->bind($class,'<Escape>',['tag','remove','sel','1.0','end']);

 $mw->bind($class,"<B1-Motion>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $Tk::x = $Ev->x;
             $Tk::y = $Ev->y;
             $w->SelectTo($Ev->xy)
            }
           )
 ;
 $mw->bind($class,"<Double-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->SelectTo($Ev->xy,'word');
             Tk::catch { $w->markSet('insert',"sel.first") }
            }
           )
 ;
 $mw->bind($class,"<Triple-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->SelectTo($Ev->xy,'line');
             Tk::catch { $w->markSet('insert',"sel.first") };
            }
           )
 ;
 $mw->bind($class,"<Shift-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->ResetAnchor($Ev->xy);
             $w->SelectTo($Ev->xy,'char')
            }
           )
 ;
 $mw->bind($class,"<Double-Shift-1>",['SelectTo',Ev('@'),'word']);
 $mw->bind($class,"<Triple-Shift-1>",['SelectTo',Ev('@'),'line']);

 $mw->bind($class,"<B1-Leave>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $Tk::x = $Ev->x;
             $Tk::y = $Ev->y;
             $w->AutoScan;
            }
           )
 ;

 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<ButtonRelease-1>",'CancelRepeat');
 $mw->bind($class,"<Control-1>",["markSet",'insert',Ev('@')]);

 $mw->bind($class,"<Left>",['SetCursor',Ev('index',"insert-1c")]);
 $mw->bind($class,"<Shift-Left>",['KeySelect',Ev('index',"insert-1c")]);
 $mw->bind($class,"<Control-Left>",['SetCursor',Ev('index',"insert-1c wordstart")]);
 $mw->bind($class,"<Shift-Control-Left>",['KeySelect',Ev('index',"insert-1c wordstart")]);

 $mw->bind($class,"<Right>",['SetCursor',Ev('index',"insert+1c")]);
 $mw->bind($class,"<Shift-Right>",['KeySelect',Ev('index',"insert+1c")]);
 $mw->bind($class,"<Control-Right>",['SetCursor',Ev('index',"insert+1c wordend")]);
 $mw->bind($class,"<Shift-Control-Right>",['KeySelect',Ev('index',"insert wordend")]);

 $mw->bind($class,"<Up>",['SetCursor',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Shift-Up>",['KeySelect',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Control-Up>",['SetCursor',Ev('PrevPara','insert')]);
 $mw->bind($class,"<Shift-Control-Up>",['KeySelect',Ev('PrevPara','insert')]);

 $mw->bind($class,"<Down>",['SetCursor',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Shift-Down>",['KeySelect',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Control-Down>",['SetCursor',Ev('NextPara','insert')]);
 $mw->bind($class,"<Shift-Control-Down>",['KeySelect',Ev('NextPara','insert')]);

 $mw->bind($class,"<Home>",['SetCursor',"insert linestart"]);
 $mw->bind($class,"<Shift-Home>",['KeySelect',"insert linestart"]);
 $mw->bind($class,"<Control-Home>",['SetCursor','1.0']);
 $mw->bind($class,"<Control-Shift-Home>",['KeySelect','1.0']);

 $mw->bind($class,"<End>",['SetCursor',"insert lineend"]);
 $mw->bind($class,"<Shift-End>",['KeySelect',"insert lineend"]);
 $mw->bind($class,"<Control-End>",['SetCursor',"end-1char"]);
 $mw->bind($class,"<Control-Shift-End>",['KeySelect',"end-1char"]);

 $mw->bind($class,"<Prior>",['SetCursor',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Shift-Prior>",['KeySelect',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Control-Prior>",['xview','scroll',-1,'page']);

 $mw->bind($class,"<Next>",['SetCursor',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Shift-Next>",['KeySelect',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Control-Next>",['xview','scroll',1,'page']);

 $mw->bind($class,"<Shift-Tab>", 'NoOp'); # Needed only to keep <Tab> binding from triggering; does not have to actually do anything.
 $mw->bind($class,"<Control-Tab>",'focusNext');
 $mw->bind($class,"<Control-Shift-Tab>",'focusPrev');

 $mw->bind($class,"<Control-space>",["markSet",'anchor','insert']);
 $mw->bind($class,"<Select>",["markSet",'anchor','insert']);
 $mw->bind($class,"<Control-Shift-space>",['SelectTo','insert','char']);
 $mw->bind($class,"<Shift-Select>",['SelectTo','insert','char']);
 $mw->bind($class,"<Control-slash>",['tag','add','sel','1.0','end']);
 $mw->bind($class,"<Control-backslash>",['tag','remove','sel','1.0','end']);

 if (!$Tk::strictMotif)
  {
   $mw->bind($class,"<Control-a>",    ['SetCursor',"insert linestart"]);
   $mw->bind($class,"<Control-b>",    ['SetCursor',"insert-1c"]);
   $mw->bind($class,"<Control-e>",    ['SetCursor',"insert lineend"]);
   $mw->bind($class,"<Control-f>",    ['SetCursor',"insert+1c"]);
   $mw->bind($class,"<Meta-b>",       ['SetCursor',"insert-1c wordstart"]);
   $mw->bind($class,"<Meta-f>",       ['SetCursor',"insert wordend"]);
   $mw->bind($class,"<Meta-less>",    ['SetCursor','1.0']);
   $mw->bind($class,"<Meta-greater>", ['SetCursor',"end-1c"]);

   $mw->bind($class,"<Control-n>",    ['SetCursor',Ev('UpDownLine',1)]);
   $mw->bind($class,"<Control-p>",    ['SetCursor',Ev('UpDownLine',-1)]);

   $mw->bind($class,"<2>",['Button2',Ev('x'),Ev('y')]);
   $mw->bind($class,"<B2-Motion>",['Motion2',Ev('x'),Ev('y')]);

  }
 $mw->bind($class,"<Destroy>",'Destroy');
 return $class;
}

# end of Tk::Text::bindRdOnly
1;
