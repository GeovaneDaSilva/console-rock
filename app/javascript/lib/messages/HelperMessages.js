import { ClientMessaging } from './ClientMessaging'

export class HelperMessages extends ClientMessaging {
  constructor(container) {
    super(container, container.querySelector('#messages'))
    this.loader = container.querySelector('#loader')
    this.classes = {
      info: 'bg-info',
      error: 'bg-danger',
      success: 'bg-success',
      warn: 'bg-warning',
    }
  }

  loading() {
    this.loader.hidden = false
    this.message('Processing...')
    this.setContainerClassName('warn')
  }

  loadingComplete() {
    this.loader.hidden = true
  }

  success(msg = 'Success!') {
    this.loadingComplete()
    this.message(msg)
    this.setContainerClassName('success')
  }

  info(msg) {
    this.loadingComplete()
    this.message(msg)
    this.setContainerClassName('info')
  }

  warn(msg) {
    this.loadingComplete()
    this.message(msg)
    this.setContainerClassName('warn')
  }

  error(error) {
    this.loadingComplete()
    this.message(error.clientMessage)
    this.setContainerClassName('error')
  }
}
