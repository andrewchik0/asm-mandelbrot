#!/bin/bash

# assemble
nasm -fmacho64 program.asm
if (( $? )); then
echo Failed to assemble file
exit 1
fi

# link
ld -static program.o -o program
if (( $? )); then
echo Failed to link program
exit 1
fi

# run
./program

# show return value
echo Program exited with code: $?
