import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['device']

  update(data) {
    const element = this.context.scope.element;
    const type = element.dataset.type;
    $.ajax({
      type: "POST",
      url: '/devices/' + this.context.scope.element.dataset.value + '/custom_update',
      data: { details: { comments: this.deviceTarget.value },
	      type: type },
      success: (data) => {
    	this.deviceTarget.innerHTML = data.details["comments"];
	$("#" + type + " .row_" + data.id + " td.comments").get(0).innerHTML = data.details["comments"];
	$("#" + element.id + " .close").click();
      }
    });
    data.preventDefault();
  }
}
