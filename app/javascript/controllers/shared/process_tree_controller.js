import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['selector', 'detail']

  connect() {
    this.select()
  }

  select() {
    const selectorEl = this.currentSelectorEl()

    this.detailTargets.forEach((el) => {
      if (el.id == selectorEl.value) {
        el.removeAttribute('hidden')
      } else {
        el.setAttribute('hidden', true)
      }
    })
  }

  currentSelectorEl() {
    return this.selectorTargets.find(el => el.checked)
  }
}
