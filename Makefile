.PHONY: all

vohttp:
	make -C lib/vohttp/
	cp lib/vohttp/out/vohttp_packed.lua lib/

encapsulate: vohttp
	./lib/vohttp/tools/volucapsulate media/css
	./lib/vohttp/tools/volucapsulate media/js

clean:
	find media/css -name '*.css.lua' -delete
	find media/css -name '*.js.lua' -delete
	make -C lib/vohttp/ clean
	rm lib/vohttp_packed.lua
