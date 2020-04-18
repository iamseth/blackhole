SHELL = /bin/bash

build:
	@./build_blacklist.sh

clean:
	@rm -rf blacklist

deploy: build
	@scp blacklist root@docker:/storage/dns/blacklist
	@ssh root@docker 'docker restart dns'
	@ssh root@docker 'docker logs dns --tail 10'

.PHONY: build clean deploy
