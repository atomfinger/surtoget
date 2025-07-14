import gleam/list
import lustre/attribute.{class}
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

  html.div([class("p-4 bg-white rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-8 text-center")], [
      html.text("Personlige Historier"),
    ]),
    html.div(
      [class("flex justify-center space-x-4")],
      list.map(stories, fn(story: Story) {
        html.div(
          [
            class(
              "w-1/3 bg-surtoget-yellow/20 rounded-lg flex flex-col items-center justify-center text-center p-6 shadow-lg",
            ),
          ],
          [
            html.p([class("text-gray-800 italic text-md mb-4")], [
              html.text(story.quote),
            ]),
            html.p([class("text-gray-600 font-semibold text-sm")], [
              html.text("- " <> story.author),
            ]),
          ],
        )
      }),
    ),
  ])
}
