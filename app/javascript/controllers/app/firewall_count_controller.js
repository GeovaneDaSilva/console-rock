import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  connect() {
    // alert(this.data.get('id'));
    this.subscription = Cable.subscriptions.create(
      {
        channel:   'FirewallCountChannel',
        id:        this.data.get('id')
      },
      {
        received: (data) => {
          // debugger
          this.awaitingRefresh = false
          const message = JSON.parse(data);

          document.getElementById('received').innerHTML = message['received'] || 0
          document.getElementById('parsed').innerHTML = message['parsed'] || 0
          document.getElementById('filtered').innerHTML = message['filtered'] || 0
          document.getElementById('reported').innerHTML = message['reported'] || 0
        },
        refresh: function() { this.perform('refresh') }
      })

    this.refreshInterval = setInterval(() => {
      if (!this.awaitingRefresh) {
        this.awaitingRefresh = true
        this.subscription.refresh()
      }
    }, 10000000)
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
