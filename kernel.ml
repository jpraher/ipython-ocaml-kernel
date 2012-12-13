(* -----------------------------------------------------------------------------
 * Copyright (C) 2012 Jakob Praher
 *
 * Distributed under the terms of the BSD License. The full license is in
 * the file COPYING, distributed as part of this software.
 * -----------------------------------------------------------------------------
 *)

open Sys
open Unix

type ip_kernel 
type ctx_t = unit
  
external create_kernel    : int -> string -> ip_kernel = "wrap_new_kernel_with_connection_file"
external free_kernel      : ip_kernel -> unit = "wrap_free_kernel"
external kernel_start     : ip_kernel -> unit = "wrap_kernel_start"
external kernel_shutdown  : ip_kernel -> unit = "wrap_kernel_shutdown"
external kernel_has_shutdown : ip_kernel -> bool = "wrap_kernel_has_shutdown"
external create_and_set_ipython_handlers : ip_kernel -> ctx_t -> unit = "wrap_create_and_set_ipython_handlers"

(* type context_t *)
(* version of format *)
type execute_request_t  = { code: string }
type execute_response_t = { successful:bool; media_type: string; data: string }

let handle_execute_request ctx request =
  {successful=true;media_type="text/plain";data=request.code}
    
let kernel = create_kernel 1 "/Users/jakob/.ipython/profile_default/security/kernel-7321.json"

let handle_sigint _ =
  kernel_shutdown kernel
  
let () =
  begin
    Callback.register "handle_execute_request" handle_execute_request;
    create_and_set_ipython_handlers kernel ();
    signal sigint (Signal_handle handle_sigint);
    kernel_start kernel;
    while not (kernel_has_shutdown kernel) do
      Unix.sleep 1
    done;
    free_kernel kernel
  end

    
