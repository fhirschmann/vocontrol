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

clean:
	find media/css -name '*.css.lua' -delete
	find media/css -name '*.js.lua' -delete
	make -C lib/vohttp/ clean
	rm lib/vohttp_packed.lua
