#!/usr/bin/env bash

export TARGET=arm
export TOOLPREFIX=arm-eabi

TOOLCHAIN_PATH="`pwd`/toolchain/$TOOLPREFIX/bin"

if [ ! -d $TOOLCHAIN_PATH ]; then 
	pushd toolchain
		ARCHES=arm ./toolchain.sh
	popd
fi

export PATH="$TOOLCHAIN_PATH:$PATH"
export QEMU=qemu-system-$TARGET

