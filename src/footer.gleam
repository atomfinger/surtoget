import lustre/attribute.{class, href}
import lustre/element.{type Element}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.footer(
    [
      class(
        "py-8 mt-10 border-t border-gray-200 text-center text-gray-500 text-sm",
      ),
    ],
    [
      html.p([], [
        html.text("Laget med frustrasjon og "),
        html.a(
          [
            href("https://gleam.run"),
            class("hover:text-yellow-600 transition-colors duration-200"),
          ],
          [html.text("Gleam")],
        ),
        html.text(" av "),
        html.a(
          [
            href("https://lindbakk.com"),
            class("hover:text-yellow-600 transition-colors duration-200"),
          ],
          [html.text("John Mikael Lindbakk")],
        ),
      ]),
    ],
  )
}
