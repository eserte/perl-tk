#include "Tk.hh"

int 
main(int argc,char *argv[])
{
 MainWindow *mw = new MainWindow();
 Button *b = new Button(mw, "-text", "Hello World",  NULL);
 // b->configure("-command", new TkCallback(mw,TkWidget::destroy), NULL);
 b->pack("-side","top",NULL);
 Tk_MainLoop();
 return 0;
}
