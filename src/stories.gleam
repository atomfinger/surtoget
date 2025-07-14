import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(a) {
  html.div([class("p-4 bg-white rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-4")], [
      html.text("Personlige Historier"),
    ]),
    html.p([class("text-gray-600")], [
      html.text(
        "Her kan du lese om hvordan folk har opplevd problemene på Sørbanen.",
      ),
    ]),
  ])
}
