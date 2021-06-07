import { Controller } from 'stimulus'
import  ModalConfirmController from "./modal_confirm_controller"

export default class extends ModalConfirmController {
  static targets = ['country']

  toggle(_ev) {
    this.toggleCountries(_ev.target.checked);
  }

  click(ev) {
    if(ev.target.checked == true) {
      super.click(ev);
    } else {
      this.toggleCountries(false);
    }
  }

  setBtnProceed() {
    const modal = this.modal();
    const checkbox = this.controlTarget;
    const countryTargets = this.countryTargets;
    modal.querySelector(".btn-ok").onclick = function() {
      checkbox.checked = true;
      const value = checkbox.checked;
      countryTargets.forEach((el) => {
        el.checked = value;
      }, value);

      $(modal).modal("hide");
    };
  }

  toggleCountries(value) {
    this.countryTargets.forEach((el) => {
      el.checked = value;
    }, value);
  }
}
