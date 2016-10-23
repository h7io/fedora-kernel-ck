#!/bin/bash

set -euo pipefail

cd kernel

readonly spec_file='kernel.spec'

readonly major_version=$(grep '%define rpmversion' $spec_file | head -1 | awk '{print $3}' | tr '.' '\n' | head -1)
readonly base_sublevel=$(grep '%define base_sublevel' $spec_file | awk '{print $NF}')
readonly stable_update=$(grep '%define stable_update' $spec_file | awk '{print $NF}')
readonly baserelease=$(grep '%global baserelease' $spec_file | awk '{print $NF}')

readonly version=$major_version.$base_sublevel.$stable_update-$baserelease

readonly archs=(\
    "k8"\
    "k8sse3"\
    "k10"\
    "bobcat"\
    "bulldozer"\
    "piledriver"\
    "steamroller"\
    "excavator"\
    "jaguar"\
    "zen"\
    "core2"\
    "nehalem"\
    "westmere"\
    "sandybridge"\
    "ivybridge"\
    "haswell"\
    "broadwell"\
    "skylake"\
    )

# default to git branch
readonly branch=${1:-$(git rev-parse --abbrev-ref HEAD)}
readonly release=${branch#f}

for arch in "${archs[@]}"; do
    chroot=fedora-$release-x86_64
    project=kernel-gcc-$arch
    filename=kernel-$version.$arch.fc$release.src.rpm

    copr-cli build --chroot $chroot --nowait $project $filename
done
