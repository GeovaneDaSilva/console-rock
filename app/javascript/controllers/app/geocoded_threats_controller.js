import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'GeocodedThreatChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          this.awaitingRefresh = false

          const detail = JSON.parse(data)
          const event = new CustomEvent(
            'geocoded-threat:add', { bubbles: true, detail: detail }
          )
          this.element.dispatchEvent(event)
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
}
