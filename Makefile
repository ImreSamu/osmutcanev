
makefile_dir := $(abspath $(shell pwd))

.PHONY: all

all: build

build:
	docker build -t imresamu/osmutcanev   .

start:
	docker run  --rm --name osmutcanev -it -v $(makefile_dir):/src imresamu/osmutcanev /src/start.sh

startdev:
	docker run  --rm --name osmutcanev -it -v $(makefile_dir):/src imresamu/osmutcanev /bin/bash

exec:
	docker exec --name osmutcanev -it  /bin/bash

