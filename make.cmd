set extension=Tk
set what=%1

if "%what%" == "" goto all
if "%what%" == "all" goto all
if "%what%" == "test" goto test
if "%what%" == "install" goto install
if "%what%" == "uninstall" goto uninstall

echo Do not know what to do for "%what%"
exit 1

:all
echo Nothing to do, this was already built once
goto end

:test
perl -Mblib ./basic_demo
perl -Mblib ./demos/widget
goto end

:install
perl -MExtUtils::Install -e install_default %extension%
goto end

:uninstall
perl do_uninst
:end
