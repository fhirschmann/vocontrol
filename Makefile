.PHONY: all release

VERSION := $(shell grep VERSION main.lua | sed -e 's/    VERSION=$"//' -e 's/$",//')

all: vohttp encapsulate

vohttp:
	make -C lib/vohttp/
	cp lib/vohttp/out/vohttp_packed.lua lib/

encapsulate:
	volucapsulate media/css
	volucapsulate media/js

release: vohttp
	rm -rf _release
	git checkout-index -f -a --prefix=_release/vocontrol/
	cp lib/vohttp_packed.lua _release/vocontrol/lib
	make -C _release/vocontrol/ encapsulate
	find _release/vocontrol/media/css -name '*.css' -delete
	find _release/vocontrol/media/js -name '*.js' -delete
	rm -r _release/vocontrol/lib/vohttp
	rm _release/vocontrol/.gitignore
	rm _release/vocontrol/.gitmodules
	mv _release/vocontrol _release/vocontrol-$(VERSION)
	cd _release && zip -r vocontrol-$(VERSION).zip vocontrol-$(VERSION)
	cd _release && gpg --armor --detach-sign vocontrol-$(VERSION).zip
	cd _release && tar czf vocontrol-$(VERSION).tar.gz vocontrol-$(VERSION)
	cd _release && gpg --armor --detach-sign vocontrol-$(VERSION).tar.gz

release-upload:
	cd _release && scp vocontrol-$(VERSION).zip vocontrol-$(VERSION).zip.asc 0x0b.de:/var/www/dl.0x0b.de/htdocs/vocontrol
	cd _release && scp vocontrol-$(VERSION).tar.gz vocontrol-$(VERSION).tar.gz.asc 0x0b.de:/var/www/dl.0x0b.de/htdocs/vocontrol

clean:
	find media/css -name '*.css.lua' -delete
	find media/css -name '*.js.lua' -delete
	make -C lib/vohttp/ clean
	rm lib/vohttp_packed.lua
	rm -rf _release
