import delayed
import gleam/erlang/process
import gleam/list
import lustre/attribute.{attribute, class, src}
import lustre/element.{type Element}
import lustre/element/html
import news
import refund
import statistics
import stories

pub fn render() -> Element(msg) {
  let articles = news.get_news_articles()
  let latest_news = list.take(articles, 3)

  html.main([class("my-10 space-y-16")], [
    blurb(),
    //render_delay_notice(delayed_subject),
    html.section([], [statistics.render()]),
    html.section([], [refund.render()]),
    html.section([], [stories.render()]),
    html.section([], [news.render(latest_news)]),
  ])
}

//TODO Temporary removed due to using the wrong API 🤷🏻‍♂️
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
