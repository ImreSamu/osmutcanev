.PHONY: all

all: build

build:
	docker build -t imresamu/osmutcanev   .

start:
	docker run  --rm --name osmutcanev -it -v /home/pella/osmutcanev:/src imresamu/osmutcanev /bin/bash

exec:
	docker exec --name osmutcanev -it  /bin/bash

