#!/bin/bash

set -euo pipefail

readonly branch=${1:-f24}

readonly patchfilepath=$(ls kernel_ck_patch/*.patch)
readonly patchfilename=${patchfilepath#kernel_ck_patch/}

echo Copying CK patch $patchfilename...
cp $patchfilepath kernel/

cd kernel

readonly spec_file='kernel.spec'

echo Checking out clean $spec_file...
git checkout $spec_file

echo Updating kernel source from $branch branch...
git checkout $branch
git pull

readonly date=$(date +'%a %b %d %Y')
readonly author='Tadas Giniotis <mail@copper.lt>'

readonly major_version=$(grep '%define rpmversion' $spec_file | head -n 1 | awk '{print $3}' | tr '.' '\n' | head -1)
readonly base_sublevel=$(grep '%define base_sublevel' $spec_file | awk '{print $NF}')
readonly stable_update=$(grep '%define stable_update' $spec_file | awk '{print $NF}')
readonly baserelease=$(($(grep '%global baserelease' $spec_file | awk '{print $NF}') + 1))

readonly version=$major_version.$base_sublevel.$stable_update-$baserelease

readonly changelog_main="$date $author - $version"
readonly changelog_entry="* $changelog_main.local\n- Applying kernel patch by Con Kolivas\n"

readonly end_of_patches='# END OF PATCH DEFINITIONS'
readonly gcc_patch="# GCC optimizations\Patch 901: 0001-MultiQueue-Skiplist-Scheduler-v0.202.patch\nPatch 902: 0002-Make-preemptible-kernel-default.patch\nPatch 903: 0003-Expose-vmsplit-for-our-poor-32-bit-users.patch\nPatch 904: 0004-Create-highres-timeout-variants-of-schedule_timeout-.patch\nPatch 905: 0005-Special-case-calls-of-schedule_timeout-1-to-use-the-.patch\nPatch 906: 0006-Convert-msleep-to-use-hrtimers-when-active.patch\nPatch 907: 0007-Replace-all-schedule-timeout-1-with-schedule_min_hrt.patch\nPatch 908: 0008-Replace-all-calls-to-schedule_timeout_interruptible-.patch\nPatch 909: 0009-Replace-all-calls-to-schedule_timeout_uninterruptibl.patch\nPatch 910: 0010-Don-t-use-hrtimer-overlay-when-pm_freezing-since-som.patch\nPatch 911: 0011-Make-hrtimer-granularity-and-minimum-hrtimeout-confi.patch\nPatch 912: 0012-Make-threaded-IRQs-optionally-the-default-which-can-.patch\nPatch 913: 0013-Reinstate-default-Hz-of-100-in-combination-with-MuQS.patch\nPatch 914: 0014-Swap-sucks.patch\nPatch 915: 0015-Make-nohz_full-not-be-picked-up-as-a-default-config-.patch\nPatch 916: 0016-Add-ck1-version.patch\n"

echo Setting default build ID to .local...
sed -i "s/^# define buildid.*/%define buildid .local/g" $spec_file

echo Setting baserelease to $baserelease...
sed -i "s/%global baserelease.*/%global baserelease $baserelease/g" $spec_file

echo Adding GCC patch...
sed -i "/$end_of_patches/ { N; s/$end_of_patches\n/$gcc_patch\n&/ }" $spec_file

echo Updating changelog...
sed -i "/%changelog/a$changelog_entry" $spec_file

rm -rf kernel-$major_version.$base_sublevel.$stable_update*.src.rpm

sed -i "s/^\*.*$author.*/\* $changelog_main/" $spec_file

fedpkg srpm

echo