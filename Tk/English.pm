package Tk::English;

require Exporter;

use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/Tk/English.pm#3$

@ISA = (Exporter);

# This file is generated automatically by pTk/makeenglish from Tk distribution.


@EXPORT = qw(
    &ABOVE &ACTIVATE &ACTIVE &ADD &ADDTAG &ADJUST &AFTER &ALL &ANCHOR &APPEND
    &APPNAME &ARROW1 &ARROW2 &ASPECT &ATOM &ATOMNAME &BASELINE &BBOX &BEFORE
    &BELOW &BEVEL &BIND &BLANK &BOTH &BOTTOM &BUTT &CANCEL &CANVASX &CANVASY
    &CASCADE &CELLS &CENTER &CGET &CHAR &CHARS &CHECKBUTTON &CHILDREN &CLASS
    &CLEAR &CLIENT &CLOSEST &COLOR &COLORMAPFULL &COLORMAPWINDOWS &COMMAND
    &COMPARE &CONFIGURE &CONTAINING &COORDS &COPY &CREATE &CURRENT &CURSELECTION
    &DCHARS &DEBUG &DEFAULT &DEICONIFY &DELETE &DELTA &DEPTH &DESELECT
    &DLINEINFO &DRAGTO &DTAG &ENCLOSED &END &ENTRYCGET &ENTRYCONFIGURE &EXISTS
    &EXPAND &FILL &FILLX &FILLY &FIND &FIRST &FLASH &FLAT &FOCUS &FOCUSMODEL
    &FORGET &FPIXELS &FRACTION &FRAME &FROM &GEOMETRY &GET &GETTAGS &GRAVITY
    &GRAY &GRID &GROOVE &GROUP &HANDLE &HEIGHT &HORIZONTAL &ICONBITMAP &ICONIFY
    &ICONMASK &ICONNAME &ICONPOSITION &ICONWINDOW &ICURSOR &ID &IDENTIFY &IDLE
    &IDLETASKS &IGNORE &INCLUDES &INDEX &INFO &INSERT &INSIDE &INTERACTIVE
    &INTERPS &INVOKE &ISMAPPED &ITEM &ITEMCGET &ITEMCONFIGURE &LAST &LEFT
    &LINEEND &LINES &LINESTART &LIST &LOWER &MANAGER &MARK &MAXSIZE &MINSIZE
    &MITER &MONOCHROME &MOVE &MOVETO &NAME &NAMES &NEAREST &NEW &NEXTRANGE &NONE
    &OUTSIDE &OVERLAPPING &OVERRIDEREDIRECT &OWN &PADX &PADY &PAGES &PARENT
    &PASSIVE &PATHNAME &PIXELS &POINTERX &POINTERXY &POINTERY &POSITION
    &POSITIONFROM &POST &POSTCASCADE &POSTSCRIPT &PRESENT &PROGRAM &PROJECTING
    &PROPAGATE &PROTOCOL &PUT &RADIOBUTTON &RAISE &RAISED &RANGE &RANGES &READ
    &READABLE &READFILE &REDITHER &RELEASE &REMOVE &REQHEIGHT &REQWIDTH
    &RESIZABLE &RGB &RIDGE &RIGHT &ROOT &ROOTX &ROOTY &ROUND &SAVEUNDER &SCALE
    &SCAN &SCREEN &SCREENCELLS &SCREENDEPTH &SCREENHEIGHT &SCREENMMHEIGHT
    &SCREENMMWIDTH &SCREENVISUAL &SCREENWIDTH &SCROLL &SEARCH &SEE &SELECT
    &SELECTION &SEPARATOR &SERVER &SET &SIZE &SIZEFROM &SLAVES &SLIDER &STATE
    &STATUS &SUNKEN &TAG &TITLE &TO &TOGGLE &TOP &TOPLEVEL &TRACING &TRANSIENT
    &TYPE &TYPES &UNITS &UNPACK &UNPOST &UNSET &USER &VARIABLE &VERTICAL
    &VIEWABLE &VISIBILITY &VISUAL &VISUALSAVAILABLE &VROOTHEIGHT &VROOTWIDTH
    &VROOTX &VROOTY &WIDTH &WINDOW &WITHDRAW &WITHTAG &WORDEND &WORDSTART
    &WRITABLE &WRITE &XVIEW &YPOSITION &YVIEW
);
sub ABOVE { 'above' }
sub ACTIVATE { 'activate' }
sub ACTIVE { 'active' }
sub ADD { 'add' }
sub ADDTAG { 'addtag' }
sub ADJUST { 'adjust' }
sub AFTER { 'after' }
sub ALL { 'all' }
sub ANCHOR { 'anchor' }
sub APPEND { 'append' }
sub APPNAME { 'appname' }
sub ARROW1 { 'arrow1' }
sub ARROW2 { 'arrow2' }
sub ASPECT { 'aspect' }
sub ATOM { 'atom' }
sub ATOMNAME { 'atomname' }
sub BASELINE { 'baseline' }
sub BBOX { 'bbox' }
sub BEFORE { 'before' }
sub BELOW { 'below' }
sub BEVEL { 'bevel' }
sub BIND { 'bind' }
sub BLANK { 'blank' }
sub BOTH { 'both' }
sub BOTTOM { 'bottom' }
sub BUTT { 'butt' }
sub CANCEL { 'cancel' }
sub CANVASX { 'canvasx' }
sub CANVASY { 'canvasy' }
sub CASCADE { 'cascade' }
sub CELLS { 'cells' }
sub CENTER { 'center' }
sub CGET { 'cget' }
sub CHAR { 'char' }
sub CHARS { 'chars' }
sub CHECKBUTTON { 'checkbutton' }
sub CHILDREN { 'children' }
sub CLASS { 'class' }
sub CLEAR { 'clear' }
sub CLIENT { 'client' }
sub CLOSEST { 'closest' }
sub COLOR { 'color' }
sub COLORMAPFULL { 'colormapfull' }
sub COLORMAPWINDOWS { 'colormapwindows' }
sub COMMAND { 'command' }
sub COMPARE { 'compare' }
sub CONFIGURE { 'configure' }
sub CONTAINING { 'containing' }
sub COORDS { 'coords' }
sub COPY { 'copy' }
sub CREATE { 'create' }
sub CURRENT { 'current' }
sub CURSELECTION { 'curselection' }
sub DCHARS { 'dchars' }
sub DEBUG { 'debug' }
sub DEFAULT { 'default' }
sub DEICONIFY { 'deiconify' }
sub DELETE { 'delete' }
sub DELTA { 'delta' }
sub DEPTH { 'depth' }
sub DESELECT { 'deselect' }
sub DLINEINFO { 'dlineinfo' }
sub DRAGTO { 'dragto' }
sub DTAG { 'dtag' }
sub ENCLOSED { 'enclosed' }
sub END { 'end' }
sub ENTRYCGET { 'entrycget' }
sub ENTRYCONFIGURE { 'entryconfigure' }
sub EXISTS { 'exists' }
sub EXPAND { 'expand' }
sub FILL { 'fill' }
sub FILLX { 'fillx' }
sub FILLY { 'filly' }
sub FIND { 'find' }
sub FIRST { 'first' }
sub FLASH { 'flash' }
sub FLAT { 'flat' }
sub FOCUS { 'focus' }
sub FOCUSMODEL { 'focusmodel' }
sub FORGET { 'forget' }
sub FPIXELS { 'fpixels' }
sub FRACTION { 'fraction' }
sub FRAME { 'frame' }
sub FROM { 'from' }
sub GEOMETRY { 'geometry' }
sub GET { 'get' }
sub GETTAGS { 'gettags' }
sub GRAVITY { 'gravity' }
sub GRAY { 'gray' }
sub GRID { 'grid' }
sub GROOVE { 'groove' }
sub GROUP { 'group' }
sub HANDLE { 'handle' }
sub HEIGHT { 'height' }
sub HORIZONTAL { 'horizontal' }
sub ICONBITMAP { 'iconbitmap' }
sub ICONIFY { 'iconify' }
sub ICONMASK { 'iconmask' }
sub ICONNAME { 'iconname' }
sub ICONPOSITION { 'iconposition' }
sub ICONWINDOW { 'iconwindow' }
sub ICURSOR { 'icursor' }
sub ID { 'id' }
sub IDENTIFY { 'identify' }
sub IDLE { 'idle' }
sub IDLETASKS { 'idletasks' }
sub IGNORE { 'ignore' }
sub INCLUDES { 'includes' }
sub INDEX { 'index' }
sub INFO { 'info' }
sub INSERT { 'insert' }
sub INSIDE { 'inside' }
sub INTERACTIVE { 'interactive' }
sub INTERPS { 'interps' }
sub INVOKE { 'invoke' }
sub ISMAPPED { 'ismapped' }
sub ITEM { 'item' }
sub ITEMCGET { 'itemcget' }
sub ITEMCONFIGURE { 'itemconfigure' }
sub LAST { 'last' }
sub LEFT { 'left' }
sub LINEEND { 'lineend' }
sub LINES { 'lines' }
sub LINESTART { 'linestart' }
sub LIST { 'list' }
sub LOWER { 'lower' }
sub MANAGER { 'manager' }
sub MARK { 'mark' }
sub MAXSIZE { 'maxsize' }
sub MINSIZE { 'minsize' }
sub MITER { 'miter' }
sub MONOCHROME { 'monochrome' }
sub MOVE { 'move' }
sub MOVETO { 'moveto' }
sub NAME { 'name' }
sub NAMES { 'names' }
sub NEAREST { 'nearest' }
sub NEW { 'new' }
sub NEXTRANGE { 'nextrange' }
sub NONE { 'none' }
sub OUTSIDE { 'outside' }
sub OVERLAPPING { 'overlapping' }
sub OVERRIDEREDIRECT { 'overrideredirect' }
sub OWN { 'own' }
sub PADX { 'padx' }
sub PADY { 'pady' }
sub PAGES { 'pages' }
sub PARENT { 'parent' }
sub PASSIVE { 'passive' }
sub PATHNAME { 'pathname' }
sub PIXELS { 'pixels' }
sub POINTERX { 'pointerx' }
sub POINTERXY { 'pointerxy' }
sub POINTERY { 'pointery' }
sub POSITION { 'position' }
sub POSITIONFROM { 'positionfrom' }
sub POST { 'post' }
sub POSTCASCADE { 'postcascade' }
sub POSTSCRIPT { 'postscript' }
sub PRESENT { 'present' }
sub PROGRAM { 'program' }
sub PROJECTING { 'projecting' }
sub PROPAGATE { 'propagate' }
sub PROTOCOL { 'protocol' }
sub PUT { 'put' }
sub RADIOBUTTON { 'radiobutton' }
sub RAISE { 'raise' }
sub RAISED { 'raised' }
sub RANGE { 'range' }
sub RANGES { 'ranges' }
sub READ { 'read' }
sub READABLE { 'readable' }
sub READFILE { 'readfile' }
sub REDITHER { 'redither' }
sub RELEASE { 'release' }
sub REMOVE { 'remove' }
sub REQHEIGHT { 'reqheight' }
sub REQWIDTH { 'reqwidth' }
sub RESIZABLE { 'resizable' }
sub RGB { 'rgb' }
sub RIDGE { 'ridge' }
sub RIGHT { 'right' }
sub ROOT { 'root' }
sub ROOTX { 'rootx' }
sub ROOTY { 'rooty' }
sub ROUND { 'round' }
sub SAVEUNDER { 'saveunder' }
sub SCALE { 'scale' }
sub SCAN { 'scan' }
sub SCREEN { 'screen' }
sub SCREENCELLS { 'screencells' }
sub SCREENDEPTH { 'screendepth' }
sub SCREENHEIGHT { 'screenheight' }
sub SCREENMMHEIGHT { 'screenmmheight' }
sub SCREENMMWIDTH { 'screenmmwidth' }
sub SCREENVISUAL { 'screenvisual' }
sub SCREENWIDTH { 'screenwidth' }
sub SCROLL { 'scroll' }
sub SEARCH { 'search' }
sub SEE { 'see' }
sub SELECT { 'select' }
sub SELECTION { 'selection' }
sub SEPARATOR { 'separator' }
sub SERVER { 'server' }
sub SET { 'set' }
sub SIZE { 'size' }
sub SIZEFROM { 'sizefrom' }
sub SLAVES { 'slaves' }
sub SLIDER { 'slider' }
sub STATE { 'state' }
sub STATUS { 'status' }
sub SUNKEN { 'sunken' }
sub TAG { 'tag' }
sub TITLE { 'title' }
sub TO { 'to' }
sub TOGGLE { 'toggle' }
sub TOP { 'top' }
sub TOPLEVEL { 'toplevel' }
sub TRACING { 'tracing' }
sub TRANSIENT { 'transient' }
sub TYPE { 'type' }
sub TYPES { 'types' }
sub UNITS { 'units' }
sub UNPACK { 'unpack' }
sub UNPOST { 'unpost' }
sub UNSET { 'unset' }
sub USER { 'user' }
sub VARIABLE { 'variable' }
sub VERTICAL { 'vertical' }
sub VIEWABLE { 'viewable' }
sub VISIBILITY { 'visibility' }
sub VISUAL { 'visual' }
sub VISUALSAVAILABLE { 'visualsavailable' }
sub VROOTHEIGHT { 'vrootheight' }
sub VROOTWIDTH { 'vrootwidth' }
sub VROOTX { 'vrootx' }
sub VROOTY { 'vrooty' }
sub WIDTH { 'width' }
sub WINDOW { 'window' }
sub WITHDRAW { 'withdraw' }
sub WITHTAG { 'withtag' }
sub WORDEND { 'wordend' }
sub WORDSTART { 'wordstart' }
sub WRITABLE { 'writable' }
sub WRITE { 'write' }
sub XVIEW { 'xview' }
sub YPOSITION { 'yposition' }
sub YVIEW { 'yview' }

1;
