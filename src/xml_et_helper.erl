-module(xml_et_helper).

-export([parse_and_extract/2]).

-include_lib("xmerl/include/xmerl.hrl").

parse_and_extract(XmlBin, LineRefFilter) ->
  XmlString = binary_to_list(XmlBin),
  {XmlRoot, _} = xmerl_scan:string(XmlString),
  recorded_calls_for_line(XmlRoot, LineRefFilter).

recorded_calls_for_line(Xml, LineRefFilter) ->
  io:format("Looking for RecordedCall with line=~p~n", [LineRefFilter]),
  Journeys = xmerl_xpath:string("//EstimatedVehicleJourney", Xml),
  Matching = [J || J <- Journeys, has_line_ref(J, LineRefFilter)],
  lists:flatmap(fun extract_calls/1, Matching).

has_line_ref(Journey, Ref) ->
  LineRefs = xmerl_xpath:string("LineRef", Journey),
  lists:any(fun(LineRefNode) ->
               case xmerl_xpath:string("text()", LineRefNode) of
                 [#xmlText{value = V}] when is_list(V) -> V =:= Ref;
                 _ -> false
               end
            end,
            LineRefs).

extract_calls(Journey) ->
  Calls = xmerl_xpath:string("EstimatedCalls/EstimatedCall", Journey),
  lists:map(fun(Call) ->
               {recorded_call,
                maybe_bool("Cancellation", Call),
                maybe_text("AimedArrivalTime", Call),
                maybe_text("ExpectedArrivalTime", Call),
                maybe_text("ArrivalStatus", Call)}
            end,
            Calls).

maybe_text(Tag, Node) ->
  case xmerl_xpath:string(Tag ++ "/text()", Node) of
    [#xmlText{value = V}] when is_list(V) ->
      {some, V};
    _ ->
      nil
  end.

maybe_bool(Tag, Node) ->
  case maybe_text(Tag, Node) of
    {some, "true"} ->
      {some, true};
    {some, "false"} ->
      {some, false};
    _ ->
      nil
  end.
