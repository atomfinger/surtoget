import gleam/float
import gleam/json
import lustre/attribute.{attribute, class, href, id}
import lustre/element.{type Element}
import lustre/element/html

pub type ChartData {
  ChartData(label: String, value: Float, image_url: String)
}

pub type OverallStats {
  OverallStats(on_time: Float, not_on_time: Float)
}

pub type BlameStats {
  BlameStats(
    banenor: Float,
    goahead: Float,
    unforeseen: Float,
    consequential_delays: Float,
  )
}

fn get_overall_stats(period: String) -> OverallStats {
  case period {
    "last_month" -> OverallStats(on_time: 74.4, not_on_time: 25.6)
    "this_year" -> OverallStats(on_time: 70.0, not_on_time: 30.0)
    _ -> OverallStats(on_time: 0.0, not_on_time: 0.0)
  }
}

fn get_blame_stats(period: String) -> BlameStats {
  case period {
    "last_month" ->
      BlameStats(
        banenor: 22.0,
        goahead: 38.0,
        unforeseen: 8.0,
        consequential_delays: 32.0,
      )
    "this_year" ->
      BlameStats(
        banenor: 40.0,
        goahead: 25.0,
        unforeseen: 35.0,
        consequential_delays: 0.0,
      )
    _ ->
      BlameStats(
        banenor: 0.0,
        goahead: 0.0,
        unforeseen: 0.0,
        consequential_delays: 0.0,
      )
  }
}

fn chart_data_encoder(data: ChartData) -> json.Json {
  json.object([
    #("label", json.string(data.label)),
    #("value", json.float(data.value)),
    #("image_url", json.string(data.image_url)),
  ])
}

pub fn render() -> Element(a) {
  html.div([class("rounded-lg")], [
    html.div([class("border-b border-gray-200")], [
      html.nav([attribute("-mx-1", ""), class("flex space-x-1")], [
        tab_button("last_month", "Siste måned", True),
        tab_button("this_year", "Dette året så langt", False),
      ]),
    ]),
    tab_content("last_month", True),
    tab_content("this_year", False),
  ])
}

fn tab_button(tab_id: String, text: String, is_active: Bool) -> Element(a) {
  let active_classes =
    "inline-block py-2 px-4 text-yellow-600 border-b-2 border-yellow-600 font-bold"
  let inactive_classes =
    "inline-block py-2 px-4 text-gray-500 hover:text-yellow-600 hover:border-yellow-600"

  html.a(
    [
      href("#"),
      attribute("data-tab", tab_id),
      class(
        "transition-colors duration-300 "
        <> case is_active {
          True -> active_classes
          False -> inactive_classes
        },
      ),
    ],
    [html.text(text)],
  )
}

fn tab_content(tab_id: String, is_active: Bool) -> Element(a) {
  let overall_stats = get_overall_stats(tab_id)
  let blame_stats = get_blame_stats(tab_id)

  let blame_chart_data = [
    ChartData("BaneNor Ansvar", blame_stats.banenor, "/static/banenor_logo.png"),
    ChartData("GoAhead Ansvar", blame_stats.goahead, "/static/goahead_logo.png"),
    ChartData("Uforutsette Årsaker", blame_stats.unforeseen, ""),
    ChartData("Følgeforsinkelser", blame_stats.consequential_delays, ""),
  ]
  let active_classes = "tab-content p-4 bg-white shadow-lg rounded-lg"
  let inactive_classes = "tab-content p-4 bg-white shadow-lg rounded-lg hidden"

  html.div(
    [
      id(tab_id <> "-content"),
      class(case is_active {
        True -> active_classes
        False -> inactive_classes
      }),
    ],
    [
      html.div(
        [
          class(
            "grid grid-cols-1 md:grid-cols-2 gap-8 items-center justify-items-center",
          ),
        ],
        [
          html.div(
            [class("flex flex-col items-center justify-center text-center p-8")],
            [
              html.div(
                [
                  class(
                    "text-8xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-orange-400",
                  ),
                ],
                [html.text(float.to_string(overall_stats.not_on_time) <> "%")],
              ),
              html.p([class("text-lg text-gray-700 mt-4 font-medium")], [
                html.text("sjanse for å være forsinket"),
              ]),
            ],
          ),
          html.div([class("flex flex-col items-center w-full")], [
            chart_container(
              tab_id <> "-blame-chart",
              blame_chart_data,
              "blame",
              "w-full h-full",
            ),
          ]),
        ],
      ),
    ],
  )
}

fn chart_container(
  id_str: String,
  data: List(ChartData),
  chart_type: String,
  size_class: String,
) -> Element(a) {
  let json_data = json.to_string(json.array(data, chart_data_encoder))
  let chart_attributes = [
    id(id_str),
    attribute("data-chartdata", json_data),
    attribute("data-charttype", chart_type),
    class(size_class),
  ]
  html.div(chart_attributes, [])
}
