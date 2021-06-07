import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['control']

  toggle(_ev) {
    const value = _ev.target.checked;
    this.controlTargets.forEach((el) => {
      el.disabled = !value;
    }, value);
  }
}
