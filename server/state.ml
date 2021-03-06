(** Copyright (c) 2016-present, Facebook, Inc.

    This source code is licensed under the MIT license found in the
    LICENSE file in the root directory of this source tree. *)

open Core

open Network

module Error = Analysis.Error


type client = {
  failures: int;
}

type connections = {
  socket: Socket.t;
  persistent_clients: client Unix.File_descr.Table.t;
  file_notifiers: Socket.t list;
  watchman_pid: Pid.t option;
}

type lookups_cache_entry = {
  table: Analysis.Lookup.t;
  source: string;
}

type t = {
  deferred_requests: Protocol.Request.t list;
  environment: (module Analysis.Environment.Handler);
  errors: (Error.t list) File.Handle.Table.t;
  handles: File.Handle.Set.t;
  lookups: lookups_cache_entry String.Table.t;
  scheduler: Scheduler.t;
  lock: Mutex.t;
  last_integrity_check: float;
  last_request_time: float;
  connections: connections ref;
}


let failure_threshold = 5


let stop_after_idle_for = 24.0 *. 60.0 *. 60.0 (* 1 day *)


let integrity_check_every = 60.0 (* 1 minute *)
