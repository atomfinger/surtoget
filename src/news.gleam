import gleam/bit_array
import gleam/list
import lustre/attribute.{alt, class, href, rel, src, target}
import lustre/element.{type Element}
import lustre/element/html

import gleam/crypto
import gleam/int
import gleam/result
import gleam/string

pub type NewsArticle {
  NewsArticle(
    title: String,
    description: String,
    external_url: String,
    external_image_url: String,
    owner: String,
    date: String,
  )
}

import gleam/dict

pub fn get_news_articles() -> List(NewsArticle) {
  let articles = [
    NewsArticle(
      title: "Signalfeil får konsekvenser for Sørlandsbanen",
      description: "En signalfeil i Oslo skaper forsinkelser og innstillinger for Sørlandsbanen, som går til og fra Oslo. Ingen tog kan passere Oslo på grunn av feilen.",
      external_url: "https://www.nrk.no/sorlandet/signalfeil-far-konsekvenser-for-sorlandsbanen-1.17340909",
      external_image_url: "",
      owner: "NRK",
      date: "15. mars 2025",
    ),
    NewsArticle(
      title: "Store togproblemer på Sørlandsbanen",
      description: "Det er meldt om store problemer for tog mellom Marnardal og Audnedal. Mye rim på kjøretråden gir dårlig kontakt mellom tog og kjøretråd, noe som fører til strømproblemer.",
      external_url: "https://www.nrk.no/sorlandet/store-togproblemer-pa-sorlandsbanen-1.17189263",
      external_image_url: "",
      owner: "NRK",
      date: "10. november 2024",
    ),
    NewsArticle(
      title: "Vy tar over Sørlandsbanen - Go-Ahead Nordic vrakes",
      description: "Den statseide togselskapet Vy tar over Sørlandsbanen, Arendalsbanen og Jærbanen fra Go-Ahead Nordic fra desember 2027.",
      external_url: "https://www.nrk.no/sorlandet/vy-tar-over-sorlandsbanen-_-go-ahead-nordic-vrakes-1.17094076",
      external_image_url: "",
      owner: "NRK",
      date: "25. oktober 2024",
    ),
    NewsArticle(
      title: "Flere ordførere i Telemark kjemper for å få tilbake stopp på Sørlandsbanen",
      description: "Fire ordførere fra Telemark har sendt et brev til stortingspolitikerne der de kritiserer Bane Nor for å ha fjernet stopp på Sørlandsbanen, noe de mener har forverret punktligheten.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/flere-ordforere-i-telemark-kjemper-for-a-fa-tilbake-stopp-pa-sorlandsbanen-1.17092301",
      external_image_url: "",
      owner: "NRK",
      date: "28. oktober 2024",
    ),
    NewsArticle(
      title: "Fikk tre timer i Drangedal",
      description: "Reisende med toget fra Stavanger til Oslo søndag ettermiddag fikk anledning til å studere omgivelsene rundt stasjonen i Prestestranda i rundt tre timer før turen kunne gå videre.",
      external_url: "https://www.drangedalsposten.no/fikk-tre-timer-i-drangedal/s/5-164-34904",
      external_image_url: "",
      owner: "Drangedalsposten",
      date: "16. juni 2025",
    ),
    NewsArticle(
      title: "Stor aktør på Jærbanen trekker seg: Frykter mer buss for tog",
      description: "Selskapet som vedlikeholder togene på Sørlandsbanen, terminerte kontrakten etter store økonomiske tap. Nå overtar Go-Ahead arbeidet selv.",
      external_url: "https://www.aftenbladet.no/lokalt/i/dRe2j1/stor-aktoer-paa-jaerbanen-trekker-seg-frykter-mer-buss-for-tog",
      external_image_url: "",
      owner: "Aftenbladet",
      date: "26. mai 2025",
    ),
    NewsArticle(
      title: "Buss for tog i sommar",
      description: "Sidan pendlarane har ferie og det er færre som tar tog, nyttar Bane Nor moglegheitene til vedlikehalds- og byggearbeid på togstrekningane.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/buss-for-tog-i-sommar-1.17424797",
      external_image_url: "",
      owner: "NRK",
      date: "20. mai 2025",
    ),
    NewsArticle(
      title: "Sørlandsbanen: Har aldri vært verre",
      description: "Sørlandsbanen har lavest punktlighet – tiltakene gir liten effekt så langt.",
      external_url: "https://www.dalane-tidende.no/sorlandsbanen-har-aldri-vart-verre/s/5-101-741316",
      external_image_url: "",
      owner: "Dalene Tidene",
      date: "19. januar 2025",
    ),
  ]
  list.sort(articles, by: fn(a, b) {
    case parse_date(a.date), parse_date(b.date) {
      Ok(date_a), Ok(date_b) -> string.compare(date_b, date_a)
      _, _ -> string.compare(a.date, b.date)
      // Fallback to string comparison if parsing fails
    }
  })
}

fn parse_date(date_string: String) -> Result(String, Nil) {
  let month_map =
    dict.from_list([
      #("januar", "01"),
      #("februar", "02"),
      #("mars", "03"),
      #("april", "04"),
      #("mai", "05"),
      #("juni", "06"),
      #("juli", "07"),
      #("august", "08"),
      #("september", "09"),
      #("oktober", "10"),
      #("november", "11"),
      #("desember", "12"),
    ])

  let parts = string.split(date_string, " ")
  case parts {
    [day_str, month_name, year_str] -> {
      let cleaned_day_str = case string.ends_with(day_str, ".") {
        True -> string.slice(day_str, 0, string.length(day_str) - 1)
        False -> day_str
      }
      use day <- result.try(int.parse(cleaned_day_str))
      use _year <- result.try(int.parse(year_str))
      use month_num <- result.try(dict.get(month_map, month_name))

      let formatted_day = case day < 10 {
        True -> "0" <> int.to_string(day)
        False -> int.to_string(day)
      }
      Ok(year_str <> "-" <> month_num <> "-" <> formatted_day)
    }
    _ -> Error(Nil)
  }
}

pub fn get_image_id(article: NewsArticle) -> String {
  crypto.hash(crypto.Sha1, bit_array.from_string(article.external_image_url))
  |> bit_array.base16_encode()
}

pub fn get_image_url(article: NewsArticle) -> String {
  "news/images/" <> get_image_id(article)
}

pub fn find_article_by_image_id(image_id: String) -> Result(NewsArticle, Nil) {
  get_news_articles()
  |> list.filter(fn(article) { get_image_id(article) == image_id })
  |> list.first()
}

pub fn render(articles: List(NewsArticle)) -> Element(a) {
  html.div([class("py-12 bg-gray-50")], [
    html.div([class("max-w-7xl mx-auto px-4 sm:px-6 lg:px-8")], [
      html.div([class("text-center")], [
        html.h2(
          [
            class(
              "text-base text-yellow-600 font-semibold tracking-wide uppercase",
            ),
          ],
          [html.text("Siste Nytt")],
        ),
        html.p(
          [
            class(
              "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl",
            ),
          ],
          [html.text("Oppdateringer om Sørbanen")],
        ),
      ]),
      html.div(
        [class("mt-12 space-y-8")],
        list.map(articles, fn(article) {
          html.a(
            [
              href(article.external_url),
              target("_blank"),
              rel("noopener noreferrer"),
              class(
                "block md:flex bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden",
              ),
            ],
            [
              html.div([class("md:w-1/3")], [
                html.img([
                  src(get_image_url(article)),
                  alt(article.title),
                  class("w-full h-full object-cover"),
                ]),
              ]),
              html.div([class("md:w-2/3 p-6 flex flex-col justify-between")], [
                html.div([], [
                  html.h3([class("text-2xl font-bold text-gray-900 mb-2")], [
                    html.text(article.title <> " [" <> article.owner <> "]"),
                  ]),
                  html.p([class("text-gray-700 text-base mb-4")], [
                    html.text(article.description),
                  ]),
                ]),
                html.p([class("text-gray-500 text-sm")], [
                  html.text(article.date),
                ]),
              ]),
            ],
          )
        }),
      ),
    ]),
  ])
}
