#include <kprintf.h>

__attribute__((__noreturn__))
void abort(void) {
	// TODO: Add proper kernel panic.
	kprintf("Kernel Panic: abort()\n");
	while (1) {}
	__builtin_unreachable();
}

