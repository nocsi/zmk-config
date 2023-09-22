DOCKER := $(shell { command -v podman || command -v docker; })

.PHONY: all clean distclean

all:
	$(DOCKER) build --tag zmk --build-arg USER_ID=$(shell id -u) .
	$(DOCKER) run --rm -it --name zmk \
        -v $(PWD)/bin:/app/bin:ro \
        -v $(PWD)/build:/app/build \
        -v $(PWD)/build.yaml:/app/build.yaml:ro \
		-v $(PWD)/config:/app/config:ro \
        -v $(PWD)/firmware:/app/firmware \
        -e OUTPUT_CONFIG=$(OUTPUT_CONFIG) \
		zmk

clean:
	rm -rf firmware/[^.]* build/[^.]*

distclean:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable
