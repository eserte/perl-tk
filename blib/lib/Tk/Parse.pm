#!/usr/bin/perl

package Tk::Parse;

require Exporter;



use vars qw($VERSION);
$VERSION = '2.004'; # $Id: //depot/Tk/Pod/Parse.pm#4$

@ISA=qw(Exporter);
@EXPORT=qw(Parse Simplify hide start_hide unhide Normalize Normalize2 Escapes
	$VERBATIM $HEADING $ITEM $INDEX $TEXT $PRAGMA $INDENT );
	
# Different types of text:

# 0. Name of file
# 1. Verbatim paragraphs
# 2. Headings
# 3. Items
# 4. Index mark
# 5. Comment block
# 6. Formatted paragraphs
# 7. Pragmas
# 8. Indented sections (which can contain 1-9)
# 9. Cut (conveys no information, but may be useful in interparagraph spacing)

# 0 = [0,0,0,0,"filename"]
# 1 = [1,line,pos,0,"verbatim paragraph"]
# 2 = [2,line,pos,level,"heading"]
# 3 = [3,line,pos,0,item]
# 4 = [4,line,pos,0,"indexing"]
# #5 = [5,line,pos,0,"comment"]
# 6 = [6,line,pos,0,"paragraph"]
# 7 = [7,line,pos,0,"pragma"]
# 8 = [8,line,pos,indentation,type...] #type 1 = "*", type 2 = "1.,2." 3=else
# 9 = [9,line,pos,0,"cut"]

=head1 NAME

Pod::Parse - Parse perl's pod files.

=head1 SYNOPSIS

B<THIS TK SNAPSHOT SHOULD BE REPLACED BY A CPAN MODULE>

=head1 DESCRIPTION

A module designed to simplify the job of parsing and formatting ``pods'', the
documentation format used by perl5. This consists of several different
functions to present and modify predigested pod files.

=head1 GUESSES

This is a work in progress, so I may have some stuff wrong, perhaps badly.
Some of my more reaching guesses:

=over 4

=item *

An =index paragraph should be split into lines, and each line placed inside
an `X' formatting command which is then preprended to the next paragraph,
like this:

  =index foo
  foo2
  foo3
  foo2!subfoo
  
  Foo!
 
Will become:

  X<foo>X<foo2>X<foo3>X<foo2!subfoo>Foo!

=item *

A related change: that an `X' command is to be used for indexing data. This
implies that all formatters need to at least ignore the `X' command.

=item *

Inside an =command, no special significance is to be placed on the first line
of the argument. Thus the following two lines should be parsed identically:

 =item 1. ABC
 
 =item 1.
 ABC

Note that neither of these are identical to this:

 =item 1.
 
 ABC

which puts the "ABC" in a separate paragraph.

=item *

I actually violate this rule twice: in parsing =index commands, and in
passing through the =pragma commands. I hope this make sense.

=item *

I added the =comment command, which simply ignores the next paragraph

=item *

I also added =pragma, which also ignores the next paragraph, but this time
it gives the formatter a chance at doing something sinister with it.

=back

=head1 POD CONVENTIONS

This module has two goals: first, to simplify the usage of the pod format,
and secondly the codification of the pod format. While perlpod contains some
information, it hardly gives the entire story. Here I present "the rules",
or at least the rules as far as I've managed to work them out.

=over 4

=item Paragraphs: The basic element

The fundamental "atom" of a pod file is the paragraph, where a paragraph is
defined as the text up to the next completely blank line ("\n\n"). Any pod
parser will read in paragraphs sequentially, deciding what do to with each
based solely on the current state and on the text at the _beginning_ of the
paragraph.

=item Commands: The method of communication

A paragraph that starts with the `=' symbol is assumed to be a special command.
All of the alphanumeric characters directly after the `=' are assumed to be
part of the name of the command, up to the first whitespace. Anything past that
whitespace is considered "the arugment", and the argument continues up till
the end of the paragraph, regardless of newlines or other whitespace.

=item Text: Commands that aren't Commands

A paragraph that doesn't start with `=' is treated as either of two types of
text. If it starts with a space or tab, it is considered a B<verbatim>
paragraph, which will be printed out... verbatim. No formatting changes
whatsover may be done. (Actually, this isn't quite true, but I'll get back to
that at a later date.)

A paragraph that doesn't start with whitespace or `=' is assumed to consist of
formmated text that can be molded as the formatter sees fit. Reformatting to
fit margins, whatever, it's fair game. These paragraphs also can contain a
number of different formatting codes, which verbatim paragraphs can't. These
formatting codes are covered later.

=item =cut: The uncommand

There is one command that needs special mention: =cut. Anything after a
paragraph starting with =cut is simply ignored by the formatter. In
addition, any text B<before> a valid command is equally ignored. Any valid
`=' command will reenable formating. This fact is used to great benefit by
Perl, which is glad to ignore anything between an `=' command and `=cut', so
you can embed a pod document right inside a perl program, and neither will
bother the other.

=item Reference to paragraph commands

=over 4

=item =cut

Ignore anything till the next paragraph starting with `='.

=item =head1

A top-level heading. Anything after the command (either on the same line or 
on further lines) is included in the heading, up until the end of the paragraph.

=item =head2

Secondary heading. Same as =head1, but different. No, there isn't a head3,
head4, etc.

=item =over [N]

Start a list. The C<N> is the number of characters to indent by. Not all
formatters will listen to this, though. A good number to use is 4.

While =over sounds like it should just be indentation, it's more complex then
that. It actually starts a nested environment, specifically for the use of
=item's. As this command recurses properly, you can use more then one, you
just have to make sure they are closed off properly by =back commands.

=item =back

Ends the last =over block. Resets the indentation to whatever it was
previously. Closes off the list of =item's.

=item =item

The point behind =over and =back. This command should only be used between
them. The argument supplied should be consistent (within a list) to one of 
three types: enumeration, itemization, or description. To exemplify:


An itemized list

  =over 4
  
  =item *
  
  A bulleted item
  
  =item *
  
  Another bulleted item
 
  =back
  
An enumerated list

  =over 4
  
  =item 1.
  
  First item.
  
  =item 2.
  
  Second item.
  
  =back
  
A described list

  =over 4
  
  =item Item #1
  
  First item
  
  =item Item #2 (which isn't really like #1, but is the second).
  
  Second item
  
  =back  
  
  
If you aren't consistent about the arguments to =item, Pod::Parse will
complain.

=item =comment

Ignore this paragraph

=item =pragma

Ignore this paragraph, as well, unless you know what you are doing.

=item =index

Undecided at this time, but probably magic involving XZ<><>.

=back

=item Reference to formatting directives

=over 4

=item BZ<><...>

Format text inside the brackets as bold.

=item IZ<><...>

Format text inside the brackets as italics.

=item ZZ<><>

Replace with a zero-width character. You'll probably figure out some uses
for this.

=item And yet more that I haven't described yet...

=back

=back

=head1 USAGE

=head2 Parse

This function takes a list of files as an argument. If no argument is given,
it defaults to the contents of @ARGV. Parse then reads through each file and
returns the data as a list. Each element of this list will be a nested list
containing data from a paragraph of the pod file. Elements pertaining to
"=over" paragraphs will themselves contain the nested entries for all of the
paragraphs within that list. Thus, it's easier to parse the output of Parse
using a recursive parses. (Um, did that parse?)

It is I<highly> recommended that you use the output of Simplify, not Parse,
as it's simpler.

The output will consist of a list, where each element in the list matches
one of these prototypes:

=over 4

=item [0,0,0,0,$filename]

This is produced at the beginning of each file parsed, where $filename is
the name of that file.

=item [-1,0,0,0,$filename]

End of same.

=item [1,$line,$pos,0,$verbatim]

This is produced for each paragraph of verbatim text. $verbatim is the text, 
$line is the line offset of the paragraph within the file, and $pos is the
byte offset. (In all of the following elements, $pos and $line have identical
meanings, so I'll skip explaining them each time.)

=item [2,$line,$pos,$level,$heading]

Producded by a =head1 or =head2 command. $level is either 1 or 2, and $heading
is the argument.

=item [3,$line,$pos,0,$item]

$item is the argument from an =item paragraph.

=item [4,$line,$pos,0,$index]

$index is the argument from an =index paragraph.

=item [6,$line,$pos,0,$text]

Normal formatted text paragraph. $text is the text.

=item [7,$line,$pos,0,$pragma]

$pragma is the argument from a =pragma paragraph.

=item [8,$line,$pos,$indentation,$type,...]

This item is produced for each matching =over/=back pair. $indentation is
the argument to =over, $type is 1 if the embedded =item's are bulleted, 2 if
they are enumerated, 3 if they are text, and 0 if there are no items.

The "..." indicates an unlimited number of further elements which are
themselves nested arrays in exactly the format being described. In other
words, a list item includes all the paragraphs inside the list inside
itself. (Clear? No? Nevermind.)

=item [9,$line,$pos,0,$cut]

$cut contains the text from a =cut paragraph. You shouldn't need to use
this, but I _suppose_ it might be necessary to do special breaks on a cut. I
doubt it though. This one is "depreciated", as Larry put it. Or perhaps
disappreciated.

=back

=head2 Simplify

This procedure takes as it's input the convoluted output from Parse(), and
outputs a much simpler array consisting of pairs of commands and arguments,
designed to be easy (easier?) to parse in your pod formatting code.

It is used very simply by saying something like:

 @Pod = Simplify(Parse());
 
 while($cmd = shift @Pod) { $arg = shift @Pod;
 	#...
 }

Where #... is the code that responds to any of the commands from the
following list. Note that you are welcome to ignore any of the commands that
you want to. Many contain duplicate information, or at least information
that will go unused. A formatted based on this data can be quite simple
indeed. (See pod2text for entirely too simple an example.)

=head2 Reference to Simplify commands

=over 4

=item "filename"

The argument contains the name of the pod file that is being parsed. These
will be present at the start of each file. You should open an output file,
output headers, etc., based on this, and not when you start parsing.

=item "endfile"

The end of the file. Each file will be ended before the next one begins, and
after all files are done with. You can do end processing here. The argument
is the same name as in "filename".

=item "setline"

This gives you a chance to record the "current" input line, probably for
debugging purposes. In this case, "current" means that the next command you
see that was derived from an input paragraph will have start at the
arguments line in the file.

=item "setloc"

Same as setline, but the byte offset in the input, instead of the line offset.

=item "pragma"

The argument contains the text of a pragma command.

=item "text"

The argument contains a paragraph of formatted text.

=item "verbatim"

The argument contains a paragraph of verbatim text.

=item "cut"

A =cut command was hit. You shouldn't really need to listen for this one.

=item "index"

The argument contains an =index paragraph. (Note: Current =index commands are
not fed through, but turned into XZ<><> commands.)

=item "head1"

=item "head2"

The argument contains the argument from a header command.


=item "setindent"

If you are tracking indentation, use the argument to set the indentation level.

=item "listbegin"

Start a list environment. The argument is the type of list (1,2,3 or 0).

=item "listend"

Ends a list environment. Same argument as listbegin.

=item "listtype"

The argument is the type of list. You can just record the argument when you
see one of these, instead of paying attention to listbegin & listend.

=item "over"

The argument is the indentation. It's probably better to listen to the
"list..." commands.

=item "back"

Ends an "over" list. The argument is the original indentation.

=item "item"

The argument is the text of the =item command.

=back

Note that all of these various commands you've seen are syncronized properly
so you don't have to pay attention to all at once, but they are all output
for your benefit. Consider the following example:

 listtype 2
 listbegin 2
 setindent 4
 over 4
 item 1.
 text Item #1
 item 2.
 text Item #2
 setindent 0
 listend 2
 back 0
 listtype 0
 
=head2 Normalize

This command is normally invoked by Parse, so you shouldn't need to deal
with it. It just cleans up text a little, turning spare '<', '>', and '&'
characters into HTML escapes (E<lt>, etc.) as well as generating warnings for
some pod formatting mistakes.

=head2 Normalize2

A little more aggresive formating based on heuristics. Not applied by
default, as it might confuse your own heuristics.

=head2 %Escapes

This hash is exported from Pod::Parse, and contains default ASCII
translations for some common HTML escape sequences. You might like to use this
as a basis for an %HTML_Escapes array in your own formatter.

=cut

$ENDFILE = -1;
$FILE = 0;
$VERBATIM = 1;
$HEADING = 2;
$ITEM = 3;
$INDEX = 4;
$TEXT = 6;
$PRAGMA = 7;
$INDENT = 8;
$CUT = 9;

	   



# "hide" suite

sub hide {
    local($thing_to_hide) = shift;
    $thing_to_hide =~ tr/\000-\177/\200-\377/;
    return $thing_to_hide;
}
            
sub start_hide {
    if ( /[\200-\377]/ ) {
        warn "hit bit char in input stream";
    }
}
                            
sub unhide {
    local($tmp) = shift;
    $tmp =~ tr/\200-\377/\000-\177/;
    return $tmp;
}
                                        

# Turn formatted text into a more normalized version. All '<' and '>' will
# belong to a command, the rest will have turned into E<lt> and E<gt>. '&'
# has been changed into E<amp>. Possibly generate some warnings

sub Normalize {
	local($_) = $_[0];

	start_hide;
        s/(E<[^<>]*>)/hide($1)/ge;
        s/([A-Z]<[^<>]*>)/hide($1)/ge;
        
        s/</hide("E<lt>")/ge;
        s/>/hide("E<gt>")/ge;
        s/&/hide("E<amp>")/ge;

      	#if (m{ ([\-\w]+\([^\051]*?[\@\$,][^\051]*?\))
        #	}x && $` !~ /([LCI]<[^<>]*|-)$/ && !/^=\w/)
        #	{
        #	warn "``$1'' should be a [LCI]<$1> ref near line $line of $ARGV\n";
        #}
        
        while (/(-[a-zA-Z])\b/g && $` !~ /[\w\-]$/) {
		warn  "``$1'' should be [CB]<$1> ref near line $line of $ARGV\n";
	}
        
	# put back pod quotes so we get the inside of <> processed;
        $_ = unhide($_);
        
}

# Apply heuristics to a formatted string.
sub Normalize2 {
	local($_) = @_;        
        
	# func() is a reference to a perl function
       	s{\b([:\w]+\(\))}{I<$1>}g;
       	
        # func(n) is a reference to a man page
        s{(\w+)(\([^\s,\051]+\))}{I<$1>$2}g;
        
        # convert simple variable references
        s/(\s+)([\$\@%][\w:]+)/${1}C<$2>/g;
        #       s/([\$\@%][\w:]+)/C<$1>/g;
        #       s/\$[\w:]+\[[0-9]+\]/C<$&>/g;
	$_;
}

# Take output from the following Parse routine, and turns it into a much
# more straightforward, non-recursive, data structure. It returns an
# array consisting of pairs of elements, the first of each pair being a 
# command, and the second it's argument. Hopefully this should prove
# simple to parse. Note that it is intended that your formatter only "listens"
# for the commands it is interested in, and simply discards the rest.

sub Simplify { &Simplify2(0,0,@_); }

sub Simplify2 {
	my($indent,$type,@list) = @_;
	my(@result)=();
	foreach(@list) {
		my($code,$line,$loc,$param,$text) = @{$_};
		push(@result,"setline",$line);
		push(@result,"setloc",$loc);
		if( $code == $INDENT) {
			my($code_dummy,$line,$loc,$i,$t,@more) = @{$_};
			#   ^^^^^^^^^^ This may be bug of perl5.002b2
			push(@result,"listtype",$t);
			push(@result,"listbegin",$t);
			push(@result,"setindent",$i);
			push(@result,"over",$i);
			push(@result,&Simplify2($i,$t,@more));
			push(@result,"setindent",$indent);
			push(@result,"listend",$t);
			push(@result,"back",$indent);
			push(@result,"listtype",$type);
		} elsif( $code == $PRAGMA) {
			push(@result,"pragma",$text);
		} elsif( $code == $ITEM) {
			push(@result,"item",$text);
		} elsif( $code == $INDEX) {
			push(@result,"index",$text);
		} elsif( $code == $TEXT) {
			push(@result,"text",$text);
		} elsif( $code == $VERBATIM) {
			push(@result,"verbatim",$text);
		} elsif( $code == $HEADING) {
			push(@result,"head$param",$text);
		} elsif( $code == $CUT) {
			push(@result,"cut",0);
		} elsif( $code == $FILE) {
			push(@result,"filename",$text);
		} elsif( $code == $ENDFILE) {
			push(@result,"endfile",$text);
		}
	}
	@result;
}

# Read input from a pod file, and generate a list describing it. Keeps
# track of the line number and position in the stream. Recursive.

sub Parse {
	local(@ARGV)=@ARGV;
	if(@_) { @ARGV = @_ }
	
	local($/);

	$type=0;
	$typecount=0;
	$eof=0;
	$bof=1;
	$saveindex="";

	$/="";
	
	$cutting=1;

	$recurse=0;

	$line=0;

	$loc=0;

	$newloc=0; $newline=0;
	
	$infile = undef;

	
	&Parse2();

}

sub Parse2 {
	my(@result)=();
	while(<>) {
		if($bof) {
			push(@result,[-1,0,0,0,$infile]) if $infile;
			push(@result,[0,0,0,0,$ARGV]);
			$infile = $ARGV;
			$newloc=0;
			$newline=0;
			$bof=0;
		}
		if(eof) {
			$bof=1;
		}
		$loc=$newloc;
		$line=$newline;
		$newloc = $loc + length($_);
		$newline= $line + (tr/\n/\n/);
		
		#Should I?
		#s/[ \t]+$//gm;
		
		#print STDERR "Read $_\n";
		
		if($cutting && !/^=/) {
			next;
		}
		$cutting=0;
		chomp;
		
		if(/^=cut/) {
			$cutting=1;
			push(@result,[9,$line,$loc,0,0]);
			next;
		}
		
		if(/^\s/) {
			push(@result,[1,$line,$loc,0,$_]);
		} elsif( /^=head(\d+)\s*/ ) {
			my($data) = $';
			$data =~ s/\n/ /g;
			push(@result,[2,$line,$loc,$1,Normalize($data)]);
		} elsif( /^=item\s*/ ) {
			my($data) = $';
			$data =~ s/\n/ /g;
			if(!$recurse) {
				warn "=item outside of an =over block near line $line of $ARGV\n";
			}
			if( $data eq "*" ) {
				if( $type == 0 || $type == 1) {
				 	$type = 1;
				} else {
					warn "Inconsistent =item near line $line of $ARGV\n";
				}
			} elsif( $data =~ /^(\d+)\.$/ ) {
				if( $type == 0 ) {
					$type=2;
					$typecount=0;
				} elsif( $type != 2 ) {
					warn "Inconsistent =item near line $line of $ARGV\n";
				}
				if( ++$typecount != $1) {
					warn "Inconsistently numbered =item near line $line of $ARGV\n";
					$typecount = $1;
				}
				
			} else {
				if( $type == 0 || $type == 3) {
					$type = 3;
				} else {
					warn "Inconsistent =item near line $line of $ARGV\n";
				}
			}
			push(@result,[3,$line,$loc,0,Normalize($data)]);
			
		} elsif( /^=over(?:\s+(\d+))?/ ) {
			my($indent,$l1,$l2)=($1,$line,$loc);
			$indent ||= 5; # good?
			$recurse++;
			local($type)=0;
			local($typecount)=0;
			my(@newresult) = Parse2();
			#print STDERR "PUSH\n";
			push(@result,[8,$l1,$l2,$indent,$type,@newresult]);
			#print STDERR "POP\n";
			$recurse--;
			last if $eof;
		} elsif( /^=back/ ) {
			if(!$recurse) {
				die "Unmatched =back near line $line of $ARGV\n";
			} 
			return @result;
		} elsif( /^=pragma\s*/) {
			push(@result,[7,$line,$loc,0,$']);
		} elsif( /^=index\s*/) {
			#push(@result,[4,$line,$loc,0,$']);
			$saveindex=$';
		} elsif( /^=comment/ ) {
			#push(@result,[5,$line,$loc]);
		} elsif( /^=/ ) {
			m/^(=\S+)/;
			warn "Unknown pod command `$1' near line $line of $ARGV\n";
		} else {
			if($saveindex) {
				$_ = join("",map("X<$_>",grep(!/^\s*$/,split(/\n/,$saveindex))))
				     . $_;
				$saveindex="";
			}
			push(@result,[6,$line,$loc,0,Normalize($_)]);
		}
		
	}
	$eof=1;
	if($recurse) {
		#die ...
		warn "Unmatched =over near line $line of $ARGV\n";
		#Assume =back
	}
	push(@result,[-1,0,0,0,$infile]) if $infile;
	@result;
}

# for testing
#@result=Parse();
#print Dumpstruct::Dumpstruct(\@result);


# Common escapes with ASCII translations. You should copy this into you're
# own local escapes hash and override the ones you need to change.

%Escapes = (
    'amp'	=>	'&',	#   ampersand
    'lt'	=>	'<',	#   left chevron, less-than
    'gt'	=>	'>',	#   right chevron, greater-than
    'quot'	=>	'"',	#   double quote

    "Aacute"	=>	"A",	#   capital A, acute accent
    "aacute"	=>	"a",	#   small a, acute accent
    "Acirc"	=>	"A",	#   capital A, circumflex accent
    "acirc"	=>	"a",	#   small a, circumflex accent
    "AElig"	=>	'Ae',		#   capital AE diphthong (ligature)
    "aelig"	=>	'ae',		#   small ae diphthong (ligature)
    "Agrave"	=>	"A",	#   capital A, grave accent
    "agrave"	=>	"a",	#   small a, grave accent
    "Aring"	=>	'A',	#   capital A, ring
    "aring"	=>	'a',	#   small a, ring
    "Atilde"	=>	'A',	#   capital A, tilde
    "atilde"	=>	'a',	#   small a, tilde
    "Auml"	=>	'A',	#   capital A, dieresis or umlaut mark
    "auml"	=>	'a',	#   small a, dieresis or umlaut mark
    "Ccedil"	=>	'C',	#   capital C, cedilla
    "ccedil"	=>	'c',	#   small c, cedilla
    "Eacute"	=>	"E",	#   capital E, acute accent
    "eacute"	=>	"e",	#   small e, acute accent
    "Ecirc"	=>	"E",	#   capital E, circumflex accent
    "ecirc"	=>	"e",	#   small e, circumflex accent
    "Egrave"	=>	"E",	#   capital E, grave accent
    "egrave"	=>	"e",	#   small e, grave accent
    "ETH"	=>	'Oe',		#   capital Eth, Icelandic
    "eth"	=>	'oe',		#   small eth, Icelandic
    "Euml"	=>	'E',	#   capital E, dieresis or umlaut mark
    "euml"	=>	'e',	#   small e, dieresis or umlaut mark
    "Iacute"	=>	"I",	#   capital I, acute accent
    "iacute"	=>	"i",	#   small i, acute accent
    "Icirc"	=>	"I",	#   capital I, circumflex accent
    "icirc"	=>	"i",	#   small i, circumflex accent
    "Igrave"	=>	"I",	#   capital I, grave accent
    "igrave"	=>	"i",	#   small i, grave accent
    "Iuml"	=>	'I',	#   capital I, dieresis or umlaut mark
    "iuml"	=>	'i',	#   small i, dieresis or umlaut mark
    "Ntilde"	=>	'N',	#   capital N, tilde
    "ntilde"	=>	'n',	#   small n, tilde
    "Oacute"	=>	"O",	#   capital O, acute accent
    "oacute"	=>	"o",	#   small o, acute accent
    "Ocirc"	=>	"O",	#   capital O, circumflex accent
    "ocirc"	=>	"o",	#   small o, circumflex accent
    "Ograve"	=>	"O",	#   capital O, grave accent
    "ograve"	=>	"o",	#   small o, grave accent
    "Oslash"	=>	"O",		#   capital O, slash
    "oslash"	=>	"o",		#   small o, slash
    "Otilde"	=>	"O",	#   capital O, tilde
    "otilde"	=>	"o",	#   small o, tilde
    "Ouml"	=>	'O',	#   capital O, dieresis or umlaut mark
    "ouml"	=>	'o',	#   small o, dieresis or umlaut mark
    "szlig"	=>	'ss',		#   small sharp s, German (sz ligature)
    "THORN"	=>	'L',		#   capital THORN, Icelandic
    "thorn"	=>	'l',		#   small thorn, Icelandic
    "Uacute"	=>	"U",	#   capital U, acute accent
    "uacute"	=>	"u",	#   small u, acute accent
    "Ucirc"	=>	"U",	#   capital U, circumflex accent
    "ucirc"	=>	"u",	#   small u, circumflex accent
    "Ugrave"	=>	"U",	#   capital U, grave accent
    "ugrave"	=>	"u",	#   small u, grave accent
    "Uuml"	=>	'U',	#   capital U, dieresis or umlaut mark
    "uuml"	=>	'u',	#   small u, dieresis or umlaut mark
    "Yacute"	=>	"Y",	#   capital Y, acute accent
    "yacute"	=>	"y",	#   small y, acute accent
    "yuml"	=>	'y',	#   small y, dieresis or umlaut mark
);


1;
