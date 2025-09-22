import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.section([class("my-10 space-y-8")], [
    html.h1([class("text-4xl font-bold text-center text-gray-800")], [
      html.text("Sørlandsbanens Tilstand"),
    ]),
    html.div([class("max-w-2xl mx-auto text-lg text-gray-700 space-y-6")], [
      html.h2([class("text-2xl font-bold text-gray-800")], [
        html.text("Fra stolt fortid til usikker fremtid"),
      ]),
      html.p([], [
        html.text(
          "Sørlandsbanen var en gang en stolt ryggrad i transporten mellom Oslo og Stavanger. I dag er den dessverre blitt et symbol på forfall og frustrasjon for tusenvis av passasjerer. Denne siden forteller historien om hvordan vi kom hit.",
        ),
      ]),
      html.h2([class("text-2xl font-bold text-gray-800")], [
        html.text("Årsakene til dagens situasjon"),
      ]),
      html.p([], [
        html.text(
          "Problemene er sammensatte. Flere tiår med manglende investeringer har ført til en utdatert og sårbar infrastruktur. Enkeltspor på lange strekninger, utdaterte signalanlegg og et generelt vedlikeholdsetterslep er bare noen av faktorene.",
        ),
      ]),
      html.p([], [
        html.text(
          "Samtidig har oppsplittingen av ansvaret for jernbanen, med Bane NOR som eier av sporet og ulike operatører som kjører togene, skapt en fragmentert og lite effektiv struktur. Dette gjør det vanskelig å gjennomføre de store, helhetlige løftene som trengs.",
        ),
      ]),
      html.h2([class("text-2xl font-bold text-gray-800")], [
        html.text("Hva må til for en bedre fremtid?"),
      ]),
      html.p([], [
        html.text(
          "For at Sørlandsbanen skal bli en pålitelig og moderne transportåre igjen, kreves det en massiv og langsiktig satsing. Dobbeltspor på hele eller store deler av strekningen er det viktigste enkelttiltaket. I tillegg må signalanleggene moderniseres og det generelle vedlikeholdsetterslepet tas igjen.",
        ),
      ]),
      html.p([], [
        html.text(
          "Det krever politisk vilje og en anerkjennelse av at jernbanen er en kritisk del av landets infrastruktur. Uten en klar og forpliktende plan, vil Sørlandsbanen fortsette å være en kilde til frustrasjon i mange år fremover.",
        ),
      ]),
    ]),
  ])
}
