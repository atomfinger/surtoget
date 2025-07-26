import gleam/http
import gleam/int
import gleam/string
import tempo/duration
import tempo/instant
import wisp

pub fn log_request_duration(
  handler: fn(wisp.Request) -> wisp.Response,
) -> fn(wisp.Request) -> wisp.Response {
  fn(req) {
    let start_time = instant.now()
    let response = handler(req)
    let end_time = instant.now()
    let duration =
      instant.difference(start_time, end_time) |> duration.as_milliseconds()

    let msg: String =
      string.concat([
        req.method |> http.method_to_string(),
        " ",
        req.path,
        " took ",
        int.to_string(duration),
        "ms",
      ])

    case duration {
      duration if duration > 500 -> wisp.log_warning(msg)
      _ -> wisp.log_info(msg)
    }

    response
  }
}
