sub OS2_massage {		# Need to put before BEGIN
  if (@ARGV) {
    die <<EOD;

Please start me as one of
	perl $0 x
	perl $0 open32
	perl $0 pm
EOD
  }
  if (not defined $win_arch) {
      $win_arch = 'pm';
      print STDERR <<EOP;

No Window architecture specified, building for PM.

Please start me as one of
	perl $0 x
	perl $0 open32
	perl $0 pm
if you want to specify architecture explicitely.

EOP
  }
  if ($win_arch ne 'x' and not -r 'pTk/mTk/open32/tkWinOS2.c' ) {
    my @zips = <../Tk-OS2-*/perltk_os2_common.zip>;
    
    die <<EOD unless @zips;

Cannot find pTk/mTk/open32/tkWinOS2.c, did you read README.os2?

EOD
    system 'unzip', $zips[-1] and die "Unzip: $!";
  }
  if ($win_arch eq 'pm' and not -r 'pTk/mTk/os2/tkOS2Int.h') {
    my @zips = <../Tk-OS2-*/perltk_os2_pm.zip>;
    
    die <<EOD unless @zips;

Cannot find pTk/mTk/os2/tkOS2Int.h, did you read README.os2?

EOD
    system 'unzip', $zips[-1] and die "Unzip: $!";
  }
  $test_perl = 'perl__.exe' if $win_arch ne 'x';
}

1;
