import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['anchor']

  open(ev) {
    ev.preventDefault()
    this.anchorTargets.forEach((el) => open(el.href, '_blank'))
  }
}
