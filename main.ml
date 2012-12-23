(* -----------------------------------------------------------------------------
 * Copyright (C) 2012 Jakob Praher
 *
 * Distributed under the terms of the BSD License. The full license is in
 * the file COPYING, distributed as part of this software.
 * -----------------------------------------------------------------------------
 *)

open Sys
open Unix
open Kernel
(* type MyHandler = Kernel.HandlerType; *)

module type MyHandler = sig
  type ctx_t 
  val execute_request : ctx_t -> Kernel.execute_request_t -> Kernel.execute_response_t
end


module MyHandler = 
struct
  type ctx_t = unit
  let execute_request ctx request =
    {Kernel.successful=true;media_type="text/plain";data=request.code}    
end

module MyIPython = Kernel.IPython(MyHandler) 
    

(* 
   main entry 
 *)
let () =
  let test_shutdown = (MyIPython.init_kernel (Array.to_list Sys.argv) () handle_execute_request) in
  while not (test_shutdown()) do
    Unix.sleep 1
  done;
    


