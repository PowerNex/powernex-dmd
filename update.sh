#!/bin/bash

set -euo pipefail

init_colors() {
    ALL_OFF="$(tput sgr0)"
    BOLD="$(tput bold)"
    BLUE="${BOLD}$(tput setaf 4)"
    GREEN="${BOLD}$(tput setaf 2)"
    RED="${BOLD}$(tput setaf 1)"
    YELLOW="${BOLD}$(tput setaf 3)"
		readonly ALL_OFF BOLD BLUE GREEN RED YELLOW
}

log() {
    local fmt=$1; shift
    printf "${GREEN}==>${ALL_OFF}${BOLD} ${fmt}${ALL_OFF}\n" "$@"
}

part() {
    local fmt=$1; shift
    printf "${BLUE}  ->${ALL_OFF}${BOLD} ${fmt}${ALL_OFF}\n" "$@"
}

error() {
    local fmt=$1; shift
    printf "${RED}==> $(gettext "ERROR:")${ALL_OFF}${BOLD} ${fmt}${ALL_OFF}\n" "$@" >&2
}

fix_patches() {
		error "Patches did't apply nicely. Starting shell. 'exit 0' when done"
		bash
}

init_colors

[[ $# -ne 1 ]] && (error "Usage: $0 <branch/tag>"; exit 1)

DMD_VERSION=$1

log "Updating dmd repo"

[ -d dmd ] || git clone https://github.com/dlang/dmd.git

pushd dmd

# To go correct branch/tag
git reset --hard master
git fetch
git checkout $DMD_VERSION
part "Cleaning up files..."
git clean -xdf


log "Applying old patches"
# Apply patches
git am -3 ../*.patch || fix_patches

compile() {
		part "Verifying patches..."
		# Verify correct
		make -f powernex.mak clean
		make -f powernex.mak || (fix_patches; compile)
}

compile

log "Making new patches"
# Make new patches
git format-patch $DMD_VERSION
part "Copying patches to repo..."
mv *.patch ../

popd

log "Finalizing"
part "Updating version file"
echo -n "$DMD_VERSION" > DMD_VERSION

part "Making commit"
git add -A
git commit -sm "Updated to $DMD_VERSION"


log "Done"
