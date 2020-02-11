VERSION=0.4
IMAGE=arne/markdown-friends:$(VERSION)


build:
	echo $(IMAGE)
	docker build . -t $(IMAGE) -t quay.io/$(IMAGE)


run:
	docker run -it -p 8081:8081 $(IMAGE)


tag:	build
	@echo $(VERSION)
	git tag -a v$(VERSION) -m v$(VERSION)
	git push --tags


push:	build
	docker push $(IMAGE)
	docker push quay.io/$(IMAGE)


.PHONY: build run tag push
