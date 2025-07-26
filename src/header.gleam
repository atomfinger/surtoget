import lustre/attribute.{attribute, class, href, src}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg

pub fn render() -> Element(msg) {
  html.header([class("py-4 bg-white shadow-md")], [
    html.div([class("container mx-auto px-4")], [
      html.div([class("flex justify-between items-center")], [
        html.div([class("md:hidden flex-shrink-0")], [
          html.a([href("/")], [
            html.img([
              src("/static/surtoget_logo_train_only.png"),
              attribute("alt", "Surtoget Logo"),
              class("h-16 w-auto"),
            ]),
          ]),
        ]),
        html.div([class("flex-grow text-center md:hidden")], [
          html.a([href("/"), class("text-2xl font-bold text-[#E3A804]")], [
            html.text("Surtoget"),
          ]),
        ]),
        html.div([class("hidden md:block flex-grow text-center")], [
          html.a([href("/")], [
            html.img([
              src("/static/surtoget_logo.png"),
              attribute("alt", "Surtoget Logo"),
              class("h-24 w-auto mx-auto"),
            ]),
          ]),
        ]),
        html.div([class("md:hidden flex-shrink-0")], [
          html.button(
            [
              attribute("id", "menu-button"),
              attribute("type", "button"),
              attribute("aria-label", "Toggle navigation menu"),
              class(
                "text-gray-500 hover:text-yellow-600 focus:outline-none focus:text-yellow-600",
              ),
            ],
            [
              svg.svg(
                [
                  class("h-8 w-8"),
                  attribute("fill", "none"),
                  attribute("viewBox", "0 0 24 24"),
                  attribute("stroke", "currentColor"),
                ],
                [
                  svg.path([
                    attribute("stroke-linecap", "round"),
                    attribute("stroke-linejoin", "round"),
                    attribute("stroke-width", "2"),
                    attribute("d", "M4 6h16M4 12h16M4 18h16"),
                  ]),
                ],
              ),
            ],
          ),
        ]),
      ]),
      html.nav(
        [
          attribute("id", "menu"),
          class(
            "hidden md:flex md:justify-center mt-2 transition-all duration-500 ease-in-out overflow-hidden",
          ),
        ],
        [
          html.ul(
            [
              class(
                "flex flex-col text-center md:flex-row md:space-x-6 text-2xl md:text-base font-medium",
              ),
            ],
            [
              li_nav_item("/", "Hjem"),
              li_nav_item("/news", "Nyheter"),
              li_nav_item("/om-surtoget", "Om Surtoget"),
              li_nav_item("/faq", "Ofte stilte spørsmål"),
            ],
          ),
        ],
      ),
    ]),
  ])
}

fn li_nav_item(href_val: String, text_val: String) -> Element(msg) {
  html.li([], [
    html.a(
      [
        href(href_val),
        class(
          "text-gray-500 hover:text-yellow-600 transition-colors duration-200",
        ),
      ],
      [html.text(text_val)],
    ),
  ])
}
