SHELL = /bin/bash

build:
	@./build_blacklist.sh

clean:
	@rm -rf blacklist

install:
	@mv blacklist /etc/unbound/blacklist
	@systemctl restart unbound
	@systemctl status unbound

.PHONY: build clean install
