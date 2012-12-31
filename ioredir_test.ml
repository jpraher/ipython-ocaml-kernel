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

type ioredir_t
external new_ioredir_stdout : unit -> ioredir_t = "wrap_new_ioredir_stdout"
external new_ioredir : int -> ioredir_t = "wrap_new_ioredir"
external free_ioredir : ioredir_t -> unit = "wrap_free_ioredir"
external ioredir_receive : ioredir_t -> string = "wrap_ioredir_receive"

let () =
  let io = new_ioredir_stdout () in
  let str = ref "" in
  let in_channel = open_in "absyn.txt" in
  try
    while true do
      let line = input_line in_channel in
      str := !str ^ line ^ "\n"
    done;
  with End_of_file ->
    close_in in_channel    ;
  let () = prerr_endline !str in 
  let () = print_endline !str in
  let str2 = ioredir_receive io in
  (*free_ioredir io;*)
  prerr_endline "RECEIVED:";
  prerr_endline str2;
  prerr_endline (string_of_int (String.length !str));
  prerr_endline (string_of_int (String.length str2));
  assert (!str  ^ "\n" = str2)
    
