#use strict;
use Fatal qw(open close);

open MF, '>Makefile';
print MF <<'EOS';
extension=Tk

all:

test:
	perl -Mblib basic_demo
	perl -Mblib demos/widget

install:
	perl -MExtUtils::Install -e install_default $(extension)

uninstall:
	perl do_uninst
EOS
close MF;

open MF, '>make.cmd';
print MF <<'EOS';
set what=%1
set extension=Tk

if "%what%" = "" goto all
if "%what%" = "all" goto all
if "%what%" = "test" goto test
if "%what%" = "install" goto install
if "%what%" = "uninstall" goto uninstall

echo Do not know what to do for "%what%"
exit 1

:all
echo Nothing to do for "all"
goto end

:test
perl -Mblib basic_demo
perl -Mblib demos/widget
goto end

:install
perl -MExtUtils::Install -e install_default %extension%

:uninstall
perl do_uninst
:end
EOS
close MF;

