#include <stdint.h>
#include <kprintf.h>

int kernel_main(uint32_t magic, uint32_t addr) {
	kprintf("hello, world!");
	return 0;
}

