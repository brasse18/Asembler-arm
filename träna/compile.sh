#!/bin/bash

nasm  -f elf64 $2
ld -s -o $1 $1.o
rm $1.o
