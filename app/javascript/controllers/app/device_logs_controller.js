import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'

export default class extends Controller {
  static targets = ['content']

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'DeviceLogsChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          this.awaitingRefresh = false
          const newLogs = document.createRange().createContextualFragment(data)
          if (this.element.children.length == 0) {
            // No existing logs, insert them all
            this.element.insertBefore(newLogs, null)
          } else {
            [].forEach.call(newLogs.children, (newLog) => {
              this._insertLog(newLog, this.element)
            })
          }

          this._trimLog()
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

  _insertLog(newLog, parent) {
    const newLogOrder = parseFloat(newLog.getAttribute('data-order'))
    const newLogId    = newLog.getAttribute('data-log-id')

    if (this.element.querySelectorAll(`li.message[data-log-id="${newLogId}"]`).length > 0) return

    for (let i = 0; i < parent.children.length; i++) {
      const childEl = parent.children[i]
      const childElOrder = parseFloat(childEl.getAttribute('data-order'))

      if (newLogOrder > childElOrder) {
        parent.insertBefore(newLog, childEl)
        break
      } else if (childEl.nextSiblingElement == null) {
        // Last li in the parent, append it
        parent.insertBefore(newLog, null)
      }
    }
    if (newLog.textContent.includes('logfile upload successful')){
      location.reload()
    }
  }

  _trimLog() {
    const logs = this.element.querySelectorAll('li.message');

    [].slice.call(logs, 500, logs.length).forEach((log) => {
      log.parentElement.removeChild(log)
    })
  }
}
