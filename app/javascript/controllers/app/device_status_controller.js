import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'
import inflection from 'inflection'

export default class extends Controller {
  static targets = [
    'indicator', 'text', 'lastContact', 'hashProgress',
    'maliciousIndicators', 'suspiciousIndicators', 'informationalIndicators'
  ]

  connect() {
    this.subscription = Cable.subscriptions.create(
      {
        channel: 'DeviceStatusChannel',
        id:      this.data.get('id')
      },
      {
        received: (data) => {
          if (this.refreshTimer) {
            clearTimeout(this.refreshTimer)
          }
          this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 10000)

          const message = JSON.parse(data)

          this.constructor.targets.forEach((targetName) => {
            if (this[`has${inflection.camelize(targetName)}Target`]) {
              this.removeLoadingChildren(this[`${targetName}Target`])
              this[targetName](message)
            }
          })
        },
        refresh: function() { this.perform('refresh') }
      }
    )

    this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 1000)
  }

  disconnect() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  removeLoadingChildren(target) {
    [].forEach.call(target.querySelectorAll('.loading'), (loadingEl) => {
      loadingEl.parentElement.removeChild(loadingEl)
    })
  }

  indicator(message) {
    const text              = message.status_text.toUpperCase()
    const existingIndicator = this.indicatorTarget.querySelector('.indicator')

    if (existingIndicator != null) {
      existingIndicator.setAttribute('class', `indicator ${message.status}`)
      existingIndicator.setAttribute('title', text)
    } else {
      const newIndicator = document.createRange().createContextualFragment(
        `<i title="${text}" class="indicator ${message.status}"/>`
      )

      this.indicatorTarget.insertBefore(newIndicator, null)
    }
  }

  text(message) {
    const text         = message.status.toUpperCase()
    const existingText = this.textTarget.querySelector('.status-text')

    if (existingText != null) {
      existingText.remove()
    }

    this.textTarget.insertAdjacentHTML('beforeend', `<span class="status-text ${message.status}"> ${text}</span>`)
  }

  lastContact(message) {
    const text         = message['updated_at'].toUpperCase()
    const existingText = this.lastContactTarget.querySelector('.status-last-contact')

    if (existingText != null) {
      existingText.innerText = text
    } else {
      const newText = document.createRange().createContextualFragment(
        `<span class="status-last-contact ${message.status}">${text}</span>`
      )
      this.lastContactTarget.insertBefore(newText, null)
    }
  }

  hashProgress(message) {
    let text
    const progress = message['hash_progress']

    if (progress < 100) {
      text = `${progress}%`
    } else {
      text = '100%, listening for changes...'
    }

    this.hashProgressTarget.querySelector('.hash-progress').innerHTML = text
    this.hashProgressTarget.querySelector('.hash-width').style.width  = `${Math.min(progress, 100)}%`
  }

  suspiciousIndicators(message) {
    this.suspiciousIndicatorsTarget.innerHTML = message['suspicious_indicators']
  }

  maliciousIndicators(message) {
    this.maliciousIndicatorsTarget.innerHTML = message['malicious_indicators']
  }

  informationalIndicators(message) {
    this.informationalIndicatorsTarget.innerHTML = message['informational_indicators']
  }
}
