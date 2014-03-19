# Объявляем константы для multiboot-заголовка
.set ALIGN,    1<<0
.set MEMINFO,  1<<1
.set FLAGS,    ALIGN | MEMINFO
.set MAGIC,    0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

# Собсна сам заголовок
# Подробнее лучше всего можно почитать
# https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
# или перевод http://gownos.blogspot.ru/2011/10/multiboot-specification.html
.section .multiboot
.align 4
	.long MAGIC
	.long FLAGS
	.long CHECKSUM

# Резервируем место под стек
.section .bootstrap_stack, "aw", @nobits
stack_bottom:
	.skip 16384 # 16 KiB
stack_top:

# The kernel entry point.
.section .text
.global _start
.type _start, @function
_start:
	movl $stack_top, %esp
	# Обнуляем EFLAGS.
	pushl   $0
	popf

	# Push the pointer to the Multiboot information structure.
	# Добавляем в стек указатель на multiboot-структуру
	pushl   %ebx
	# Добавляем в стек магическое число для проверки валидности multiboot-структуры
	pushl   %eax

	# Прыгаем к main
	call kernel_main

	# Выключаем обработку прерываний
	cli
	hlt
# Бесконечный цикл
.Lhang:
	jmp .Lhang
.size _start, . - _start
