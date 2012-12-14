
KERNEL_SRC=../ipython-xlang-kernel/src

.PHONY: all

all: kernel.opt

kernel_stubs.o:
	ocamlc -v -ccopt -I${KERNEL_SRC} -c kernel_stubs.c

kernel.cma:
	ocamlmklib -v -cclib -v -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel kernel_stubs.o kernel.ml -o kernel

kernel.mli: kernel.ml
	ocamlc -i kernel.ml > kernel.mli

# this works for me ...
kernel.opt: kernel.ml kernel_stubs.c
	ocamlopt -o kernel.opt -ccopt -I${KERNEL_SRC} -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel unix.cmxa kernel.ml kernel_stubs.c
