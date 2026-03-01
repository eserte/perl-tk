use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use Test::More qw(no_plan);

use_ok 'Tk::X';

if ($^O =~ m{^(MSWin32|linux|freebsd)$}) {
    ok looks_like_number Tk::X::None(),        'None is defined and a number';
    ok looks_like_number Tk::X::ControlMask(), 'ControlMask is defined and a number';
}
