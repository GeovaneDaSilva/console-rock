import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['content']

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'RecentDeviceListChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          this.awaitingRefresh = false
          this.contentTarget.innerHTML = data
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
