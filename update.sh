#!/bin/bash

[[ $# -ne 1 ]] && (echo "Usage: $0 <branch/tag>"; exit 1)

set -xeuo pipefail

DMD_VERSION=$1

[ -d dmd ] || git clone https://github.com/dlang/dmd.git

pushd dmd

# To go correct branch/tag
git reset --hard master
git fetch
git checkout $DMD_VERSION

# Apply patches
git am -3 ../*.patch
# Verify correct
make -f powernex.mak

# Make new patches
git format-patch $DMD_VERSION
mv *.patch ../

popd

echo -n "$DMD_VERSION" > DMD_VERSION
