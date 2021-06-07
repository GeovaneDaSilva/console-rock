import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['detections', 'detectionsLabel', 'iconWrapper'];

  connect() {
    const appId = this.data.get('app-id')
    const deviceId = this.data.get('device-id')

    if (appId && deviceId) {
      this.subscription = Cable.subscriptions.create(
        {
          channel: 'DeviceAppsChannel',
          app_id: appId,
          device_id: deviceId
        },
        {
          received: (data) => this.updateCards(JSON.parse(data)),
          refresh: function() { this.perform('refresh') }
        }
      )

      this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 1000)
    } else {
      this.updateCards(
        {
          detection_count: 0,
          enabled: false
        }
      )
    }
  }

  disconnect() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  updateCards(parsedEvent) {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }
    this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 1000 * 60 * 3)

    this.detectionsTarget.innerText = parseFloat(parsedEvent.detection_count).toLocaleString()
    this.detectionsLabelTarget.innerText = parsedEvent.detection_count === 1 ? 'Detection' : 'Detections'

    this.iconWrapperTarget.classList.remove('no-detections', 'detections')
    this.element.classList.remove('disabled')

    if (parsedEvent.enabled) {
      if (parsedEvent.detection_count > 0) {
        this.iconWrapperTarget.classList.add('detections')
      } else {
        this.iconWrapperTarget.classList.add('no-detections')
      }
    } else {
      this.element.classList.add('disabled')
    }
  }
}
