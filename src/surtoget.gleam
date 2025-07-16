import gleam/erlang/process
import gleam/http/response
import gleam/list
import image_cache
import lustre/attribute.{attribute, class, href, rel, src}
import lustre/element.{type Element}
import lustre/element/html
import mist
import news
import news_page
import refund
import statistics
import stories
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  wisp.configure_logger()
  let assert Ok(cache) = image_cache.start()
  let assert Ok(_) =
    wisp_mist.handler(handle_request(_, cache.data), secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}

pub fn handle_request(
  req: Request,
  image_cache: process.Subject(image_cache.ImageCacheMessage),
) -> Response {
  use <- wisp.serve_static(req, under: "/static", from: "priv/static")
  use <- wisp.serve_static(req, under: "/css", from: "priv/css")
  route_request(req, image_cache)
}

fn route_request(
  req: Request,
  image_cache: process.Subject(image_cache.ImageCacheMessage),
) -> Response {
  case wisp.path_segments(req) {
    [] | ["home"] | ["index"] -> render_index()
    ["news"] -> render_news_page()
    ["news", "images", image_id] ->
      handle_news_image_request(image_id, image_cache)
    _ -> wisp.not_found()
  }
}

fn handle_news_image_request(
  image_id: String,
  actor: process.Subject(image_cache.ImageCacheMessage),
) -> response.Response(wisp.Body) {
  case image_cache.get_cached_image(image_id, actor) {
    Ok(image) ->
      wisp.response(200)
      |> wisp.file_download_from_memory(named: image_id, containing: image)

    Error(_) -> {
      case news.find_article_by_image_id(image_id) {
        Ok(article) -> {
          case image_cache.fetch_and_cache_image(article, actor) {
            Ok(image) ->
              wisp.response(200)
              |> wisp.file_download_from_memory(
                named: image_id,
                containing: image,
              )
            Error(_) -> wisp.response(404)
          }
        }
        Error(_) -> wisp.response(404)
      }
    }
  }
}

fn render_news_page() -> Response {
  let articles = news.get_news_articles()
  let news_page_element: Element(msg) =
    html.html([attribute("lang", "no")], [
      html.head([], [
        html.title([], "Nyheter - Surtoget"),
        html.link([href("/css/tailwind.css"), rel("stylesheet")]),
        html.meta([
          attribute("content", "width=device-width, initial-scale=1.0"),
          attribute.name("viewport"),
        ]),
      ]),
      html.body([class("bg-gray-50 text-gray-800")], [
        html.div([class("container mx-auto px-4")], [
          header(),
          news_page.render(articles),
          footer(),
        ]),
      ]),
    ])

  news_page_element
  |> element.to_string_tree()
  |> wisp.html_response(200)
}

fn render_index() -> Response {
  let index_page: Element(msg) =
    html.html([attribute("lang", "no")], [
      html.head([], [
        html.title([], "Surtoget - Sørbanens sanne ansikt"),
        html.script([src("https://d3js.org/d3.v7.min.js")], ""),
        html.link([href("/css/tailwind.css"), rel("stylesheet")]),
        html.meta([
          attribute("content", "width=device-width, initial-scale=1.0"),
          attribute.name("viewport"),
        ]),
      ]),
      html.body([class("bg-gray-50 text-gray-800")], [
        html.script([src("/static/charts.js"), attribute("defer", "")], ""),
        html.div([class("container mx-auto px-4")], [
          header(),
          main_content(),
          footer(),
        ]),
      ]),
    ])

  index_page
  |> element.to_string_tree()
  |> wisp.html_response(200)
}

fn header() -> Element(msg) {
  html.header([class("py-4 bg-white shadow-md")], [
    html.div([class("container mx-auto px-4")], [
      html.div([class("flex justify-center")], [
        html.a([href("/")], [
          html.img([
            src("/static/surtoget_logo.png"),
            attribute("alt", "Surtoget Logo"),
            class("h-24 w-auto"),
          ]),
        ]),
      ]),
      html.nav([class("mt-2")], [
        html.ul([class("flex justify-center space-x-6 text-base font-medium")], [
          li_nav_item("/", "Hjem"),
          li_nav_item("/news", "Nyheter"),
          li_nav_item("/om", "Om Oss"),
          li_nav_item("/kontakt", "Kontakt"),
        ]),
      ]),
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

fn main_content() -> Element(msg) {
  let articles = news.get_news_articles()
  let latest_news = list.take(articles, 3)

  html.main([class("my-10 space-y-16")], [
    blurb(),
    html.section([], [statistics.render()]),
    html.section([], [refund.render()]),
    html.section([], [stories.render()]),
    html.section([], [news.render(latest_news)]),
  ])
}

fn blurb() -> Element(msg) {
  html.section([class("my-10 flex items-center space-x-8")], [
    html.img([
      src("/static/surtoget_logo.png"),
      attribute("alt", "Surtoget Logo"),
      class("h-32 w-auto"),
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
    [html.p([], [html.text("Laget med frustrasjon og Gleam.")])],
  )
}
