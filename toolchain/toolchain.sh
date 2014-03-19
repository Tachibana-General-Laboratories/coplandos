#!/usr/bin/env bash

# Определяем операционку
HOSTOS=`uname`
# Определяем архитектуру нашего пека
HOSTARCH=`uname -m`
# Будем компилировать компилятор в несколько потоков
PARALLEL=-j8
# Кстати скачаем мы всё отсюда
GNU_FTP=ftp://ftp.gnu.org/gnu
MAKE=make

# Включаем версии всех частей тулчейна
. ./toolvers.sh

# Удобства ради будет возможность создавать тулчейн сразу под несколько архитектур
# Вот так
#   export ARCHES="i686 arm x86_64"
#   ./toolchains.sh
# , например
# При этом надо выдавать ошибку если перепенная незаполнена
if [ -z "$ARCHES" ]; then
	echo "WTF?! Environment variable ARCHES is empty"
	exit 1
fi

# Донастраиваем разные переменные
if [ "$HOSTOS" = "Linux" ]; then
	# как на счёт знания о количестве ядер процессора
	COUNT=`grep processor /proc/cpuinfo | wc -l`
	PARALLEL=-j`expr $COUNT + $COUNT`
fi
if [ "$HOSTOS" = "FreeBSD" ]; then
	# Заголовки и библиотеки можно посмотреть и там
	export CPPFLAGS=-I/usr/local/include
	export LDFLAGS=-L/usr/local/lib
	# нам нужен гнутый make
	MAKE=gmake
fi
if [ "$HOSTOS" = "Darwin" ]; then
	# На маке всё не как у людей
	export CPPFLAGS=-I/opt/local/include
	export LDFLAGS=-L/opt/local/lib
fi

if [ "$HOSTARCH" = "amd64" ]; then
	HOSTARCH=x86_64
fi

# Скачаные исходники будем хранить в отдельной папке
mkdir -p src
pushd src
	# Качаем всё необходимое
	if [ ! -f binutils-$BINVER.tar.bz2 ]; then
		wget -N $GNU_FTP/binutils/binutils-$BINVER.tar.bz2
	fi
	if [ ! -f gcc-$GCCVER.tar.bz2 ]; then
		wget -N $GNU_FTP/gcc/gcc-$GCCVER/gcc-$GCCVER.tar.bz2
	fi
	if [ ! -f gdb-$GDBVER.tar.bz2 ]; then
		wget -N $GNU_FTP/gdb/gdb-$GDBVER.tar.bz2
	fi
	if [ ! -f mpfr-$MPFRVER.tar.bz2 ]; then
		wget -N $GNU_FTP/mpfr/mpfr-$MPFRVER.tar.bz2
	fi
	if [ ! -f mpc-$MPCVER.tar.gz ]; then
		wget -N $GNU_FTP/mpc/mpc-$MPCVER.tar.gz
	fi
	if [ ! -f gmp-$GMPVER.tar.bz2 ]; then
		wget -N $GNU_FTP/gmp/gmp-$GMPVER.tar.bz2
	fi

	# Скачанное надо неким образом распаковать
	function extract-tool()
	{
		echo "extract-tool " $1 $2 $3 $4

		TARFILE=${1}-${2}.tar$3
		TARGETDIR=${1}-${2}

		if [ -f ${TARGETDIR}/.extracted ]; then
			echo "$TARFILE already extracted into $TARGETDIR, skipping"
			return 0
		fi

		if [ ! -f $TARFILE ]; then
			echo "error, missing $TARFILE"
			exit 1
		fi

		echo extracting $TARFILE
		rm -rf $TARGETDIR
		tar xf $TARFILE || exit 1

		# Вы ведь внимательно читаете?
		# Эта штука нам потом пригодится
		# Будем патчить наш кросскомпилятор
		if [ ! -z "$4" ]; then
			echo patching $1
			patch -d $TARGETDIR -p1 < ../$4 || exit 1
		fi

		# Метим папочку на предмет успешной распаковки
		touch $TARGETDIR/.extracted || exit 1

		echo extracted $1
	}

	# Ну и расспаковываем всё
	if [ ! -f .extracted-stamp ]; then
		extract-tool binutils $BINVER .bz2 binutils-patch.txt
		extract-tool gcc $GCCVER .bz2 gcc-patch.txt
		extract-tool gdb $GDBVER .bz2 gdb-patch.txt
		extract-tool gmp $GMPVER .bz2
		extract-tool mpc $MPCVER .gz
		extract-tool mpfr $MPFRVER .bz2
		# Делаем отметочку об успешной распаковке всего
		touch .extracted-stamp
	fi

	# Для удобства сделаем символические ссылки
	pushd gcc-$GCCVER
		ln -sf ../gmp-$GMPVER gmp
		ln -sf ../mpc-$MPCVER mpc
		ln -sf ../mpfr-$MPFRVER mpfr
	popd
popd

# Кросскомпилятор сам себя не соберёт
# Посему настало время для сборки
for ARCH in $ARCHES; do
	if [ "$ARCH" == "arm" ]; then
		# Для arm по умолчанию создаём кросс без эльфов
		TARGET=arm-eabi
	else
		if [[ "$ARCH" != *-elf* ]]; then
			TARGET=$ARCH-elf
		else
			TARGET=$ARCH
		fi
	fi

	# Сюда всё будет собираться
	INSTALLPATH=`pwd`/$TARGET

	# Собирать будем в отдельной папке
	mkdir -p build
	BINBUILDPATH=build/binutils-$BINVER-$ARCH-$HOSTOS-$HOSTARCH
	GCCBUILDPATH=build/gcc-$GCCVER-$ARCH-$HOSTOS-$HOSTARCH
	GDBBUILDPATH=build/gdb-$GDBVER-$ARCH-$HOSTOS-$HOSTARCH

	export PATH=$INSTALLPATH/bin:$PATH

	# Начнём с binutils
	if [ ! -f $BINBUILDPATH/built.txt ]; then
		mkdir -p $BINBUILDPATH
		pushd $BINBUILDPATH &&
			../../src/binutils-$BINVER/configure --target=$TARGET --prefix=$INSTALLPATH --disable-werror --disable-nls &&
			#$MAKE configure-host &&
			$MAKE $PARALLEL &&
			$MAKE install &&
			touch built.txt || exit 1
		popd
	fi

	# А теперь сам gcc
	if [ ! -f $GCCBUILDPATH/built.txt ]; then
		ARCH_OPTIONS=
		if [ $ARCH == "arm" ]; then
			ARCH_OPTIONS="--with-cpu=arm926ej-s --with-fpu=vfp"
		fi
		mkdir -p $GCCBUILDPATH
		pushd $GCCBUILDPATH &&
			# Кстати ни кому не нужен кросскомпилятор под другие ЯП из тех, что поддерживаются в gcc?
			# Например язык Ada или C++
			../../src/gcc-$GCCVER/configure --target=$TARGET --prefix=$INSTALLPATH --disable-nls --enable-languages=c $ARCH_OPTIONS --without-headers --disable-werror &&
			$MAKE all-gcc $PARALLEL &&
			$MAKE all-target-libgcc $PARALLEL &&
			$MAKE install-gcc &&
			$MAKE install-target-libgcc &&
			touch built.txt || exit 1
		popd
	fi

	# И отладчик заодно скомпилируем
	if [ ! -f $GDBBUILDPATH/built.txt ]; then
		mkdir -p $GDBBUILDPATH
		pushd $GDBBUILDPATH &&
			../../src/gdb-$GDBVER/configure --target=$TARGET --prefix=$INSTALLPATH --disable-werror &&
			$MAKE $PARALLEL &&
			$MAKE install &&
			touch built.txt || exit 1
		popd
	fi
done

echo The end

