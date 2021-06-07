import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['customers']

  connect() {
    const accountId = this.data.get('account-id')
    const data = JSON.parse(this.data.get('seed-data'))

    this.drawLineGraph(data)
  }

  drawLineGraph(rawData) {
    const graphData = rawData.result.map((item) => {
      return {
        name: item.customer, value: item.score, date: item.date
      }
    })

    var i, j, done, len, len2
    const graphData2 = []
    const dates2 = []
    for (i = 0; i < graphData.length; i++){
      done = false
      for (j = 0; j < graphData2.length; j++){
        if (graphData[i].name == graphData2[j].name){
          graphData2[j].data.push(graphData[i].value)
          done = true
          break
        }
      }
      if (!done){
        graphData2.push({ name: graphData[i].name, data: [graphData[i].value]})
      }
      if (!(dates2.includes(graphData[i].date))){
        dates2.push(graphData[i].date)
      }
    }

    len = -1
    for (i = 0; i < graphData2.length; i++){
      if (graphData2[i].data.length > len){
        len = graphData2[i].data.length
      }
    }

    if (len > 0){
      for (i = 0; i < graphData2.length; i++){
        if (graphData2[i].data.length < len){
          len2 = len - graphData2[i].data.length
          for (j = 0; j < len2; j++){
            graphData2[i].data.unshift(0)
          }
        }
      }
    }

    this.createLineGraph(graphData2, dates2)
  }

  createLineGraph(graphData, dates) {
    const options = {
      title: {
          text: 'Secure Score Progress'
      },
      xAxis: {
        categories: dates
      },
      yAxis: {
        title: {
          text: 'Secure Score (% of max)'
        }
      },
      legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'middle'
      },
      plotOptions: {
        series: {
          label: {
            connectorAllowed: false
          }
        }
      },
      series: graphData,
      credits: {
        enabled: false
      }
    }

    Highcharts.chart(this.customersTarget, options)
  }
}
