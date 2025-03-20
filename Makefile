IMAGE_TAG ?= hickorydns/hickory-dns:latest
BUILD_ARGS ?=
# All: linux/amd64,linux/arm64,linux/riscv64,linux/ppc64le,linux/s390x,linux/386,linux/mips64le,linux/mips64,linux/arm/v7,linux/arm/v6
# Supported by alpine: linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x,linux/riscv64
PLATFORM ?= linux/amd64
ACTION ?= load
PROGRESS_MODE ?= plain
EXTRA_ARGS ?=

## -- helpers for ENVs possibly used in BUILD_ARGS (manual builds), see README
VERSION ?=
SOURCE_FILE ?=
SOURCE_SHA256 ?=
FEATURES ?=

ifeq ($(origin VERSION),environment)
	BUILD_ARGS += --build-arg VERSION='${VERSION}'
endif

ifeq ($(origin SOURCE_FILE),environment)
	BUILD_ARGS += --build-arg SOURCE_FILE='${SOURCE_FILE}'
endif

ifeq ($(origin SOURCE_SHA256),environment)
	BUILD_ARGS += --build-arg SOURCE_SHA256='${SOURCE_SHA256}'
endif

ifeq ($(origin FEATURES),environment)
	BUILD_ARGS += --build-arg FEATURES='${FEATURES}'
endif

## -- end

.PHONY: build-alpine test-alpine

build-alpine:
	# https://github.com/docker/buildx#building
	docker buildx build \
		--build-arg VCS_REF="$(shell git rev-parse HEAD)" \
		--build-arg BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		--tag $(IMAGE_TAG) \
		--progress $(PROGRESS_MODE) \
		--platform $(PLATFORM) \
		--pull \
		${BUILD_ARGS} \
		$(EXTRA_ARGS) \
		--$(ACTION) \
		./alpine

test-alpine:
	IMAGE_TAG="$(IMAGE_TAG)" \
	docker compose -f ./compose.test.yml up --exit-code-from sut --abort-on-container-exit
