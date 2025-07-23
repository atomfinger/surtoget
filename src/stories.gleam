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
      quote: "Jeg tok toget på Sørlandsbanen en vinterdag, men det stoppet midt på strekningen på grunn av for mye snø. Vi ble sendt ut på en liten stasjon uten oppvarming, og jeg hadde ikke klær for kulda. Ingen alternativ transport ble satt opp, og vi ble stående der og fryse uten at noe form for kommunikasjon kom. Det føltes som vi ble glemt.",
      author: "Anonym",
    ),
    Story(
      quote: "Jeg prøver å besøke sønnen min jevnlig, men det har blitt stadig vanskeligere. Sørlandsbanen er så lite til å stole på og det er alltid noe. Ofte er det buss for tog, og reisen tar mye lenger tid enn den burde. Det gjør det stressende å planlegge, og jeg ender ofte opp med å vurdere om det i det hele tatt er verdt turen.",
      author: "Anonym",
    ),
    Story(
      quote: "Jeg har mye familie i Telemark, men det har blitt krevende å besøke dem. Når jeg skal rekke noe viktig – som en konfirmasjon eller bursdag – må jeg ofte reise med toget dagen i forveien, bare for å være sikker på å komme frem i tide. Sørlandsbanen er rett og slett for treg og upålitelig. Det tar tid fra både jobb og privatliv, og jeg kjenner det tærer på motivasjonen til å dra i det hele tatt.",
      author: "John M. Lindbakk",
    ),
    Story(
      quote: "Jeg skulle ta fly, men endte opp med å miste det fordi Sørlandsbanen ble forsinket av signalfeil. Jeg hadde god margin da jeg dro hjemmefra, men det hjelper lite når toget står stille uten forklaring.",
      author: "Anonym",
    ),
    Story(
      quote: "Jeg skulle ta med min tre måneder gamle sønn hjem til jul, med barnevogn og alt som hører med i julestria. Jeg var der i god tid før toget skulle gå, men ingen konduktør å se de 15 minuttene jeg stod der. Til slutt var det heldigvis en hyggelig medpassasjer som hjalp meg med barnevognen.. 2 min. før toget skulle gå! Ganske stressende, så det ble noen tårer på den nybakte moren da jeg omsider kom meg inn på toget.",
      author: "Anonym",
    ),
    Story(
      quote: "Avgangen 14:27 fra Bø til Oslo er KONSEKVENT forsinket. Alt fra 5 min til to timer. Den verste forsinkelsen var to timer og åtte minutter. Med et lite barn. Fint lite informasjon, og avgangstiden ble utvidet med 10 minutter av gangen, så det var ikke så mye annet å gjøre enn å stå der.",
      author: "Anonym",
    ),
    Story(
      quote: "Jeg og gutten min på to år skulle ta turen fra Bø til Oslo, men ikke overraskende ble det trøbbel på strekningen. Vi ble stående på Hokksund stasjon, og ble lovet buss for tog. Stort sett alle kom seg på en buss etter hvert (men ikke før en times tid). Men vi som hadde småbarn, vi måtte bli stående på Hokksund stasjon i tre timer (!) for de klarte ikke å skaffe barneseter til de fem barna som var med. Det endte med at vi måtte regiontoget fra Hokksund til Oslo etter tre timer. Altså ingen buss på oss.",
      author: "Kjersti Kaasa ",
    ),
  ]
  |> list.shuffle()
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
          [html.text("Folkets meninger")],
        ),
        html.p(
          [
            class(
              "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl",
            ),
          ],
          [html.text("Hva folk sier om Sørlandsbanen")],
        ),
      ]),
      html.div([class("mt-10")], [
        html.div(
          [
            class(
              "space-y-10 lg:space-y-0 lg:grid lg:grid-cols-3 lg:gap-x-8 lg:gap-y-10",
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
