import { Controller } from 'stimulus'

export default class extends Controller {

  connect() {
    setTimeout(() => {
      this.element.classList.remove(this.data.get('class'))
    }, 60)
  }
}
