import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import news.{type NewsArticle}

pub fn render(articles: List(NewsArticle)) -> Element(a) {
  html.div([attribute.class("p-4 bg-gray-100 rounded-lg")], [
    html.h2(
      [attribute.class("text-2xl font-bold text-gray-800 mb-4 text-center")],
      [html.text("Nyhetsartikler om Sørbanen")],
    ),
    html.div([attribute.class("text-center mb-8")], [
      html.p([attribute.class("text-gray-600")], [
        html.text("Er det en sak vi mangler? Tips oss via epost: "),
        html.a(
          [
            attribute.href("mailto:tips@surtoget.no"),
            attribute.class("text-yellow-600 hover:underline"),
          ],
          [html.text("tips@surtoget.no")],
        ),
      ]),
    ]),
    html.div(
      [attribute.class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8")],
      list.map(articles, fn(article: NewsArticle) {
        html.a(
          [
            attribute.href(article.external_url),
            attribute.target("_blank"),
            attribute.rel("noopener noreferrer"),
            attribute.class(
              "block bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 overflow-hidden",
            ),
          ],
          [
            html.img([
              attribute.src(news.get_image_url(article)),
              attribute.alt(article.title),
              attribute.class("w-full h-48 max-h-48 object-cover"),
            ]),
            html.div([attribute.class("p-6")], [
              html.h3(
                [attribute.class("text-xl font-semibold text-gray-900 mb-2")],
                [html.text(article.title <> " [" <> article.owner <> "]")],
              ),
              html.p([attribute.class("text-gray-700 text-base mb-2")], [
                html.text(article.description),
              ]),
              html.p([attribute.class("text-gray-500 text-sm")], [
                html.text(article.date),
              ]),
            ]),
          ],
        )
      }),
    ),
  ])
}
