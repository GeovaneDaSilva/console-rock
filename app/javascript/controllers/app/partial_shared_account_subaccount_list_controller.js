/* eslint-env browser */
/* globals $ */
import { Controller } from 'stimulus'

// Item Class
// ------------------------------------------------------
class CustomerIntegrationValue {
  constructor(appId, accountId, isShowAll, integrationContainer) {
    this.appId = appId
    this.accountId = accountId
    this.isShowAll = isShowAll
    this.integrationContainer = integrationContainer
    this.listeners = []
    this.setupListeners()
  }

  // listeners
  setupListeners() {
    this.listeners.push(this.setupValueListener())
    this.listeners.push(this.setupCheckboxListener())
    this.listeners.push(this.setupRemoveButtonListener())
  }

  removeListeners() {
    this.listeners.forEach((removeListenerFn) => removeListenerFn.call(this))
  }

  setupValueListener() {
    const handler = this.onValueChange.bind(this)
    this.valueContainer.addEventListener('keyup', handler)
    this.valueContainer.addEventListener('change', handler)
    return () => {
      this.valueContainer.removeEventListener('keyup', handler)
      this.valueContainer.removeEventListener('change', handler)
    }
  }

  setupCheckboxListener() {
    const handler = this.onCheckboxChange.bind(this)
    this.customerCheckbox.addEventListener('change', handler)
    return () => {
      this.customerCheckbox.removeEventListener('change', handler)
    }
  }

  setupRemoveButtonListener() {
    const handler = this.onRemoveButtonClicked.bind(this)
    this.removeCustomerIntegrationButton.addEventListener('click', handler)
    return () => {
      this.removeCustomerIntegrationButton.removeEventListener('click', handler)
    }
  }

  // events
  onShow() {
    this.integrationContainer.hidden = false
  }

  onHideIfNotSelected() {
    if (!this.isChecked) {
      this.integrationContainer.hidden = true
    }
  }

  onRemoveButtonClicked(event) {
    event.preventDefault()

    this.valueContainer.value = ''
    this.valueContainer.dispatchEvent(new Event('change'))

    this.customerCheckbox.checked = false
    this.customerCheckbox.dispatchEvent(new Event('change'))
  }

  onCheckboxChange(event) {
    const target = event.target

    if (target.checked) {
      this.integrationContainer.hidden = false
    } else if (!this.isShowAll) {
      this.integrationContainer.hidden = true
    }
  }

  onValueChange(event) {
    const target = event.target
    this.value = target.value
    if (this.value && !this.customerCheckbox.checked) {
      this.customerCheckbox.checked = true
    }
  }

  onShowAllChange(isShowAll) {
    this.isShowAll = isShowAll
  }

  // elements
  get customerCheckbox() {
    return document.querySelector(
      `${this.appRoot} .sub-account-list__add-customer__checkbox[data-account-id="${this.accountId}"]`
    )
  }

  get valueContainer() {
    return document.querySelector(
      `${this.itemRoot} .sub-account-list__customer-integration__value-input[data-account-id="${this.accountId}"]`
    )
  }

  get removeCustomerIntegrationButton() {
    return document.querySelector(
      `${this.appRoot} .sub-account-list__remove-integration-button[data-account-id="${this.accountId}"]`
    )
  }

  // selectors
  get appRoot() {
    return `[data-app-id='${this.appId}']`
  }

  get itemRoot() {
    return `${this.appRoot} .sub-account-list__row[data-account-id="${this.accountId}"]`
  }

  // state
  get isChecked() {
    return this.customerCheckbox.checked
  }
}

// Container Class
// --------------------------------------------------------------------
export default class extends Controller {
  static targets = [
    'showAll',
    'selectCustomersContainer',
    'customerIntegrationContainer',
  ];

  initialize() {
    const appId = this.element.dataset.appId
    this.appId = appId
    this.customerIntegrationValues = this.fetchCustomerIntegrationValues()
  }

  disconnect() {
    this.customerIntegrationValues.forEach((customerIntegrationValue) => {
      customerIntegrationValue.removeListeners()
    })
  }

  // operations
  fetchCustomerIntegrationValues() {
    return this.customerIntegrationDOMContainers.map(this.generateValueObjects.bind(this))
  }

  generateValueObjects(customerIntegrationContainer) {
    return new CustomerIntegrationValue(this.appId, customerIntegrationContainer.dataset.accountId,  this.isShowAll, customerIntegrationContainer)
  }

  // handlers
  onToggleShowAll() {
    this.customerIntegrationValues.forEach((customerIntegrationValue) => {
      customerIntegrationValue.onShowAllChange(this.isShowAll)
      if (this.isShowAll) {
        customerIntegrationValue.onShow()
        this.selectCustomersContainer.hidden = true
      } else {
        customerIntegrationValue.onHideIfNotSelected()
        this.selectCustomersContainer.hidden = false
      }
    })
  }

  get isShowAll() {
    return this.showAllTarget.checked
  }

  get customerIntegrationDOMContainers() {
    return this.customerIntegrationContainerTargets
  }

  get selectCustomersContainer() {
    return this.selectCustomersContainerTarget
  }
}
