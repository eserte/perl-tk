# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 217 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/ClassInit.al)"
sub ClassInit
{
 my ($class,$mw) = @_;
 $class->SUPER::ClassInit($mw);

 $class->bindRdOnly($mw);

 $mw->bind($class,"<Tab>", sub { my $w = shift; $w->Insert("\t"); $w->focus; $w->break});

 $mw->bind($class,"<Control-i>", ['Insert',"\t"]);
 $mw->bind($class,"<Return>", ['Insert',"\n"]);
 $mw->bind($class,"<Delete>",'Delete');
 $mw->bind($class,"<BackSpace>",'Backspace');


 $mw->bind($class,"<Insert>",
            sub
            {
             my $w = shift;
             Tk::catch { $w->Insert($w->SelectionGet) }
            }
           )
 ;
 $mw->bind($class,"<KeyPress>",['Insert',Ev('A')]);
 # Additional emacs-like bindings:

 if (!$Tk::strictMotif)
  {

   $mw->bind($class,"<Control-d>",['delete','insert']);
   $mw->bind($class,"<Control-k>",
              sub
              {
               my $w = shift;
               if ($w->compare('insert',"==","insert lineend"))
                {
                 $w->delete('insert')
                }
               else
                {
                 $w->delete('insert',"insert lineend")
                }
              }
             )
   ;
   $mw->bind($class,"<Control-o>",
              sub
              {
               my $w = shift;
               $w->insert('insert',"\n");
               $w->markSet('insert',"insert-1c")
              }
             )
   ;
   $mw->bind($class,"<Control-t>",'Transpose');
   $mw->bind($class,"<Meta-d>",['delete','insert','insert wordend']);
   $mw->bind($class,"<Meta-BackSpace>",['delete','insert-1c wordstart','insert']);

   # A few additional bindings of my own.
   $mw->bind($class,"<Control-h>",
              sub
              {
               my $w = shift;
               if ($w->compare('insert',"!=",'1.0'))
                {
                 $w->delete("insert-1c");
                 $w->see('insert')
                }
              }
             )
   ;
   $mw->bind($class,"<ButtonRelease-2>",
              sub
              {
               my $w = shift;
               my $Ev = $w->XEvent;
               if (!$Tk::mouseMoved)
                {
                 Tk::catch
                  {
                   $w->insert($Ev->xy,$w->SelectionGet);
                  }
                }
              }
             )


  }
 $Tk::prevPos = undef;
 return $class;
}

# end of Tk::Text::ClassInit
1;
