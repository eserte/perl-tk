package Tk::Mwm;

use vars qw($VERSION);
$VERSION = '4.002'; # $Id: //depot/Tkutf8/Mwm/Mwm.pm#2 $

use Tk qw($XS_VERSION);
require DynaLoader;

use vars qw($VERSION);
$VERSION = '4.002'; # $Id: //depot/Tkutf8/Mwm/Mwm.pm#2 $

use base  qw(DynaLoader);

bootstrap Tk::Mwm;

package Tk;
use Tk::Submethods ( 'mwm' => [qw(decorations ismwmrunning protocol transientfor)] );
package Tk::Mwm;

1;

