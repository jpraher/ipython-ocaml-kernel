type ip_kernel
external create_kernel : int -> string -> ip_kernel
  = "wrap_new_kernel_with_connection_file"
external env_init : string -> unit = "wrap_kernel_env_init"
external free : ip_kernel -> unit = "wrap_free_kernel"
external start : ip_kernel -> unit = "wrap_kernel_start"
external shutdown : ip_kernel -> unit = "wrap_kernel_shutdown"
external has_shutdown : ip_kernel -> bool = "wrap_kernel_has_shutdown"
type execute_response_t =
    Success of string * string
  | Error of string * string * string list
type native_execute_request_t = { content_string : string; }
type execute_request_t = { content : Yojson.Basic.json; }
val handle_execute_request :
  'a ->
  [< `Assoc of (string * [< `String of string ]) list ] -> execute_response_t
module type HandlerType =
  sig
    type ctx_t
    val execute_request : ctx_t -> execute_request_t -> execute_response_t
  end
module IPython :
  functor (Handler : HandlerType) ->
    sig
      external create_and_set_ipython_handlers :
        ip_kernel -> Handler.ctx_t -> unit
        = "wrap_create_and_set_ipython_handlers"
      val start_kernel :
        int ->
        string ->
        Handler.ctx_t -> ('a -> execute_request_t -> 'b) -> ip_kernel
      val init_kernel :
        string list ->
        Handler.ctx_t -> ('a -> execute_request_t -> 'b) -> ip_kernel
    end
val wait_for_shutdown : ip_kernel -> unit
