#!/usr/bin/env bash

# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

# renovate: datasource=github-release-attachments depName=cilium/hubble
hubble_version="v0.13.2"

declare -A hubble_sha256
# renovate: datasource=github-release-attachments depName=cilium/hubble digestVersion=v0.13.2
hubble_sha256[loong64]="9b9cae4c9411caba245b3501630498eb84485db46afd876aeb9ce947736f1b53"

for arch in loong64 ; do
  curl --fail --show-error --silent --location "https://github.com/Loongson-Cloud-Community/hubble/releases/download/${hubble_version}/hubble-linux-${arch}.tar.gz" --output "/tmp/hubble-${arch}.tgz"
  printf "%s %s" "${hubble_sha256[${arch}]}" "/tmp/hubble-${arch}.tgz" | sha256sum -c
  mkdir -p "/out/linux/${arch}/bin"
  tar -C "/out/linux/${arch}/bin" -xf "/tmp/hubble-${arch}.tgz" hubble
done

loongarch64-linux-gnu-strip /out/linux/loong64/bin/hubble

