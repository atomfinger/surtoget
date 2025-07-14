document.addEventListener('DOMContentLoaded', () => {
  function createDonutChart(elementId, data, colors, chartWidth = 250, chartHeight = 250, centerContent = null) {
    const width = chartWidth;
    const height = chartHeight;
    const radius = Math.min(width, height) / 2;

    // Clear any existing SVG to prevent multiplication
    d3.select(`#${elementId}`).select("svg").remove();

    const svg = d3.select(`#${elementId}`)
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", `translate(${width / 2}, ${height / 2})`);

    const pie = d3.pie()
      .value(d => d.value)
      .sort(null);

    const arc = d3.arc()
      .innerRadius(radius * 0.6)
      .outerRadius(radius);

    // Tooltip setup
    const tooltip = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)
      .style("position", "absolute")
      .style("background-color", "white")
      .style("border", "solid")
      .style("border-width", "1px")
      .style("border-radius", "5px")
      .style("padding", "10px")
      .style("pointer-events", "none"); // Important for mouse events to pass through

    svg.selectAll("path")
      .data(pie(data))
      .enter()
      .append("path")
      .attr("d", arc)
      .attr("fill", (d, i) => colors[i % colors.length])
      .on("mouseover", function(event, d) {
        tooltip.style("opacity", 1);
        d3.select(this).style("stroke", "black").style("opacity", 0.8);
      })
      .on("mousemove", function(event, d) {
        tooltip
          .html(`${d.data.label}: ${d.data.value}%`)
          .style("left", (event.pageX + 10) + "px")
          .style("top", (event.pageY - 10) + "px");
      })
      .on("mouseout", function(event, d) {
        tooltip.style("opacity", 0);
        d3.select(this).style("stroke", "none").style("opacity", 1);
      });

    // Render center content (logo or text)
    if (centerContent) {
      if (centerContent.type === 'image') {
        svg.append("image")
          .attr("xlink:href", centerContent.value)
          .attr("x", -radius * 0.4) // Adjust position to center image
          .attr("y", -radius * 0.4)
          .attr("width", radius * 0.8)
          .attr("height", radius * 0.8);
      } else if (centerContent.type === 'text') {
        svg.append("text")
          .attr("text-anchor", "middle")
          .attr("dominant-baseline", "middle")
          .attr("fill", "#333")
          .style("font-size", "18px")
          .style("font-weight", "bold")
          .text(centerContent.value);
      }
    } else {
      // Default percentage text if no centerContent is provided
      svg.selectAll("text")
        .data(pie(data))
        .enter()
        .append("text")
        .attr("transform", d => `translate(${arc.centroid(d)})`)
        .attr("text-anchor", "middle")
        .attr("fill", "white")
        .style("font-size", "14px")
        .text(d => `${d.data.value}%`);
    }
  }

  function renderChartsForTab(tabId) {
    const overallDataElement = document.getElementById(`${tabId}-overall-chart`);
    if (overallDataElement) {
      const overallData = JSON.parse(overallDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-overall-chart`, overallData, ['#4CAF50', '#F44336']);
    }

    const banenorDataElement = document.getElementById(`${tabId}-banenor-chart`);
    if (banenorDataElement) {
      const banenorData = JSON.parse(banenorDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-banenor-chart`, banenorData, ['#2196F3', '#FFC107'], 150, 150, { type: 'image', value: '/static/banenor_logo.png' });
    }

    const goaheadDataElement = document.getElementById(`${tabId}-goahead-chart`);
    if (goaheadDataElement) {
      const goaheadData = JSON.parse(goaheadDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-goahead-chart`, goaheadData, ['#9C27B0', '#FF9800'], 150, 150, { type: 'image', value: '/static/goahead_logo.png' });
    }

    const unforeseenDataElement = document.getElementById(`${tabId}-unforeseen-chart`);
    if (unforeseenDataElement) {
      const unforeseenData = JSON.parse(unforeseenDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-unforeseen-chart`, unforeseenData, ['#607D8B', '#B0BEC5'], 150, 150, { type: 'text', value: 'Annet' });
    }
  }

  const tabButtons = document.querySelectorAll('[data-tab]');
  const tabContents = document.querySelectorAll('.tab-content');

  tabButtons.forEach(button => {
    button.addEventListener('click', () => {
      const tabId = button.dataset.tab;

      tabButtons.forEach(btn => btn.classList.remove('active', 'bg-gray-300'));
      tabContents.forEach(content => content.classList.remove('active', 'block'));
      tabContents.forEach(content => content.classList.add('hidden'));

      button.classList.add('active', 'bg-gray-300');
      document.getElementById(`${tabId}-content`).classList.remove('hidden');
      document.getElementById(`${tabId}-content`).classList.add('active', 'block');

      renderChartsForTab(tabId);
    });
  });

  // Initial render for the active tab
  const initialActiveTab = document.querySelector('.tab-content.active');
  if (initialActiveTab) {
    renderChartsForTab(initialActiveTab.id.replace('-content', ''));
  } else {
    // If no active tab is set initially, activate the first one
    if (tabButtons.length > 0) {
      tabButtons[0].click();
    }
  }
});