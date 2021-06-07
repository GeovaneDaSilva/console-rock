import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'list', 'name']

  connect() {
    let a = this.listTarget.getElementsByTagName("a")[0];
    if(a)
      a.click();
  }

  show(ev) {
    let accountId = ev.target.dataset.id;
    let customerId = ev.target.dataset.customer_id
    $.ajax({
      type: "get",
      url: `/accounts/${accountId}/integrations/cylance`,
      data: { customer_id: customerId },
      success: (data) => {
        $(this.formTarget).html(data.html);
      }
    });
    this.nameTarget.innerText = ev.target.text;
    ev.preventDefault();
  }
}
