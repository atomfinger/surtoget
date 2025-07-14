import gleam/json
import lustre/attribute.{attribute, class, id}
import lustre/element.{type Element}
import lustre/element/html

pub type ChartData {
  ChartData(label: String, value: Int)
}

pub type OverallStats {
  OverallStats(on_time: Int, not_on_time: Int)
}

pub type FaultStats {
  FaultStats(fault: Int, other: Int)
}

fn get_overall_stats(period: String) -> OverallStats {
  case period {
    "last_month" -> OverallStats(on_time: 65, not_on_time: 35)
    "this_year" -> OverallStats(on_time: 70, not_on_time: 30)
    _ -> OverallStats(on_time: 0, not_on_time: 0)
  }
}

fn get_banenor_fault_stats(period: String) -> FaultStats {
  case period {
    "last_month" -> FaultStats(fault: 45, other: 55)
    "this_year" -> FaultStats(fault: 40, other: 60)
    _ -> FaultStats(fault: 0, other: 0)
  }
}

fn get_goahead_fault_stats(period: String) -> FaultStats {
  case period {
    "last_month" -> FaultStats(fault: 30, other: 70)
    "this_year" -> FaultStats(fault: 25, other: 75)
    _ -> FaultStats(fault: 0, other: 0)
  }
}

fn get_unforeseen_fault_stats(period: String) -> FaultStats {
  case period {
    "last_month" -> FaultStats(fault: 15, other: 85)
    "this_year" -> FaultStats(fault: 10, other: 90)
    _ -> FaultStats(fault: 0, other: 0)
  }
}

fn chart_data_encoder(data: ChartData) -> json.Json {
  json.object([
    #("label", json.string(data.label)),
    #("value", json.int(data.value)),
  ])
}

pub fn render() -> Element(a) {
  html.div([class("p-4 bg-gray-100 rounded-lg")], [
    html.h2([class("text-2xl font-bold text-gray-800 mb-8 text-center")], [
      html.text("Statistikk om Punktlighet"),
    ]),
    html.div([class("flex justify-center mb-8")], [
      tab_button("last_month", "Siste Måned", "active bg-gray-300"),
      tab_button("this_year", "Dette Året Så Langt", ""),
    ]),
    tab_content("last_month", "active block"),
    tab_content("this_year", "hidden"),
  ])
}

fn tab_button(tab_id: String, text: String, active_class: String) -> Element(a) {
  html.button(
    [
      id(tab_id <> "-tab"),
      class(
        "px-6 py-3 text-lg font-medium rounded-t-lg focus:outline-none "
        <> active_class
        <> " hover:bg-gray-200",
      ),
      attribute("data-tab", tab_id),
    ],
    [html.text(text)],
  )
}

fn tab_content(tab_id: String, active_class: String) -> Element(a) {
  let overall_stats = get_overall_stats(tab_id)
  let banenor_fault_stats = get_banenor_fault_stats(tab_id)
  let goahead_fault_stats = get_goahead_fault_stats(tab_id)
  let unforeseen_fault_stats = get_unforeseen_fault_stats(tab_id)

  let overall_chart_data = [
    ChartData("På Tid", overall_stats.on_time),
    ChartData("Ikke På Tid", overall_stats.not_on_time),
  ]
  let banenor_chart_data = [
    ChartData("BaneNor Feil", banenor_fault_stats.fault),
    ChartData("Andre Feil", banenor_fault_stats.other),
  ]
  let goahead_chart_data = [
    ChartData("GoAhead Feil", goahead_fault_stats.fault),
    ChartData("Andre Feil", goahead_fault_stats.other),
  ]
  let unforeseen_chart_data = [
    ChartData("Uforutsette Feil", unforeseen_fault_stats.fault),
    ChartData("Andre Feil", unforeseen_fault_stats.other),
  ]

  html.div(
    [
      id(tab_id <> "-content"),
      class("tab-content p-8 bg-white rounded-b-lg shadow-md " <> active_class),
    ],
    [
      // Overall chart at the top
      html.div([class("flex justify-center mb-8")], [
        chart_container(tab_id <> "-overall-chart", overall_chart_data, ""),
      ]),
      // Shared title for blame charts
      html.h3([class("text-xl font-semibold text-gray-800 mb-4 text-center")], [
        html.text("Skyldfordeling"),
      ]),
      // Three smaller charts in a row
      html.div([class("grid grid-cols-3 gap-8")], [
        chart_container(
          tab_id <> "-banenor-chart",
          banenor_chart_data,
          "banenor",
        ),
        chart_container(
          tab_id <> "-goahead-chart",
          goahead_chart_data,
          "goahead",
        ),
        chart_container(
          tab_id <> "-unforeseen-chart",
          unforeseen_chart_data,
          "unforeseen",
        ),
      ]),
    ],
  )
}

fn chart_container(
  id_str: String,
  data: List(ChartData),
  chart_type: String,
) -> Element(a) {
  let json_data = json.to_string(json.array(data, chart_data_encoder))
  let chart_attributes = [
    id(id_str),
    attribute("data-chartdata", json_data),
    attribute("data-charttype", chart_type),
  ]
  html.div([class("flex flex-col items-center")], [
    html.div(chart_attributes, []),
  ])
}
