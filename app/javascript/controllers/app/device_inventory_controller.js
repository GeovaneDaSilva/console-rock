import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['device']

  connect() {
    $.ajax({
      type: "get",
      url: '/devices/' + this.context.scope.element.dataset.value + '/inventory',
      success: (data) => {
        this.update(data);
      }
    })
  }

  update(data) {
    this.deviceTarget.innerHTML = data
  }
}
