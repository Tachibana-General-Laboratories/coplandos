#!/usr/bin/env bash

export TARGET=i386
export TOOLPREFIX=i686-elf

TOOLCHAIN_PATH="`pwd`/toolchain/$TOOLPREFIX"

if [ ! -d $TOOLCHAIN_PATH ]; then 
	pushd toolchain
		ARCHES=i686 ./toolchain.sh
	popd
fi

export PATH="$TOOLCHAIN_PATH:$PATH"
export QEMU=qemu-system-$TARGET

