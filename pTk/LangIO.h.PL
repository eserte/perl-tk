#!/usr/local/bin/perl -w
use Config;
my @gard = qw(
_FILEDEFED
STDIO_H
_H_STDIO
_H_STDIO_
_INCLUDED_STDIO
_INC_STDIO
_STDIO_H
_STDIO_H_
_STDIO_INCLUDED
__H_STDIO__
__STDIO_H
__STDIO_H__
__STDIO_LOADED
__h_stdio__
__stdio_h__
_h_stdio
_h_stdio_
_included_stdio
_stdio_h
_stdio_h_
_stdio_included
);

my %gard;

while (@gard)
 {
  my $gard = pop(@gard);
  $gard{$gard} = 1;
 }

my @cinc = ();

if ($^O eq 'MSWin32' && defined $ENV{'INCLUDE'})
 {
  @cinc = split(';',$ENV{'INCLUDE'});
 }
push(@cinc,$Config{'usrinc'});
foreach $dir (@cinc)
 {
  my $inc = "$dir/stdio.h";
  if (open(INC,"<$inc"))
   {
    my $gard;
    while (<INC>)
     {
      if (/^#ifndef\s+([_\w]+)/ || /^#if\s+!defined\(([_\w]+)\)/)
       {
        $gard = $1;
        last;
       }
     }
    while (<INC>)
     {
      if (/^#define\s+$gard/o)
       {
        warn "stdio.h garded with $gard\n";
        if (!exists $gard{$gard})
         {
          $gard{$gard} = 1;
          warn ">>> PLEASE TELL nick\@ni-s.u-net.com about this value <<<\n";
         }
        push(@gard,$gard);
        last;
       }
     }
    close(INC);
    unless (@gard)
     {
      warn "Cannot find #include gard in $inc\n";
     }
    last;
   }
  else
   {
    warn "Cannot read $inc:$!";
   }
 }

@gard = keys %gard;

my $file = "LangIO.h";

if (-f $file)
 {
  chmod(0666,$file) unless (-w $file);
  unlink($file);
 }
open(H,">$file") || die "Cannot open $file:$!";

print H <<'END';
#ifdef NEED_REAL_STDIO
#include <stdio.h>
#else
END
print H "#if ",join(" && \\\n    ",map("!defined($_)",@gard,'FILE')),"\n";
foreach (@gard)
 {
  print H "#define $_\n";
 }
print H <<'END';
#define _FILEDEFED
#undef FILE
struct _FILE;
#define FILE struct _FILE
EXTERN int printf  _ANSI_ARGS_((CONST char *,...));
EXTERN int sscanf  _ANSI_ARGS_((CONST char *, CONST char *,...));
#ifdef SPRINTF_RETURN_CHAR
EXTERN char *sprintf _ANSI_ARGS_((char *, CONST char *,...));
#else
EXTERN int sprintf _ANSI_ARGS_((char *, CONST char *,...));
#endif
#endif
#endif /* NEED_REAL_STDIO */

#ifndef EOF
#define EOF (-1)
#endif

/* This is to catch case with no stdio */
#ifndef BUFSIZ
#define BUFSIZ 1024
#endif

#ifndef SEEK_SET
#define SEEK_SET 0
#endif

#ifndef SEEK_CUR
#define SEEK_CUR 1
#endif

#ifndef SEEK_END
#define SEEK_END 2
#endif
END
