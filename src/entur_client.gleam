import entur_decoder.{type Data, type EstimatedCall, type ServiceJourney}
import gleam/hackney
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamql
import tempo.{type Date, ISO8601Date, ISO8601Seconds}
import tempo/date
import tempo/datetime
import tempo/duration
import tempo/error

const api_host = "api.entur.io"

const path = "/journey-planner/v3/graphql"

pub fn check_for_dealays() -> option.Option(Bool) {
  let query = query(date.current_local())
  let result: Result(option.Option(Data), gleamql.GraphQLError) =
    gleamql.new()
    |> gleamql.set_query(query)
    |> gleamql.set_host(api_host)
    |> gleamql.set_path(path)
    |> gleamql.set_default_content_type_header()
    |> gleamql.set_decoder(entur_decoder.data_decoder())
    |> gleamql.send(hackney.send)

  case result {
    Ok(data_option) ->
      case data_option {
        option.Some(data) -> option.Some(has_delays(data))
        option.None -> option.None
      }
    Error(_) -> option.None
  }
}

fn has_delays(data: Data) -> Bool {
  let lines_delayed =
    data.lines
    |> list.filter(fn(line) {
      False == line.service_journeys |> list.is_empty()
    })
    |> list.filter(fn(line) {
      any_service_journeys_delayed(line.service_journeys)
    })
    |> list.length()
  lines_delayed > 0
}

fn any_service_journeys_delayed(service_journeys: List(ServiceJourney)) -> Bool {
  let delayed_journeys =
    service_journeys
    |> list.filter(fn(joruney) {
      any_estimated_calls_delayed(joruney.estimated_calls)
    })
    |> list.length()
  delayed_journeys > 0
}

fn any_estimated_calls_delayed(estimated_calls: List(EstimatedCall)) -> Bool {
  let delayed_estimated_calls =
    estimated_calls
    |> list.filter(fn(estimated_call) { estimated_call.realtime })
    |> list.filter(fn(estimated_call) {
      estimated_call.actual_arrival_time |> string.is_empty()
    })
    |> list.filter(fn(estimated_call) {
      is_estimated_call_delayed(estimated_call)
    })
    |> list.length()
  delayed_estimated_calls > 0
}

fn is_estimated_call_delayed(estimated_call: EstimatedCall) -> Bool {
  case
    is_delayed(
      estimated_call.expected_arrival_time,
      estimated_call.aimed_arrival_time,
    )
  {
    Ok(is_delayed) -> is_delayed
    //Default to false in case of error
    Error(_) -> False
  }
}

fn is_delayed(
  expected_arrival: String,
  aimed_arrival: String,
) -> Result(Bool, error.DateTimeParseError) {
  use expected_arrival_datetime <- result.try(datetime.parse(
    expected_arrival,
    in: ISO8601Seconds,
  ))
  use aimed_arrival_datetime <- result.try(datetime.parse(
    aimed_arrival,
    in: ISO8601Seconds,
  ))
  let minute_difference =
    datetime.difference(aimed_arrival_datetime, expected_arrival_datetime)
    |> duration.as_minutes()
    |> int.absolute_value()

  // We allow for a 15 minute wiggleroom before we call something delayed.
  Ok(minute_difference > 15)
}

fn query(date: Date) -> String {
  "query {
  lines(publicCode: \"F5\") {
    id
    serviceJourneys {
      estimatedCalls(date: \"" <> date.format(date, in: ISO8601Date) <> "\") {
        aimedArrivalTime
        cancellation
        date
        expectedArrivalTime
        realtime
        realtimeState
        actualArrivalTime
      }
    }
  }
}
"
}
