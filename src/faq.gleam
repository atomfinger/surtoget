import gleam/list
import lustre/attribute.{class, href}
import lustre/element.{type Element}
import lustre/element/html

type Question {
  Question(
    question: String,
    answer: List(String),
    links: List(#(String, String)),
  )
}

pub fn render() -> Element(msg) {
  let questions = [
    Question(
      "Hvor kommer dataene fra?",
      [
        "All data vi bruker kommer fra BaneNor. De publiserer sanntidsdata og punktlighetsrapporter som vi bruker for å lage statistikk og visualiseringer.",
        "Data om forsinkelser hentes fra Entur sitt Real-time data API.",
      ],
      [
        #(
          "https://www.banenor.no/reise-og-trafikk/punktlighetsstatistikk/",
          "Punktlighetsstatistikk",
        ),
        #(
          "https://www.banenor.no/reise-og-trafikk/punktlighetsrapporter/",
          "Punktlighetsrapporter",
        ),
        #(
          "https://developer.entur.org/pages-real-time-api",
          "Entur real-time API",
        ),
      ],
    ),
    Question(
      "Hvordan kan jeg dele min historie?",
      [
        "Du kan sende din historie til oss via Google Forms eller på e-post til kontakt@surtoget.no. Vi publiserer historier fortløpende.",
        "Du kan velge å være anonym. Innsendinger via Google-skjema og e-post blir slettet etter en uke. Vi forbeholder oss retten til å redigere og korrigere stavefeil, men vi vil ikke skrive om historien din. Hvis du vil ha historien din slettet, kan du kontakte oss på samme e-postadresse.",
      ],
      [
        #(
          "https://docs.google.com/forms/d/e/1FAIpQLSe_x8FSwMMBNf6l_EOhfF2x8ieLVVOKNF6482n4Jfxtqg89oA/viewform?usp=header",
          "Skjema for historier",
        ),
      ],
    ),
    Question(
      "Hvorfor bare Sørlandsbanen?",
      [
        "Fordi det er Sørlandsbanen som frustrerer meg personlig 🤷🏻‍♂️",
        "Når det er sagt så tror jeg at Sørlandsbanen trekker den generelle punktlighetsstatistikken ganske langt ned, så da er Sørlandsbanen kanskje et OK fokus og ha.",
      ],
      [],
    ),
    Question(
      "Hvem har skylda for at Sørlandsbanen er så dårlig?!",
      [
        "Det skulle jeg også gjerne visst. Jeg er dessverre ikke noe ekspert på dette, men jeg håper å få lagt inn mer informasjon om hvorfor ting har blitt som de har blitt.",
        "Om jeg må komme med en teori så ville jeg pekt på en kombinasjon av privatisering, uvillighet til å modernisere infrastruktur, mangel på togsett, tvilsomme kjøpt av tog uten snøplog og nedprioritering i budsjetter. Alle disse tingene har nok hatt en påvirkning og gjort jernbanenorge dårligere.",
      ],
      [],
    ),
    Question(
      "Hvilke teknologier brukes?",
      [
        "Surtoget er bygget med følgende teknologier:",
        "- Gleam: Et moderne og brukervennlig programmeringsspråk for backenden.",
        "- Lustre: Et webrammeverk for Gleam.",
        "- Tailwind CSS: For design og styling.",
        "- Simpleanalytics: For statistikk på besøkende på siden",
        "- fly.io: Der nettsiden kjøres",
        "Kildekoden er åpen og tilgjengelig på GitHub.",
      ],
      [
        #(
          "https://github.com/atomfinger/surtoget",
          "https://github.com/atomfinger/surtoget",
        ),
        #("fly.io/legal/privacy-policy.", "fly.io privacy policy"),
        #("https://docs.simpleanalytics.com/privacy", "Simpleanalytics"),
      ],
    ),
    Question(
      "Hvilke data lagres om besøkende?",
      [
        "Ingen. Vi bruker ikke informasjonskapsler (cookies) og sporer ikke besøkende.",
        "Hvis du sender oss en e-post, blir den slettet etter en uke. Hvis du deler en historie og ikke vil være anonym, blir navnet eller aliaset ditt lagret til du ber om at det blir fjernet.",
      ],
      [],
    ),
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
          "Finner du ikke svaret på det du lurer på eller har du noen innspill? Send oss en e-post på ",
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
    html.div(
      [],
      list.map(question.answer, fn(paragraph) {
        html.p([class("mt-2")], [html.text(paragraph)])
      }),
    ),
    html.ul(
      [class("list-disc list-inside mt-2")],
      list.map(question.links, fn(link) {
        html.li([], [
          html.a([href(link.0), class("text-yellow-600 hover:underline")], [
            html.text(link.1),
          ]),
        ])
      }),
    ),
  ])
}
