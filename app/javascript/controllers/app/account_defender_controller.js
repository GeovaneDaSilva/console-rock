import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['devices', 'detections']

  connect() {
    const accountId = this.data.get('account-id')

    this.subscription = Cable.subscriptions.create(
      {
        channel: 'AccountDefenderChannel',
        account_id: accountId
      },
      {
        received: (data) => { this.updateGraphs(JSON.parse(data)) },
        refresh: function() { this.perform('refresh') }
      }
    )

    this.refreshInterval = setInterval(() => {
      if (!this.awaitingRefresh) {
        this.awaitingRefresh = true
        this.subscription.refresh()
      }
    }, 5000)
  }

  disconnect() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  updateGraphs(data) {
    this.awaitingRefresh = false

    this.drawDeviceGraph(data.devices)
    this.drawDetectionsGraph(data.detections)
  }

  drawDeviceGraph(deviceData) {
    const total = deviceData.reduce((total, healthType) => {
      return total + healthType.value
    }, 0)

    if (total > 0) {
      const graphData = deviceData.map((healthType) => {
        return {
          name: healthType.name, value: healthType.value, count: total,
          y: (healthType.value/Math.min(total, 1) * 100.0)
        }
      })

      if (this.deviceChart == undefined) {
        this.createDeviceGraph(graphData)
      } else {
        this.updateDeviceGraph(graphData)
      }
    } else {
      this.devicesTarget.classList.add('empty')
    }
  }

  createDeviceGraph(graphData) {
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
      title: false,
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
          name: 'Defender Health',
          colorByPoint: true,
          innerSize: '50%',
          data: graphData
        }
      ]
    }

    this.deviceChart = Highcharts.chart(this.devicesTarget, options)
  }

  updateDeviceGraph(graphData) {
    this.deviceChart.series[0].setData(
      graphData, true, true, true
    )
  }

  drawDetectionsGraph(detectionsData) {
    const total = detectionsData.reduce((total, detection) => {
      return total + detection.value
    }, 0)

    if (total > 0) {
      const graphData = detectionsData.map((detection) => {
        return {
          name: detection.name, y: (detection.value/Math.min(total, 1) * 100.0),
          value: detection.value
        }
      })

      if (this.detectionsChart == undefined) {
        this.createDetectionsGraph(graphData)
      } else {
        this.updateDetectionsGraph(graphData)
      }
    } else {
      this.detectionsTarget.classList.add('empty')
    }
  }

  createDetectionsGraph(graphData) {
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
      title: false,
      tooltip: {
        headerFormat: '{series.name}<br>',
        pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
      },
      legend: {
        floating: true,
        labelFormat: '{name} ({value})'
      },
      plotOptions: {
        pie: {
          dataLabels: {
            enabled: false,
          },
          showInLegend: true,
          startAngle: -90,
          endAngle: 90,
          center: ['50%', '75%'],
          size: '110%'
        }
      },
      colors: ['#b92c28', '#e38d13', '#28a4c9'],
      series: [
        {
          name: 'Detection Summary',
          colorByPoint: true,
          innerSize: '50%',
          data: graphData
        }
      ]
    }

    this.detectionsChart = Highcharts.chart(this.detectionsTarget, options)
  }

  updateDetectionsGraph(graphData) {
    this.detectionsChart.series[0].setData(
      graphData, true, true, true
    )
  }
}
