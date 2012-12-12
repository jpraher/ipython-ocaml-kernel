
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

#include "kernel_stubs.h"

CAMLprim
value wrap_new_kernel_with_connection_file(value num_threads,
                                           value connection_file)
{
    int num_threads_ = Int_val(num_threads);
    const char * connection_file_ = String_val(connection_file);
    kernel_t * k = new_kernel_with_connection_file(num_threads_, connection_file_);
    return (value)k;
}

CAMLprim
value wrap_free_kernel(value kernel) {
    kernel_t * k = (kernel_t*)kernel;
    free_kernel(k);
    return Val_unit;
}

CAMLprim
value wrap_kernel_shutdown(value kernel) {
    kernel_t * k = (kernel_t*)kernel;
    kernel_shutdown(k);
    return Val_unit;
}

CAMLprim
value wrap_kernel_start(value kernel) {
    kernel_t * k = (kernel_t*)kernel;
    kernel_start(k);
    return Val_unit;
}

CAMLprim
value wrap_kernel_has_shutdown(value kernel) {
    kernel_t * k = (kernel_t*)kernel;
    return Val_bool(kernel_has_shutdown(k));
}
