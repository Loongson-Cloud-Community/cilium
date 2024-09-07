# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

ARG TESTER_IMAGE=cr.loongnix.cn/cilium/image-tester:dd09c8d3ef349a909fbcdc99279516baef153f22
ARG GOLANG_IMAGE=cr.loongnix.cn/library/golang:1.21
ARG UBUNTU_IMAGE=cr.loongnix.cn/library/debian:buster

ARG CILIUM_LLVM_IMAGE=cr.loongnix.cn/cilium/cilium-llvm:a8c542efc076b62ba683e7699c0013adb6955f0f
ARG CILIUM_BPFTOOL_IMAGE=cr.loongnix.cn/cilium/cilium-bpftool:d3093f6aeefef8270306011109be623a7e80ad1b
ARG CILIUM_IPTABLES_IMAGE=cr.loongnix.cn/cilium/iptables:67f517af50e18f64cd12625021f1c39246bb4f92

FROM ${CILIUM_LLVM_IMAGE} as llvm-dist
FROM ${CILIUM_BPFTOOL_IMAGE} as bpftool-dist
FROM ${CILIUM_IPTABLES_IMAGE} as iptables-dist

FROM ${GOLANG_IMAGE} as gops-cni-builder

RUN apt-get update && apt-get install -y binutils-loongarch64-linux-gnu

# build-gops.sh will build both archs at the same time
WORKDIR /go/src/github.com/cilium/cilium/images/runtime
RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium/images/runtime --mount=target=/root/.cache,type=cache --mount=target=/go/pkg/mod,type=cache \
    ./build-gops.sh
# download-cni.sh will build both archs at the same time
RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium/images/runtime --mount=target=/root/.cache,type=cache --mount=target=/go/pkg/mod,type=cache \
    ./download-cni.sh

FROM ${UBUNTU_IMAGE} as rootfs

# Change the number to force the generation of a new git-tree SHA. Useful when
# we want to re-run 'apt-get upgrade' for stale images.
ENV FORCE_BUILD=3

# Update ubuntu packages to the most recent versions
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y jq

WORKDIR /go/src/github.com/cilium/cilium/images/runtime
RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium/images/runtime \
    ./install-runtime-deps.sh

COPY --from=iptables-dist /iptables /iptables
RUN dpkg -i /iptables/*\.deb && rm -rf /iptables

RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium/images/runtime \
    ./iptables-wrapper-installer.sh --no-sanity-check

COPY --from=llvm-dist /usr/local/bin/clang /usr/local/bin/llc /usr/local/bin/
COPY --from=bpftool-dist /usr/local /usr/local

ARG TARGETPLATFORM
COPY --from=gops-cni-builder /out/linux/loong64/bin/loopback /cni/loopback
COPY --from=gops-cni-builder /out/linux/loong64/bin/gops /bin/gops

FROM ${TESTER_IMAGE} as test
COPY --from=rootfs / /
COPY --from=llvm-dist /test /test
COPY --from=bpftool-dist /test /test
RUN /test/bin/cst -C /test/llvm
RUN /test/bin/cst -C /test/bpftool

FROM scratch
LABEL maintainer="maintainer@cilium.io"
COPY --from=rootfs / /
