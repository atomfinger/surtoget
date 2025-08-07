import clockwork
import entur_client
import gets
import gleam/erlang/atom
import gleam/erlang/process
import gleam/http/response
import gleam/list
import gleam/time/timestamp
import lustre/attribute.{attribute, class, src}
import lustre/element.{type Element}
import lustre/element/html
import news
import refund
import statistics
import stories
import wisp

const index_ets_key = "index_page"

pub fn get_cached_index_page(
  index_tid: atom.Atom,
  render_page: fn(Element(msg)) -> response.Response(wisp.Body),
) -> response.Response(wisp.Body) {
  case gets.lookup(index_tid, atom.create(index_ets_key)) {
    Ok(page) -> page
    Error(_) -> {
      wisp.log_error("Something happened that shouldn't happen")
      render(False) |> render_page()
    }
  }
}

pub fn start(
  render_page: fn(Element(msg)) -> response.Response(wisp.Body),
) -> Result(atom.Atom, atom.Atom) {
  let cache_name = atom.create("index_page_cache")
  case gets.new_cache(cache_name) {
    Ok(tid) -> {
      // Instant insert to ensure that there's always something ready to go
      let _ = render(False) |> render_page() |> update_index_page(tid)

      let assert Ok(cron) = "*/5 * * * *" |> clockwork.from_string
      let job = fn() { scheduler(tid, render_page) }
      //TODO: Clockwork has outdated dependencies. Must wait or fork.
      schedule.new("minutely-job", cron, job)
      |> schedule.with_logging()
      |> schedule.with_telemetry()

      let assert Ok(running_schedule) = schedule.start(scheduler)

      Ok(tid)
    }
    Error(reason) -> Error(reason)
  }
}

fn scheduler(
  index_tid: atom.Atom,
  render_page: fn(Element(msg)) -> response.Response(wisp.Body),
) {
  wisp.log_info("Running delayed update check...")
  // Spawning a new unlinked process to avoid any issues propagating
  process.spawn_unlinked(fn() {
    let _ =
      render_with_entur_check() |> render_page() |> update_index_page(index_tid)
    wisp.log_info("Entur update successful")
  })
}

fn update_index_page(page: response.Response(wisp.Body), index_tid: atom.Atom) {
  gets.insert(index_tid, atom.create(index_ets_key), page)
}

fn render_with_entur_check() {
  case entur_client.is_train_delayed() {
    Ok(has_delays) -> {
      render(has_delays)
    }
    Error(_) -> {
      wisp.log_error("Failed to check for delays")
      render(False)
    }
  }
}

fn render(is_delayed: Bool) -> Element(a) {
  let articles = news.get_news_articles()
  let latest_news = list.take(articles, 3)

  html.main([class("my-10 space-y-16")], [
    blurb(),
    render_delay_notice(is_delayed),
    html.section([], [statistics.render()]),
    html.section([], [refund.render()]),
    html.section([], [stories.render()]),
    html.section([], [news.render(latest_news)]),
  ])
}

fn render_delay_notice(is_delayed: Bool) -> Element(msg) {
  case is_delayed {
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
      src("/static/surtoget_logo.webp"),
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
