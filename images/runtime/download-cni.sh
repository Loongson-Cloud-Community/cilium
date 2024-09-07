#!/usr/bin/env bash

# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=cni-version.sh
source "${script_dir}/cni-version.sh"
# https://github.com/Loongson-Cloud-Community/containernetworking-plugins/releases/download/v1.4.1/cni-plugins-linux-loong64-v1.4.1.tgz
for arch in loong64; do
  curl --fail --show-error --silent --location "https://github.com/Loongson-Cloud-Community/containernetworking-plugins/releases/download/v${cni_version}/cni-plugins-linux-${arch}-v${cni_version}.tgz" --output "/tmp/cni-${arch}.tgz"
  printf "%s %s" "${cni_sha512[${arch}]}" "/tmp/cni-${arch}.tgz" | sha512sum -c
  mkdir -p "/out/linux/${arch}/bin"
  tar -C "/out/linux/${arch}/bin" -xf "/tmp/cni-${arch}.tgz" ./loopback
done

loongarch64-linux-gnu-strip /out/linux/loong64/bin/loopback
