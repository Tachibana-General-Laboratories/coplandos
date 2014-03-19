# coplandos 0.1.0

Поддерживаемые платфотрмы на данный момент: qemu-system-i386 и qemu-system-arm

Сборка тулчейна
```bash
cd toolchain
ARCHES="arm i686" ./toolchain.sh
```

Сборка под arm
```bash
. ./activate-arm.sh
make
```

Сборка под i386
```bash
. ./activate-i686.sh
make
```

После сборки ядра оно автоматически запускается в qemu.

При смене архитектуры обязательно выполнить `make clean`.

