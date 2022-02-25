SHELL = /bin/bash
SERVER = carbon

build:
	@./build_blacklist.sh

clean:
	@rm -rf blacklist

install: clean build
	@mv blacklist /etc/unbound/blacklist
	@systemctl restart unbound
	@systemctl status unbound

remote-install:
	@rsync -a "$(PWD)/" carbon:/tmp/blackhole/ --delete
	@ssh $(SERVER) "cd /tmp/blackhole && sudo make install"

.PHONY: build clean install remote-install
