
KERNEL_SRC=../ipython-xlang-kernel/src

kernel_stubs.o:
	ocamlc -v -ccopt -I${KERNEL_SRC} -c kernel_stubs.c

kernel.cma:
	ocamlmklib -v -cclib -v -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel kernel_stubs.o kernel.ml -o kernel

# this works for me ...
kernel.opt:
	ocamlopt -o kernel.opt -ccopt -I${KERNEL_SRC} -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel unix.cmxa kernel.ml kernel_stubs.c
