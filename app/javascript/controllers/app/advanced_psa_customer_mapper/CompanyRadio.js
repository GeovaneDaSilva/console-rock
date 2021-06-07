/**
 * Responsible for holding on-click listeners for the company radios (PSA companies)
 * on the Advanced PSA Mapper UI. Also holds methods to make the UI reacts on
 * certain events.
 *
 * Make sure to destroy the listener once the UI is being disconnected (e.g.,
 * turbolinks advances)
 */
export class CompanyRadio {
  constructor(node, onSelectCallback) {
    this.node = node
    this.onSelectCallback = onSelectCallback
    this.onSelect = this.onSelect.bind(this)
    this.setupListeners()
  }

  setupListeners() {
    this.node.addEventListener('click', this.onSelect)
  }

  destroy() {
    this.node.removeEventListener('click', this.onSelect)
  }

  get id() {
    return this.node.value
  }

  get name() {
    return this.node.parentNode.textContent.trim()
  }

  get parent() {
    return this.node.parentNode
  }

  successfullyMapped() {
    this.parent.classList.add('bg-success')
    setTimeout(() => {
      this.parent.classList.remove('bg-success')
    }, 5000)
  }

  onSelect(event) {
    this.onSelectCallback(this, event)
  }

  unSelect() {
    this.node.checked = false
  }
}
