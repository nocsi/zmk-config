DOCKER := $(shell { command -v podman || command -v docker; })
TIMESTAMP := $(shell date -u +"%Y%m%d%H%M%S")
BUILD_MATRIX := build.txt

.PHONY: all clean distclean

all:
	$(DOCKER) build --tag zmk --file Dockerfile .
	# need pip `remarshal` package and `jq`
	yaml2json build.yaml | jq -c '.include[]' > $(BUILD_MATRIX)
	$(DOCKER) run --rm -it --name zmk \
		-v $(PWD)/$(BUILD_MATRIX):/app/$(BUILD_MATRIX) \
		-v $(PWD)/firmware:/app/firmware:z \
		-v $(PWD)/config:/app/config:ro \
		-e TIMESTAMP=$(TIMESTAMP) \
		-e BUILD_MATRIX=$(BUILD_MATRIX) \
		-e USERID=$(shell id -u) \
		zmk

clean:
	rm -rf firmware/*.uf2 $(BUILD_MATRIX)

distclean:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable
