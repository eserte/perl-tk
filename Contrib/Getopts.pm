package Tk::Getopts;
require Tk::Toplevel;

@ISA = qw(Tk::Toplevel);

# Sanction this class.
Tk::Widget->Construct('Getopts');

use Tk;
use English;

# Variables global to this package.
my($w, $waitvar) = 0;

###############################################################################
##
## Tk::Getopts::new() - Create a new options dialog.
##
## Usage: $status = $parent->Getopts(\%subenv, $title, \@options, $help, @args);
##
## Input:
##
## $parent =  The parent widget.
## $class  =  Passed in automagically.
## %subenv =  An variable environment structure stored in a hashed array.
##            I hate stuff that automatically writes to $opt_name variables.
##            This way I only overwrite variables when I call the (at present
##            undefined, import function) and I have the option of keeping
##            separate Getopts results stored within seperate subenvs. Am I
##            making sense?
## $title   = The title of the dialog.
## @options = My available options.
## $help    = A string containing the help file.  Needs to be, and will be
##            when I get around to it, scrolled.
## @args    = Any configuration arguments for all windows.  Easy way to send
##            in arguments you wish to apply to the configuration of all
##            components of a Getopts dialog.
##
#
#  Please note that this is still under construction and was the result of
#  a quick and dirty programming session last night.  I just wanted to
#  solicit opinion from the perl community at large.  Send opinions and/or
#  suggestions to pat@advance.com.
#
###############################################################################

sub new
{
   my($class, $parent, $subenv, $title, $options, $help, @args) = @ARG;
   my($type, $nchecks);
   my(%opts) = process_options(@$options);

   my(@entry_keys, %entrys);
   my(@check_keys, %checks);
   my(@scale_keys, %scales);
   my($type, $key);

   my($nchecks, $nentrys, $nscales);
   $nchecks = $nentrys = $nscales = 0;

   $parent->withdraw;
   $w = $parent->Toplevel(-class => 'Getopts', -bg => "grey", @args);
   $w->title($title);
   $w->iconname("Getopts");

   # Default routines to tie to our buttons.  May be overridden.
   my($action_accept) = \&Getopts_Accept;
   my($action_cancel) = \&Getopts_Cancel;
   my($action_help) = [ \&Getopts_Help, $help ];

   # The Label.
   my($label) = $w->Label(-fg => "black", -bg => "grey", -relief => "sunken",
			  @args);
   $label->configure("-text" => "Getopts Interactive Options Selector");
   $label->pack("-fill" => "x");

   @check_keys = @entry_keys = @scale_keys = ();
   %entrys = %checks = %scales = ();

   foreach $key (keys %opts)
   {
      $type = $opts{$key}->{'Type'};

      $check_keys[++$#check_keys] = "$key" if ($type eq "Checkbox");
      $entry_keys[++$#entry_keys] = "$key" if ($type eq "Entry");
      $scale_keys[++$#scale_keys] = "$key" if ($type eq "Scale");
   }

   if ($#check_keys > -1)
   {
      $check_frame = $w->Frame(-bg => "grey", @args);

      $check_label = $w->Label(-text => "Checkbox Options:",
			       -relief => "raised", -bg => "grey",
			       -fg => "black", @args);
      $check_label->pack("-fill" => "x");

      my($text_len, $nbfs);
      $text_len = $nbfs = 0;

      $check_subframes[$nbfs] = $check_frame->Frame(-bg => "grey", @args);

      foreach $key (@check_keys)
      {
	 $$subenv{$key} = 0;

	 $text_len += length($key);

	 if ($text_len > 80 && length($key) < 80)
	 {
	    $text_len = length($key);
	    $check_subframes[$nbfs]->pack(-fill => "x");

	    $check_subframes[++$nbfs] =
	       $check_frame->Frame(-bg => "grey", @args);
	 }

	 $check->[++$nchecks] =
	    $check_subframes[$nbfs]->Checkbutton(-text => $key,
					       "-fg" => "black",
					       "-bg" => "grey",
					       "-variable" => \$$subenv{$key},
					       "-onvalue" => 1,
					       "-offvalue" => 0,
					       "-anchor" => "w", @args);

	 $check->[$nchecks]->pack("-side" => "left", "-fill" => "x",
				"-expand" => 1);
      }
      $check_subframes[$nbfs]->pack(-fill => "x");
      $check_frame->pack(-fill => "x");
   }

   if ($#scale_keys > -1)
   {
      $scale_frame = $w->Frame(-bg => "grey", @args);

      $scale_label = $w->Label("-text" => "Scale/Slider Options:",
			       -relief => "raised", -bg => "grey",
			       -fg => "black", @args);
      $scale_label->pack("-fill" => "x");

      foreach $key (@scale_keys)
      {
	 $$subenv{$key} = 0;

	 foreach $opt (@{$opts{$key}->{'Options'}})
	 {
	    print "OPT: $opt\n";
	 }

	 $scales->[$nscales] =
	    $scale_frame->Scale(-label => "$key",
				ORIENTATION => "horizontal",
				-fg => "black", -bg => "grey",
				@{$opts{$key}->{'Options'}});

	 $scales->[$nscales]->configure(-command=>[\&ScaleSet,\$$subenv{$key}]);

	 $scales->[$nscales]->pack(-side => "left", -expand => 1);
      }
      $scale_frame->pack(-fill => "x", -expand => 1);
   }

   if ($#entry_keys > -1)
   {
      $entry_frame = $w->Frame(@args);

      $entry_label = $w->Label("-text" => "Type In Options:",
				-relief => "raised",
				"-bg" => "grey", "-fg" => "black", @args);
      $entry_label->pack("-fill" => "x");

      foreach $key (@entry_keys)
      {
	 $$subenv{$key} = "";
	 $entry_lframes->[++$nentrys] =
	    $entry_frame->Frame(-bg => "grey", @args);

	 $entry_labels->[$nentrys] =
	    $entry_lframes->[$nentrys]->Label(-text => "$key: ",
					      -relief => "raised",
					      -bg => "grey",
					      -fg => "black", @args);

	 $entrys->[$nentrys] =
	    $entry_lframes->[$nentrys]->Entry(-text => \$$subenv{$key},
					       -width => 40,
					       -relief => "sunken",
					       -fg => "black",
					       -bg => "grey", @args);

	 $entry_labels->[$nentrys]->pack(-side => "left", -expand => 1);
	 $entrys->[$nentrys]->pack(-side => "left", -expand => 1);
	 $entry_lframes->[$nentrys]->pack(-fill => "x");
      }
      $entry_frame->pack(-fill => "x");
   }

   # The Accept Button.
   my($accept) = $w->Button("-text" => "Accept", "-bg" => "grey",
			    "-fg" => "darkgreen", @args);
   $accept->pack(-side => "left", -expand => 1);
   $accept->bind("<1>", $action_accept);

   # The Help Button.
   my($help) = $w->Button("-text" => "Help", "-bg" => "grey",
			    "-fg" => "darkgreen", @args);
   $help->pack(-side => "left", -expand => 1);
   $help->bind("<1>", $action_help);

   # The Cancel Button.
   my($cancel) = $w->Button("-text" => "Cancel", "-fg" => "red",
			    "-bg" => "grey", @args);
   $cancel->pack(-side => "left", -expand => 1);
   $cancel->bind("<1>", $action_cancel);

   $w->{'Label'} = $label;
   $w->{'Cancel'} = $cancel;
   $w->{'Accept'} = $accept;

   tkwait('variable', \$waitvar);
}

# Default accept function.
sub Getopts_Accept
{
   $waitvar = 1;
}

# Default cancel function.
sub Getopts_Cancel
{
   $waitvar = 0;
}

sub Getopts_Help
{
   my($class, $help, @args) = @ARG;

   my($top) = $w->Toplevel(-class => 'Getopts', -bg => "grey", @args);
   $top->title("Getopts Help");
   $top->iconname("Getopts_Help");

   my($text) = $top->Text(-bg => "grey", -fg => "black", @args);

   $text->Insert("$help\n");

   $text->pack(-expand => 1);
}

sub ScaleSet
{
   my($ref, $val) = @ARG;
   $$ref = "$val";
}

sub process_options
{
   my(@options) = @ARG;
   my(%ret_struct) = ();

   sub set_options
   {
      my($info, $ref) = @ARG;
      my($opt, $flag, $setting);

      foreach $opt (grep(/=>/, split(/:/, $info)))
      {
	 $opt =~ /^(\S+)=>(\S+)$/;
	 $flag = $1;
	 $setting = $2;
	 $flag = ($flag =~ /^\-/) ? $flag : "-".lc($flag);

	 print "Setting Option: $1 => $2\n";
	 if (!defined($$ref->{'Options'}))
	 {
	    $$ref->{'Options'} = [ $flag => $setting ];
	 }
	 else
	 {
	    $$ref->{'Options'} = [ @{$$ref->{'Options'}}, $flag => $setting ];
	 }
      }
   }

   foreach (@options)
   {
      next unless (/(\w+)=(\S*)/);
      
      $var = $1;
      $varinfo = $2;

      print "VAR: $var - VARINFO: $varinfo\n";

      if ($varinfo =~ "Checkbox(.*)")
      {
	 $ret_struct{$var}->{'Type'} = "Checkbox";
	 set_options($1, \$ret_struct{$var});
	 next;
      }

      if ($varinfo =~ /^Entry(.*)/)
      {
	 $ret_struct{$var}->{'Type'} = "Entry";
	 $ret_struct{$var}->{'Pattern'} = "$2";
	 set_options($1, \$ret_struct{$var});
	 next;
      }

      if ($varinfo =~ /^Scale(.*)/)
      {
	 my($nscaleopts) = -1;
	 $ret_struct{$var}->{'Type'} = "Scale";
	 set_options($1, \$ret_struct{$var});
      }
   }

   return(%ret_struct);
}

1;
