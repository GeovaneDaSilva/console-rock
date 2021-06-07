/* globals $ */
import { merge, template } from 'lodash'
import { Controller } from 'stimulus'

import { railsFormParamsToObject } from '../../lib/railsFormParamsToObject'
import { railsRequest } from '../../lib/railsRequest'
import { CompanyRadio } from './advanced_psa_customer_mapper/CompanyRadio'
import { CustomerRow } from './advanced_psa_customer_mapper/CustomerRow'
import { ClientMessaging } from '../../lib/messages/ClientMessaging'
import { HelperMessages } from '../../lib/messages/HelperMessages'
import { ChangeWatcher } from '../../lib/element_watchers/ChangeWatcher'
import { KeyupWatcher } from '../../lib/element_watchers/KeyupWatcher'

const COMPANIES_TEMPLATE_ID = 'psaCompanyTemplate'
const CUSTOMERS_TEMPLATE_ID = 'customerTemplate'

const SEARCH_TYPE = 'search'
const CREATE_TYPE = 'create'
const DELETE_TYPE = 'delete'

const fetchTemplate = (str) => {
  const content = document.querySelector(`#${str}`).innerText
  return template(content)
}

const getAllCustomerRows = () => document.querySelectorAll('tr.customer-row')
const getAllCompanies = () => document.querySelectorAll('input[name="psa_company"]')

const formatCustomer = (customer) => {
  let relatedToName
  let relatedToId

  if (customer.cached_company) {
    relatedToName = customer.cached_company.name
    relatedToId = customer.cached_company.id
  }

  return Object.assign({}, customer, {
    type: 'customer',
    relatedToName,
    relatedToId,
  })
}

const resetCustomersForm = (form) => {
  const query = form.querySelector('input[name="customers[q]"]')
  const connectedCheckbox = form.querySelector('input[name="customers[no_connection]"][type="checkbox"]')
  const limitSelector = form.querySelector('select[name="customers[limit]"]')
  query.value = ''
  query.dispatchEvent(new Event('change'))
  connectedCheckbox.checked = false
  connectedCheckbox.dispatchEvent(new Event('change'))
  limitSelector.selectedIndex = 1
  limitSelector.dispatchEvent(new Event('change'))
}

const resetCompaniesForm = (form) => {
  const query = form.querySelector('input[name="companies[q]"]')
  const connectedCheckbox = form.querySelector('input[name="companies[no_connection]"][type="checkbox"]')
  const companyTypes = form.querySelector('select[name="companies[company_types][]"]')
  const limitSelector = form.querySelector('select[name="companies[limit]"]')

  query.value = ''
  query.dispatchEvent(new Event('change'))
  connectedCheckbox.checked = false
  connectedCheckbox.dispatchEvent(new Event('change'))
  companyTypes.selectedIndex = -1
  companyTypes.dispatchEvent(new Event('change'))
  limitSelector.selectedIndex = 1
  limitSelector.dispatchEvent(new Event('change'))
}

class PsaAccountMessages extends ClientMessaging {
  constructor(container) {
    super(container, container.querySelector('#companiesHeaderText'))
  }
}

export default class extends Controller {
  static targets = ['companiesRadioContainer', 'customersTableBody', 'customerSearchButton', 'companySearchButton']

  constructor(...args) {
    super(...args)
    this.customerTemplate = fetchTemplate(CUSTOMERS_TEMPLATE_ID)
    this.companiesTemplate = fetchTemplate(COMPANIES_TEMPLATE_ID)

    this.customers = []
    this.companies = []
    this.firstLoad = true

    this.selectedCustomers = new Set()
    this.messages = new HelperMessages(this.messagesContainer).defaultTag('p')
    this.psaAccountMessages = new PsaAccountMessages(this.companiesHeader).defaultTag(null)
    this.allCustomersSelected = false

    this.customersLimit = 10
    this.companiesLimit = 10
    this.onLoadMoreChange = this.onLoadMoreChange.bind(this)
    this.customersLimitWatcher = new ChangeWatcher(this.customersLimitInput, this.onLoadMoreChange, { type: 'customers', coerceValueTo: 'number' })
    this.companiesLimitWatcher = new ChangeWatcher(this.companiesLimitInput, this.onLoadMoreChange, { type: 'companies', coerceValueTo: 'number' })

    this.customerSearchEnterWatchers = this.customerInputs.forEach((input) => {
      return new KeyupWatcher(input, 13, (watcher, { event }) => {
        this.onSearchCustomers(event)
      })
    })

    this.companySearchEnterWatchers = this.companyInputs.forEach((input) => {
      return new KeyupWatcher(input, 13, (watcher, { event }) => {
        this.onSearchCompanies(event)
      })
    })

    this.onSelectCallback = this.onSelectCallback.bind(this)
    this.onSelectCompanyCallback = this.onSelectCompanyCallback.bind(this)
    this.onErrorCallback = this.onErrorCallback.bind(this)
    this.onSuccessCallback = this.onSuccessCallback.bind(this)

    this.setup()

    window.form = this
  }

  setup() {
    this.customersLimit = this.customersLimitWatcher.currentValue
    this.companiesLimit = this.companiesLimitWatcher.currentValue

    this.attachAllCompanies()
    this.attachAllCustomers()
    this.resetMessaging()
    return this
  }

  disconnect() {
    this.companiesLimitWatcher.destroy()
    this.customersLimitWatcher.destroy()
    this.customerSearchEnterWatchers.forEach((watcher) => watcher.destroy())
    this.companySearchEnterWatchers.forEach((watcher) => watcher.destroy())
    this.customers.forEach((customer) => {
      customer.destroy()
    })
    this.companies.forEach((company) => {
      company.destroy()
    })
  }

  // Element getters
  // ---------------------------------------------------------------------------
  get form() {
    return this.element
  }

  get customerInputs() {
    return this.form.querySelectorAll('[name^="customers"]')
  }

  get companyInputs() {
    return this.form.querySelectorAll('[name^="companies"]')
  }

  get customersContainer() {
    return this.customersTableBodyTarget
  }

  get companiesContainer() {
    return this.companiesRadioContainerTarget.querySelector('.form-group')
  }

  get companiesHeader() {
    return this.form.querySelector('#companiesHeader')
  }

  /**
   * reference to the container that renders messages to help the customer along
   */
  get messagesContainer() {
    return this.form.querySelector('#flashNotificationsContainer')
  }

  get companiesLimitInput() {
    return this.form.querySelector('select[name="companies[limit]"]')
  }

  get customersLimitInput() {
    return this.form.querySelector('select[name="customers[limit]"]')
  }

  get loadMoreCustomersButton() {
    return this.form.querySelector('#loadMoreCustomers')
  }

  get loadMoreCompaniesButton() {
    return this.form.querySelector('#loadMoreCompanies')
  }

  get customerSearchButton() {
    return this.customerSearchButtonTarget
  }

  get companySearchButton() {
    return this.companySearchButtonTarget
  }

  // Data getters
  // ---------------------------------------------------------------------------
  /**
   * returns an object of the serialized form parameters. The object's nesting
   * matches the form parameters. E.g., all of the `customer[x]` parameters on
   * the rails form will be contained in its own object.
   *
   * Example:
   * {
   *   companies: {
   *     limit: 10,
   *     offset: 50
   *   },
   *   customers: {
   *     limit: 10,
   *     offset: 50
   *   }
   * }
   */
  get formBody() {
    const serializedParams = $(this.form).serialize()
    const url = new URL(`${this.url}?${serializedParams}`)
    const urlParams = {}

    for (const [key, val] of url.searchParams) {
      railsFormParamsToObject(urlParams, key, val)
    }
    return urlParams
  }

  get url() {
    return this.form.action
  }

  get method() {
    return this.form.method
  }

  get companiesOffset() {
    return this.companies.length
  }

  get customerOffset() {
    return this.customers.length
  }

  // UI operations & behaviours
  // ---------------------------------------------------------------------------
  resetMessaging() {
    if (this.firstLoad && !this.customers.length) {
      this.messages.warn('It looks like you don\'t have any customers. There\'s nothing left to do here. Once you\'ve created some customers, come back here to connect them to a PSA Account.')
    } else {
      this.messages.info('Select one or more customers to connect them to a PSA account')
      this.psaAccountMessages.message('No customers selected...')
    }
  }

  updateUI() {
    if (this.selectedCustomers.size > 0) {
      switch(this.selectedCustomers.size) {
      case 1: {
        const customer = this.selectedCustomers.values().next().value
        this.messages.info('Now, select a PSA account to connect your customer to.')
        this.psaAccountMessages.message(`${customer.name} selected`)
        break
      }
      default: {
        this.messages.info('Now, select a PSA account to connect your customers to.')
        this.psaAccountMessages.message(`${this.selectedCustomers.size} customers selected`)
      }
      }
    } else {
      this.resetMessaging()
    }
  }

  onSelectCallback(customer) {
    if (customer.isSelected) {
      this.selectedCustomers.add(customer)
    } else {
      this.selectedCustomers.delete(customer)
    }
    this.updateUI()
  }

  onSelectAll(event) {
    event.preventDefault()
    if (this.allCustomersSelected) {
      this.unSelectAllCustomers()
      this.allCustomersSelected = false
    } else {
      this.selectAllCustomers()
      this.allCustomersSelected = true
    }
  }

  selectAllCustomers() {
    this.customers.forEach((customer) => {
      customer.select()
    })
  }

  unSelectAllCustomers() {
    this.customers.forEach((customer) => {
      customer.unSelect()
    })
  }

  onLoadMoreChange(value, klass) {
    switch(klass.metadata.type) {
    case 'customers': {
      this.customersLimit = value
      break
    }
    case 'companies': {
      this.companiesLimit = value
      break
    }
    }
  }

  updateLoadMoreButton(type, response) {
    let limit = 0
    let button = undefined
    let buttonVisible = true
    switch(type) {
    case 'customers': {
      limit = this.customersLimit
      button = this.loadMoreCustomersButton
      break
    }
    case 'companies': {
      limit = this.companiesLimit
      button = this.loadMoreCompaniesButton
      break
    }
    }
    if (response.length < limit) {
      buttonVisible = false
    }
    // hide or show
    button.hidden = !buttonVisible
  }

  onResetCustomersSearch() {
    resetCustomersForm(this.form)
    this.customerSearchButton.dispatchEvent(new Event('click'))
  }

  onResetCompaniesSearch() {
    resetCompaniesForm(this.form)
    this.companySearchButton.dispatchEvent(new Event('click'))
  }

  // UI updating
  // ---------------------------------------------------------------------------
  attachAllCustomers() {
    const customers = Array.from(getAllCustomerRows()).map((node) =>
      new CustomerRow(node, this.onSelectCallback)
    )
    this.customers = customers
    return customers
  }

  attachAllCompanies() {
    const companies = Array.from(getAllCompanies()).map((node) =>
      new CompanyRadio(node, this.onSelectCompanyCallback)
    )
    this.companies = companies
    return companies
  }

  addCustomers(customers) {
    customers.forEach((customer) => {
      const customerString = this.customerTemplate(formatCustomer(customer))
      this.customersContainer.insertAdjacentHTML('beforeend', customerString)
      const node = this.customersContainer.querySelector(`tr.customer-row[data-customer-id='${customer.id}']`)
      this.customers.push(new CustomerRow(node, this.onSelectCallback))
    })
  }

  addCompanies(companies) {
    companies.forEach((company) => {
      const companyString = this.companiesTemplate(company)
      this.companiesContainer.insertAdjacentHTML('beforeend', companyString)
      const node = this.companiesContainer.querySelector(`input[name='psa_company'][value='${company.id}']`)
      this.companies.push(new CompanyRadio(node, this.onSelectCompanyCallback))
    })
  }

  replaceCustomersContainer(customers) {
    this.customers.forEach((customer) => customer.destroy())
    const contents = ['']
    customers.forEach((customer) => {
      contents.push(this.customerTemplate(formatCustomer(customer)))
    })
    this.customersContainer.innerHTML = contents.join('')
    this.attachAllCustomers()
  }

  replaceCompaniesContainer(companies) {
    this.companies.forEach((company) => company.destroy())
    const contents = ['']
    companies.forEach((company) => {
      contents.push(this.companiesTemplate(company))
    })
    this.companiesContainer.innerHTML = contents.join('')
    this.attachAllCompanies()
  }

  // Requests
  // ---------------------------------------------------------------------------
  onErrorCallback(error) {
    this.messages.error(error)
  }

  onSuccessCallback() {
    this.firstLoad = false
    this.messages.success()
  }

  /**
   * Handles all requests between this form and rails
   */
  makeRequest(type = SEARCH_TYPE, params = {}) {
    let body = merge({}, this.formBody, params)
    let method = this.method
    let url = this.form.action

    switch(type) {
    case CREATE_TYPE: {
      url = this.form.dataset.createUrl
      method = 'POST'
      body = params
      break
    }
    case DELETE_TYPE: {
      url = this.form.dataset.deleteUrl
      method = 'DELETE'
      body = params
      break
    }
    }

    this.messages.loading()

    return railsRequest(
      url,
      {
        method,
        body,
        onError: this.onErrorCallback,
        onSuccess: this.onSuccessCallback
      }
    )
  }

  async onSearchCustomers(event) {
    event.preventDefault()
    const response = await this.makeRequest(SEARCH_TYPE, {
      companies: {
        ignore: 1
      },
      company_types: {
        ignore: 1,
      },
    })
    this.allCustomersSelected = false
    this.replaceCustomersContainer(response.body.customers)
    this.updateLoadMoreButton('customers', response.body.customers)
  }

  async onSearchCompanies(event) {
    event.preventDefault()
    const response = await this.makeRequest(SEARCH_TYPE, {
      customers: {
        ignore: 1,
      },
      company_types: {
        ignore: 1,
      },
    })
    this.allCustomersSelected = false
    this.replaceCompaniesContainer(response.body.companies)
    this.updateLoadMoreButton('companies', response.body.companies)
  }

  async onLoadMoreCompanies(event) {
    event.preventDefault()
    const response = await this.makeRequest(SEARCH_TYPE, {
      companies: { offset: this.companiesOffset },
      customers: { ignore: 1 },
      company_types: { ignore: 1 }
    })
    this.allCustomersSelected = false
    this.addCompanies(response.body.companies)
    this.updateLoadMoreButton('companies', response.body.companies)
  }

  async onLoadMoreCustomers(event) {
    event.preventDefault()
    const response = await this.makeRequest(SEARCH_TYPE, {
      companies: { ignore: 1 },
      company_types: { ignore: 1 },
      customers: {
        offset: this.customerOffset,
      },
    })
    this.allCustomersSelected = false
    this.addCustomers(response.body.customers)
    this.updateLoadMoreButton('customers', response.body.customers)
  }

  async onSelectCompanyCallback(company, event) {
    if (this.selectedCustomers.size < 1) {
      event.preventDefault()
      event.stopPropagation()
    } else {
      const customers = Array.from(this.selectedCustomers)
      const customerIds = customers.map(customer => customer.id)
      await this.makeRequest(CREATE_TYPE, {
        create: {
          company_id: company.id,
          customer_ids: customerIds,
        },
      })
      customers.forEach((customer) => {
        customer.changeCompany(company.name)
        customer.unSelect()
        customer.successfullyMapped()
      })
      company.unSelect()
      company.successfullyMapped()
      // TODO: change this to an event that is dispatched which resets the UI
      this.allCustomersSelected = false
      setTimeout(() => {
        this.updateUI()
      }, 5000)
    }
  }

  async onDeleteAllSelectedMaps(event) {
    event.preventDefault()
    if (this.selectedCustomers.size > 0) {
      const customers = Array.from(this.selectedCustomers)
      const customerIds = customers.map(customer => customer.id)
      await this.makeRequest(DELETE_TYPE, {
        destroy: {
          customer_ids: customerIds,
        },
      })
      customers.forEach((customer) => {
        customer.changeCompany('')
        customer.unSelect()
        customer.successfullyMapped()
      })
      this.allCustomersSelected = false
      setTimeout(() => {
        this.updateUI()
      }, 5000)
    }
  }
}
