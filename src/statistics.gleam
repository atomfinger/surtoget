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
  html.div([class("p-4 bg-gray-100 rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-8 text-center")], [
      html.text("Statistikk om punktlighet"),
    ]),
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
    "bg-white inline-block py-2 px-4 text-blue-600 border-l border-t border-r rounded-t"
  let inactive_classes =
    "bg-gray-100 inline-block py-2 px-4 text-gray-500 hover:text-gray-600 hover:bg-gray-200 border-l border-t border-r rounded-t"

  html.a(
    [
      href("#"),
      attribute("data-tab", tab_id),
      class(case is_active {
        True -> active_classes
        False -> inactive_classes
      }),
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
  let active_classes = "tab-content p-4 bg-white border"
  let inactive_classes = "tab-content p-4 bg-white border hidden"

  html.div(
    [
      id(tab_id <> "-content"),
      class(case is_active {
        True -> active_classes
        False -> inactive_classes
      }),
    ],
    [
      html.div([class("grid grid-cols-2 gap-4 justify-items-center")], [
        html.div(
          [
            class(
              "flex flex-col items-center justify-center text-center w-[500px] h-[300px]",
            ),
          ],
          [
            html.div([class("text-9xl font-extrabold text-red-700")], [
              html.text(float.to_string(overall_stats.not_on_time) <> "%"),
            ]),
            html.p([class("text-xl text-gray-600 mt-4")], [
              html.text("sjanse for å være forsinket eller forstyrret"),
            ]),
          ],
        ),
        html.div([class("flex flex-col items-center")], [
          chart_container(
            tab_id <> "-blame-chart",
            blame_chart_data,
            "blame",
            "w-[500px]",
          ),
        ]),
      ]),
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
