import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.drawChart().then((chart) => {
      this.chart = chart
      this.chartReady()
    })
  }

  disconnect() {
    clearInterval(this.refreshRawDataInterval)
  }

  chartReady() {
    if (this.data.get('seed-data') != null) {
      const seedData = JSON.parse(this.data.get('seed-data'))
      this.updateXAxis(seedData)
      this.updateGraphValues(seedData)
    }

    if (this.data.get('refresh-url') != null) {
      this.refreshRawData().then((rawData) => {
        if (this.data.get('seed-data') === null) {
          this.updateXAxis(rawData)
          this.updateGraphValues(rawData)
        }

        this.refreshRawDataInterval = setInterval(() => {
          if (this.fetchingData == false) {
            this.refreshRawData().then((newRawData) => this.updateGraphValues(newRawData))
          }
        }, 10000)
      })
    }
  }

  refreshRawData() {
    this.fetchingData = true

    return new Promise((resolve, reject) => {
      const statsXhr = new XMLHttpRequest()

      statsXhr.addEventListener('load', () => {
        if (statsXhr.status == 200) {
          resolve(JSON.parse(statsXhr.response))
        } else {
          reject()
        }
      })

      statsXhr.open('GET', this.data.get('refresh-url'), true)
      statsXhr.send()
    })
  }

  updateXAxis(rawData) {
    this.chart.axes[0].categories = Object.keys(rawData['historical_counts'])
  }

  updateGraphValues(rawData) {
    this.fetchingData = false
    this.updateHistoricalCounts(rawData)
  }

  updateHistoricalCounts(rawData) {
    const series = this.chart.series
    const suspicious = []
    const malicious   = []
    const informational      = []
    const customers  = []

    Object.keys(rawData['historical_counts']).forEach((month) => {
      malicious.push(rawData['historical_counts'][month]['malicious'])
      suspicious.push(rawData['historical_counts'][month]['suspicious'])
      informational.push(rawData['historical_counts'][month]['informational'])
      customers.push(rawData['historical_counts'][month]['descendants'])
    })

    series[0].setData(malicious, true, true, true)
    series[1].setData(suspicious, true, true, true)
    series[2].setData(informational, true, true, true)

    if (this.showCustomers()) {
      series[3].setData(customers, true, true, true)
    }
  }

  drawChart() {
    return new Promise((resolve, _reject) => {
      const options = {
        credits: {
          enabled: false
        },
        title: {
          text: 'Total detections by verdict, per month'
        },
        yAxis: {
          allowDecimals: false
        },
        series: [
          {
            type: 'column',
            name: 'Malicious',
            color: '#D12149',
            data: []
          },          {
            type: 'column',
            name: 'Suspicious',
            color: '#F47920',
            data: []
          },
          {
            type: 'column',
            name: 'Informational',
            color: '#3AA9C8',
            data: []
          }
        ]
      }

      if (this.showCustomers()) {
        options.series.push({
          type: 'spline',
          name: 'Customers',
          data: [],
          marker: {
            lineWidth: 2,
            lineColor: Highcharts.getOptions().colors[3],
            fillColor: 'black'
          }
        })
      }

      Highcharts.chart(this.element, options, resolve)
    })
  }

  showCustomers() {
    return this.data.get('show-customers') === 'true'
  }
}
