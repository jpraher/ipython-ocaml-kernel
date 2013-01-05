
KERNEL_SRC=/Users/jakob/src/projects/ipython-xlang-kernel/src
KERNEL_LIB=${KERNEL_SRC}
KERNEL_INCLUDE=${KERNEL_SRC}
OCAML_INCLUDE=/opt/local/lib/ocaml

.PHONY: all clean

all: kernel.cmi kernel.cmxa

kernel.mli: kernel.ml
	ocamlfind ocamlc -package yojson -i kernel.ml > kernel.mli

kernel.cmi: kernel.mli
	ocamlfind ocamlc -package yojson kernel.mli

# kernel_stubs.o: kernel_stubs.c
#	$(CC) -c -L${KERNEL_LIB} -I${KERNEL_INCLUDE} -I${OCAML_INCLUDE}  kernel_stubs.c

# kernel_stubs.a: kernel_stubs.o
#	ar rcs kernel_stubs.a kernel_stubs.o

# cmxa - native code
# cma  - byte code

# -ccopt -I${KERNEL_SRC} -cclib -L${KERNEL_SRC} -cclib -lipython-xlang-kernel
# kernel.cmxa: kernel.ml kernel_stubs.a
#	ocamlopt -a -o kernel.cmxa kernel.ml kernel_stubs.a
# ocamlc -where

LIBEXT=.so

%.cmx: %.ml
	ocamlfind ocamlopt -verbose -package yojson -c $<

kernel_stubs.o: kernel_stubs.c
	ocamlc -ccopt -I${KERNEL_INCLUDE} $<

dll_kernel_stubs.$(LIBEXT): kernel_stubs.o
	ocamlmklib -o _kernel_stubs $<  -L${KERNEL_LIB} -lipython-xlang-kernel

kernel.cmxa: kernel.cmx dll_kernel_stubs.$(LIBEXT) kernel.cmi
	ocamlfind ocamlopt -verbose -package yojson -a -o $@ $< -cclib -l_kernel_stubs -cclib -L${KERNEL_LIB} -cclib -lipython-xlang-kernel

# kernel.cmxa: kernel.cmx kernel_stubs.o
#	ocamlmklib -o kernel kernel.cmx kernel_stubs.o -lipython-xlang-kernel -L${KERNEL_LIB}

# kernel_stubs.a -cclib -L${KERNEL_LIB} -cclib -lipython-xlang-kernel
echo_kernel: kernel.cmxa main.ml
	ocamlopt  -verbose -o echo_kernel -cclib -L. unix.cmxa kernel.cmxa  main.ml

clean:
	rm -f *.cmxa
	rm -f *.cmx
	rm -f *.o
	rm -f *.so
	rm -f echo_kernel
