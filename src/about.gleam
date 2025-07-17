import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.section([class("my-10 space-y-8")], [
    html.h1([class("text-4xl font-bold text-center text-gray-800")], [
      html.text("Om Surtoget"),
    ]),
    html.div([class("max-w-2xl mx-auto text-lg text-gray-700 space-y-6")], [
      html.p([], [
        html.text(
          "Surtoget er et initiativ startet av en gruppe frustrerte pendlere som er lei av de stadige forsinkelsene, innstillingene og den generelle mangelen på pålitelighet på Sørlandsbanen.",
        ),
      ]),
      html.p([], [
        html.text(
          "Vårt mål er å synliggjøre problemene og skape et press på de ansvarlige for å få en bedre og mer forutsigbar togstrekning. Vi samler inn og deler historier fra passasjerer, presenterer statistikk over forsinkelser og gir informasjon om rettigheter ved togtrøbbel.",
        ),
      ]),
      html.p([], [
        html.text(
          "Vi tror at ved å stå sammen kan vi gjøre en forskjell. Engasjer deg, del din historie og bli med i kampen for et bedre togtilbud!",
        ),
      ]),
    ]),
  ])
}
