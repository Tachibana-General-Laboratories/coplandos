export ROOTDIR:=`pwd`


ifndef TARGET
TARGET := $(shell echo "How about TARGET variable?" 1>&2; exit 1;)
endif

ifndef TOOLPREFIX
TOOLPREFIX := $(shell echo "How about TOOLPREFIX variable?" 1>&2; exit 1;)
endif

ifndef QEMU
QEMU := $(shell if which qemu-system-$(TARGET) > /dev/null; \
	then echo qemu-system-i386; exit; fi; \
	if which qemu > /dev/null; \
	then echo qemu; exit; \
	else \
	echo "How about QEMU?" 1>&2; exit 1; fi;)
endif

export CC := $(TOOLPREFIX)-gcc
export AS := $(TOOLPREFIX)-as
export LD := $(TOOLPREFIX)-ld
export OBJCOPY := $(TOOLPREFIX)-objcopy
export OBJDUMP := $(TOOLPREFIX)-objdump
export CFLAGS := $(CFLAGS) -std=c99 -ffreestanding -Wall -Wextra
export ASFLAGS := $(ASFLAGS)
export LDFLAGS := $(LDFLAGS) -nostdlib -lgcc

.PHONY: all kernel/kernel clean qemu

all: qemu

kernel/kernel:
	$(MAKE) -C kernel kernel

clean:
	$(MAKE) -C kernel clean

qemu: kernel/kernel
	$(QEMU) -kernel kernel/kernel -serial mon:stdio -smp 1 -m 512 

