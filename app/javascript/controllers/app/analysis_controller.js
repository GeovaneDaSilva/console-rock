import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['content']

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'AnalysisChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          this.contentTarget.innerHTML = data
        }
      })
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
