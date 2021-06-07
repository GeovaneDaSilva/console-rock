import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['accountSelectTypeAllAccounts', 'addButton', 'removeButton', 'addActionButton', 'removeActionButton', 'addDependencyButton', 'removeDependencyButton', 'appType', 'appSelect']

  connect() {
    this.addButtonTarget.addEventListener('keyup', () => {
      this.addItem()
    })

    this.addActionButtonTarget.addEventListener('keyup', () => {
      this.addAction()
    })

    this.removeButtonTarget.addEventListener('keyup', () => {
      this.removeItem(this.target)
    })

    this.removeActionButtonTarget.addEventListener('keyup', () => {
      this.removeAction(this.target)
    })

    this.showToggle()
  }

  showToggle() {
    const toggle = document.querySelector('.include-descendants')
    const accountIdField = this.element.querySelector('input[name="account_id"]')

    if (this.accountSelectTypeAllAccountsTarget.checked) {
      toggle.classList.add('hidden')
      accountIdField.classList.add('hidden')
    } else {
      toggle.classList.remove('hidden')
      accountIdField.classList.remove('hidden')
    }
  }

  addItem() {
    var collection = document.querySelector('.conditions')
    var item = document.querySelector('.condition-template').cloneNode(true)
    var inputs = item.querySelector('.form-group').children

    item.classList.remove('condition-template', 'hidden')
    item.classList.add('condition')
    for (var i = 0; i < inputs.length; i++) {
      inputs[i].disabled = false
    }

    collection.appendChild(item)
  }

  addAction() {
    var collection = document.querySelector('.actions')
    var action = document.querySelector('.action-template').cloneNode(true)
    var actionSelect = action.querySelector('.action-select')

    action.classList.remove('action-template', 'hidden')
    action.classList.add('action')
    actionSelect.disabled = false

    collection.appendChild(action)
  }

  addDependency() {
    var collection = document.querySelector('.dependencies')
    var dependency = document.querySelector('.dependency-template').cloneNode(true)
    var inputs = dependency.querySelector('.form-group').children

    dependency.classList.remove('dependency-template', 'hidden')
    dependency.classList.add('dependency')
    for (var i = 0; i < inputs.length; i++) {
      inputs[i].disabled = false
    }

    collection.appendChild(dependency)
  }

  removeItem(e) {
    e.target.closest('.condition').remove()
  }

  removeAction(e) {
    e.target.closest('.action').remove()
  }

  removeDependency(e) {
    e.target.closest('.dependency').remove()
  }

  showActionInputs(e) {
    this.showIncidentInputs(e)
    this.showAvActionInputs(e)
  }

  showIncidentInputs(e) {
    var target = e.target
    var selectedIndex = target.selectedIndex

    this.showTemplateSelect(target, selectedIndex)
    this.showConsolidateToggle(target, selectedIndex)
    this.uncheckConsolidateCheckbox(e)
    this.toggleConsolidateInputs(e)
  }

  showTemplateSelect(target, selectedIndex) {
    var row = target.closest('.action')
    var incidentTemplate = row.querySelector('.incident-template')

    if (selectedIndex == 1) {
      incidentTemplate.classList.remove('hidden')
      incidentTemplate.disabled = false
    } else {
      incidentTemplate.classList.add('hidden')
      incidentTemplate.disabled = true
    }
  }

  showConsolidateToggle(target, selectedIndex) {
    var row = target.closest('.action')
    var consolidateToggle = row.querySelector('.consolidate-results')

    if (selectedIndex == 1) {
      consolidateToggle.classList.remove('hidden')
    } else {
      consolidateToggle.classList.add('hidden')
    }
  }

  toggleConsolidateInputs(e) {
    var state = e.target.checked
    var row = e.target.closest('.action')
    var inputs = row.querySelectorAll('.consolidate-input')

    for (var i = 0; i < inputs.length; i++) {
      if (state) {
        inputs[i].classList.remove('hidden')
        inputs[i].disabled = false
      } else {
        inputs[i].classList.add('hidden')
        inputs[i].disabled = true
      }
    }
  }

  uncheckConsolidateCheckbox(e) {
    var row = e.target.closest('.action')
    var consolidateCheckbox = row.querySelector('input[name="consolidate_results"]')
    consolidateCheckbox.checked = false
  }

  showAvActionInputs(e) {
    var target = e.target
    var row = target.closest('.action')
    var avVendorField = row.querySelector('.av-vendor')
    var avActionDropdown = row.querySelector('.av-action')
    var avActionOptionDropdown = row.querySelector('.av-action-option')
    var selectedIndex = target.selectedIndex

    this.toggleAvVendorField(avVendorField, selectedIndex)
    this.showAvActionSelect(avActionDropdown, selectedIndex)
    this.showAvActionOptionSelect(avActionOptionDropdown, avActionDropdown, selectedIndex)
  }

  toggleAvVendorField(target, selectedIndex) {
    if (selectedIndex == 2) {
      target.disabled = false
    } else {
      target.disabled = true
    }
  }

  showAvActionSelect(target, selectedIndex) {
    if (selectedIndex == 2) {
      this.populateAvActions(target)
      target.classList.remove('hidden')
      target.disabled = false
    } else {
      target.classList.add('hidden')
      target.disabled = true
    }
  }

  populateAvActions(target) {
    var i, size = target.options.length - 1
    for (i = size; i >= 0; i--) {
      target.remove(i)
    }

    var options = []
    switch (this.appTypeTarget.value) {
    case 'sentinelone':
      options = ['Analyst Verdict', 'Mitigation Action', 'Whitelist']
      break
    default:
      []
    }

    for (i = 0; i < options.length; i++) {
      var option = options[i]
      var element = document.createElement('option')
      element.text = option 
      element.value = option
      target.add(element)
    }
  }

  showAvActionOptionSelect(target, avActionTarget, selectedIndex) {
    if (selectedIndex == 2) {
      this.populateAvActionOptions(target, avActionTarget)
      target.classList.remove('hidden')
      target.disabled = false
    } else {
      target.classList.add('hidden')
      target.disabled = true
    }
  }

  populateAvActionOptions(target, avActionTarget) {
    var i, size = target.options.length - 1
    for (i = size; i >= 0; i--) {
      target.remove(i)
    }

    var options = []
    switch (avActionTarget.value) {
    case 'Analyst Verdict':
      options = ['undefined', 'true_positive', 'false_positive', 'suspicious']
      break
    case 'Mitigation Action':
      options = ['kill', 'quarantine', 'remediate', 'rollback', 'disconnectFromNetwork']
      break
    case 'Whitelist':
      options = ['by file hash']
      break
    default:
      []
    }

    for (i = 0; i < options.length; i++) {
      var option = options[i]
      var element = document.createElement('option')
      element.text = option 
      element.value = option
      target.add(element)
    }
  }

  refreshAvActions(e) {
    var app_id = e.target.value
    var lookup = e.target.dataset.lookup
    var type_lookup = JSON.parse(lookup)
    var app_type = type_lookup[app_id]

    this.appTypeTarget.value = app_type

    var avVendorFields = document.querySelectorAll('.av-vendor')
    var avActionDropdowns = document.querySelectorAll('.av-action')
    var avActionOptionDropdowns = document.querySelectorAll('.av-action-option')
    for (var i = 0; i < avActionDropdowns.length; i++) {
      avVendorFields[i].value = app_type
      this.populateAvActions(avActionDropdowns[i])
      this.populateAvActionOptions(avActionOptionDropdowns[i], avActionDropdowns[i])
    }
  }

  refreshAvActionOptions(e) {
    var target = e.target
    var row = target.closest('.action')
    var avActionDropdown = row.querySelector('.av-action')
    var avActionOptionDropdown = row.querySelector('.av-action-option')
    this.populateAvActionOptions(avActionOptionDropdown, avActionDropdown)
  }
}
