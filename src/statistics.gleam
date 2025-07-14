import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(a) {
  html.div([class("p-4 bg-gray-100 rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-4")], [
      html.text("Statistikk"),
    ]),
    html.p([class("text-gray-600")], [
      html.text("Her kommer det statistikk om forsinkelser og innstillinger."),
    ]),
  ])
}
