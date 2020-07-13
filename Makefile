-include env_make

TAG ?= latest
BASE_IMAGE_TAG ?= drupal-acquia-php-7.3

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
	echo $(BASE_IMAGE_TAG)
	docker build -t $(REPO):$(TAG) \
        --build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
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
