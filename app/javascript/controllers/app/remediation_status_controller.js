import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['detail', 'status']

  connect() {
    // alert(this.data.get('id'));
    this.subscription = Cable.subscriptions.create(
      {
        channel:   'RemediationStatusChannel',
        id:        this.data.get('id')
      },
      {
        received: (data) => {
          this.awaitingRefresh = false
          const message = JSON.parse(data);

          if (message['status_detail'] != null){
            this.detailTarget.innerHTML = new Date(message['status_detail']);            
          }

          switch(message['status']) {
            case "complete":
              this.statusTarget.innerHTML ='<span class="text-success"><i class="fa fa-check-circle"></i>Complete</span>'
              break;
            case "failed":
              this.statusTarget.innerHTML ='<span class="text-danger"><i class="fa fa-exclamation-triangle"></i>Complete</span>'
              break;
            case "in_progress":
              this.statusTarget.innerHTML ='<div class="inline-loader loading"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div> In Progress'
              break;
            case "draft":
              this.statusTarget.innerHTML ='<span class="text-blue">Draft</span>'
          }
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
