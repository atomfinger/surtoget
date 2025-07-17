import lustre/attribute.{class, href, src}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.section([class("my-10 space-y-8")], [
    html.h1([class("text-4xl font-bold text-center text-gray-800")], [
      html.text("Om Surtoget.no"),
    ]),
    html.div([class("max-w-2xl mx-auto text-lg text-gray-700 space-y-6")], [
      html.h2([class("text-2xl font-bold text-gray-800")], [
        html.text("Hvorfor Surtoget?"),
      ]),
      html.p([], [html.text("Frustrasjon. Rett og slett.")]),
      html.p([], [
        html.text(
          "Utallige ganger har jeg selv, eller familiemedlemmer, blitt sittende fast på et tog i timevis. Og hver gang er det den samme leksa: fingerpeking mellom selskaper, tomme løfter om bedring, og en total mangel på informasjon.",
        ),
      ]),
      html.p([], [
        html.text("Og når sommeren kommer, og jeg tror at nå, "),
        html.em([], [html.text("nå")]),
        html.text(
          " blir det bedre... da stenger de hele greia for vedlikehold. Resultatet? En vinter som er verre enn den forrige.",
        ),
      ]),
      html.h2([class("text-2xl font-bold text-gray-800")], [
        html.text("Målet med Surtoget"),
      ]),
      html.p([], [
        html.text(
          "Surtoget.no er et forsøk på å belyse problemet. For det kan da umulig være bare jeg som har det sånn? Målet er å skape en plattform for informasjon, og forhåpentligvis, en arena for samtale. Eller i det minste, et sted å få ut litt frustrasjon.",
        ),
      ]),
    ]),
    html.div(
      [
        class(
          "max-w-4xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8 items-center pt-10",
        ),
      ],
      [
        html.div([class("md:col-span-1 flex justify-center")], [
          html.img([
            class("w-48 h-48 rounded-full object-cover shadow-lg"),
            src("/static/lindbakk.jpg"),
            attribute.alt("John Mikael Lindbakk"),
          ]),
        ]),
        html.div([class("md:col-span-2 space-y-6 text-lg text-gray-700")], [
          html.h2([class("text-2xl font-bold text-gray-800")], [
            html.text("Hvem står bak?"),
          ]),
          html.p([], [
            html.text("Surtoget.no er et enmannsprosjekt av "),
            html.a(
              [
                href("https://lindbakk.com/"),
                class("text-blue-600 hover:underline"),
              ],
              [html.text("John Mikael Lindbakk")],
            ),
            html.text(
              ". En utvikler som har kjent på frustrasjonen av Sørlandsbanen utallige ganger.",
            ),
          ]),
        ]),
      ],
    ),
  ])
}
