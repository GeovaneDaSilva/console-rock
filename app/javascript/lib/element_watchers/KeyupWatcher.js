export class KeyupWatcher {
  constructor(node, keyCode, onEventCallback, metadata = {}) {
    this.node = node
    this.keyCode = keyCode
    this.onEvent = this.onEvent.bind(this)
    this.metadata = metadata

    this.onEventCallback = onEventCallback

    this.setupListener()
  }

  destroy() {
    this.removeEventListener()
  }

  setupListener() {
    this.node.addEventListener('keyup', this.onEvent)
  }

  removeEventListener() {
    this.node.removeEventListener('keyup', this.onEvent)
  }

  onEvent(event) {
    if (event.keyCode === this.keyCode) {
      this.onEventCallback(this, { event })
    }
  }
}
