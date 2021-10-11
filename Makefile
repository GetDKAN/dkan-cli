-include env_make

TAG ?= classic
UBUNTU_VER ?= 20.04

ifeq ($(TAG), classic)
        DRUSH_VER = "^8"
else
        DRUSH_VER = "^10"
endif

REPO = getdkan/dkan-cli
NAME = dkan-cli

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
        --build-arg BASE_IMAGE_TAG=$(UBUNTU_VER) \
	    --build-arg DRUSH_VER=$(DRUSH_VER) \
	    ./

test:
	IMAGE=$(REPO):$(TAG) echo "SKIP"

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
