import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['control']

  connect() {
    this.setBtnProceed();
  }

  click(ev) {
    if(ev.target.checked == true) {
      ev.target.checked = false;
      $(this.modal()).modal("show");
    }
  }

  setBtnProceed() {
    const modal = this.modal();
    const checkbox = this.controlTarget;
    modal.querySelector(".btn-ok").onclick = function() {
      checkbox.checked = true;
      $(modal).modal("hide");
    };
  }

  elem() {
    return this.scope.element;
  }

  modal() {
    const elem = this.elem();
    return elem.querySelector("#" + elem.dataset.modal);
  }
}
