(* -----------------------------------------------------------------------------
 * Copyright (C) 2012 Jakob Praher
 *
 * Distributed under the terms of the BSD License. The full license is in
 * the file COPYING, distributed as part of this software.
 * -----------------------------------------------------------------------------
 *)

open Sys
open Unix
open Yojson.Basic

type ip_kernel 
  
external create_kernel    : int -> string -> ip_kernel = "wrap_new_kernel_with_connection_file"
external env_init  : string -> unit = "wrap_kernel_env_init"
external free      : ip_kernel -> unit = "wrap_free_kernel"
external start     : ip_kernel -> unit = "wrap_kernel_start"
external shutdown  : ip_kernel -> unit = "wrap_kernel_shutdown"
external has_shutdown : ip_kernel -> bool = "wrap_kernel_has_shutdown"


type execute_response_t =
  | Success of string * string
  | Error of string * string * string list
    
(* type context_t *)
(* version of format *)
type native_execute_request_t  = { content_string: string }
type execute_request_t = { content: json }
(* type execute_response_t = { successful:bool; media_type: string; data: string } *)


let handle_execute_request ctx request =
  match request with 
      `Assoc obj ->  
        match List.assoc "code" obj with 
            `String code -> Success ("text/plain", code )
(*
  let `Assoc obj = request.content in  
  let `String code = List.assoc "code" obj in
*)
    
(* let kernel = create_kernel 1 "/Users/jakob/.ipython/profile_default/security/kernel-7321.json" *)

module type HandlerType = sig
  type ctx_t
  val execute_request : ctx_t -> execute_request_t -> execute_response_t
end

module IPython = functor(Handler: HandlerType) ->
struct
  external create_and_set_ipython_handlers : ip_kernel -> Handler.ctx_t -> unit = "wrap_create_and_set_ipython_handlers"

  let start_kernel num_threads conn_file ctx execute_request_fn =
  begin
    Callback.register "handle_execute_request" (fun ctx {content_string = text}  -> execute_request_fn ctx {content = (from_string text) });
    let kernel = create_kernel num_threads conn_file in
    begin
      let shutdown_fn = fun _ -> shutdown kernel in
      signal sigint (Signal_handle  shutdown_fn);
      create_and_set_ipython_handlers kernel ctx ;
      start kernel;
      kernel
    end
  end

  let init_kernel argv =
    let conn_file = ref "" in
    (* parse options *)
    let rec get_options xs =
      match xs with
          [] -> ()
        | "-f" :: file :: xs' -> conn_file := file; get_options xs'
        | _ :: xs' -> get_options xs'
    in
    get_options argv;
    start_kernel 1 (!conn_file)

end

let wait_for_shutdown kernel  =
  while not (has_shutdown kernel) do
    Unix.sleep 1
  done;
  free kernel
    


