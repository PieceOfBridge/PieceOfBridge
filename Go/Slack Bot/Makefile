ifneq ($(TAG),)
VERSION := $(TAG)
else



ifeq ("$(BRANCH_NAME)","master")
VERSION := latest
else
VERSION := $(shell git symbolic-ref -q --short HEAD || git describe --tags --exact-match)
endif

endif

export APP := js-bot
export VERSION := $(VERSION)
export REPO := docker.domain.ru
export DOCKER_BUILDKIT=1
export NOCACHE := $(if $(NOCACHE),"--no-cache")

push:
	@docker push ${REPO}/${APP}:${VERSION}

build:
	@docker build ${NOCACHE} --pull \
	-t ${REPO}/${APP}:${VERSION} \
	--ssh default \
	--progress=plain \
	--build-arg APP=${APP} \
	--build-arg VERSION=${VERSION} .