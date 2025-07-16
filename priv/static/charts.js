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
    const radius = (Math.min(width, height) / 2) * 0.8;

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
        .style("font-size", "16px")
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
      button.classList.add("text-yellow-600", "border-yellow-600", "font-bold");
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
  setTimeout(() => {
    const initialActiveTab = document.querySelector("[data-tab]");
    if (initialActiveTab) {
      initialActiveTab.click();
    }
  }, 100);
});
