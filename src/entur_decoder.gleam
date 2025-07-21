import gleam/dynamic/decode

pub fn data_decoder() -> decode.Decoder(Data) {
  let decoder = {
    use lines <- decode.subfield(["data", "lines"], decode.list(line_decoder()))
    decode.success(Data(lines))
  }
  decoder
}

fn line_decoder() -> decode.Decoder(Line) {
  let decoder = {
    use id <- decode.field("id", decode.string)
    use service_journeys <- decode.field(
      "serviceJourneys",
      decode.list(service_journey_decoder()),
    )
    decode.success(Line(id, service_journeys))
  }
  decoder
}

fn service_journey_decoder() -> decode.Decoder(ServiceJourney) {
  let decoder = {
    use estimated_calls <- decode.field(
      "estimatedCalls",
      decode.list(estimated_call_decoder()),
    )
    decode.success(ServiceJourney(estimated_calls))
  }
  decoder
}

fn estimated_call_decoder() -> decode.Decoder(EstimatedCall) {
  let decoder = {
    use aimed_arrival_time <- decode.field("aimedArrivalTime", decode.string)
    use cancellation <- decode.field("cancellation", decode.bool)
    use date <- decode.field("date", decode.string)
    use expected_arrival_time <- decode.field(
      "expectedArrivalTime",
      decode.string,
    )
    use realtime <- decode.field("realtime", decode.bool)
    use realtime_state <- decode.field("realtimeState", decode.string)
    use actual_arrival_time <- decode.optional_field(
      "actualArrivalTime",
      "",
      decode.string,
    )
    decode.success(EstimatedCall(
      aimed_arrival_time,
      cancellation,
      date,
      expected_arrival_time,
      realtime,
      realtime_state,
      actual_arrival_time,
    ))
  }
  decoder
}

pub type Data {
  Data(lines: List(Line))
}

pub type Line {
  Line(id: String, service_journeys: List(ServiceJourney))
}

pub type ServiceJourney {
  ServiceJourney(estimated_calls: List(EstimatedCall))
}

pub type EstimatedCall {
  EstimatedCall(
    aimed_arrival_time: String,
    cancellation: Bool,
    date: String,
    expected_arrival_time: String,
    realtime: Bool,
    realtime_state: String,
    actual_arrival_time: String,
  )
}
