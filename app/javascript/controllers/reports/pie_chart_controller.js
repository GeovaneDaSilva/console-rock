import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.title = this.element.dataset.title
    this.seriesName = this.element.dataset.seriesName

    const rawData = JSON.parse(this.data.get('data'))
    this.graphData = this.parseData(rawData)

    this.drawGraph()
  }

  /**
   * This component expects the incoming data to be an object, with keys being the
   * x values, and the values being the y value.
   *
   * For example:
   * {
   *   'Cyberterrorist App': 6,
   *   'Webroot App': 5,
   * }
   * would result in two categories, with a total of 11 points, with each
   * category taking 6/11 and 5/11 of the area of the chart respectively.
   */
  parseData(rawData) {
    let total = 0
    const keys = Object.keys(rawData)

    keys.forEach(key => total += rawData[key])

    return keys.map((key) => {
      const value = rawData[key]
      return {
        name: key,
        value: value,
        count: total,
        y: (value / Math.min(total, 1) * 100.0)
      }
    })
  }

  drawGraph() {
    const options = {
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie'
      },
      credits: {
        enabled: false
      },
      title: {
        text: this.title || 'Pie chart'
      },
      tooltip: {
        headerFormat: '{series.name}<br>',
        pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b>: {point.value}',
            style: {
              color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
            }
          }
        }
      },
      colors: ['#8dc63f', '#d12149', '#343b3a'],
      series: [
        {
          name: this.seriesName,
          colorByPoint: true,
          innerSize: '10%',
          data: this.graphData
        }
      ]
    }

    Highcharts.chart(this.element, options)
  }
}
