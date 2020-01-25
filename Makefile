SHELL = /bin/bash


build:
	@./build_blacklist.sh

deploy:
	@scp adservers root@docker:/storage/dns/adservers
	@ssh root@docker 'docker restart dns'

.PHONY: build deploy

