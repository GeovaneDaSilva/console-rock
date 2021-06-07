import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'collapseable'
  ]

  toggle(_ev) {
    this.collapseableTarget.classList.toggle('collapse')
    this.element.classList.toggle('open')

    if (this.collapseableTarget.classList.contains('collapse')) {
      [].forEach.call(this.collapseableTarget.querySelectorAll('[data-required]'), (el) => {
        el.removeAttribute('required')
      })
    } else {
      [].forEach.call(this.collapseableTarget.querySelectorAll('[data-required]'), (el) => {
        el.setAttribute('required', true)
      })
    }
  }
}
