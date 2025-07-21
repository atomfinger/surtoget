import entur_decoder.{Data, EstimatedCall, Line, ServiceJourney}
import gleam/json
import gleam/option
import gleeunit/should

pub fn when_data_exists_test() {
  let json_string =
    "{\"lines\":[{\"id\":\"GOA:Line:50\",\"serviceJourneys\":[{\"estimatedCalls\":[{\"aimedArrivalTime\":\"2025-07-21T12:36:00+02:00\",\"cancellation\":false,\"date\":\"2025-07-21\",\"expectedArrivalTime\":\"2025-07-21T12:36:00+02:00\",\"realtime\":false,\"realtimeState\":\"scheduled\"}]}]}]}"

  let result =
    json.parse(from: json_string, using: entur_decoder.data_decoder())
  let expected =
    Ok(
      Data([
        Line("GOA:Line:50", [
          ServiceJourney([
            EstimatedCall(
              "2025-07-21T12:36:00+02:00",
              False,
              "2025-07-21",
              "2025-07-21T12:36:00+02:00",
              False,
              "scheduled",
              option.None,
            ),
          ]),
        ]),
      ]),
    )

  should.equal(result, expected)
}

pub fn empty_estimated_calls_should_not_cause_errors_test() {
  let json_string =
    "{\"lines\":[{\"id\":\"GOA:Line:50\",\"serviceJourneys\":[{\"estimatedCalls\":[]}]}]}"

  let result =
    json.parse(from: json_string, using: entur_decoder.data_decoder())

  should.equal(result, Ok(Data([Line("GOA:Line:50", [ServiceJourney([])])])))
}

pub fn estimated_call_with_null_actual_arrival_time_test() {
  let json_string =
    "{\"lines\":[{\"id\":\"GOA:Line:50\",\"serviceJourneys\":[{\"estimatedCalls\":[{\"aimedArrivalTime\":\"2025-07-21T12:36:00+02:00\",\"cancellation\":false,\"date\":\"2025-07-21\",\"expectedArrivalTime\":\"2025-07-21T12:36:00+02:00\",\"realtime\":false,\"realtimeState\":\"scheduled\",\"actualArrivalTime\":null}]}]}]}"

  let result =
    json.parse(from: json_string, using: entur_decoder.data_decoder())

  let expected =
    Ok(
      Data([
        Line("GOA:Line:50", [
          ServiceJourney([
            EstimatedCall(
              "2025-07-21T12:36:00+02:00",
              False,
              "2025-07-21",
              "2025-07-21T12:36:00+02:00",
              False,
              "scheduled",
              option.None,
            ),
          ]),
        ]),
      ]),
    )

  should.equal(result, expected)
}

pub fn early_morning_estimated_call_test() {
  let json_string =
    "{\"lines\":[{\"id\":\"GOA:Line:50\",\"serviceJourneys\":[{\"estimatedCalls\":[{\"aimedArrivalTime\":\"2025-07-21T07:16:00+02:00\",\"cancellation\":false,\"date\":\"2025-07-21\",\"expectedArrivalTime\":\"2025-07-21T07:16:00+02:00\",\"realtime\":false,\"realtimeState\":\"scheduled\",\"actualArrivalTime\":null}]}]}]}"

  let result =
    json.parse(from: json_string, using: entur_decoder.data_decoder())

  let expected =
    Ok(
      Data([
        Line("GOA:Line:50", [
          ServiceJourney([
            EstimatedCall(
              "2025-07-21T07:16:00+02:00",
              False,
              "2025-07-21",
              "2025-07-21T07:16:00+02:00",
              False,
              "scheduled",
              option.None,
            ),
          ]),
        ]),
      ]),
    )

  should.equal(result, expected)
}

pub fn estimated_call_with_realtime_and_actual_arrival_time_test() {
  let json_string =
    "{\"lines\":[{\"id\":\"GOA:Line:50\",\"serviceJourneys\":[{\"estimatedCalls\":[{\"aimedArrivalTime\":\"2025-07-21T08:36:00+02:00\",\"cancellation\":false,\"date\":\"2025-07-21\",\"expectedArrivalTime\":\"2025-07-21T08:03:44+02:00\",\"realtime\":true,\"realtimeState\":\"updated\",\"actualArrivalTime\":\"2025-07-21T08:03:44+02:00\"}]}]}]}"

  let result =
    json.parse(from: json_string, using: entur_decoder.data_decoder())

  let expected =
    Ok(
      Data([
        Line("GOA:Line:50", [
          ServiceJourney([
            EstimatedCall(
              "2025-07-21T08:36:00+02:00",
              False,
              "2025-07-21",
              "2025-07-21T08:03:44+02:00",
              True,
              "updated",
              option.Some("2025-07-21T08:03:44+02:00"),
            ),
          ]),
        ]),
      ]),
    )

  should.equal(result, expected)
}
