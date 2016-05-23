.PHONY: all

all: build start startweb

build:
	docker-compose build

start:
	docker-compose up -d  db
	docker-compose run --rm osmutcanev
	docker-compose stop db
	docker-compose rm -f -v

download_osmadmin:
	./src/admin/download_osmadmin.sh

download_osmlatest:
	./src/admin/download_osmlatest.sh

startweb:
	docker-compose up -d web

startdev:
	docker-compose run --rm osmutcanev /bin/bash

down:
	docker-compose down

clean:
	docker-compose rm -f -v

