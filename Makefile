IMAGE_TAG ?= trustdns/trust-dns:latest
BUILD_ARGS ?=

.PHONY: build-alpine test-alpine push

build-alpine:
	docker build -f ./alpine/Dockerfile ./alpine -t "${IMAGE_TAG}" ${BUILD_ARGS} --build-arg BUILD_DATE="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"

test-alpine:
	IMAGE_TAG="${IMAGE_TAG}" docker-compose -f ./docker-compose.test.yml up --exit-code-from sut --abort-on-container-exit

push:
	@echo "Pushing to ${IMAGE_TAG} in 2sec"
	@sleep 2
	docker push "${IMAGE_TAG}"
