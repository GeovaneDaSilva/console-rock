import { Controller } from 'stimulus'

export default class extends Controller {

  connect() {
    let targetId = window.location.hash.substr(1)
    let elem = document.getElementById(`${targetId}-detail`)

    elem.classList.add('highlight')

    elem.removeAttribute('hidden')
    elem.scrollIntoView()
  }
}
