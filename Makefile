DOCKER := $(shell { command -v podman || command -v docker; })

.PHONY: all clean distclean

all:
	$(DOCKER) build --tag zmk --file Dockerfile .
	$(DOCKER) run --rm -it --name zmk \
        -v $(PWD)/build:/app/build \
		-v $(PWD)/config:/app/config:ro \
        -v $(PWD)/firmware:/app/firmware \
		-e USERID=$(shell id -u) \
		zmk

clean:
	rm -rf firmware/*.uf2 build/[^.]*

distclean:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable
