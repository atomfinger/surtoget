import gleam/bit_array
import gleam/list
import lustre/attribute.{alt, class, href, loading, rel, src, target}
import lustre/element.{type Element}
import lustre/element/html

import gleam/crypto
import gleam/int
import gleam/result
import gleam/string

pub type NewsArticle {
  NewsArticle(
    title: String,
    description: String,
    external_url: String,
    external_image_url: String,
    owner: String,
    date: String,
  )
}

import gleam/dict

pub fn get_news_articles() -> List(NewsArticle) {
  let articles = [
    NewsArticle(
      title: "Kun én avgang om dagen med Sørlandsbanen",
      description: "Fram til og med onsdag er det kun én daglig avgang på Sørlandsbanen i hver retning. Årsaken er at det er oppdaget løse sideruter på åtte togsett (type 73), som nå er tatt ut av drift for reparasjon.",
      external_url: "https://www.nrk.no/sorlandet/kun-en-avgang-om-dagen-med-sorlandsbanen--1.17504983",
      external_image_url: "https://gfx.nrk.no/FLUplHUikquKhdgPCOAtZg6eJGjwKHV-nbChZdoNum8Q.jpg",
      owner: "NRK",
      date: "25. juli 2025",
    ),
    NewsArticle(
      title: "Togvindu løsnet – avganger innstilt",
      description: "Go-Ahead har innstilt alle regiontogavganger av type 73 på Sørlandsbanen etter at et sidevindu løsnet på et tog. Åtte togsett er tatt ut av tjeneste for inspeksjon, og det er funnet løse vinduer på tre av dem. Nattogene går som normalt.",
      external_url: "https://www.nrk.no/sorlandet/avganger-pa-sorlandsbanen-er-innstilt-1.17503849",
      external_image_url: "https://gfx.nrk.no/uUl2XauH6-h-p1RPbwcMfwDXKlNquOnXuMFEizrB5Xig.jpg",
      owner: "NRK",
      date: "24. juli 2025",
    ),
    NewsArticle(
      title: "Go-Ahead melder om togtrøbbel i dag, tysdag",
      description: "Togselskapet Go-Ahead melder om togtrøbbel på Sørlandsbanen tirsdag. Avgangen fra Stavanger klokka 4.20 mot Oslo er innstilt. Det blir satt opp buss for tog på strekningen mellom Stavanger og Kongsberg.",
      external_url: "https://www.boblad.no/nyheit/go-ahead-melder-om-togtrobbel-i-dag-tysdag/360802",
      external_image_url: "https://image.boblad.no/305005.webp?imageId=305005&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "21. juli 2025",
    ),
    NewsArticle(
      title: "Rim tvang tog til å snu i motbakke – mener Bane Nor kunne løst problemet raskere",
      description: "Rim på kontaktledningen på Sørlandsbanen førte til at tog måtte snu i en motbakke, noe som skapte forsinkelser. Go Ahead Nordic kritiserer Bane NOR for treg problemløsning.",
      external_url: "https://www.tu.no/artikler/rim-tvang-tog-til-a-snu-i-motbakke-mener-bane-nor-kunne-lost-problemet-raskere-br/554340",
      external_image_url: "https://images.gfx.no/1000x/2867/2867644/NTB_HIO_aa45YWU.jpg",
      owner: "TU",
      date: "03. januar 2025",
    ),
    NewsArticle(
      title: "Avsporing på Sandnes: – Trafikken vil nok stort sett gå som normalt",
      description: "Et tomt tog har sporet av ved Skeiane stasjon i Sandnes, noe som forårsaker forsinkelser på Sørlandsbanen. Togtrafikken forventes likevel å gå stort sett som normalt, da andre spor er tilgjengelige.",
      external_url: "https://www.nrk.no/rogaland/avsporing-pa-sandnes_-_-trafikken-vil-nok-stort-sett-ga-som-normalt-1.17218999",
      external_image_url: "https://gfx.nrk.no/OxNJVxbO4jw-Pyhti0Y_TAVkW3t8hDUPaFsmESJWateA.jpg",
      owner: "NRK",
      date: "23. januar 2025",
    ),
    NewsArticle(
      title: "Esa vurderer å åpne sak mot Norge etter tildelingen av Sørlandsbanen til Vy",
      description: "Eftas overvåkingsorgan, Esa, vurderer å åpne sak mot Norge etter at Jernbanedirektoratet i oktober i fjor tildelte Sørlandsbanen til Vy og vraket Go-Ahead.",
      external_url: "https://www.finansavisen.no/politikk/2025/05/15/8264298/esa-vurderer-a-apne-sak-mot-norge-etter-tildelingen-av-sorlandsbanen-til-vy",
      external_image_url: "https://imaginary.finansavisen.no/aoi-cover?width=2560&height=1440&top=834&left=382&areawidth=1518&areaheight=994&url=https%3A%2F%2Fsmooth-storage.aptoma.no%2Fusers%2Fhegnar%2Fimages%2F107652070.jpg%3Ft%5Bquality%5D%3D100%26%26accessToken%3Dbabc1782acf1bdd757801aefa6fc4321d3b70c4bd2ee7103187b6ddd5b1e75bc",
      owner: "Finansavisen",
      date: "15. mai 2025",
    ),
    NewsArticle(
      title: "Står saman: – Me jobbar vidare for at toga skal stoppe der folk bur",
      description: "Tre ordførere i Telemark kjemper for bedre togtilbud i regionen.",
      external_url: "https://www.boblad.no/nyheit/star-saman-me-jobbar-vidare-for-at-toga-skal-stoppe-der-folk-bur/336999",
      external_image_url: "https://image.boblad.no/337003.webp?imageId=337003&x=5.59&y=27.32&cropw=81.28&croph=52.19&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "15. mai 2025",
    ),
    NewsArticle(
      title: "Togtrøbbel skyldes slitte hjul",
      description: "Slitte togshjul forårsaker forsinkelser og innstillinger på Sørlandsbanen. Nye hjul ventes, men tidspunkt for utskifting er ukjent.",
      external_url: "https://www.nrk.no/sorlandet/togtrobbel-skyldes-slitte-hjul-1.17443405",
      external_image_url: "https://gfx.nrk.no/FLUplHUikquKhdgPCOAtZg6eJGjwKHV-nbChZdoNum8Q.jpg",
      owner: "NRK",
      date: "04. juni 2025",
    ),
    NewsArticle(
      title: "Får ikke togstopp tilbake",
      description: "Digitalt møte i Togforum Sørlandsbanen skuffet ordførere som håpet på gjenåpning av togstopp.",
      external_url: "https://www.drangedalsposten.no/far-ikke-togstopp-tilbake/s/5-164-34639",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/dran/2025/6/8/14/utekontor.jpg?chk=24FA34",
      owner: "Drangedalsposten",
      date: "08. juni 2025",
    ),
    NewsArticle(
      title: "Sørlandsbanen digitaliseres",
      description: "Bane NOR digitaliserer Sørlandsbanen ved å erstatte dagens signalsystem med ERTMS. Dette skal redusere forsinkelser og øke togfrekvensen.",
      external_url: "https://www.banenor.no/prosjekter/alle-prosjekter/ertms-fremtidens-signalsystem/aktuelt-om-ertms/sorlandbanen-digitaliseres/",
      external_image_url: "https://www.banenor.no/contentassets/4aea6634ca014ecd93341f302c1cda54/ertms_holmlia_foto-liv-tone-otterholt_nett.jpg?format=avi1&width=1680&height=1120&quality=80",
      owner: "Bane NOR",
      date: "10. juli 2025",
    ),
    NewsArticle(
      title: "Skal ha nytt møte med Bane Nor – er ikkje fornøgde",
      description: "Nytt møte i Sørlandsbanen togforum der forsvinning av togstopp ble diskutert.",
      external_url: "https://www.boblad.no/nyheit/skal-ha-nytt-mote-med-bane-nor-er-ikkje-fornogde/357587",
      external_image_url: "https://image.boblad.no/357616.webp?imageId=357616&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "30. juni 2025",
    ),
    NewsArticle(
      title: "Tog mellom Stavanger og Kongsberg i dag innstilt",
      description: "Go-Ahead Nordic har kansellert et tog på grunn av et problem og råder passasjerer til å ta neste tog.",
      external_url: "https://www.boblad.no/nyheit/tog-mellom-stavanger-og-kongsberg-i-dag-innstilt/360132",
      external_image_url: "https://image.boblad.no/174848.webp?imageId=174848&width=2116&height=1208&format=avi1",
      owner: "Bøblad",
      date: "16. juli 2025",
    ),
    NewsArticle(
      title: "Signalfeil får konsekvenser for Sørlandsbanen",
      description: "En signalfeil i Oslo skaper forsinkelser og innstillinger for Sørlandsbanen, som går til og fra Oslo. Ingen tog kan passere Oslo på grunn av feilen.",
      external_url: "https://www.nrk.no/stor-oslo/full-stans-i-togtrafikken-pa-ostlandet-1.17340830",
      external_image_url: "https://gfx.nrk.no/lRhO5YMIPnGG9ilUJdcIWgGa6gx2aH0aK_Vghre7plEA.jpg",
      owner: "NRK",
      date: "15. mars 2025",
    ),
    NewsArticle(
      title: "Store togproblemer på Sørlandsbanen",
      description: "Det er meldt om store problemer for tog mellom Marnardal og Audnedal. Mye rim på kjøretråden gir dårlig kontakt mellom tog og kjøretråd, noe som fører til strømproblemer.",
      external_url: "https://www.nrk.no/sorlandet/store-togproblemer-pa-sorlandsbanen-1.17189263",
      external_image_url: "https://gfx.nrk.no/xTBdyfd8MOT7mtRWnun-4g8SKcchDTAlXmyV0ptecHAw.jpg",
      owner: "NRK",
      date: "10. november 2024",
    ),
    NewsArticle(
      title: "Vy tar over Sørlandsbanen - Go-Ahead Nordic vrakes",
      description: "Den statseide togselskapet Vy tar over Sørlandsbanen, Arendalsbanen og Jærbanen fra Go-Ahead Nordic fra desember 2027.",
      external_url: "https://www.nrk.no/sorlandet/vy-tar-over-sorlandsbanen-_-go-ahead-nordic-vrakes-1.17094076",
      external_image_url: "https://gfx.nrk.no/hgJLNVrVhRS-J1gOrBvWygRXp7yx4sW44VmMgM0k9KiA.jpg",
      owner: "NRK",
      date: "25. oktober 2024",
    ),
    NewsArticle(
      title: "Flere ordførere i Telemark kjemper for å få tilbake stopp på Sørlandsbanen",
      description: "Fire ordførere fra Telemark har sendt et brev til stortingspolitikerne der de kritiserer Bane Nor for å ha fjernet stopp på Sørlandsbanen, noe de mener har forverret punktligheten.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/flere-ordforere-i-telemark-kjemper-for-a-fa-tilbake-stopp-pa-sorlandsbanen-1.17092301",
      external_image_url: "https://gfx.nrk.no/8tySAizN-1qRWm0521Z1Wwk33kXVrLgfzcBuUBmItZ0w.jpg",
      owner: "NRK",
      date: "28. oktober 2024",
    ),
    NewsArticle(
      title: "Fikk tre timer i Drangedal",
      description: "Reisende med toget fra Stavanger til Oslo søndag ettermiddag fikk anledning til å studere omgivelsene rundt stasjonen i Prestestranda i rundt tre timer før turen kunne gå videre.",
      external_url: "https://www.drangedalsposten.no/fikk-tre-timer-i-drangedal/s/5-164-34904",
      external_image_url: "",
      owner: "Drangedalsposten",
      date: "16. juni 2025",
    ),
    NewsArticle(
      title: "Stor aktør på Jærbanen trekker seg: Frykter mer buss for tog",
      description: "Selskapet som vedlikeholder togene på Sørlandsbanen, terminerte kontrakten etter store økonomiske tap. Nå overtar Go-Ahead arbeidet selv.",
      external_url: "https://www.aftenbladet.no/lokalt/i/dRe2j1/stor-aktoer-paa-jaerbanen-trekker-seg-frykter-mer-buss-for-tog",
      external_image_url: "https://premium.vgc.no/v2/images/8d8574ae-b5f7-45d1-a430-053142232d54?fit=crop&format=auto&h=995&w=1900&s=df82e18af61f9b4734df0b06c288f2d93af1f07c",
      owner: "Aftenbladet",
      date: "26. mai 2025",
    ),
    NewsArticle(
      title: "Buss for tog i sommar",
      description: "Sidan pendlarane har ferie og det er færre som tar tog, nyttar Bane Nor moglegheitene til vedlikehalds- og byggearbeid på togstrekningane.",
      external_url: "https://www.nrk.no/vestfoldogtelemark/buss-for-tog-i-sommar-1.17424797",
      external_image_url: "https://gfx.nrk.no/E1nhPRb6k7GReJkcTROcIg5Xo1p44-YoUgEFoTF7St0g",
      owner: "NRK",
      date: "20. mai 2025",
    ),
    NewsArticle(
      title: "Sørlandsbanen: Har aldri vært verre",
      description: "Sørlandsbanen har lavest punktlighet – tiltakene gir liten effekt så langt.",
      external_url: "https://www.dalane-tidende.no/sorlandsbanen-har-aldri-vart-verre/s/5-101-741316",
      external_image_url: "https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1200_1200_s_f/0000/dala/2022/11/6/14/Go%2BAhead%2B19.07.20%2B(20)%2BDriftsbanegrden%2BKongsberg_1.jpg?chk=8714D3",
      owner: "Dalene Tidene",
      date: "19. januar 2025",
    ),
  ]
  list.sort(articles, by: fn(a, b) {
    case parse_date(a.date), parse_date(b.date) {
      Ok(date_a), Ok(date_b) -> string.compare(date_b, date_a)
      _, _ -> string.compare(a.date, b.date)
      // Fallback to string comparison if parsing fails
    }
  })
}

fn parse_date(date_string: String) -> Result(String, Nil) {
  let month_map =
    dict.from_list([
      #("januar", "01"),
      #("februar", "02"),
      #("mars", "03"),
      #("april", "04"),
      #("mai", "05"),
      #("juni", "06"),
      #("juli", "07"),
      #("august", "08"),
      #("september", "09"),
      #("oktober", "10"),
      #("november", "11"),
      #("desember", "12"),
    ])

  let parts = string.split(date_string, " ")
  case parts {
    [day_str, month_name, year_str] -> {
      let cleaned_day_str = case string.ends_with(day_str, ".") {
        True -> string.slice(day_str, 0, string.length(day_str) - 1)
        False -> day_str
      }
      use day <- result.try(int.parse(cleaned_day_str))
      use _year <- result.try(int.parse(year_str))
      use month_num <- result.try(dict.get(month_map, month_name))

      let formatted_day = case day < 10 {
        True -> "0" <> int.to_string(day)
        False -> int.to_string(day)
      }
      Ok(year_str <> "-" <> month_num <> "-" <> formatted_day)
    }
    _ -> Error(Nil)
  }
}

pub fn get_image_id(article: NewsArticle) -> String {
  crypto.hash(crypto.Sha1, bit_array.from_string(article.external_image_url))
  |> bit_array.base16_encode()
}

pub fn get_image_url(article: NewsArticle) -> String {
  "/news/images/" <> get_image_id(article)
}

pub fn find_article_by_image_id(image_id: String) -> Result(NewsArticle, Nil) {
  get_news_articles()
  |> list.filter(fn(article) { get_image_id(article) == image_id })
  |> list.first()
}

pub fn render(articles: List(NewsArticle)) -> Element(a) {
  html.div([class("py-12 bg-gray-50")], [
    html.div([class("max-w-7xl mx-auto px-4 sm:px-6 lg:px-8")], [
      html.div([class("text-center")], [
        html.h2(
          [
            class(
              "text-base text-yellow-600 font-semibold tracking-wide uppercase",
            ),
          ],
          [html.text("Siste Nytt")],
        ),
        html.p(
          [
            class(
              "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl",
            ),
          ],
          [html.text("Oppdateringer om Sørlandsbanen")],
        ),
      ]),
      html.div(
        [class("mt-12 space-y-8")],
        list.map(articles, fn(article) {
          html.a(
            [
              href(article.external_url),
              target("_blank"),
              rel("noopener noreferrer"),
              class(
                "block md:flex bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 overflow-hidden",
              ),
            ],
            [
              html.div([class("md:w-1/3")], [
                html.img([
                  loading("lazy"),
                  src(get_image_url(article)),
                  alt(article.title),
                  class("w-full h-full object-cover max-h-80 md:max-h-full"),
                ]),
              ]),
              html.div([class("md:w-2/3 p-6 flex flex-col justify-between")], [
                html.div([], [
                  html.h3([class("text-2xl font-bold text-gray-900 mb-2")], [
                    html.text(article.title <> " [" <> article.owner <> "]"),
                  ]),
                  html.p([class("text-gray-700 text-base mb-4")], [
                    html.text(article.description),
                  ]),
                ]),
                html.p([class("text-gray-500 text-sm")], [
                  html.text(article.date),
                ]),
              ]),
            ],
          )
        }),
      ),
      html.div([class("mt-12 text-center")], [
        html.p([class("text-gray-600")], [
          html.text("Mangler vi en sak? Send den til "),
          html.a(
            [
              href("mailto:tips@surtoget.no"),
              class("text-yellow-600 hover:underline"),
            ],
            [html.text("tips@surtoget.no")],
          ),
        ]),
      ]),
    ]),
  ])
}
