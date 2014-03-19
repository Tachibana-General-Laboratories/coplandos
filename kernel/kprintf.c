#include <kprintf.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>

static void putc(char c) {
#ifdef UART_DRIVER
	write_serial(c);
#endif
#ifdef VGA_TERM_DRIVER
	terminal_write(c);
#endif
}

static void puts(const char *s, int len) {
	while(len--) putc(*s++);
}

static char buf[1024];
 
int kprintf(const char* restrict fmt, ...) {
	va_list args;

	va_start(args, fmt);
	int i = vsprintf(buf, fmt, args);
	va_end(args);

	puts(buf, i);

	return i;
}

