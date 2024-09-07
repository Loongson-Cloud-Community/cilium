# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

REGISTRIES ?= cr.loongnix.cn/cilium
# quay.io is not enabled, see https://github.com/cilium/image-tools/issues/11
# REGISTRIES ?= docker.io/cilium quay.io/cilium

PUSH ?= false

OUTPUT := "type=image"
ifeq ($(PUSH),true)
OUTPUT := "type=registry,push=true"
endif

PLATFORMS=linux/loong64

all-images: lint runtime-image builder-image cilium-image operator-image hubble-relay-image

lint:
	scripts/lint.sh

.buildx_builder:
	# see https://github.com/docker/buildx/issues/308
	mkdir -p ../.buildx
	docker buildx create --platform $(PLATFORMS) --buildkitd-flags '--debug' > $@
runtime-image-loong64:
	docker build -t cr.loongnix.cn/cilium/cilium-runtime:1.15.4 \
               --build-arg http_proxy=$(http_proxy) \
               --build-arg https_proxy=$(https_proxy) \
               runtime
runtime-image: .buildx_builder
	TEST=true scripts/build-image.sh cilium-runtime-dev images/runtime $(PLATFORMS) $(OUTPUT) "$$(cat .buildx_builder)" $(REGISTRIES)

update-runtime-image:
	scripts/update-cilium-runtime-image.sh

check-runtime-image:
	CHECK=true scripts/update-cilium-runtime-image.sh

builder-image-loong64:
	docker build -t cr.loongnix.cn/cilium/cilium-builder:1.15.4 \
               --build-arg http_proxy=$(http_proxy) \
               --build-arg https_proxy=$(https_proxy) \
               builder

builder-image: .buildx_builder
	TEST=true scripts/build-image.sh cilium-builder-dev images/builder $(PLATFORMS) $(OUTPUT) "$$(cat .buildx_builder)" $(REGISTRIES)

update-builder-image:
	scripts/update-cilium-builder-image.sh

check-builder-image:
	CHECK=true scripts/update-cilium-builder-image.sh

cilium-image: .buildx_builder
	ROOT_CONTEXT=true scripts/build-image.sh cilium-dev images/cilium $(PLATFORMS) $(OUTPUT) "$$(cat .buildx_builder)" $(REGISTRIES)

operator-image-loong64:
	docker build -t cr.loongnix.cn/cilium/cilium-operator-generic:1.15.4 \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=loong64 \
		--build-arg OPERATOR_VARIANT=operator-generic \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(https_proxy) \
		operator

operator-image: .buildx_builder 
	ROOT_CONTEXT=true scripts/build-image.sh operator-dev images/operator $(PLATFORMS) $(OUTPUT) "$$(cat .buildx_builder)" $(REGISTRIES)

hubble-relay-image: .buildx_builder
	ROOT_CONTEXT=true scripts/build-image.sh hubble-relay-dev images/hubble-relay $(PLATFORMS) $(OUTPUT) "$$(cat .buildx_builder)" $(REGISTRIES)

update-envoy-image:
	scripts/update-cilium-envoy-image.sh

check-envoy-image:
	scripts/check-cilium-envoy-image.sh
