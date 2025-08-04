import gleam/erlang/atom

@external(erlang, "ets_cache", "new")
pub fn new_cache(name: atom.Atom) -> Result(atom.Atom, atom.Atom)

@external(erlang, "ets_cache", "insert")
pub fn insert(
  tid: atom.Atom,
  key: atom.Atom,
  value: v,
) -> Result(Nil, atom.Atom)

@external(erlang, "ets_cache", "lookup")
pub fn lookup(tid: atom.Atom, key: atom.Atom) -> Result(v, atom.Atom)
