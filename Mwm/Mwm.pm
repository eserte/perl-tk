package Tk::Mwm; 
require Tk;
require DynaLoader;

use vars qw($VERSION @ISA);
$VERSION = '3.006'; # $Id: //depot/Tk8/Mwm/Mwm.pm#6$

use base  qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

package Tk;
use Tk::Submethods ( 'mwm' => [qw(decorations ismwmrunning protocol transientfor)] );
package Tk::Mwm;

1;

