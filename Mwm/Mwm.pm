package Tk::Mwm;
require Tk;
require DynaLoader;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Mwm/Mwm.pm#8$

use base  qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION;

package Tk;
use Tk::Submethods ( 'mwm' => [qw(decorations ismwmrunning protocol transientfor)] );
package Tk::Mwm;

1;

