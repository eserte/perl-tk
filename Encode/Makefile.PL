my $build_encode = 0;
eval { require utf8 };
if ($@)
 {
  warn "No utf8 in perl$]\n";
 }
else
 {
  eval { require Encode };
  if (!$@ && Encode->can('getEncoding')
      && defined(Encode->getEncoding('iso8859-1')))
   {
    warn "Suitable Encode module already installed\n";
   }
  else
   {
    $build_encode = 1;
   }
 }

if ($build_encode)
 {
  use ExtUtils::MakeMaker;
  WriteMakefile(
	NAME		=> "Encode",
	VERSION_FROM	=> 'Encode.pm',
	'dist'		=> {
 			     COMPRESS	=> 'gzip -9f',
 	      		     SUFFIX	=> 'gz',
 	      		     DIST_DEFAULT => 'all tardist',
 			   },
 	MAN3PODS	=> {},
  );
 }
else
 {
  my $file = 'Makefile';
  open(MAKEFILE,">$file") || die "Cannot open $file:$!";
  foreach my $targ (qw(all config install test))
   {
    print MAKEFILE "$targ:\n\n";
   }
  print MAKEFILE "clean:\n\trm -f Makefile\n\n";

  close(MAKEFILE);
 }

