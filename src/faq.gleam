import gleam/list
import lustre/attribute.{class, href}
import lustre/element.{type Element}
import lustre/element/html

type Question {
  Question(question: String, answer: String)
}

pub fn render() -> Element(msg) {
  let questions = [
    Question("Hva er Surtoget?", "svar"),
    Question("Hvordan kan jeg bidra?", "svar"),
    Question("Hvorfor er toget alltid forsinket?", "svar"),
  ]

  html.section([class("my-10 space-y-8")], [
    html.h1([class("text-4xl font-bold text-center text-gray-800")], [
      html.text("Ofte Stilte Spørsmål"),
    ]),
    html.div(
      [class("max-w-2xl mx-auto text-lg text-gray-700 space-y-6")],
      list.map(questions, render_question),
    ),
    html.div([class("text-center mt-12")], [
      html.p([class("text-lg text-gray-600")], [
        html.text(
          "Finner du ikke svaret på det du lurer på? Send oss en e-post på ",
        ),
        html.a(
          [
            href("mailto:kontakt@surtoget.no"),
            class("text-yellow-600 hover:underline"),
          ],
          [html.text("kontakt@surtoget.no")],
        ),
      ]),
    ]),
  ])
}

fn render_question(question: Question) -> Element(msg) {
  html.div([], [
    html.h2([class("text-2xl font-semibold text-gray-800")], [
      html.text(question.question),
    ]),
    html.p([class("mt-2")], [html.text(question.answer)]),
  ])
}
