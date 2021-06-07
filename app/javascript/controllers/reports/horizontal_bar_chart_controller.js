import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.title = this.element.dataset.title
    this.seriesName = this.element.dataset.seriesName

    const rawData = JSON.parse(this.data.get('data'))
    this.graphData = this.processData(rawData)

    this.drawGraph()
  }

  processData(data) {
    const keys = Object.keys(data)
    return keys.map((key) => {
      let value = data[key]

      if (!Array.isArray(value)) {
        value = [value]
      }

      return { name: key, data: value }
    })
  }

  drawGraph() {
    const options = {
      chart: {
        type: 'bar',
      },
      colors: [
        '#8dc63f',
        '#343b3a',
        '#a8b0b2',
        '#39597e',
        '#3aa9c8',
        '#d12149',
        '#f47920',
        '#ffdd00',
        '#b2d235',
        '#1c6933',
      ],
      title: {
        text: this.title || 'Horizontal bar chart',
      },
      xAxis: {
        visible: false,
        categories: [this.seriesName]
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Total Detections',
          align: 'high',
        },
        labels: {
          overflow: 'justify',
        },
        allowDecimals: false,
      },
      plotOptions: {
        bar: {
          dataLabels: {
            enabled: true,
          },
        },
      },
      tooltip: {
        enabled: true,
      },
      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle',
        x: false,
        y: 80,
        floating: true,
        borderWidth: 1,
        backgroundColor:
          (Highcharts.theme && Highcharts.theme.legendBackgroundColor) ||
          '#FFFFFF',
        shadow: true,
      },
      credits: {
        enabled: false,
      },
      series: this.graphData
    }

    Highcharts.chart(this.element, options)
  }
}
