VERSION := $(shell cat VERSION)
BUILD_TIME := $(shell date -u +%Y-%m-%dT%H:%M:%S)
COMMIT := $(shell git log --pretty=format:'%h' -n 1)
BIN_PATH := bin/duclean
PACKAGE_BASE := github.com/c0va23/duclean

init_dir:
	mkdir -p bin/
	mkdir -p releases/

get_deps:
	git submodule init
	git submodule update

test:
	go test images/*.go
	go test containers/*.go
	go test volumes/*.go

build_duclean: init_dir
	go build -o $(BIN_PATH) \
		-ldflags "-X main.version=$(VERSION) \
			-X main.buildTime=$(BUILD_TIME) \
			-X main.commit=$(COMMIT)" \
		$(PACKAGE_BASE)/cmd/duclean

build: build_duclean

push_tag:
	git tag v$(VERSION)
	git push origin v$(VERSION)

archive: init_dir build
	bzip2 --compress --keep $(BIN_PATH) --stdout > releases/duclean-v$(VERSION).bz2
