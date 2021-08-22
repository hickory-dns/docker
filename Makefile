IMAGE_TAG ?= trustdns/trust-dns:latest
BUILD_ARGS ?=

## -- helpers for ENVs possibly used in BUILD_ARGS (manual builds), see README
VERSION ?=
SOURCE_FILE ?=
SOURCE_SHA256 ?=

ifeq ($(origin VERSION),environment)
	BUILD_ARGS += --build-arg VERSION='${VERSION}'
endif

ifeq ($(origin SOURCE_FILE),environment)
	BUILD_ARGS += --build-arg SOURCE_FILE='${SOURCE_FILE}'
endif

ifeq ($(origin SOURCE_SHA256),environment)
	BUILD_ARGS += --build-arg SOURCE_SHA256='${SOURCE_SHA256}'
endif

## -- end

.PHONY: build-alpine test-alpine push

build-alpine:
	@echo "Build arguments: ${BUILD_ARGS}"
	docker build --pull -f ./alpine/Dockerfile ./alpine -t "${IMAGE_TAG}" ${BUILD_ARGS} --build-arg BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"

test-alpine:
	IMAGE_TAG="${IMAGE_TAG}" docker-compose -f ./docker-compose.test.yml up --exit-code-from sut --abort-on-container-exit

push:
	@echo "Pushing to ${IMAGE_TAG} in 2sec"
	@sleep 2
	docker push "${IMAGE_TAG}"
