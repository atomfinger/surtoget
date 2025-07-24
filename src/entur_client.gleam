import gleam/hackney
import gleam/http/request
import gleam/list
import gleam/option.{type Option}
import gleam/uri
import wisp

@external(erlang, "xml_et_helper", "parse_and_extract")
fn recorded_calls_for_line(xml: String, line_ref: String) -> List(RecordedCall)

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
    |> echo
    |> list.filter(fn(record_call) {
      record_call.arrival_status |> option.unwrap("") == "delayed"
    })
    |> list.find(fn(record_call) {
      check_delayed_times(
        record_call.aimed_arrival_time,
        record_call.expected_arrival_time,
      )
    })
  case delayed_result {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn check_delayed_times(time1: Option(String), time2: Option(String)) -> Bool {
  True
}
