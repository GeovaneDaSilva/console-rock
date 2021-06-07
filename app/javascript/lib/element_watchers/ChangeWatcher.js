export class ChangeWatcher {
  constructor(node, onChangeCallback, metadata = {}) {
    this.node = node
    this.metadata = metadata
    this.onChange = this.onChange.bind(this)
    this.onChangeCallback = onChangeCallback

    this.setupListener()
  }

  destroy() {
    this.removeEventListener()
  }

  setupListener() {
    this.node.addEventListener('change', this.onChange)
  }

  removeEventListener() {
    this.node.removeEventListener('change', this.onChange)
  }

  onChange(event) {
    let val = event.currentTarget.value
    if (this.metadata.coerceValueTo === 'number') {
      val = Number(val)
    }
    this.onChangeCallback(val, this, { event })
  }

  get currentValue() {
    let value = this.node.value
    if (this.metadata.coerceValueTo === 'number') {
      value = Number(value)
    }
    return value
  }
}
