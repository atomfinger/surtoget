import gleam/erlang/process
import lustre/attribute.{attribute, href, rel}
import lustre/element
import lustre/element/html.{html}
import mist
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  wisp.configure_logger()

  let assert Ok(_) =
    wisp_mist.handler(route_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}

fn route_request(req: Request) -> Response {
  case wisp.path_segments(req) {
    [] | ["home"] | ["index"] -> render_index()
    _ -> wisp.not_found()
  }
}

fn render_index() -> Response {
  let index_page: element.Element(msg) =
    html([attribute("lang", "en")], [
      html.head([], [
        html.title([], "Surtoget"),
        html.link([href("/css/main.css"), rel("stylesheet")]),
        html.meta([
          attribute("content", "width=device-width, initial-scale=1.0"),
          attribute.name("viewport"),
        ]),
      ]),
      html.body([], [index_page()]),
    ])
  index_page
  |> element.to_string_tree
  |> wisp.html_response(200)
}

fn index_page() -> element.Element(msg) {
  html.h1([], [html.text("Velkommen til Surtoget!")])
}
