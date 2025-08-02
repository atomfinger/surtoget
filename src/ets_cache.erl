-module(ets_cache).

-export([new/1, insert/3, lookup/2]).

new(Name) ->
  try
    {ok, ets:new(Name, [set, public, named_table, {read_concurrency, true}])}
  catch
    _:badarg ->
      % This error can happen if the table name is not an atom,
      % or if the table already exists. We check for the latter.
      case ets:whereis(Name) of
        undefined ->
          % Table does not exist, so it must be a different badarg error.
          {error, {erlang_error, atom_to_binary(badarg, utf8)}};
        _ ->
          % Table already exists, which is fine for our use case.
          {ok, Name}
      end;
    _:Reason ->
      {error, {erlang_error, atom_to_binary(Reason, utf8)}}
  end.

insert(Tid, Key, Value) ->
  try ets:insert(Tid, {Key, Value}) of
    _ ->
      {ok, nil}
  catch
    _:Reason ->
      {error, {erlang_error, term_to_binary(Reason)}}
  end.

lookup(Tid, Key) ->
  try ets:lookup(Tid, Key) of
    [{_, Value}] ->
      {ok, Value};
    [] ->
      {error, empty}
  catch
    _:Reason ->
      {error, {erlang_error, term_to_binary(Reason)}}
  end.
