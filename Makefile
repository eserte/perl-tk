extension=Tk

all:
	@echo Nothing to do, this was already built once

test:
	perl -Mblib ./basic_demo
	perl -Mblib ./demos/widget

install:
	perl -MExtUtils::Install -e install_default $(extension)

uninstall:
	perl do_uninst

