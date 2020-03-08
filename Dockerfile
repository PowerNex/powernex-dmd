FROM archlinux/base
MAINTAINER Dan Printzell <me@vild.io>

RUN pacman -Syu --noconfirm dmd dtools dub ldc git tar xz base-devel

