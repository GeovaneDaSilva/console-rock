// app/javascripts/controllers/config_key_value_controller.js
/*global toastr*/
import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['text', 'row']

  edit(event) {
    const a = event.target.closest("a");
    this.fillInDestination(a.dataset.target.substr(1));
    event.preventDefault();
  }

  del(event) {
    const i = this.rowTarget.rowIndex;
    this.rowTarget.closest("table").deleteRow(i);
    event.preventDefault();
  }

  fillInDestination(targetId) {
    const dest = document.getElementById(targetId);
    //substitute-values
    dest.querySelector("[name='scan_type']").value = this.rowTarget.querySelector("[name$='key]']").value;
    dest.querySelector("[name='label']").value = this.rowTarget.querySelector("[name$='label]']").value;

    const regex = dest.querySelector("[name='regex']");
    regex.value = this.rowTarget.querySelector("[name$='regex]']").value;
    regex.dispatchEvent(new Event('keyup'));

    dest.querySelector("[name='reporting_threshold']").value = this.rowTarget.querySelector("[name$='reporting_threshold]']").value;
    dest.querySelector("[name='keywords']").value = this.rowTarget.querySelector("[name$='keywords]']").value;
  }
}
