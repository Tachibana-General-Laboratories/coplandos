#ifndef KPRINTF_H
#define KPRINTF_H 1
#include <stdarg.h>

int kprintf(const char* restrict format, ...);
int vsprintf(char *buf, const char *fmt, va_list args);

#endif
