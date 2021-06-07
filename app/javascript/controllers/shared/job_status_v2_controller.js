import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.submit = this.submit.bind(this)
    this.interval = this.longPoll()
    this.submit()
  }

  disconnect() {
    this.removeListeners()
    this.clearInterval()
  }

  get form() {
    return this.element
  }

  get url() {
    return this.form.action
  }

  get intervalLength() {
    return this.form.dataset.interval
  }

  get messagesContainer() {
    return this.form.querySelector(this.form.dataset.messageContainer)
  }

  get loadingContainer() {
    return this.form.querySelector(this.form.dataset.loadingContainer)
  }

  get body() {
    return {
      job_id: this.form.querySelector('input[name="job_id"]').value,
    }
  }

  async submit() {
    if (this.inFlight) {
      return null
    }

    this.inFlight = true
    this.loading(true)

    const headers = new Headers()
    const csrfHeaderValue = document.querySelector('meta[name="csrf-token"]').content

    headers.append('X-CSRF-Token', csrfHeaderValue)
    headers.append('Content-Type', 'application/json')

    const options = {
      headers,
      method: 'POST',
      cache: 'no-cache',
      credentials: 'same-origin',
      referrerPolicy: 'same-origin',
      body: JSON.stringify(this.body)
    }

    try {
      const response = await fetch(this.url, options)
      const body = await response.json()
      this.onSuccess(body)
    } catch (e) {
      this.onError(e)
    } finally {
      this.inFlight = false
    }
  }

  clearInterval() {
    clearInterval(this.interval)
  }

  longPoll() {
    return setInterval(this.submit, this.intervalLength)
  }

  loading(enabled) {
    if (!enabled) {
      this.loadingContainer.hidden = true
    } else {
      this.loadingContainer.hidden = false
    }
  }

  onSuccess(body) {
    // const originalStatus = this.status
    const status = body.status
    switch (status) {
    case 'queued': {
      // TODO: if status was working, indicate error (due to retries)
      this.message('Waiting in the queue...')
      this.loading(true)
      break
    }
    case 'working': {
      this.message('Building your report...')
      this.loading(true)
      break
    }
    case 'failed': {
      this.onError()
      break
    }
    case 'completed': {
      this.clearInterval()
      this.message('Complete! Reloading the page...')
      this.loading(false)
      this.reload(5000)
      break
    }
    }
    this.status = status
  }

  onError() {
    this.clearInterval()
    this.message('Something went wrong. We have been notified, please try again in a few minutes or contact support')
    this.loading(false)
  }

  message(msg) {
    this.messagesContainer.innerHTML = msg
  }

  reload(timeout) {
    setTimeout(() => {
      location.reload()
    }, timeout)
  }
}
