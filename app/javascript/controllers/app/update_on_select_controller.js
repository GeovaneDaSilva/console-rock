import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['select', 'updateTarget']

  connect() {
    this.valueMap = JSON.parse(this.data.get('map'))

    this.selectTarget.addEventListener('change', () => {
      this.update()
    })
  }

  update() {
    if (this.valueMap[this.selectTarget.value]) {
      let value = this.valueMap[this.selectTarget.value];
      if(Array.isArray(value))
        value = value[0];
      this.updateTargetTarget.value = value;
    }
  }
}
