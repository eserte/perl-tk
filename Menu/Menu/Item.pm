package Tk::Menu::Item;

require Tk::Menu;

use Carp;
use strict;

sub PreInit
{
 # Dummy (virtual) method
 my ($class,$menu,$minfo) = @_;
}

sub new
{
 my ($class,$menu,%minfo) = @_;
 my $kind = $class->kind;
 my $name = $minfo{'-label'};
 if (defined $kind)
  {
   my $invoke = delete $minfo{'-invoke'};
   if (defined $name)
    {
     # Use ~ in name/label to set -underline
     if (defined($minfo{-label}) && !defined($minfo{-underline}))
      {
       my $cleanlabel = $minfo{-label};
       my $underline = ($cleanlabel =~ s/^(.*)~/$1/) ? length($1): undef;
       if (defined($underline) && ($underline >= 0))
        {
         $minfo{-underline} = $underline;
         $name = $cleanlabel if ($minfo{-label} eq $name);
         $minfo{-label} = $cleanlabel;
        }
      }
    }
   else
    {
     $name = $minfo{'-bitmap'} || $minfo{'-image'};
     croak("No -label") unless defined($name);
     $minfo{'-label'} = $name;
    }
   $class->PreInit($menu,\%minfo);    
   $menu->add($kind,%minfo);          
   $menu->invoke('last') if ($invoke);
  }
 else
  {
   $menu->add('separator');
  }
 return bless [$menu,$name],$class;
} 

sub configure
{
 my $obj = shift;
 my ($menu,$name) = @$obj;
 $menu->entryconfigure($name,@_);
}

sub cget
{
 my $obj = shift;
 my ($menu,$name) = @$obj;
 $menu->entrycget($name,@_);
}

sub parentMenu
{
 my $obj = shift;
 return $obj->[0];
}

# Default "kind" is a command
sub kind { return 'command' }

# Now the derived packages 

package Tk::Menu::Separator;
@Tk::Menu::Separator::ISA = qw(Tk::Menu::Item);
Construct Tk::Menu 'Separator';
sub kind { return undef }

package Tk::Menu::Button;
@Tk::Menu::Button::ISA = qw(Tk::Menu::Item);
Construct Tk::Menu 'Button';

package Tk::Menu::Command;
@Tk::Menu::Command::ISA = qw(Tk::Menu::Button);
Construct Tk::Menu 'Command';

package Tk::Menu::Cascade;
@Tk::Menu::Cascade::ISA = qw(Tk::Menu::Item);
Construct Tk::Menu 'Cascade';
sub kind { return 'cascade' }

sub PreInit
{
 my ($class,$menu,$minfo) = @_;
 my $tearoff   = delete $minfo->{-tearoff};
 my $items     = delete $minfo->{-menuitems};
 my $widgetvar = delete $minfo->{-menuvar};
 my @args = ();
 push(@args, '-tearoff' => $tearoff) if (defined $tearoff);
 push(@args, '-menuitems' => $items) if (defined $items);
 my $submenu = $menu->Menu(@args);
 $minfo->{'-menu'} = $submenu;
 $$widgetvar = $submenu if (defined($widgetvar) && ref($widgetvar));
}

sub menu
{
 my ($self,%args) = @_;
 my $w = $self->parentMenu;
 my $menu = $self->cget('-menu');
 if (!defined $menu)
  {
   require Tk::Menu;
   $w->ColorOptions(\%args); 
   $menu = $w->Menu(%args);
   $self->configure('-menu'=>$menu);
  }
 else
  {
   $menu->configure(%args);
  }
 return $menu;
}

package Tk::Menu::Checkbutton;
@Tk::Menu::Checkbutton::ISA = qw(Tk::Menu::Item);
Construct Tk::Menu 'Checkbutton';
sub kind { return 'checkbutton' }

package Tk::Menu::Radiobutton;
@Tk::Menu::Radiobutton::ISA = qw(Tk::Menu::Item);
Construct Tk::Menu 'Radiobutton';
sub kind { return 'radiobutton' }

package Tk::Menu::Item;

1;
__END__

=head1 NAME

Tk::Menu::Item - Base class for Menu items

=head1 SYNOPYSIS

   require Tk::Menu::Item;

   my $but = $menu->Button(...);
   $but->configure(...);
   my $what = $but->cget();

   package Whatever;
   require Tk::Menu::Item;
   @ISA = qw(Tk::Menu::Item);

   sub PreInit
   {
    my ($class,$menu,$info) = @_;
    $info->{'-xxxxx'} = ...
    my $y = delete $info->{'-yyyy'};
   }

=head1 DESCRIPTION

Tk::Menu::Item is the base class from which Tk::Menu::Button,
Tk::Menu::Cascade, Tk::Menu::Radiobutton and Tk::Menu::Checkbutton are derived.
There is also a Tk::Menu::Separator.

Constructors are declared so that $menu-E<gt>Button(...) etc. do what you would 
expect. 

The C<-label> option is pre-processed allowing ~ to be prefixed to the character
to derive a C<-underline> value. Thus

    $menu->Button(-label => 'Goto ~Home',...)

    is equivalent to 

    $menu->Button(-label => 'Goto Home', -underline => 6, ...)

C<Cascade> accepts C<-menuitems> which is a list of items for the sub-menu.
Within this list (which is also accepted by Menu and Menubutton) the first
two elements of each item should be the "constructor" name and the label:

    -menuitems => [
                   [Button      => '~Quit', -command => [destroy => $mw]],
                   [Checkbutton => '~Oil',  -variable => \$oil], 
                  ] 

Also C<-tearoff> is propagated to the submenu, and C<-menuvar> (if present) 
is set to the created sub-menu.

The returned object is currently a blessed reference to an array of two items:
the containing Menu and the 'label'. 
Methods C<configure> and C<cget> are mapped onto underlying C<entryconfigure>
and C<entrycget>.

The main purpose of the OO interface is to allow derived item classes to 
be defined which pre-set the options used to create a more basic item.


=head1 BUGS

This OO interface is very new. Using the label as the "key" is a problem
for separaror items which don't have one. The alternative would be to 
use an index into the menu but that is a problem if items are deleted
(or inserted other than at the end).

There should probably be a PostInit entry point too, or a more widget like
defered 'configure'.

=cut


