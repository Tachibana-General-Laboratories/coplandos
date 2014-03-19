#include <stdint.h>
#include <kprintf.h>
#include <uart.h>

int kernel_main(uint32_t magic, uint32_t addr) {
	init_uart();
	kprintf("hello, world!\n");
	return 0;
}

