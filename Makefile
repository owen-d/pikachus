REPO = owend/pikachus
TAG = latest
IMAGE = $(REPO):$(TAG)

.PHONY: build
build:
	stack exec site build

.PHONY: build-docker
build-docker: build
	docker build -t $(IMAGE) .

.PHONY: deploy-docker
deploy-docker: build-docker
	docker push $(IMAGE)
