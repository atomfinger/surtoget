document.addEventListener("DOMContentLoaded", () => {
  const menuButton = document.getElementById("menu-button");
  const menu = document.getElementById("menu");

  if (menuButton && menu) {
    menuButton.addEventListener("click", () => {
      menu.classList.toggle("hidden");
    });
  }

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

    const width = chartWidth;
    const height = chartHeight;
    const radius = Math.min(width, height) / 2.5;

    const svg = chartWrapper
      .append("svg")
      .attr("width", width)
      .attr("height", height)
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

    const path = arcs
      .append("path")
      .attr("d", arc)
      .attr("fill", (d, i) => colors[i % colors.length]);

    const text = arcs
      .append("text")
      .attr("transform", (d) => `translate(${arc.centroid(d)})`)
      .attr("text-anchor", "middle")
      .attr("fill", "white")
      .style("font-size", "14px")
      .text((d) => `${d.data.value}%`);

    function handleMouseOver(event, d) {
      tooltip.style("opacity", 1);
      d3.select(this).style("stroke", "black").style("opacity", 0.8);
    }

    function handleMouseMove(event, d) {
      tooltip
        .html(`${d.data.label}: ${d.data.value}%`)
        .style("left", `${event.pageX + 10}px`)
        .style("top", `${event.pageY - 10}px`);
    }

    function handleMouseOut(event, d) {
      tooltip.style("opacity", 0);
      d3.select(this).style("stroke", "none").style("opacity", 1);
    }

    function handleClick(event, d) {
      // Always hide the tooltip before showing a new one
      tooltip.style("opacity", 0);

      // If the same element is clicked again, toggle the tooltip
      if (this === window.lastClickedElement) {
        window.lastClickedElement = null;
        return;
      }

      tooltip
        .style("opacity", 1)
        .html(`${d.data.label}: ${d.data.value}%`)
        .style("left", `${event.pageX + 10}px`)
        .style("top", `${event.pageY - 10}px`);

      window.lastClickedElement = this;
      event.stopPropagation();
    }

    path
      .on("mouseover", handleMouseOver)
      .on("mousemove", handleMouseMove)
      .on("mouseout", handleMouseOut)
      .on("click", handleClick);

    d3.select(window).on("resize", () => {
      tooltip.style("opacity", 0);
    });

    d3.select("body").on("click", () => {
      tooltip.style("opacity", 0);
    });

    text
      .on("mouseover", handleMouseOver)
      .on("mousemove", handleMouseMove)
      .on("mouseout", handleMouseOut)
      .on("click", handleClick);

    if (hasTitle) {
      svg
        .append("text")
        .attr("text-anchor", "middle")
        .attr("dy", "0.35em")
        .style("font-size", "14px")
        .text("Skyldfordeling");
    }

    const outerArc = d3
      .arc()
      .innerRadius(radius * 0.7)
      .outerRadius(radius * 0.7);

    const legendElements = arcs.append("g");

    legendElements.each(function (d) {
      const g = d3.select(this);
      if (!d.data.image_url) {
        g.append("text")
          .attr("transform", function (d) {
            const pos = outerArc.centroid(d);
            const midangle = d.startAngle + (d.endAngle - d.startAngle) / 2;
            pos[0] = radius * (midangle < Math.PI ? 1 : -1);
            return `translate(${pos})`;
          })
          .text(d.data.label)
          .each(function (d) {
            const text = d3.select(this);
            const words = d.data.label.split("\n");
            text.text("");
            for (let i = 0; i < words.length; i++) {
              const tspan = text.append("tspan").text(words[i]);
              if (i > 0) {
                tspan.attr("x", 0).attr("dy", "1.2em");
              }
            }
          })
          .style("text-anchor", function (d) {
            const midangle = d.startAngle + (d.endAngle - d.startAngle) / 2;
            return midangle < Math.PI ? "start" : "end";
          })
          .attr("fill", "black")
          .style("font-size", "14px");
      } else {
        g.append("image")
          .attr("xlink:href", d.data.image_url)
          .attr("transform", function (d) {
            const pos = outerArc.centroid(d);
            const midangle = d.startAngle + (d.endAngle - d.startAngle) / 2;
            pos[0] = radius * 1.1 * (midangle < Math.PI ? 1 : -1);
            pos[1] -= 40;
            return `translate(${pos})`;
          })
          .attr("width", 80)
          .attr("height", 80);
      }
    });

    function updateLegend() {
      const mobileLegendContainer = d3.select(`#${container.node().id}-legend`);
      if (window.innerWidth < 528) {
        legendElements.style("display", "none");
        mobileLegendContainer.style("display", "flex");
      } else {
        legendElements.style("display", "block");
        mobileLegendContainer.style("display", "none");
      }
    }

    function createMobileLegend(data, colors) {
      const legendContainer = d3.select(`#${container.node().id}-legend`);
      legendContainer.html(""); // Clear existing legend

      const outerDiv = legendContainer.append("div");
      const innerDiv = outerDiv.append("div");

      data.forEach((d, i) => {
        const legendItem = innerDiv
          .append("div")
          .style("display", "flex")
          .style("align-items", "center")
          .style("margin-bottom", "0.5rem");

        legendItem
          .append("div")
          .style("width", "12px")
          .style("height", "12px")
          .style("background-color", colors[i % colors.length]);

        legendItem
          .append("span")
          .style("margin-left", "0.5rem")
          .style("font-size", "14px")
          .text(d.label);
      });
    }

    function handleLegendLayout() {
      const legendContainer = d3.select(`#${container.node().id}-legend`);
      if (!legendContainer.node()) return;

      const outerDiv = legendContainer.select("div");
      const innerDiv = outerDiv.select("div");

      if (window.innerWidth < 405) {
        outerDiv.style("display", "flex");
        outerDiv.style("justify-content", "center");
        innerDiv.style("display", "flex");
        innerDiv.style("flex-direction", "column");
        innerDiv.style("align-items", "flex-start");
      } else {
        outerDiv.style("display", "block");
        innerDiv.style("display", "flex");
        innerDiv.style("flex-direction", "row");
        innerDiv.style("flex-wrap", "wrap");
        innerDiv.style("justify-content", "center");
        innerDiv.style("align-items", "center");
        innerDiv.selectAll("div").style("margin-right", "1rem");
      }
    }

    createMobileLegend(data, colors);
    updateLegend();
    window.addEventListener("resize", () => {
      updateLegend();
      handleLegendLayout();
    });
    handleLegendLayout();
  }

  function createLineChart(elementId, data) {
    const container = d3.select(`#${elementId}`);
    container.html(""); // Clear previous chart

    const width = parseInt(container.style("width"));
    const height = 300;
    const margin = { top: 20, right: 20, bottom: 40, left: 40 };
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
      .attr("stroke", "#F59E0B")
      .attr("stroke-width", 3)
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
      .attr("fill", "#F59E0B");

    svg
      .selectAll(".text")
      .data(data)
      .enter()
      .append("text")
      .attr("x", (d) => x(d.label) + x.bandwidth() / 2)
      .attr("y", (d) => y(d.value) - 10)
      .attr("text-anchor", "middle")
      .text((d) => `${d.value}%`);
  }

  function renderChartsForTab(tabId) {
    const blameDataElement = document.getElementById(`${tabId}-blame-chart`);
    if (blameDataElement) {
      const blameData = JSON.parse(blameDataElement.dataset.chartdata);
      const container = d3.select(`#${tabId}-blame-chart`);
      const width = parseInt(container.style("width"));
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
      createLineChart("punctuality_over_time-chart", lineChartData);
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

  window.addEventListener("resize", () => {
    const activeTab = document.querySelector(".tab-content:not(.hidden)");
    if (activeTab) {
      const tabId = activeTab.id.replace("-content", "");
      renderChartsForTab(tabId);
    }
  });

  // Re-render the chart on window resize
  window.addEventListener("resize", () => {
    const activeTab = document.querySelector(".tab-content:not(.hidden)");
    if (activeTab) {
      const tabId = activeTab.id.replace("-content", "");
      if (tabId === "punctuality_over_time") {
        renderChartsForTab(tabId);
      }
    }
  });

  const tabsToggle = document.getElementById("tabs-toggle");
  const tabsMenu = document.getElementById("tabs-menu");

  if (tabsToggle) {
    tabsToggle.addEventListener("click", (event) => {
      event.stopPropagation();
      tabsMenu.classList.toggle("hidden");
    });
  }

  document.addEventListener("click", (event) => {
    if (
      tabsMenu &&
      !tabsMenu.classList.contains("hidden") &&
      !tabsMenu.contains(event.target) &&
      !tabsToggle.contains(event.target)
    ) {
      tabsMenu.classList.add("hidden");
    }
  });
});
