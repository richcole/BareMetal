#!/bin/bash

gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -o prime.o prime.c -DBAREMETAL
ld -T app.ld -o prime.app prime.o

gcc -m64 -fomit-frame-pointer -o prime prime.c -DLINUX
