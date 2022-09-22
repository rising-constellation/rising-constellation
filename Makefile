.PHONY: build build-back upload upload-front upload-back
VERSION := $(shell git --no-pager describe --always --dirty)

help:
	@echo "Commands:\n"
	@echo "  make ni"
	@echo "  -> npm install all frontend projects\n"
	@echo "  make nr"
	@echo "  -> npm rebuild node-sass in all frontend projects\n"
	@echo "  make a|b|c"
	@echo "  -> run node 1/2/3\n"

ni:
	cd assets && npm install
	cd front/ && npm install

nr:
	cd assets && npm rebuild node-sass
	cd front/ && npm rebuild node-sass

build:
	echo $(VERSION) > priv/VERSION
	docker build -t build_image --build-arg APP_REVISION=$(VERSION) --build-arg BACK_ONLY=false  .
	docker create --name extract build_image
	docker cp extract:/home/rc/build/vue.tar.gz ./build/
	docker cp extract:/home/rc/build/rc.tar.gz ./build/
	docker rm extract

build-back:
	docker build -t build_image --build-arg APP_REVISION=$(VERSION) --build-arg BACK_ONLY=true .
	docker create --name extract build_image
	docker cp extract:/home/rc/build/rc.tar.gz ./build/
	docker rm extract

a:
	mix compile
	PORT=4000 ERL_AFLAGS="-name node_1@127.0.0.1 -setcookie on-est-bien-bien-bien-bien-bien" iex -S mix phx.server
b:
	PORT=4001 ERL_AFLAGS="-name node_2@127.0.0.1 -setcookie on-est-bien-bien-bien-bien-bien" iex -S mix phx.server
c:
	PORT=4002 ERL_AFLAGS="-name node_3@127.0.0.1 -setcookie on-est-bien-bien-bien-bien-bien" iex -S mix phx.server

upload: upload-front upload-back

upload-front:
	./upload-front.sh

upload-back:
	./upload-back.sh
