import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = [
    'loaders', 'hiddens', 'totalDevices', 'reportedDevices',
    'positiveDevices'
  ]

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'HuntStatusChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          this.awaitingRefresh = false
          const message = JSON.parse(data)

          this.removeLoaders()
          this.showHiddens()
          this.updateTotalDevices(message)
          this.updateReportedDevices(message)
          this.updatePositiveDevices(message)
        },
        refresh: function() { this.perform('refresh') }
      })

    this.refreshInterval = setInterval(() => {
      if (!this.awaitingRefresh) {
        this.awaitingRefresh = true
        this.subscription.refresh()
      }
    }, 10000)
  }

  disconnect() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  removeLoaders() {
    this.loadersTargets.forEach((el) => el.parentElement.removeChild(el))
  }

  showHiddens() {
    this.hiddensTargets.forEach((el) => el.removeAttribute('hidden'))
  }

  updateTotalDevices(message) {
    this.totalDevicesTargets.forEach((el) => el.innerText = message.total_device_count)
  }

  updateReportedDevices(message) {
    this.reportedDevicesTargets.forEach((el) => {
      el.innerText = message.reported_device_count
      setTimeout(() => {
        if (message.total_device_count > 0) {
          el.setAttribute('data-percentage', Math.round(message.reported_device_count / message.total_device_count * 100))
        } else {
          el.setAttribute('data-percentage', 0)
        }
      }, 500)
    })
  }

  updatePositiveDevices(message) {
    this.positiveDevicesTargets.forEach((el) => {
      el.setAttribute('data-hunt-positive-devices', message.positive_reported_device_count)
      el.innerText = message.positive_reported_device_count

      setTimeout(() => {
        if (message.total_device_count > 0) {
          el.setAttribute('data-percentage', Math.round(message.positive_reported_device_count / message.total_device_count * 100))
        } else {
          el.setAttribute('data-percentage', 0)
        }
      }, 500)
    })
  }
}
