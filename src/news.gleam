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
  html.div([class("p-4 bg-gray-100 rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-8 text-center")], [
      html.text("Nyhetsartikler om Sørbanen"),
    ]),
    html.div(
      [class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8")],
      list.map(articles, fn(article: NewsArticle) {
        html.a(
          [
            href(article.external_url),
            target("_blank"),
            rel("noopener noreferrer"),
            class(
              "block bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 overflow-hidden",
            ),
          ],
          [
            html.img([
              src(article.image_url),
              alt(article.title),
              class("w-full h-48 object-cover"),
            ]),
            html.div([class("p-6")], [
              html.h3([class("text-xl font-semibold text-gray-900 mb-2")], [
                html.text(article.title),
              ]),
              html.p([class("text-gray-700 text-base mb-2")], [
                html.text(article.description),
              ]),
              html.p([class("text-gray-500 text-sm")], [html.text(article.date)]),
            ]),
          ],
        )
      }),
    ),
  ])
}
