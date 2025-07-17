document.addEventListener("DOMContentLoaded", () => {
  function createDonutChart(
    elementId,
    data,
    colors,
    chartWidth,
    chartHeight,
    hasTitle,
  ) {
    const container = d3.select(`#${elementId}`);
    // Clear any existing content to prevent multiplication
    container.html("");

    const chartWrapper = container.append("div");

    const legendWrapper = container
      .append("div")
      .style("display", "flex")
      .style("flex-direction", "column")
      .style("justify-content", "center")
      .style("margin-left", "-60px");

    const width = chartWidth * 0.7;
    const height = chartHeight * 0.7;
    const radius = (Math.min(width, height) / 2) * 0.9;

    const svg = chartWrapper
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", `0 0 ${width} ${height}`)
      .append("g")
      .attr("transform", `translate(${width / 2}, ${height / 2})`);

    const pie = d3
      .pie()
      .value((d) => d.value)
      .sort(null);

    const arc = d3
      .arc()
      .innerRadius(radius * 0.6)
      .outerRadius(radius);

    const tooltip = d3
      .select("body")
      .append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)
      .style("position", "absolute")
      .style("background-color", "white")
      .style("border", "solid")
      .style("border-width", "1px")
      .style("border-radius", "5px")
      .style("padding", "10px")
      .style("pointer-events", "none");

    const arcs = svg
      .selectAll("arc")
      .data(pie(data))
      .enter()
      .append("g")
      .attr("class", "arc");

    arcs
      .append("path")
      .attr("d", arc)
      .attr("fill", (d, i) => colors[i % colors.length])
      .on("mouseover", function (event, d) {
        tooltip.style("opacity", 1);
        d3.select(this).style("stroke", "black").style("opacity", 0.8);
      })
      .on("mousemove", function (event, d) {
        tooltip
          .html(`${d.data.label}: ${d.data.value}%`)
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 10 + "px");
      })
      .on("mouseout", function (event, d) {
        tooltip.style("opacity", 0);
        d3.select(this).style("stroke", "none").style("opacity", 1);
      });

    arcs
      .append("text")
      .attr("transform", (d) => `translate(${arc.centroid(d)})`)
      .attr("text-anchor", "middle")
      .attr("fill", "white")
      .style("font-size", "14px")
      .text((d) => `${d.data.value}%`);

    if (hasTitle) {
      svg
        .append("text")
        .attr("text-anchor", "middle")
        .attr("dy", "0.35em")
        .style("font-size", "14px")
        .text("Skyldfordeling");
    }

    // Legend
    const legend = legendWrapper
      .selectAll(".legend-item")
      .data(data)
      .enter()
      .append("div")
      .attr("class", "legend-item")
      .style("display", "flex")
      .style("align-items", "center")
      .style("margin-bottom", "10px");

    legend
      .append("div")
      .style("width", "20px")
      .style("height", "20px")
      .style("background-color", (d, i) => colors[i % colors.length])
      .style("border-radius", "50%")
      .style("margin-right", "10px");

    const textAndImage = legend
      .append("div")
      .style("display", "flex")
      .style("align-items", "center");

    textAndImage
      .append("span")
      .style("font-size", "14px")
      .style("color", "#333")
      .text((d) => (d.image_url ? "" : d.label));

    textAndImage
      .filter((d) => d.image_url) // Only add image if image_url is not empty
      .append("img")
      .attr("src", (d) => d.image_url)
      .attr("alt", (d) => d.label)
      .style("width", "80px")
      .style("height", "auto")
      .style("margin-left", "10px");
  }

  function createLineChart(elementId, data, width, height) {
    const container = d3.select(`#${elementId}`);
    container.html("");

    const margin = { top: 20, right: 20, bottom: 30, left: 40 };
    const chartWidth = width - margin.left - margin.right;
    const chartHeight = height - margin.top - margin.bottom;

    const svg = container
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    const x = d3
      .scaleBand()
      .range([0, chartWidth])
      .padding(0.1)
      .domain(data.map((d) => d.label));

    const y = d3.scaleLinear().range([chartHeight, 0]).domain([0, 100]);

    svg
      .append("g")
      .attr("transform", `translate(0,${chartHeight})`)
      .call(d3.axisBottom(x));

    svg.append("g").call(d3.axisLeft(y));

    // Add Y axis label
    svg
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - margin.left)
      .attr("x", 0 - chartHeight / 2)
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .text("Punktlighet (%)");

    // Add X axis label
    svg
      .append("text")
      .attr(
        "transform",
        `translate(${chartWidth / 2},${chartHeight + margin.top + 10})`,
      )
      .style("text-anchor", "middle")
      .text("År");

    const line = d3
      .line()
      .x((d) => x(d.label) + x.bandwidth() / 2)
      .y((d) => y(d.value));

    svg
      .append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "#2196F3")
      .attr("stroke-width", 2)
      .attr("d", line);

    svg
      .selectAll(".dot")
      .data(data)
      .enter()
      .append("circle")
      .attr("class", "dot")
      .attr("cx", (d) => x(d.label) + x.bandwidth() / 2)
      .attr("cy", (d) => y(d.value))
      .attr("r", 5)
      .attr("fill", "#2196F3");
  }

  function renderChartsForTab(tabId) {
    const blameDataElement = document.getElementById(`${tabId}-blame-chart`);
    if (blameDataElement) {
      const blameData = JSON.parse(blameDataElement.dataset.chartdata);
      const width = 500;
      const height = 300;
      createDonutChart(
        `${tabId}-blame-chart`,
        blameData,
        ["#2196F3", "#9C27B0", "#607D8B", "#FF5722"],
        width,
        height,
        true,
      );
    }

    const lineChartElement = document.getElementById(
      "punctuality_over_time-chart",
    );
    if (lineChartElement && tabId === "punctuality_over_time") {
      const lineChartData = JSON.parse(lineChartElement.dataset.chartdata);
      const width = 500;
      const height = 300;
      createLineChart(
        "punctuality_over_time-chart",
        lineChartData,
        width,
        height,
      );
    }
  }

  const tabButtons = document.querySelectorAll("[data-tab]");
  const tabContents = document.querySelectorAll(".tab-content");

  tabButtons.forEach((button) => {
    button.addEventListener("click", (e) => {
      e.preventDefault();
      const tabId = button.dataset.tab;

      // Deactivate all tabs
      tabButtons.forEach((btn) => {
        const tabId = btn.dataset.tab;
        const tabContent = document.getElementById(`${tabId}-content`);
        btn.classList.remove(
          "text-yellow-600",
          "border-yellow-600",
          "font-bold",
          "border-b-2",
        );
        btn.classList.add(
          "text-gray-500",
          "hover:text-yellow-600",
          "hover:border-yellow-600",
        );
        if (tabContent) {
          tabContent.classList.add("hidden");
        }
      });

      // Activate the clicked tab
      button.classList.add(
        "text-yellow-600",
        "border-yellow-600",
        "font-bold",
        "border-b-2",
      );
      button.classList.remove(
        "text-gray-500",
        "hover:text-yellow-600",
        "hover:border-yellow-600",
      );

      const activeContent = document.getElementById(`${tabId}-content`);
      if (activeContent) {
        activeContent.classList.remove("hidden");
        renderChartsForTab(tabId);
      }
    });
  });

  // Initial render for the active tab
  const initialActiveTab = document.querySelector(".tab-content:not(.hidden)");
  if (initialActiveTab) {
    const tabId = initialActiveTab.id.replace("-content", "");
    renderChartsForTab(tabId);
  }
});
