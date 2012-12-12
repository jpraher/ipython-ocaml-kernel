#! /bin/sh
export DYLD_LIBRARY_PATH=../ipython-xlang-kernel/src

./kernel.opt $@
