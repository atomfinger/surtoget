import lustre/attribute.{attribute, class, href, rel, target}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg

fn claim_icon() -> Element(a) {
  svg.svg(
    [
      class("w-8 h-8 mr-3 text-green-500"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
      attribute("viewBox", "0 0 24 24"),
      attribute("fill", "currentColor"),
    ],
    [
      svg.path([
        attribute(
          "d",
          "M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM19 18H6c-2.21 0-4-1.79-4-4 0-2.21 1.79-4 4-4h.71C7.37 8.69 9.49 7 12 7c2.76 0 5 2.24 5 5v1h2c1.66 0 3 1.34 3 3s-1.34 3-3 3z",
        ),
      ]),
    ],
  )
}

fn no_claim_icon() -> Element(a) {
  svg.svg(
    [
      class("w-8 h-8 mr-3 text-red-500"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
      attribute("viewBox", "0 0 24 24"),
      attribute("fill", "currentColor"),
    ],
    [
      svg.path([
        attribute(
          "d",
          "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z",
        ),
      ]),
    ],
  )
}

pub fn render() -> Element(a) {
  html.div([class("p-6 bg-white rounded-lg shadow-lg")], [
    html.h2(
      [
        class(
          "text-base font-semibold text-yellow-500 uppercase tracking-wide text-center",
        ),
      ],
      [html.text("Penger tilbake ved forsinkelse")],
    ),
    html.h3([class("text-2xl font-bold text-gray-800 mt-2 mb-4 text-center")], [
      html.text("Sur fordi toget er forsinket? Slik får du penger tilbake!"),
    ]),
    html.p([class("mb-6 text-gray-700")], [
      html.text(
        "Vi vet, det er kjipt å være forsinket. Men visste du at du kan ha krav på refusjon? Her er en enkel oversikt over når du kan juble hele veien til banken, og når du må bite i det sure eplet.",
      ),
    ]),
    html.div([class("grid md:grid-cols-2 gap-8")], [
      // Left column: What you get
      html.div([class("flex items-start")], [
        claim_icon(),
        html.div([], [
          html.h4([class("text-xl font-semibold text-gray-800 mb-2")], [
            html.text("Dette har du krav på"),
          ]),
          html.p([class("text-gray-700")], [
            html.text(
              "Er du mer enn 60 minutter forsinket med Sørtoget? Da får du 50% av billettkostnaden tilbake. Enkelt og greit!",
            ),
          ]),
        ]),
      ]),
      // Right column: What you don't get
      html.div([class("flex items-start")], [
        no_claim_icon(),
        html.div([], [
          html.h4([class("text-xl font-semibold text-gray-800 mb-2")], [
            html.text("...og dette har du ikke krav på"),
          ]),
          html.p([class("text-gray-700")], [
            html.text(
              "Dessverre, hvis forsinkelsen skyldes ekstremvær, naturkatastrofer, eller streik, må du nok bare smøre deg med tålmodighet (og en god bok).",
            ),
          ]),
        ]),
      ]),
    ]),
    html.div([class("mt-8 pt-6 border-t border-gray-200")], [
      html.h4([class("text-xl font-semibold text-gray-800 mb-4 text-center")], [
        html.text("Slik krever du refusjon"),
      ]),
      html.p([class("text-gray-700 text-center mb-6")], [
        html.text("For å få pengene dine, send en e-post til "),
        html.a(
          [
            href("mailto:kundeservice@go-aheadnordic.no"),
            class("text-yellow-600 hover:underline"),
          ],
          [html.text("kundeservice@go-aheadnordic.no")],
        ),
        html.text(
          " med en kopi av billetten din og en kort beskrivelse av hendelsen. Fristen er 3 måneder, så ikke somle!",
        ),
      ]),
      html.div([class("text-center")], [
        html.a(
          [
            href(
              "https://go-aheadnordic.no/reiseinformasjon/endring-refusjon-og-gebyrer",
            ),
            target("_blank"),
            rel("noopener noreferrer"),
            class(
              "inline-block bg-yellow-500 text-white font-bold py-3 px-6 rounded-lg hover:bg-yellow-600 transition-colors duration-200",
            ),
          ],
          [html.text("Les mer og søk om refusjon")],
        ),
      ]),
    ]),
  ])
}
