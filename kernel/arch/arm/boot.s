// Таблица прерываний
interrupt_vector_table:
	b . // Reset
	b .
	b . // SoftWare Interrupt instruction
	b .
	b .
	b .
	b .
	b .

.comm stack, 0x10000 // Оставляем 64k под стек (пойдёт в BSS секцию)
_start:
	.globl _start
	ldr sp, =stack+0x10000 // Настраиваем стек
	bl kernel_main // Прыгаем к main
1: // Вечный цикл
	b 1b @ Halt
