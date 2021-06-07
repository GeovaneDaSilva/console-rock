/**
 * Responsible for holding click listeners for the customer rows on the Advanced
 * PSA Mapper UI. Also holds methods to make the UI reacts on certain events.
 *
 * Make sure to call destroy on this class when turbolinks advances or the UI
 * disconnects.
 */
export class CustomerRow {
  constructor(node, selectCallback) {
    this.node = node
    this.isSelected = false

    this.selectCallback = selectCallback
    this.onClick = this.onClick.bind(this)

    this.setupListeners()
  }

  destroy() {
    this.removeListeners()
  }

  setupListeners() {
    this.node.addEventListener('click', this.onClick)
  }

  removeListeners() {
    this.node.removeEventListener('click', this.onClick)
  }

  successfullyMapped() {
    this.node.classList.add('bg-success')
    setTimeout(() => {
      this.node.classList.remove('bg-success')
    }, 5000)
  }

  get name() {
    return this.customerNameContainer.innerText.trim()
  }

  get id() {
    return this.node.dataset.customerId
  }

  get companyId() {
    return this.node.dataset.companyId
  }

  get hasCompany() {
    return !!this.companyId
  }

  get companyNameContainer() {
    return this.node.querySelector('td.company-name')
  }

  get customerNameContainer() {
    return this.node.querySelector('td.customer-name')
  }

  select() {
    this.isSelected = true
    this.update()
  }

  unSelect() {
    this.isSelected = false
    this.update()
  }

  changeCompany(name) {
    this.companyNameContainer.innerText = name
  }

  toggleSelectedStyles() {
    if (this.isSelected) {
      this.node.classList.add('bg-primary')
    } else {
      this.node.classList.remove('bg-primary')
    }
  }

  update() {
    this.toggleSelectedStyles()
    this.selectCallback(this)
  }

  onClick() {
    this.isSelected = !this.isSelected
    this.update()
  }
}
