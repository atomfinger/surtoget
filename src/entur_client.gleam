import gleam/hackney
import gleam/http/request
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/uri
import tempo.{ISO8601Seconds}
import tempo/datetime
import tempo/duration
import wisp

@external(erlang, "xml_et_helper", "parse_and_extract")
pub fn recorded_calls_for_line(
  xml: String,
  line_ref: String,
) -> List(RecordedCall)

pub type RecordedCall {
  RecordedCall(
    cancellation: Option(Bool),
    aimed_arrival_time: Option(String),
    expected_arrival_time: Option(String),
    arrival_status: Option(String),
  )
}

const url = "https://api.entur.io/realtime/v1/rest/et?datasetId=GOA"

const line = "GOA:Line:50"

pub fn is_train_delayed() -> Bool {
  let assert Ok(uri) = uri.parse(url)
  let assert Ok(req) = request.from_uri(uri)
  case hackney.send(req) {
    Ok(response) -> response.body |> has_delay()
    Error(_) -> {
      wisp.log_error("Error, could not request realtime data")
      False
    }
  }
}

fn has_delay(xml: String) -> Bool {
  let record_calls = recorded_calls_for_line(xml, line)
  let delayed_result =
    record_calls
    |> list.filter(fn(record_call) {
      case record_call.arrival_status {
        option.Some("delayed") -> True
        option.None -> False
        option.Some(_) -> False
      }
    })
    |> list.find(fn(record_call) {
      case
        check_delayed_times(
          record_call.aimed_arrival_time,
          record_call.expected_arrival_time,
        )
      {
        Ok(is_delayed) -> is_delayed
        Error(_) -> False
      }
    })
  case delayed_result {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn check_delayed_times(
  aimed_arrival_option: Option(String),
  expected_arrival_option: Option(String),
) -> Result(Bool, String) {
  use aimed_arrival <- result.try(option.to_result(
    aimed_arrival_option,
    "No aimed arrival",
  ))
  use expected_arrival <- result.try(option.to_result(
    expected_arrival_option,
    "No expected arrival",
  ))
  let assert Ok(expected_arrival_datetime) =
    datetime.parse(expected_arrival, in: ISO8601Seconds)
  let assert Ok(aimed_arrival_datetime) =
    datetime.parse(aimed_arrival, in: ISO8601Seconds)
  let minute_difference =
    datetime.difference(aimed_arrival_datetime, expected_arrival_datetime)
    |> duration.as_minutes()
    |> int.absolute_value()

  // We allow for a 15 minute wiggleroom before we call something delayed.
  case minute_difference > 15 {
    True -> io.println("THE TRAIN IS DELAYED")
    False -> io.println("The train is not delayed")
  }
  Ok(minute_difference > 15)
}
