document.addEventListener('DOMContentLoaded', () => {
  function createDonutChart(elementId, data, colors, chartWidth, chartHeight) {
    const width = chartWidth;
    const height = chartHeight;
    const radius = Math.min(width, height) / 2 * 0.6; // Make donut smaller to leave more space

    // Clear any existing SVG to prevent multiplication
    d3.select(`#${elementId}`).select("svg").remove();

    const svg = d3.select(`#${elementId}`)
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", `0 0 ${width} ${height}`)
      .append("g")
      .attr("transform", `translate(${width / 2}, ${height / 2})`);

    const pie = d3.pie()
      .value(d => d.value)
      .sort(null);

    const arc = d3.arc()
      .innerRadius(radius * 0.6)
      .outerRadius(radius);

    const outerArc = d3.arc()
      .innerRadius(radius * 1.1) // Brought even closer to the chart
      .outerRadius(radius * 1.1); // Brought even closer to the chart

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

    const arcs = svg.selectAll("arc")
      .data(pie(data))
      .enter()
      .append("g")
      .attr("class", "arc");

    arcs.append("path")
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

    // Always display percentage text on segments
    arcs.append("text")
      .attr("transform", d => `translate(${arc.centroid(d)})`)
      .attr("text-anchor", "middle")
      .attr("fill", "white")
      .style("font-size", "14px")
      .text(d => `${d.data.value}%`);

    // Add external labels (logos or text) for blame chart
    const chartType = d3.select(`#${elementId}`).attr("data-charttype");
    if (chartType === 'blame') {
      arcs.each(function(d) {
        const midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        const pos = outerArc.centroid(d);
        let angle = (midAngle * 180 / Math.PI); // Convert radians to degrees

        // Rotate GoAhead logo by an additional 180 degrees
        if (d.data.image_url === '/static/goahead_logo.png' || d.data.label === "Uforutsette Årsaker") {
          angle += 180;
        }

        const imageSize = 80;
        const textFontSize = "20px";

        if (d.data.image_url && d.data.image_url !== '') {
          d3.select(this).append("image")
            .attr("xlink:href", d.data.image_url)
            .attr("width", imageSize)
            .attr("height", imageSize)
            .attr("x", pos[0] - imageSize / 2) // Center the image
            .attr("y", pos[1] - imageSize / 2)
            .attr("transform", `rotate(${angle}, ${pos[0]}, ${pos[1]})`); // Rotate image
        } else {
          d3.select(this).append("text")
            .attr("transform", `translate(${pos}) rotate(${angle})`)
            .attr("text-anchor", "middle")
            .attr("fill", "#333")
            .style("font-size", textFontSize)
            .text(d.data.label);
        }
      });
    }
  }

  function renderChartsForTab(tabId) {
    const overallDataElement = document.getElementById(`${tabId}-overall-chart`);
    if (overallDataElement) {
      const overallData = JSON.parse(overallDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-overall-chart`, overallData, ['#4CAF50', '#F44336'], 500, 500);
    }

    const blameDataElement = document.getElementById(`${tabId}-blame-chart`);
    if (blameDataElement) {
      const blameData = JSON.parse(blameDataElement.dataset.chartdata);
      createDonutChart(`${tabId}-blame-chart`, blameData, ['#2196F3', '#9C27B0', '#607D8B', '#FF5722'], 500, 500);
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