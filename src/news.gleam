import gleam/list
import lustre/attribute.{alt, class, href, rel, src, target}
import lustre/element.{type Element}
import lustre/element/html

pub type NewsArticle {
  NewsArticle(
    title: String,
    description: String,
    image_url: String,
    external_url: String,
    date: String,
  )
}

pub fn get_news_articles() -> List(NewsArticle) {
  [
    NewsArticle(
      title: "Sørbanen: Nye forsinkelser skaper frustrasjon",
      description: "Togtrafikken på Sørbanen er igjen rammet av forsinkelser, noe som vekker sterk misnøye blant pendlere.",
      image_url: "https://via.placeholder.com/300x200?text=Togforsinkelse",
      external_url: "https://www.example.com/news/forsinkelse1",
      date: "10. juli 2025",
    ),
    NewsArticle(
      title: "Investeringer i jernbanen: Vil det hjelpe Sørbanen?",
      description: "Regjeringen lover nye investeringer i jernbanen, men spørsmålet er om det vil løse problemene på Sørbanen.",
      image_url: "https://via.placeholder.com/300x200?text=Jernbaneinvestering",
      external_url: "https://www.example.com/news/investering",
      date: "05. juli 2025",
    ),
    NewsArticle(
      title: "Passasjerer krever bedre punktlighet på Sørbanen",
      description: "En ny undersøkelse viser at passasjerer er lei av manglende punktlighet og krever handling.",
      image_url: "https://via.placeholder.com/300x200?text=Passasjerkrav",
      external_url: "https://www.example.com/news/punktlighet",
      date: "01. juli 2025",
    ),
    NewsArticle(
      title: "Vinterkaos på Sørbanen: Snø og kulde skaper problemer",
      description: "Vinterværet har ført til store utfordringer for togtrafikken på Sørbanen, med innstilte avganger og lange forsinkelser.",
      image_url: "https://via.placeholder.com/300x200?text=Vinterkaos",
      external_url: "https://www.example.com/news/vinterkaos",
      date: "20. juni 2025",
    ),
  ]
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
                  src(article.image_url),
                  alt(article.title),
                  class("w-full h-full object-cover"),
                ]),
              ]),
              html.div([class("md:w-2/3 p-6 flex flex-col justify-between")], [
                html.div([], [
                  html.h3([class("text-2xl font-bold text-gray-900 mb-2")], [
                    html.text(article.title),
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
