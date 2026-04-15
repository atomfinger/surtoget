import entur_client
import gets
import gleam/erlang/atom
import gleam/erlang/process.{type Subject}
import gleam/http/response
import gleam/list
import gleam/otp/actor
import gleam/otp/supervision.{type ChildSpecification}
import lustre/attribute.{attribute, class, src}
import lustre/element.{type Element}
import lustre/element/html
import news
import refund
import statistics
import stories
import wisp

// 5 minutes
const wait_time_ms = 300_000

const index_ets_key = "index_page"

const cache_name = "index_page_cache"

pub type Message {
  Tick
}

type State {
  State(
    tid: atom.Atom,
    render_page: fn(Element(Nil)) -> response.Response(wisp.Body),
    self: Subject(Message),
  )
}

pub fn get_cached_index_page() -> response.Response(wisp.Body) {
  let tid = atom.create(cache_name)
  case gets.lookup(tid, atom.create(index_ets_key)) {
    Ok(page) -> page
    Error(_) -> {
      wisp.log_error("Something happened that shouldn't happen")
      wisp.internal_server_error()
    }
  }
}

pub fn supervised(
  render_page: fn(Element(Nil)) -> response.Response(wisp.Body),
) -> ChildSpecification(Subject(Message)) {
  supervision.worker(fn() { start(render_page) })
}

pub fn start(
  render_page: fn(Element(Nil)) -> response.Response(wisp.Body),
) -> actor.StartResult(Subject(Message)) {
  let tid = atom.create(cache_name)
  actor.new_with_initialiser(5000, fn(subject) {
    case gets.new_cache(tid) {
      Error(_) -> Error("Failed to create ETS cache")
      Ok(cache_tid) -> {
        let _ = render(False) |> render_page() |> update_index_page(cache_tid)
        process.send_after(subject, wait_time_ms, Tick)
        actor.initialised(State(tid: cache_tid, render_page:, self: subject))
        |> actor.returning(subject)
        |> Ok
      }
    }
  })
  |> actor.on_message(handle_message)
  |> actor.start
}

fn handle_message(state: State, message: Message) -> actor.Next(State, Message) {
  case message {
    Tick -> {
      wisp.log_info("Running delayed update check...")
      process.spawn_unlinked(fn() {
        let _ =
          render_with_entur_check()
          |> state.render_page()
          |> update_index_page(state.tid)
        wisp.log_info("Entur update successful")
      })
      process.send_after(state.self, wait_time_ms, Tick)
      actor.continue(state)
    }
  }
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
