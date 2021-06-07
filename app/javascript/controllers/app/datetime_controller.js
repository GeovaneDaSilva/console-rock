import { Controller } from 'stimulus'
import { render } from 'timeago.js'

export default class extends Controller {
  connect() {
    render(this.element)
  }
}
