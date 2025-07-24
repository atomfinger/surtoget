-module(xml_et_helper).

-export([parse_and_extract/2]).

-include_lib("xmerl/include/xmerl.hrl").

parse_and_extract(XmlBin, LineRefFilter) ->
  XmlString = binary_to_list(XmlBin),
  LineRefFilterString = binary_to_list(LineRefFilter),
  {XmlRoot, _} = xmerl_scan:string(XmlString),
  recorded_calls_for_line(XmlRoot, LineRefFilterString).

recorded_calls_for_line(Xml, LineRefFilter) ->
  Journeys = xmerl_xpath:string("//*[local-name()='EstimatedVehicleJourney']", Xml),
  Matching = [J || J <- Journeys, has_line_ref(J, LineRefFilter)],
  lists:flatmap(fun extract_calls/1, Matching).

has_line_ref(Journey, Ref) ->
  LineRefs = xmerl_xpath:string(".//*[local-name()='LineRef']", Journey),
  lists:any(fun(LineRefNode) ->
               case xmerl_xpath:string("./text()", LineRefNode) of
                 [#xmlText{value = V}] when is_list(V) -> V =:= Ref;
                 _ -> false
               end
            end,
            LineRefs).

extract_calls(Journey) ->
  Calls = xmerl_xpath:string(".//*[local-name()='EstimatedCall']", Journey),
  lists:map(fun(Call) ->
               {recorded_call,
                maybe_bool("Cancellation", Call),
                maybe_text("AimedArrivalTime", Call),
                maybe_text("ExpectedArrivalTime", Call),
                maybe_text("ArrivalStatus", Call)}
            end,
            Calls).

maybe_text(Tag, Node) ->
  case xmerl_xpath:string(".//*[local-name()='" ++ Tag ++ "']/text()", Node) of
    [#xmlText{value = V}] when is_list(V) ->
      {some, V};
    _ ->
      none
  end.

maybe_bool(Tag, Node) ->
  case maybe_text(Tag, Node) of
    {some, "true"} ->
      {some, true};
    {some, "false"} ->
      {some, false};
    _ ->
      none
  end.
