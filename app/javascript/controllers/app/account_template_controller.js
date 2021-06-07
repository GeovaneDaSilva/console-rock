import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel:  'AccountTemplateChannel',
        id:       this.data.get('id'),
        template: this.data.get('template')
      },
      {
        received: (data) => {
          this.element.innerHTML = data
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}
