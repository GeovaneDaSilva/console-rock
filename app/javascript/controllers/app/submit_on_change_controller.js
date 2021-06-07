import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.element.addEventListener('change', () => {
      Rails.fire(this.element.form, 'submit')
    })
  }
}
