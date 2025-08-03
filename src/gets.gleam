import gleam/erlang/atom
import gleam/http/response
import wisp

@external(erlang, "ets_cache", "new")
pub fn new_cache(name: atom.Atom) -> Result(atom.Atom, atom.Atom)

@external(erlang, "ets_cache", "insert")
pub fn insert(
  tid: atom.Atom,
  key: atom.Atom,
  value: response.Response(wisp.Body),
) -> Result(Nil, atom.Atom)

@external(erlang, "ets_cache", "lookup")
pub fn lookup(
  tid: atom.Atom,
  key: atom.Atom,
) -> Result(response.Response(wisp.Body), atom.Atom)
