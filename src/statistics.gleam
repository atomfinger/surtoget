import gleam/float
import gleam/int
import gleam/json
import gleam/list
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

type MonthlyStats {
  MonthlyStats(
    month: String,
    on_time: Float,
    banenor: Float,
    goahead: Float,
    unforeseen: Float,
    consequential_delays: Float,
  )
}

fn get_monthly_stats() -> List(MonthlyStats) {
  [
    MonthlyStats(
      month: "January",
      on_time: 57.3,
      banenor: 38.0,
      goahead: 20.0,
      unforeseen: 18.0,
      consequential_delays: 24.0,
    ),
    MonthlyStats(
      month: "February",
      on_time: 65.6,
      banenor: 28.0,
      goahead: 42.0,
      unforeseen: 5.0,
      consequential_delays: 25.0,
    ),
    MonthlyStats(
      month: "May",
      on_time: 74.4,
      banenor: 22.0,
      goahead: 38.0,
      unforeseen: 9.0,
      consequential_delays: 32.0,
    ),
  ]
}

fn format_float(f: Float) -> Float {
  let rounded = float.round(f *. 10.0)
  let result = int.to_float(rounded) /. 10.0
  result
}

fn get_yearly_average_stats() -> BlameStats {
  let monthly_stats = get_monthly_stats()
  let count = int.to_float(list.length(monthly_stats))
  let total_banenor =
    list.fold(monthly_stats, 0.0, fn(acc, stat) { acc +. stat.banenor })
  let total_goahead =
    list.fold(monthly_stats, 0.0, fn(acc, stat) { acc +. stat.goahead })
  let total_unforeseen =
    list.fold(monthly_stats, 0.0, fn(acc, stat) { acc +. stat.unforeseen })
  let total_consequential_delays =
    list.fold(monthly_stats, 0.0, fn(acc, stat) {
      acc +. stat.consequential_delays
    })

  BlameStats(
    banenor: format_float(total_banenor /. count),
    goahead: format_float(total_goahead /. count),
    unforeseen: format_float(total_unforeseen /. count),
    consequential_delays: format_float(total_consequential_delays /. count),
  )
}

fn get_yearly_average_on_time() -> Float {
  let monthly_stats = get_monthly_stats()
  let count = int.to_float(list.length(monthly_stats))
  let total_on_time =
    list.fold(monthly_stats, 0.0, fn(acc, stat) { acc +. stat.on_time })
  format_float(total_on_time /. count)
}

fn get_overall_stats(period: String) -> OverallStats {
  case period {
    "last_month" -> OverallStats(on_time: 74.4, not_on_time: 25.6)
    "this_year" -> {
      let on_time = get_yearly_average_on_time()
      OverallStats(on_time: on_time, not_on_time: 100.0 -. on_time)
    }
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
    "this_year" -> get_yearly_average_stats()
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
  html.div([], [
    html.div([class("flex items-center justify-between")], [
      html.div([class("flex items-center")], [
        html.h2(
          [
            class(
              "text-base font-semibold text-yellow-500 uppercase tracking-wide mr-4",
            ),
          ],
          [html.text("Statistikk")],
        ),
        html.nav([attribute("-mx-1", ""), class("flex space-x-1")], [
          tab_button("last_month", "Siste rapport (Mai)", True),
          tab_button("this_year", "Dette året så langt", False),
          tab_button("punctuality_over_time", "Punktlighet over tid", False),
        ]),
      ]),
    ]),
    tab_content("last_month", True),
    tab_content("this_year", False),
    punctuality_over_time_content(False),
  ])
}

fn tab_button(tab_id: String, text: String, is_first: Bool) -> Element(a) {
  let initial_classes =
    "inline-block py-2 px-4 text-gray-500 hover:text-yellow-600 hover:border-yellow-600"
  let active_classes =
    "inline-block py-2 px-4 text-yellow-600 border-b-2 border-yellow-600 font-bold"

  html.a(
    [
      href("#"),
      attribute("data-tab", tab_id),
      class(
        "transition-colors duration-300 "
        <> case is_first {
          True -> active_classes
          False -> initial_classes
        },
      ),
    ],
    [html.text(text)],
  )
}

fn tab_content(tab_id: String, is_first: Bool) -> Element(a) {
  let overall_stats = get_overall_stats(tab_id)
  let blame_stats = get_blame_stats(tab_id)

  let blame_chart_data = [
    ChartData(
      "BaneNor sin skyld",
      blame_stats.banenor,
      "/static/banenor_logo.png",
    ),
    ChartData(
      "GoAhead sin skyld",
      blame_stats.goahead,
      "/static/goahead_logo.png",
    ),
    ChartData("Uforutsette\nårsaker", blame_stats.unforeseen, ""),
    ChartData("Følgeforsinkelser", blame_stats.consequential_delays, ""),
  ]
  let content_classes = "tab-content p-4 bg-white shadow-lg rounded-lg"
  let hidden_classes = " hidden"

  html.div(
    [
      id(tab_id <> "-content"),
      class(case is_first {
        True -> content_classes
        False -> content_classes <> hidden_classes
      }),
    ],
    [
      html.div(
        [
          class(
            "grid grid-cols-1 lg:grid-cols-2 lg:gap-4 items-center justify-items-center",
          ),
        ],
        [
          html.div(
            [
              class(
                "flex flex-col items-center justify-center text-center p-4 lg:p-8",
              ),
            ],
            [
              html.div(
                [
                  class(
                    "text-8xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-orange-400",
                  ),
                ],
                [
                  html.text(
                    float.to_string(format_float(overall_stats.not_on_time))
                    <> "%",
                  ),
                ],
              ),
              html.p([class("text-lg text-gray-700 mt-4 font-medium")], [
                html.text("sjanse for forsinkelse"),
              ]),
            ],
          ),
          chart_container(
            tab_id <> "-blame-chart",
            blame_chart_data,
            "blame",
            "w-full h-full flex flex-col items-center justify-center",
          ),
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

fn get_punctuality_over_time_data() -> List(ChartData) {
  let historical_data = [
    ChartData(label: "2021", value: 73.1, image_url: ""),
    ChartData(label: "2022", value: 73.9, image_url: ""),
    ChartData(label: "2023", value: 65.0, image_url: ""),
    ChartData(label: "2024", value: 60.6, image_url: ""),
  ]
  let total_punctuality = get_yearly_average_on_time()
  let current_year_data =
    ChartData(label: "2025", value: total_punctuality, image_url: "")

  list.append(historical_data, [current_year_data])
}

fn punctuality_over_time_content(is_first: Bool) -> Element(a) {
  let chart_data = get_punctuality_over_time_data()
  let content_classes = "tab-content p-4 bg-white shadow-lg rounded-lg"
  let hidden_classes = " hidden"

  html.div(
    [
      id("punctuality_over_time-content"),
      class(case is_first {
        True -> content_classes
        False -> content_classes <> hidden_classes
      }),
    ],
    [
      html.div([class("flex justify-center w-full")], [
        chart_container(
          "punctuality_over_time-chart",
          chart_data,
          "line",
          "w-full h-full",
        ),
      ]),
    ],
  )
}
