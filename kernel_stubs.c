
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
#include <caml/callback.h>
#include <caml/memory.h>
#include <assert.h>
#include <string.h>

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
    static value * handle_execute_request_f = NULL;
    if (handle_execute_request_f == NULL) {
        handle_execute_request_f = caml_named_value("handle_kernel_shutdown");
        // assert(handle_execute_request_f != NULL);
    }

    if (handle_execute_request_f != NULL) {
        caml_callback(*handle_execute_request_f, Val_unit);
    }
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

/*
  handle callback
 */
int wrap_handle_execute_request(void * ctx,
                                const ipython_execute_request_t * ext_request,
                                ipython_execute_response_t      * ext_response
                                )
{
    static value * handle_execute_request_f = NULL;
    if (handle_execute_request_f == NULL) {
        handle_execute_request_f = caml_named_value("handle_execute_request");
        assert(handle_execute_request_f != NULL);
    }


    // convert the request
    value request, response, resp_successful, resp_media_type, resp_data;

    request = caml_alloc(1, 0);
    Store_field(request, 0, caml_copy_string(ext_request->code));

    response = caml_callback2(*handle_execute_request_f,
                                  (value)ctx,
                                  request
                                 );

    resp_successful  = Field(response, 0);
    resp_media_type  = Field(response, 1);
    resp_data        = Field(response, 2);

    ext_response->successful = Int_val(resp_successful);
    ext_response->media_type = strdup(String_val(resp_media_type));
    ext_response->data       = strdup(String_val(resp_data));

    return 1;
}


CAMLprim
value wrap_create_and_set_ipython_handlers(value kernel, value ctx) {

    kernel_t * k = (kernel_t*)kernel;
    shell_handler_t * s = new_ipython_shell_handler(k);
    handler_table_t table;
    table.context = (void*) ctx;
    table.generic = NULL;
    table.execute_request = &wrap_handle_execute_request;
    ipython_shell_handler_set_handlers(s, &table);
    return Val_unit;
}
