import about
import delayed
import faq
import footer
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request
import gleam/http/response
import gleam/list
import gleam/result
import gleam/string
import header
import image_cache
import index
import lustre/attribute.{attribute, class, href, rel, src}
import lustre/element.{type Element}
import lustre/element/html
import marceau
import mist
import news
import not_found
import simplifile
import wisp.{type Request, type Response}
import wisp/internal
import wisp/wisp_mist

pub type Context {
  Context(
    image_cache_subject: process.Subject(image_cache.ImageCacheMessage),
    delayed_subject: process.Subject(delayed.DelayMessage),
    // Some pages are fully static, so we might as well pre-render them on startup
    // just to avoid doing extra processing (despite it being pretty fast anyway)
    about_page: response.Response(wisp.Body),
    faq_page: response.Response(wisp.Body),
    news_page: response.Response(wisp.Body),
  )
}

pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  wisp.configure_logger()
  let assert Ok(cache) = image_cache.start()
  let assert Ok(delayed) = delayed.start()
  let ctx =
    Context(
      image_cache_subject: cache.data,
      delayed_subject: delayed.data,
      about_page: render_page(about.render()),
      faq_page: render_page(faq.render()),
      news_page: news.get_news_articles() |> news.render() |> render_page(),
    )
  let assert Ok(_) =
    wisp_mist.handler(handle_request(_, ctx), secret_key_base)
    |> mist.new()
    |> mist.bind("0.0.0.0")
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use <- wisp.serve_static(req, under: "/static", from: "priv/static")
  use <- wisp.serve_static(req, under: "/css", from: "priv/css")
  use <- wisp.serve_static(req, under: "/javascript", from: "priv/javascript")
  case route_request(req, ctx) {
    response if response.status == 404 -> {
      let page = render_page(not_found.render())
      wisp.not_found()
      |> wisp.set_body(page.body)
      |> wisp.set_header("content-type", "text/html; charset=utf-8")
    }
    response -> response
  }
}

fn route_request(req: Request, ctx: Context) -> Response {
  case wisp.path_segments(req) {
    [] | ["home"] | ["index"] -> render_page(index.render(ctx.delayed_subject))
    ["om-surtoget"] -> ctx.about_page
    ["faq"] -> ctx.faq_page
    ["health"] -> wisp.ok()
    ["favicon.ico"] -> get_favicon(req)
    ["news"] -> ctx.news_page
    ["news", "images", image_id] ->
      handle_news_image_request(image_id, req, ctx.image_cache_subject)
    _ -> wisp.not_found()
  }
}

fn get_favicon(req: Request) {
  serve_static_image(req, "static/favicon.ico")
}

fn serve_static_image(req: Request, image_path: String) -> Response {
  let file_type =
    image_path
    |> string.split(on: ".")
    |> list.last
    |> result.unwrap("")
  let mime_type = marceau.extension_to_mime_type(file_type)
  let path = "priv/" <> image_path
  case simplifile.file_info(path) {
    Ok(file_info) ->
      case simplifile.file_info_type(file_info) {
        simplifile.File -> {
          wisp.response(200)
          |> response.set_header("content-type", mime_type)
          |> response.set_body(wisp.File(path))
          |> handle_etag(req, file_info.size)
        }
        _ -> wisp.not_found()
      }
    _ -> wisp.not_found()
  }
}

// We should not store images that someone else has a license to. At
// the same time we want to be able to show the actual article photo
// on the site. To strike a balance we use a local in-memory cache.
//
// The reason we do not use direct links is because we want to be
// good samaritans and avoid causing unwanted bandwith load due to 
// direct hotlinking. Read more about it here:
// https://mailchimp.com/resources/hotlinking/
//
// Using an in-memory cahce puts most of the bandwith burden onto
// surtoget.no, while the traffic for external sources will be
// negible regardless of traffic to our site.
//
// The current implementation is pretty simple and naive. We might
// have to consider a proper CDN at some point, but this will get
// the job done for now.
fn handle_news_image_request(
  image_id: String,
  req: Request,
  actor: process.Subject(image_cache.ImageCacheMessage),
) -> response.Response(wisp.Body) {
  case image_cache.get_cached_image(image_id, actor) {
    Ok(image) ->
      wisp.response(200)
      |> wisp.file_download_from_memory(named: image_id, containing: image)
      |> handle_etag(req, bytes_tree.byte_size(image))
    Error(_) -> {
      serve_static_image(req, "static/train-placeholder.png")
    }
  }
}

fn handle_etag(resp: Response, req: Request, file_size: Int) -> Response {
  let etag = internal.generate_etag(file_size, 0)
  case request.get_header(req, "if-none-match") {
    Ok(old_etag) if old_etag == etag -> wisp.response(304)
    _ -> response.set_header(resp, "etag", etag)
  }
}

fn render_head(
  title_text: String,
  extra_elements: List(Element(msg)),
) -> Element(msg) {
  let common_elements = [
    html.title([], title_text),
    html.link([href("/css/tailwind.css"), rel("stylesheet")]),
    html.meta([
      attribute("content", "width=device-width, initial-scale=1.0"),
      attribute.name("viewport"),
    ]),
    html.link([
      attribute.href("/favicon.ico"),
      attribute.type_("image/x-icon"),
      attribute.rel("icon"),
    ]),
    html.script([src("/javascript/main.js"), attribute("defer", "")], ""),
    html.script([src("https://d3js.org/d3.v7.min.js")], ""),
    html.script(
      [
        attribute.src("https://scripts.simpleanalyticscdn.com/latest.js"),
        attribute("async", ""),
      ],
      "",
    ),
  ]

  html.head([], list.append(common_elements, extra_elements))
}

fn render_page(content: Element(msg)) -> response.Response(wisp.Body) {
  let index_page: Element(msg) =
    html.html([attribute("lang", "no")], [
      render_head("Surtoget - Sørlandsbanens sanne ansikt", []),
      html.body([class("bg-gray-50 text-gray-800")], [
        html.div(
          [class("container mx-auto px-4 min-w-[330px] max-w-[1024px]")],
          [header.render(), content, footer.render()],
        ),
      ]),
    ])

  index_page
  |> element.to_document_string_tree()
  |> wisp.html_response(200)
}
