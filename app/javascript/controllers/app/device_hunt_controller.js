import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['content']

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel:   'DeviceHuntChannel',
        id:        this.data.get('id'),
        revision:  this.data.get('revision'),
        device_id: this.data.get('device'),
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
