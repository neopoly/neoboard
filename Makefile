NAME=neoboard

check-env:
ifndef DOCKER_REGISTRY
	$(error DOCKER_REGISTRY is undefined)
endif

build:
	docker build -t ${NAME} .

shell: build
	docker run -it --rm ${NAME} bash

test: build
	docker run --rm -it -p 4000:4000 ${NAME}

daemon: build
	docker run -d --name ${NAME} ${NAME}

tag: check-env
	docker tag ${NAME} ${DOCKER_REGISTRY}/${NAME}:latest

push: tag
	docker push ${DOCKER_REGISTRY}/${NAME}:latest
