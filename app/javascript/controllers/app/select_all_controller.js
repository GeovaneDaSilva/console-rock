import { Controller } from 'stimulus'


export default class extends Controller {
  toggle(ev) {
    ev.preventDefault()

    let checked = this.data.get('checked') === 'true' ? true : false;

    [].forEach.call(document.querySelectorAll(this.data.get('parent')), (checkbox) => {
      checkbox.checked = checked
    })

    this.data.set('checked', !checked)
  }
}
