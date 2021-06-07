import { Controller } from 'stimulus'

export default class extends Controller {
  toggleAll(ev) {
    const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"]');

    [].forEach.call(allCheckboxes, (checkbox) => {
      checkbox.checked = ev.target.checked
    })
  }
}
