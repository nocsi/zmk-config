DOCKER := $(shell { command -v podman || command -v docker; })

.PHONY: all clean distclean

all:
	$(DOCKER) build --tag zmk --build-arg USER_ID=$(shell id -u) .
	$(DOCKER) volume create build
	$(DOCKER) run --rm -it --name zmk \
        -v build:/app \
		-v $(PWD)/config:/app/config:ro \
        -v $(PWD)/firmware:/app/firmware \
        -e OUTPUT_CONFIG=$(OUTPUT_CONFIG) \
		zmk

clean:
	rm -rf firmware/[^.]*
	$(DOCKER) volume rm build config firmware

distclean:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable
