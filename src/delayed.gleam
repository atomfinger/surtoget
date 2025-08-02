//// The purpose of this file is to hold data related to whether there are any current
//// delays for Sørlandsbanen. We update only once every 5 minutes to avoid hitting the
//// entur API any more than we need to.
//// 
//// Right now we will only hold a boolean, but in the future we might hold more data.

import entur_client
import gleam/erlang/atom
import gleam/erlang/process
import wisp

@external(erlang, "ets_cache", "new")
pub fn new_cache(name: atom.Atom) -> Result(atom.Atom, atom.Atom)

@external(erlang, "ets_cache", "insert")
pub fn insert(
  tid: atom.Atom,
  key: atom.Atom,
  value: Bool,
) -> Result(Nil, atom.Atom)

@external(erlang, "ets_cache", "lookup")
pub fn lookup(tid: atom.Atom, key: atom.Atom) -> Result(Bool, atom.Atom)

// 5 minutes in ms
const wait_time_ms = 300_000

const delated_ets_key: String = "has_delays"

// Starts a very simple scheduled process that kics inn every 5 minutes
pub fn start() -> Result(atom.Atom, atom.Atom) {
  let cache_name = atom.create("delayed_cache")
  case new_cache(cache_name) {
    Ok(tid) -> {
      process.spawn(fn() { scheduler(tid) })
      Ok(tid)
    }
    Error(reason) -> Error(reason)
  }
}

pub fn is_delayed(tid: atom.Atom) -> Bool {
  case lookup(tid, atom.create(delated_ets_key)) {
    Ok(value) -> value
    Error(_) -> False
  }
}

fn scheduler(tid: atom.Atom) {
  wisp.log_info("Running delayed update check...")
  // Spawning a new unlinked process to avoid any issues propagating
  process.spawn_unlinked(fn() {
    case update(tid) {
      Ok(_) -> wisp.log_info("Update check ran successfully")
      Error(_) -> wisp.log_error("Failed to update delay status")
    }
  })
  process.sleep(wait_time_ms)
  scheduler(tid)
}

fn update(tid: atom.Atom) -> Result(Nil, Nil) {
  case entur_client.is_train_delayed() {
    Ok(has_delays) -> {
      let _ = insert(tid, atom.create(delated_ets_key), has_delays)
      Ok(Nil)
    }
    Error(_) -> {
      wisp.log_error("Failed to check for delays")
      Error(Nil)
    }
  }
}
