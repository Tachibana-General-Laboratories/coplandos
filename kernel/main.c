#include <stdint.h>
#include <kprintf.h>
#include <uart.h>

int kernel_main(uint32_t magic, uint32_t addr) {
	init_uart();
	kprintf("hello, world! %d \n", 0x666);
	return 0;
}

