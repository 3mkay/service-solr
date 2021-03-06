-include env_make

VERSION ?= 7.5.0
FROM ?= solr:7.5.0-alpine
TAG ?= $(VERSION)

REPO ?= docksal/solr
NAME = docksal-solr-$(VERSION)
SOLR_DEFAULT_CONFIG_SET ?= search_api_solr_8.x-2.0

ifneq ($(STABILITY_TAG),)
	ifneq ($(TAG),latest)
		override TAG := $(TAG)-$(STABILITY_TAG)
	endif
endif

.PHONY: build test push shell run start stop logs clean release

build:
	VERSION=$(VERSION) scripts/download_configsets.sh
	docker build -t $(REPO):$(TAG) --build-arg FROM=$(FROM) --build-arg VERSION=$(VERSION) --build-arg SOLR_DEFAULT_CONFIG_SET=$(SOLR_DEFAULT_CONFIG_SET) .

test:
	IMAGE=$(REPO):$(TAG) NAME=$(NAME) VERSION=$(VERSION) ./tests/test.bats

push:
	docker push $(REPO):$(TAG)

shell: clean
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run: clean
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

start: clean
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

exec:
	docker exec $(NAME) /bin/bash -c "$(CMD)"

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	docker rm -f $(NAME) >/dev/null 2>&1 || true

release: build push

default: build
