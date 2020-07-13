# DKAN CLI docker container image

## DockerHub Automated Build Config
DockerHub is configured to build two tags: classic and master:
+ master is for the latest and greatest, drush v10 and should suited to run DKAN2.
+ classic have the latest PHP and tooling, but only drush v8 since it's the upmost version that DKAN-classic supports.

Both docker tags tracks the git master branch. When master is updated, latest
will be built with drush v10 installed and classic will be built with drush v8
installed.

## Work with image locally
Makefile offers handy commands to work with image locally.

### Build
Build image locally.
```
$ make build
```

To build dkan-cli image suitable for Dkan classic (Drupal 7), set the tag variable to classic
```
$ make build TAG=classic
```


### Push
Push image to registry.
```
$ make push
```

### Shell
Run a bash shell on an temporary instance of the image.
```
$ make shell
```

### Run
Run a command on an temporary instance of the image.
```
$ make run CMD='echo "hello world"'
```

### Release (Build + Push)
Build image locally, then push it to remote registry.
```
$ make release
```

## Build on Docker Hub
Build Arguments are set using the hooks overrides, documentation available
[here](https://docs.docker.com/docker-hub/builds/advanced/#override-build-test-or-push-commands).

```
├── hooks
│   └── build
```
