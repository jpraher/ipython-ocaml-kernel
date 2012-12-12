


/*
CAMLprim value get_raw_data( value unit )
{
    CAMLlocal1( ml_data );
    char * raw_data;
    int data_len;
    //  get raw_data and data_len here
    //   (if raw_data is c-mallocated,
    //    you can use sizeof() for its length)
    ml_data = caml_alloc_string(data_len);
    memcpy( String_val(ml_data), raw_data, data_len );
    return ml_data;
}*/

// wrap the kernel as ocaml functions


#include "api.h"
#include <caml/mlvalues.h>
#include <caml/alloc.h>


CAMLprim value wrap_new_kernel_with_connection_file(value num_threads,
                                                    value connection_file);
CAMLprim value wrap_free_kernel(value kernel);
CAMLprim value wrap_kernel_start(value kernel);
CAMLprim value wrap_kernel_shutdown(value kernel);
CAMLprim value wrap_kernel_has_shutdown(value kernel);
