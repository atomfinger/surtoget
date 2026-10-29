-module(entur_ffi).

-export([get/2]).

% The response is turned into a charlist (~16 bytes per byte) and a full xmerl
% tree, so keep it bounded: a normal response is ~140KB.
-define(MAX_BODY, 2000000).
% hackney's timeouts apply per connect/read, so a server that trickles bytes
% could hold a request open forever; this caps the whole request.
-define(DEADLINE_MS, 30000).

get(Url, Headers) ->
    Options = [{with_body, true},
               {max_body, ?MAX_BODY},
               {connect_timeout, 5000},
               {recv_timeout, 15000}],
    Ref = make_ref(),
    {Pid, Monitor} =
        spawn_monitor(fun() ->
                         exit({Ref, hackney:request(get, Url, Headers, <<>>, Options)})
                      end),
    receive
        {'DOWN', Monitor, process, Pid, {Ref, {ok, 200, _RespHeaders, Body}}}
            when is_binary(Body) ->
            {ok, Body};
        {'DOWN', Monitor, process, Pid, _} ->
            {error, nil}
    after ?DEADLINE_MS ->
        exit(Pid, kill),
        erlang:demonitor(Monitor, [flush]),
        {error, nil}
    end.
