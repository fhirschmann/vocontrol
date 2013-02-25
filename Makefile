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
	git checkout-index -f -a --prefix=_release/vomote/
	cp lib/vohttp_packed.lua _release/vomote/lib
	make -C _release/vomote/ encapsulate
	find _release/vomote/media/css -name '*.css' -delete
	find _release/vomote/media/js -name '*.js' -delete
	rm -r _release/vomote/lib/vohttp
	rm _release/vomote/.gitignore
	rm _release/vomote/.gitmodules
	mv _release/vomote _release/vomote-$(VERSION)
	cd _release && zip -r vomote-$(VERSION).zip vomote-$(VERSION)
	cd _release && tar czf vomote-$(VERSION).tar.gz vomote-$(VERSION)

release-upload:
	scp _release/vomote-$(VERSION).zip 0x0b.de:/var/www/vomote.0x0b.de/htdocs/releases
	scp _release/vomote-$(VERSION).tar.gz 0x0b.de:/var/www/vomote.0x0b.de/htdocs/releases

clean:
	find media/css -name '*.css.lua' -delete
	find media/css -name '*.js.lua' -delete
	make -C lib/vohttp/ clean
	rm lib/vohttp_packed.lua
	rm -rf _release
