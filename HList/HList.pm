package Tk::HList; 

use vars qw($VERSION @ISA);
$VERSION = '3.006'; # $Id: //depot/Tk8/HList/HList.pm#6$

use Tk qw(Ev);

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'HList';
sub Tk::Widget::ScrlHList { shift->Scrolled('HList'=>@_) }

bootstrap Tk::HList $Tk::VERSION; 

sub Tk_cmd { \&Tk::hlist }

sub CreateArgs
{
 my ($package,$parent,$args) = @_;
 my @result = $package->SUPER::CreateArgs($parent,$args);
 my $columns = delete $args->{-columns};                     
 push(@result, '-columns' => $columns) if (defined $columns);
 return @result;
}

EnterMethods Tk::HList __FILE__,qw(add addchild anchor column
                                   delete dragsite dropsite entrycget
                                   entryconfigure geometryinfo indicator header hide item info
                                   nearest see select selection show xview yview);

use Tk::Submethods ( 'delete' => [qw(all entry offsprings siblings)],
                     'header' => [qw(configure cget create delete exists size)],
                     'indicator' => [qw(configure cget create delete exists size)],
                     'info' => [qw(anchor bbox children data dragsite
                                   dropsite exists hidden item next parent prev)],
                     'item' => [qw(configure cget create delete exists)],
                     'selection' => [qw(clear get includes set)],
                     'anchor' => [qw(clear set)],
                     'column' => [qw(width)],
                   );


sub ClassInit
{
 my ($class,$mw) = @_;

 $mw->bind($class,'<ButtonPress-1>',[ 'Button1' ] );
 $mw->bind($class,'<Shift-ButtonPress-1>',[ 'ShiftButton1' ] );
 $mw->bind($class,'<Control-ButtonRelease-1>', sub {} );
 $mw->bind($class,'<ButtonRelease-1>',
		sub
		 {
		  my $w = shift;
		  my $Ev = $w->XEvent;

		  $w->CancelRepeat
		      if($w->cget('-selectmode') ne "dragdrop");
		  $w->ButtonRelease1($Ev);
		 });
 $mw->bind($class,'<B1-Motion>',[ 'Button1Motion' ] );
 $mw->bind($class,'<B1-Leave>',[ 'AutoScan' ] );

 $mw->bind($class,'<Double-ButtonPress-1>',['Double1']);

 $mw->bind($class,'<Control-B1-Motion>', sub {} );
 $mw->bind($class,'<Control-ButtonPress-1>',['CtrlButton1']);
 $mw->bind($class,'<Control-Double-ButtonPress-1>',['CtrlButton1']);

 $mw->bind($class,'<B1-Enter>',
		sub
		 {
		  my $w = shift;
		  my $Ev = $w->XEvent;
		  $w->CancelRepeat
		      if($w->cget('-selectmode') ne "dragdrop");
		 });

 $mw->bind($class,'<Up>',['UpDown', 'prev']);
 $mw->bind($class,'<Down>',['UpDown', 'next']);

 $mw->bind($class,'<Shift-Up>',['ShiftUpDown', 'prev']);
 $mw->bind($class,'<Shift-Down>',['ShiftUpDown', 'next']);

 $mw->bind($class,'<Left>', ['LeftRight', 'left']);
 $mw->bind($class,'<Right>',['LeftRight', 'right']);

 $mw->bind($class,'<Prior>', sub {shift->yview('scroll', -1, 'pages') } );
 $mw->bind($class,'<Next>',  sub {shift->yview('scroll',  1, 'pages') } );

 $mw->bind($class,'<Return>', ['KeyboardActivate']);
 $mw->bind($class,'<space>',  ['KeyboardBrowse']);
 $mw->bind($class,'<Home>',   ['KeyboardHome']);

 return $class;
}

sub Button1
{
 my $w = shift;
 my $Ev = $w->XEvent;

 delete $w->{'shiftanchor'}; 
 delete $w->{tixindicator}; 

 $w->focus()
    if($w->cget("-takefocus"));

 my $mode = $w->cget("-selectmode");

 if ($mode eq "dragdrop")
  {
   # $w->Send_WaitDrag($Ev->y);
   return;
  }

 my $ent = $w->GetNearest($Ev->y);

 return unless (defined($ent) and length($ent));

 my @info = $w->info('item',$Ev->x, $Ev->y);
 if (@info)
  {
   die "Assert" unless $info[0] eq $ent;
  }
 else
  {
   @info = $ent;
  }

 if (defined($info[1]) && $info[1] eq 'indicator')
  {
   $w->{tixindicator} = $ent;
   $w->EventType( "<Arm>" );
   $w->Callback(-indicatorcmd => $ent);
  }
 else
  {
   my $browse = 0;
     
   if($mode eq "single")
    {
     $w->anchor('set', $ent);
    }
   elsif($mode eq "browse")
    {
     $w->anchor('set', $ent);
     $w->select('clear' );
     $w->select('set', $ent);
     $browse = 1;
    }
   elsif($mode eq "multiple")
    {
     $w->select('clear');
     $w->anchor('set', $ent);
     $w->select('set', $ent);
     $browse = 1;
    }
   elsif($mode eq "extended")
    {
     $w->anchor('set', $ent);
     $w->select('clear');
     $w->select('set', $ent);
     $browse = 1;
    }
     
   if ($browse)
    {
     $w->Callback(-browsecmd => @info);
    }
  }
}

sub ShiftButton1
{
 my $w = shift;
 my $Ev = $w->XEvent;

 my $to = $w->GetNearest($Ev->y);

 delete $w->{'shiftanchor'}; 
 delete $w->{tixindicator}; 

 return unless (defined($to) and length($to));

 my $mode = $w->cget('-selectmode');

 if($mode eq "extended")
  {
   my $from = $w->info('anchor');
   if($from)
    {
     $w->select('clear');
     $w->select('set', $from, $to);
    }
   else
    {
     $w->anchor('set', $to);
     $w->select('clear');
     $w->select('set', $to);
    }
  }
}

sub GetNearest
{
 my ($w,$y) = @_;
 my $ent = $w->nearest($y);
 if (defined $ent)
  {
   my $state = $w->entrycget($ent, '-state');
   return $ent if (!defined($state) || $state ne 'disabled');
  }
 return undef;
}

sub ButtonRelease1
{
 my ($w, $Ev) = @_;

 delete $w->{'shiftanchor'}; 

 my $mode = $w->cget('-selectmode');

 if($mode eq "dragdrop")
  {
#   $w->Send_DoneDrag();
   return;
  }

 my ($x, $y) = ($Ev->x, $Ev->y);
 my $ent = $w->GetNearest($y);

 return unless (defined($ent) and length($ent));

 if($w->{tixindicator})
  {
   return unless delete($w->{tixindicator}) eq $ent;
   my @info = $w->info('item',$Ev->x, $Ev->y);
   if(defined($info[1]) && $info[1] eq 'indicator')
    {
     $w->EventType( "<Activate>" );
     $w->Callback(-indicatorcmd => $ent);
    }
   return;
  }

 if($x < 0 || $y < 0 || $x > $w->width || $y > $w->height)
  {
   $w->select('clear');

   return if($mode eq "single" || $mode eq "browse")

  }
 else
  {
   if($mode eq "single" || $mode eq "browse")
    {
     $w->anchor('set', $ent);
     $w->select('clear');
     $w->select('set', $ent);

    }
   elsif($mode eq "multiple")
    {
     $w->select('set', $ent);
    }
   elsif($mode eq "extended")
    {
     $w->select('set', $ent);
    }
  }

 $w->Callback(-browsecmd =>$ent);
}

sub Button1Motion
{
 my $w = shift;
 my $Ev = $w->XEvent;

 delete $w->{'shiftanchor'}; 

 my $mode = $w->cget('-selectmode');

 if ($mode eq "dragdrop")
  {
#   $w->Send_StartDrag();
   return;
  }

 my $ent = $w->GetNearest($Ev->y);
 return unless (defined($ent) and length($ent));

 if($w->{tixindicator})
  {
   $w->EventType( $w->{tixindicator} eq $ent ? "<Arm>" : "<Disarm>" );
   $w->Callback(-indicatorcmd => $w->{tixindicator});
   return;
  }

 if ($mode eq "single")
  {
   $w->anchor('set', $ent);
  }
 elsif ($mode eq "multiple" || $mode eq "extended")
  {
   my $from = $w->info('anchor');
   if($from)
    {
     $w->select('clear');
     $w->select('set', $from, $ent);
    }
   else
    {
     $w->anchor('set', $ent);
     $w->select('clear');
     $w->select('set', $ent);
    }
  }

 if ($mode ne "single")
  {
   $w->Callback(-browsecmd =>$ent);
  }
}

sub Double1
{
 my $w = shift;
 my $Ev = $w->XEvent;

 delete $w->{'shiftanchor'}; 

 my $ent = $w->GetNearest($Ev->y);

 return unless (defined($ent) and length($ent));

 $w->anchor('set', $ent)
	unless($w->info('anchor'));

 $w->select('set', $ent);
 $w->Callback(-command => $ent);
}

sub CtrlButton1
{
 my $w = shift;
 my $Ev = $w->XEvent;

 delete $w->{'shiftanchor'}; 

 my $ent = $w->GetNearest($Ev->y);

 return unless (defined($ent) and length($ent));

 my $mode = $w->cget('-selectmode');

 if($mode eq "extended")
  {
   $w->anchor('set', $ent) unless( $w->info('anchor') );

   if($w->select('includes', $ent))
    {
     $w->select('clear', $ent);
    }
   else
    {
     $w->select('set', $ent);
    }
   $w->Callback(-browsecmd =>$ent);
  }
}

sub UpDown
{
 my $w = shift;
 my $spec = shift;

 my $done = 0;
 my $anchor = $w->info('anchor');

 delete $w->{'shiftanchor'}; 

 unless( $anchor )
  {
   $anchor = ($w->info('children'))[0] || "";

   return unless (defined($anchor) and length($anchor));

   if($w->entrycget($anchor, '-state') ne "disabled")
    {
     # That's a good anchor
     $done = 1;
    }
   else
    {
     # We search for the first non-disabled entry (downward)
     $spec = 'next';
    }
  }

 my $ent = $anchor;

 # Find the prev/next non-disabled entry
 #
 while(!$done)
  {
   $ent = $w->info($spec, $ent);
   last unless( $ent );
   next if( $w->entrycget($ent, '-state') eq "disabled" );
   next if( $w->info('hidden', $ent) );
   last;
  }

 unless( $ent )
  {
   $w->yview('scroll', $spec eq 'prev' ? -1 : 1, 'unit');
   return;
  }

 $w->anchor('set', $ent);
 $w->see($ent);

 if($w->cget('-selectmode') ne "single")
  {
   $w->select('clear');
   $w->selection('set', $ent);
   $w->Callback(-browsecmd =>$ent);
  }
}

sub ShiftUpDown
{
 my $w = shift;
 my $spec = shift;

 my $mode = $w->cget('-selectmode');

 return $w->UpDown($spec)
   if($mode eq "single" || $mode eq "browse");

 my $anchor = $w->info('anchor');

 return $w->UpDown($spec) unless (defined($anchor) and length($anchor));

 my $done = 0;

 $w->{'shiftanchor'} = $anchor unless( $w->{'shiftanchor'} ); 

 my $ent = $w->{'shiftanchor'};

 while( !$done )
  {
   $ent = $w->info($spec, $ent);
   last unless( $ent );
   next if( $w->entrycget($ent, '-state') eq "disabled" );
   next if( $w->info('hidden', $ent) );
   last;
  }

 unless( $ent )
  {
   $w->yview('scroll', $spec eq 'prev' ? -1 : 1, 'unit');
   return;
  }

 $w->select('clear');
 $w->selection('set', $anchor, $ent);
 $w->see($ent);

 $w->{'shiftanchor'} = $ent; 
 
 $w->Callback(-browsecmd =>$ent);
}

sub LeftRight
{
 my $w = shift;
 my $spec = shift;

 delete $w->{'shiftanchor'}; 

 my $anchor = $w->info('anchor');

 unless($anchor)
  {
   $anchor = ($w->info('children'))[0] || "";
  }

 my $done = 0;
 my $ent = $anchor;

 while(!$done)
  {
   my $e = $ent;

   if($spec eq "left")
    {
     $ent = $w->info('parent', $e);

     $ent = $w->info('prev', $e)
       unless($ent && $w->entrycget($ent, '-state') ne "disabled")
    }
   else
    {
     $ent = ($w->info('children', $e))[0];

     $ent = $w->info('next', $e)
       unless($ent && $w->entrycget($ent, '-state') ne "disabled")
    }

   last unless( $ent );
   last if($w->entrycget($ent, '-state') ne "disabled");
  }

 unless( $ent )
  {
   $w->xview('scroll', $spec eq "left" ? -1 : 1, 'unit');
   return;
  }

 $w->anchor('set', $ent);
 $w->see($ent);

 if($w->cget('-selectmode') ne "single")
  {
   $w->select('clear');
   $w->selection('set', $ent);

   $w->Callback(-browsecmd =>$ent);
  }
}   

sub KeyboardHome
{
 my $w = shift;
 $w->yview('moveto' => 0);
 $w->xview('moveto' => 0);
}

sub KeyboardActivate
{
 my $w = shift;

 my $anchor = $w->info('anchor');

 return unless (defined($anchor) and length($anchor));

 if($w->cget('-selectmode'))
  {
   $w->select('clear');
   $w->select('set', $anchor);
  }
 $w->Callback(-command => $anchor);
}

sub KeyboardBrowse
{
 my $w = shift;

 my $anchor = $w->info('anchor');

 return unless (defined($anchor) and length($anchor));

 if ($w->indicatorExists($anchor))
  {
   $w->Callback(-indicatorcmd => $anchor);
  }

 if($w->cget('-selectmode'))
  {
   $w->select('clear');
   $w->select('set', $anchor);
  }
 $w->Callback(-browsecmd =>$anchor);
}

sub AutoScan
{
 my $w = shift;

 return if($w->cget('-selectmode') eq "dragdrop");
 
 my $Ev = $w->XEvent;
 my $y = $Ev->y;
 my $x = $Ev->x;

 if($y >= $w->height)
  {
   $w->yview('scroll', 1, 'units');
  }
 elsif($y < 0)
  {
   $w->yview('scroll', -1, 'units');
  }
 elsif($x >= $w->width)
  {
   $w->xview('scroll', 2, 'units');
  }
 elsif($x < 0)
  {
   $w->xview('scroll', -2, 'units');
  }
 else
  {
   return;
  }
 $w->RepeatId($w->after(50,"AutoScan",$w));
 $w->Button1Motion;
}

sub children
{
 # Tix has core-tk window(s) which are not a widget(s)
 # the generic code returns these as an "undef"
 my $w = shift;
 my @info = grep(defined($_),$w->winfo('children'));
 @info;
}

1;

