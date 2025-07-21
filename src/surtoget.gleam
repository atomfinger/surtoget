import about
import delayed
import faq
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request
import gleam/http/response
import gleam/list
import gleam/result
import gleam/string
import image_cache
import lustre/attribute.{attribute, class, href, rel, src}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import marceau
import mist
import news
import refund
import simplifile
import statistics
import stories
import wisp.{type Request, type Response}
import wisp/internal
import wisp/wisp_mist

pub type Context {
  Context(
    image_cache_subject: process.Subject(image_cache.ImageCacheMessage),
    delayed_subject: process.Subject(delayed.DelayMessage),
  )
}

pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  wisp.configure_logger()
  let assert Ok(cache) = image_cache.start()
  let assert Ok(delayed) = delayed.start()
  let ctx = Context(cache.data, delayed.data)
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
  route_request(req, ctx)
}

fn route_request(req: Request, ctx: Context) -> Response {
  case wisp.path_segments(req) {
    [] | ["home"] | ["index"] -> render_page(main_content(ctx.delayed_subject))
    ["om-surtoget"] -> render_page(about.render())
    ["faq"] -> render_page(faq.render())
    ["health"] -> wisp.ok()
    ["favicon.ico"] -> get_favicon(req)
    ["news"] -> news.get_news_articles() |> news.render() |> render_page()
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
          [header(), content, footer()],
        ),
      ]),
    ])

  index_page
  |> element.to_document_string_tree()
  |> wisp.html_response(200)
}

fn header() -> Element(msg) {
  html.header([class("py-4 bg-white shadow-md")], [
    html.div([class("container mx-auto px-4")], [
      html.div([class("flex justify-between items-center")], [
        html.div([class("md:hidden flex-shrink-0")], [
          html.a([href("/")], [
            html.img([
              src("/static/surtoget_logo_train_only.png"),
              attribute("alt", "Surtoget Logo"),
              class("h-16 w-auto"),
            ]),
          ]),
        ]),
        html.div([class("flex-grow text-center md:hidden")], [
          html.a([href("/"), class("text-2xl font-bold text-[#E3A804]")], [
            html.text("Surtoget"),
          ]),
        ]),
        html.div([class("hidden md:block flex-grow text-center")], [
          html.a([href("/")], [
            html.img([
              src("/static/surtoget_logo.png"),
              attribute("alt", "Surtoget Logo"),
              class("h-24 w-auto mx-auto"),
            ]),
          ]),
        ]),
        html.div([class("md:hidden flex-shrink-0")], [
          html.button(
            [
              attribute("id", "menu-button"),
              attribute("type", "button"),
              class(
                "text-gray-500 hover:text-yellow-600 focus:outline-none focus:text-yellow-600",
              ),
            ],
            [
              svg.svg(
                [
                  class("h-8 w-8"),
                  attribute("fill", "none"),
                  attribute("viewBox", "0 0 24 24"),
                  attribute("stroke", "currentColor"),
                ],
                [
                  svg.path([
                    attribute("stroke-linecap", "round"),
                    attribute("stroke-linejoin", "round"),
                    attribute("stroke-width", "2"),
                    attribute("d", "M4 6h16M4 12h16M4 18h16"),
                  ]),
                ],
              ),
            ],
          ),
        ]),
      ]),
      html.nav(
        [
          attribute("id", "menu"),
          class(
            "hidden md:flex md:justify-center mt-2 transition-all duration-500 ease-in-out overflow-hidden",
          ),
        ],
        [
          html.ul(
            [
              class(
                "flex flex-col text-center md:flex-row md:space-x-6 text-2xl md:text-base font-medium",
              ),
            ],
            [
              li_nav_item("/", "Hjem"),
              li_nav_item("/news", "Nyheter"),
              li_nav_item("/om-surtoget", "Om Surtoget"),
              li_nav_item("/faq", "Ofte stilte spørsmål"),
            ],
          ),
        ],
      ),
    ]),
  ])
}

fn li_nav_item(href_val: String, text_val: String) -> Element(msg) {
  html.li([], [
    html.a(
      [
        href(href_val),
        class(
          "text-gray-500 hover:text-yellow-600 transition-colors duration-200",
        ),
      ],
      [html.text(text_val)],
    ),
  ])
}

fn main_content(
  delayed_subject: process.Subject(delayed.DelayMessage),
) -> Element(msg) {
  let articles = news.get_news_articles()
  let latest_news = list.take(articles, 3)

  html.main([class("my-10 space-y-16")], [
    blurb(),
    render_delay_notice(delayed_subject),
    html.section([], [statistics.render()]),
    html.section([], [refund.render()]),
    html.section([], [stories.render()]),
    html.section([], [news.render(latest_news)]),
  ])
}

fn render_delay_notice(
  delayed_subject: process.Subject(delayed.DelayMessage),
) -> Element(msg) {
  case delayed.is_delayed(delayed_subject) {
    True ->
      html.div([class("my-10 p-4 bg-yellow-100 rounded-lg shadow-md")], [
        html.p(
          [class("text-lg font-semibold text-yellow-800 flex items-center")],
          [
            html.span([class("relative flex h-3 w-3 mr-3")], [
              html.span(
                [
                  class(
                    "animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75",
                  ),
                ],
                [],
              ),
              html.span(
                [class("relative inline-flex rounded-full h-3 w-3 bg-red-500")],
                [],
              ),
            ]),
            html.text("Akkurat nå: Sørlandsbanen er forsinket... Igjen 🙄"),
          ],
        ),
      ])
    False -> html.div([], [])
  }
}

fn blurb() -> Element(msg) {
  html.section([class("my-10 flex flex-col md:flex-row items-center gap-8")], [
    html.img([
      src("/static/surtoget_logo.png"),
      attribute("alt", "Surtoget Logo"),
      class("h-32 w-auto hidden md:block"),
    ]),
    html.div([class("text-lg text-gray-700")], [
      html.p([], [
        html.text(
          "Velkommen til Surtoget! Kjenner du på den spesielle blandingen av håp og fortvilelse hver gang du setter deg på Sørlandsbanen?",
        ),
      ]),
      html.p([class("mt-4")], [
        html.text(
          "Her deler vi historier fra virkeligheten, belyser problemene og gir deg verktøyene du trenger for å takle en hverdag med en av Norges mest utilregnelige toglinjer.",
        ),
      ]),
    ]),
  ])
}

fn footer() -> Element(msg) {
  html.footer(
    [
      class(
        "py-8 mt-10 border-t border-gray-200 text-center text-gray-500 text-sm",
      ),
    ],
    [
      html.p([], [
        html.text("Laget med frustrasjon og "),
        html.a(
          [
            href("https://gleam.run"),
            class("hover:text-yellow-600 transition-colors duration-200"),
          ],
          [html.text("Gleam")],
        ),
        html.text(" av "),
        html.a(
          [
            href("https://lindbakk.com"),
            class("hover:text-yellow-600 transition-colors duration-200"),
          ],
          [html.text("John Mikael Lindbakk")],
        ),
      ]),
    ],
  )
}
