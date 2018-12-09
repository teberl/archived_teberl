.PHONY: help

DOCKER_USERNAME ?= teberl
APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
	@echo "${DOCKER_USERNAME}/$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		-t ${DOCKER_USERNAME}/$(APP_NAME):$(APP_VSN)-$(BUILD) \
		-t ${DOCKER_USERNAME}/$(APP_NAME):latest .

## TODO this part is not running since the cert files from prod are missing
run: ## Run the app in Docker
	docker run --env-file docker.env \
		--expose 4000 -p 4000:4000 \
		--rm -it ${DOCKER_USERNAME}/$(APP_NAME):latest