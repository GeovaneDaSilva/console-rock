import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.title = this.element.dataset.title
    this.seriesName = this.element.dataset.seriesName

    this.graphData = JSON.parse(this.data.get('data'))
    this.drawGraph()
  }

  /**
   * This component expects the incoming data to be an array of arrays, with
   * each inner array having a length of two, the first being the name of the
   * segment and the second being the value of the segment.
   *
   * For example:
   * [
   *   ['Omg wow', 100],
   *   ['Blah', 60],
   *   ['Neato', 10]
   * ]
   * would result in there being two funnel segments, with the upper part of the
   * funnel having the name 'Omg wow' and a value (and corresponding size) of 100,
   * and the lower part of the funnel having the name 'Neato' and a value (and
   * corresponding size) of 10. Segments in the middle will be layered in the funnel
   * as expected (e.g., 'Blah' will be present with a value of 60).
   *
   * You may layer in as many segments as you would like.
   */
  drawGraph() {
    const options = {
      chart: {
        type: 'funnel3d',
        options3d: {
          enabled: true,
          alpha: 10,
          depth: 50,
          viewDistance: 50
        }
      },
      title: {
        text: this.title || 'Funnel chart'
      },
      plotOptions: {
        series: {
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b> ({point.y:,.0f})',
            allowOverlap: true,
            y: 10
          },
          neckWidth: '20%',
          neckHeight: '30%',
          width: '80%',
          height: '80%'
        },
        funnel3d: {
          colors: [
            '#60C3E1', // light blue
            '#527297', // blue
            '#8DC63F', // green
          ]
        }
      },
      credits: {
        enabled: false,
      },
      series: [
        {
          name: this.seriesName,
          data: this.graphData,
        },
      ]
    }

    Highcharts.chart(this.element, options)
  }
}
