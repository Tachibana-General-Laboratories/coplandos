ARCHDIR:=arch/$(TARGET)

include $(ARCHDIR)/make.config

OBJS += main.o string.o vsprintf.o kprintf.o abort.o
CFLAGS += -MD -Iinclude -D__IS_KERNEL

include $(shell find . -name '*.d')

kernel: $(OBJS)
	$(CC) -T $(ARCHDIR)/linker.ld -o kernel $(OBJS) $(LDFLAGS)

clean:
	rm -f $(OBJS) kernel $(shell find . -name '*.d')

