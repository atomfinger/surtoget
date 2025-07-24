import lustre/attribute.{class, href}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.div([class("text-center py-16")], [
    html.h1(
      [class("text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl")],
      [element.text("404 - Siden var ikke på stasjonen")],
    ),
    html.p([class("mt-6 text-base leading-7 text-gray-600")], [
      element.text(
        "Siden du lette etter tok Sørtoget og kom dessverre ikke frem. Vi sjekket stasjonen, men vi kunne ikke finne den.",
      ),
    ]),
    html.div([class("mt-10 flex items-center justify-center gap-x-6")], [
      html.a(
        [
          href("/"),
          class(
            "rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600",
          ),
        ],
        [element.text("Gå tilbake til forsiden")],
      ),
    ]),
  ])
}
