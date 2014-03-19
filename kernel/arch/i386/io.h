#ifndef IO_H
#define IO_H

#include <stdint.h>

#define asm __asm__ volatile

static inline uint8_t
inb(uint16_t port) {
	uint8_t data;

	asm("in %1,%0" : "=a" (data) : "d" (port));
	return data;
}

static inline void
outb(uint16_t port, uint8_t data) {
	asm("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(uint16_t port, uint16_t data) {
	asm("out %0,%1" : : "a" (data), "d" (port));
}

#endif

