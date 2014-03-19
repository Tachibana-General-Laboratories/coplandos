ARCHDIR:=arch/$(TARGET)

include $(ARCHDIR)/make.config

OBJS += main.o string.o vprintf.o abort.o
CFLAGS += -MD -Iinclude -D__IS_KERNEL

include $(shell find . -name '*.d')

kernel: $(OBJS)
	$(LD) $(LDFLAGS) -T $(ARCHDIR)/linker.ld -o kernel $(OBJS)

clean:
	rm -f $(OBJS) kernel $(shell find . -name '*.d')

