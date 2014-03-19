#include <stdint.h>
#include <stdbool.h>
#define SERIAL_BASE 0x16000000
#define SERIAL_FLAG_REGISTER 0x18
#define SERIAL_BUFFER_FULL (1 << 5)

static volatile uint32_t *uart;

void init_uart() {
	uart = (volatile uint32_t*)SERIAL_BASE;
}

static inline bool buffer_full() {
	return *(uart + SERIAL_FLAG_REGISTER) & SERIAL_BUFFER_FULL;
}

char read_uart() {
	// TODO
	return 0;
}

void write_uart(char c) {
	while(buffer_full());

	*uart = c;

	while(buffer_full());
}
 
