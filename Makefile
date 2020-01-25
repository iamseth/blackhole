SHELL = /bin/bash


build:
	@./build_blacklist.sh

deploy:
	@scp adservers root@docker:/storage/dns/adservers


.PHONY: build deploy
