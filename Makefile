.PHONY: all release

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


clean:
	find media/css -name '*.css.lua' -delete
	find media/css -name '*.js.lua' -delete
	make -C lib/vohttp/ clean
	rm lib/vohttp_packed.lua
