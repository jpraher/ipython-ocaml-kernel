type ip_kernel
type ctx_t = unit
external create_kernel : int -> string -> ip_kernel
  = "wrap_new_kernel_with_connection_file"
external free_kernel : ip_kernel -> unit = "wrap_free_kernel"
external kernel_start : ip_kernel -> unit = "wrap_kernel_start"
external kernel_shutdown : ip_kernel -> unit = "wrap_kernel_shutdown"
external kernel_has_shutdown : ip_kernel -> bool = "wrap_kernel_has_shutdown"
external create_and_set_ipython_handlers : ip_kernel -> ctx_t -> unit
  = "wrap_create_and_set_ipython_handlers"
type execute_request_t = { code : string; }
type execute_response_t = {
  successful : bool;
  media_type : string;
  data : string;
}
val is_shutdown : bool ref
val handle_execute_request : 'a -> execute_request_t -> execute_response_t
val start_kernel : int -> string -> ctx_t -> 'a -> 'b -> bool
val init_ipython_kernel : string list -> ctx_t -> 'a -> 'b -> bool
