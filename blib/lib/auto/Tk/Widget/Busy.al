# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Busy
{
 my ($w,%args) = @_;
 return unless $w->viewable;
 $args{'-cursor'} = 'watch' unless (exists $args{'-cursor'});
 unless (exists $w->{'Busy'})
  {
   my %old = ();           
   my $key;                
   my @tags = $w->bindtags;
   foreach $key (keys %args)
    {
     $old{$key} = $w->Tk::cget($key);
    }
   $old{'bindtags'} = \@tags;
   $old{'grab'}     = $w->grabSave;
   unless ($w->Tk::bind('Busy'))
    {                     
     $w->Tk::bind('Busy','<KeyPress>','bell');
     $w->Tk::bind('Busy','<ButtonPress>','bell');
    }                     
   $w->bindtags(['Busy']);
   $w->{'Busy'} = \%old;
  }
 $w->Tk::configure(%args);
 eval {local $SIG{'__DIE__'};  $w->grab };
 $w->update;
}

1;
