import gleam/list
import lustre/attribute.{class, href}
import lustre/element.{type Element}
import lustre/element/html

pub type Story {
  Story(quote: String, author: String)
}

fn get_stories() -> List(Story) {
  [
    Story(
      quote: "Jeg mistet et viktig møte fordi toget var 2 timer forsinket. Utrolig frustrerende!",
      author: "Test",
    ),
    Story(
      quote: "Barna mine ble stående og vente i en time på stasjonen i går. Ikke første gang.",
      author: "Test",
    ),
    Story(
      quote: "Jeg har gitt opp å ta toget til jobb. Nå kjører jeg bil i stedet, selv om det er dyrere og dårligere for miljøet.",
      author: "Test",
    ),
    Story(
      quote: "Hver dag er et nytt eventyr med Sørbanen. Man vet aldri om man kommer frem i tide.",
      author: "Test",
    ),
    Story(
      quote: "Jeg har begynt å ta fly for å reise mellom Oslo og Stavanger. Det er dyrere, men i det minste kommer jeg frem.",
      author: "Test",
    ),
  ]
}

pub fn render() -> Element(a) {
  let stories = list.take(get_stories(), 3)

  html.div([class("p-6 bg-white rounded-lg shadow-lg")], [
    html.div([class("max-w-7xl mx-auto px-4 sm:px-6 lg:px-8")], [
      html.div([class("text-center")], [
        html.h2(
          [
            class(
              "text-base text-yellow-600 font-semibold tracking-wide uppercase",
            ),
          ],
          [html.text("Personlige Historier")],
        ),
        html.p(
          [
            class(
              "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl",
            ),
          ],
          [html.text("Hva folk sier om Sørbanen")],
        ),
      ]),
      html.div([class("mt-10")], [
        html.div(
          [
            class(
              "space-y-10 md:space-y-0 md:grid md:grid-cols-3 md:gap-x-8 md:gap-y-10",
            ),
          ],
          list.map(stories, fn(story: Story) {
            html.div([class("relative")], [
              html.div(
                [class("p-6 bg-gray-50 rounded-lg border border-gray-200")],
                [
                  html.p([class("text-lg text-gray-600")], [
                    html.text("“" <> story.quote <> "”"),
                  ]),
                  html.p([class("mt-4 text-right text-gray-500")], [
                    html.text("- " <> story.author),
                  ]),
                ],
              ),
            ])
          }),
        ),
      ]),
      html.div([class("mt-12 text-center")], [
        html.p([class("text-gray-600")], [
          html.text("Har du en egen historie du vil dele? Send den til "),
          html.a(
            [
              href("mailto:kontakt@surtoget.no"),
              class("text-yellow-600 hover:underline"),
            ],
            [html.text("kontakt@surtoget.no")],
          ),
        ]),
      ]),
    ]),
  ])
}
