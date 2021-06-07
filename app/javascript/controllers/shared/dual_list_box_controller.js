import { Controller } from 'stimulus'
import { Debounce } from '../../lib/debounce'

export default class extends Controller {
  static targets = [
    'deselectItemsButton',
    'selectItemsButton',
    'itemsFilter',
    'selectedItemsFilter',
    'toggleItemsCheckbox',
    'toggleSelectedItemsCheckbox',
    'submitButton'
  ]

  connect() {
    this.deselectItemsButtonTarget.addEventListener('click', () => {
      this.toggleSelectedItemsCheckboxTarget.checked = false
      this.deselectItems()
    })

    this.selectItemsButtonTarget.addEventListener('click', () => {
      this.toggleItemsCheckboxTarget.checked = false
      this.selectItems()
    })

    this.itemsFilterTarget.addEventListener('keyup', Debounce((e) => {
      this.refreshItems(e.target.value, '.item')
    }, 250))

    this.selectedItemsFilterTarget.addEventListener('keyup', Debounce((e) => {
      this.refreshItems(e.target.value, '.selected-item')
    }, 250))

    this.toggleItemsCheckboxTarget.addEventListener('click', (e) => {
      this.toggleAll('.item', e.target.checked)
    })

    this.toggleSelectedItemsCheckboxTarget.addEventListener('click', (e) => {
      this.toggleAll('.selected-item', e.target.checked)
    })

    this.submitButtonTarget.addEventListener('click', () => {
      this.toggleAll('.item', false)
      this.toggleAll('.selected-item', true)
    })
  }

  deselectItems() {
    var selectedItems = document.querySelectorAll('.selected-items input:checked')
    var itemsContainer = document.querySelector('.items')
    for (var i = 0; i < selectedItems.length; i++) {
      var selectedItem = selectedItems[i]
      var selectedItemLabel = selectedItem.parentNode
      var listItem = selectedItem.parentNode.parentNode.parentNode
      selectedItem.classList.remove('selected-item')
      selectedItem.classList.add('item')
      selectedItem.checked = false
      selectedItemLabel.style.display = 'inline-block'
      itemsContainer.appendChild(listItem)
    }
  }

  selectItems() {
    var items = document.querySelectorAll('.items input:checked')
    var selectedItemsContainer = document.querySelector('.selected-items')
    for (var i = 0; i < items.length; i++) {
      var item = items[i]
      var itemLabel = item.parentNode
      var list_item = item.parentNode.parentNode.parentNode
      item.classList.remove('item')
      item.classList.add('selected-item')
      item.checked = false
      itemLabel.style.display = 'inline-block'
      selectedItemsContainer.appendChild(list_item)
    }
  }

  refreshItems(keyword, selector) {
    var filter = keyword.toLowerCase().trim()
    var items = document.querySelectorAll(selector)

    for (var i = 0; i < items.length; i++) {
      items[i].parentNode.style.display = 'none'
    }

    for (var j = 0; j < items.length; j++) {
      var itemLabel = items[j].parentNode
      var text = itemLabel.textContent.toLowerCase().trim()
      if (text.includes(filter)) {
        itemLabel.style.display = 'inline-block'
      }
    }
  }

  toggleAll(selector, state) {
    var items = document.querySelectorAll(selector)
    for (var i = 0; i < items.length; i++) {
      items[i].checked = state
    }
  }
}
