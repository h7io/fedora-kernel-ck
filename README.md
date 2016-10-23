# Fedora kernel packaging and COPR build scripts

Scripts to build architecture-specific Fedora kernel SRPMs with patches from [GeorgeSapkin/kernel_gcc_patch](https://github.com/GeorgeSapkin/kernel_gcc_patch).

Pre-build kernels at: [https://copr.fedorainfracloud.org/coprs/georgespk/](https://copr.fedorainfracloud.org/coprs/georgespk/).

## Supported architectures

### AMD
* k8
* k8sse3
* k10
* bobcat
* bulldozer
* piledriver
* steamroller
* excavator
* jaguar
* zen

### Intel
* core2
* nehalem
* westmere
* sandybridge
* ivybridge
* haswell
* broadwell
* skylake

## Usage

`fedpkg` and `copr-cli` need to be correctly setup before use. More info:
* [https://fedoraproject.org/wiki/Building_a_custom_kernel](https://fedoraproject.org/wiki/Building_a_custom_kernel)
* [https://developer.fedoraproject.org/deployment/copr/copr-cli.html](https://developer.fedoraproject.org/deployment/copr/copr-cli.html)

### `gen-all.sh [branch]`

Generates latest x86_64 kernel SRPMs for all supported architectures for specified branch (default: f24)

### `build-copr.sh [branch]`

Submits built SRPMs for specified branch (default: f24) to [COPR](https://copr.fedorainfracloud.org/coprs/). Assumes that `copr-cli` is correctly initialized and projects in the form of `kernel-gcc-$arch` are already configured in COPR.
