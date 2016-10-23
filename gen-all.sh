#!/bin/bash

set -euo pipefail

readonly branch=${1:-f24}

readonly patchfilepath=$(ls kernel_gcc_patch/*.patch)
readonly patchfilename=${patchfilepath#kernel_gcc_patch/}

echo Copying GCC patch $patchfilename...
cp $patchfilepath kernel/

cd kernel

readonly spec_file='kernel.spec'

echo Checking out clean $spec_file...
git checkout $spec_file

echo Updating kernel source from $branch branch...
git checkout $branch
git pull

readonly date=$(date +'%a %b %d %Y')
readonly author='George Sapkin <george@sapk.in>'

readonly major_version=$(grep '%define rpmversion' $spec_file | head -n 1 | awk '{print $3}' | tr '.' '\n' | head -1)
readonly base_sublevel=$(grep '%define base_sublevel' $spec_file | awk '{print $NF}')
readonly stable_update=$(grep '%define stable_update' $spec_file | awk '{print $NF}')
readonly baserelease=$(($(grep '%global baserelease' $spec_file | awk '{print $NF}') + 1))

readonly version=$major_version.$base_sublevel.$stable_update-$baserelease

readonly changelog_main="$date $author - $version"
readonly changelog_entry="* $changelog_main.local\n- Added architecture-specific GCC optimizaions\n"

readonly end_of_patches='# END OF PATCH DEFINITIONS'
readonly gcc_patch="# GCC optimizations\nPatch999: $patchfilename\n"

echo Setting default build ID to .local...
sed -i "s/^# define buildid.*/%define buildid .local/g" $spec_file

echo Setting baserelease to $baserelease...
sed -i "s/%global baserelease.*/%global baserelease $baserelease/g" $spec_file

echo Adding GCC patch...
sed -i "/$end_of_patches/ { N; s/$end_of_patches\n/$gcc_patch\n&/ }" $spec_file

echo Updating changelog...
sed -i "/%changelog/a$changelog_entry" $spec_file

rm -rf kernel-$major_version.$base_sublevel.$stable_update*.src.rpm

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

for arch in "${archs[@]}"; do
    hi_arch=$(echo $arch | tr '[:lower:]' '[:upper:]')

    echo Generating $arch source RPM...
    echo CONFIG_M$hi_arch=y > config-local

    sed -i "s/^%define buildid.*/%define buildid .$arch/" $spec_file
    sed -i "s/^\*.*$author.*/\* $changelog_main\.$arch/" $spec_file

    fedpkg srpm

    echo
done
