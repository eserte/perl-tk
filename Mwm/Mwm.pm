package Tk::Mwm; 
require Tk;
require DynaLoader;

use vars qw($VERSION @ISA);
$VERSION = '3.005'; # $Id: //depot/Tk8/Mwm/Mwm.pm#5$

@ISA = qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

package Tk;
use Tk::Submethods ( 'mwm' => [qw(decorations ismwmrunning protocol transientfor)] );
package Tk::Mwm;

1;

