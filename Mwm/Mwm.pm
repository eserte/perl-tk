package Tk::Mwm;

use vars qw($VERSION);
$VERSION = '3.012'; # $Id: //depot/Tk8/Mwm/Mwm.pm#12 $

use Tk qw($XS_VERSION);
require DynaLoader;

use vars qw($VERSION);
$VERSION = '3.012'; # $Id: //depot/Tk8/Mwm/Mwm.pm#12 $

use base  qw(DynaLoader);

bootstrap Tk::Mwm;

package Tk;
use Tk::Submethods ( 'mwm' => [qw(decorations ismwmrunning protocol transientfor)] );
package Tk::Mwm;

1;

