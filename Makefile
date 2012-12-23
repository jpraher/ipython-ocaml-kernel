
KERNEL_SRC=../ipython-xlang-kernel/src

.PHONY: all

all: kernel.opt

kernel.mli: kernel.ml
	ocamlc -i kernel.ml > kernel.mli

kernel.cmi: kernel.mli
	ocamlc  kernel.mli

kernel.cmxa: kernel.ml kernel_stubs.c
	ocamlopt -a -o kernel.cmxa -ccopt -I${KERNEL_SRC} -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel  kernel.ml main.ml kernel_stubs.c

echo_kernel: kernel.cmxa main.ml
	ocamlopt -o echo_kernel unix.cmxa kernel.cmxa  main.ml
