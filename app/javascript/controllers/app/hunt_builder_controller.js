import { Controller } from 'stimulus'

const regExp = /(\d+)/g
const array  = []

export default class extends Controller {
  static targets = ['test', 'testType', 'testTemplate']

  addTest(ev) {
    ev.preventDefault()
    ev.stopPropagation()

    const newIndex       = `$1${new Date().getTime()}`
    const targetType     = this.testTypeTarget.value
    const templateTarget = this.templateTargetForType(targetType)
    const template       = templateTarget.innerHTML
    const templFragment  = document.createRange().createContextualFragment(template)
    const testTarget     = this.testTargetForType(targetType)

    array.forEach.call(templFragment.querySelectorAll('input, label'), (el) => {
      ['id', 'name', 'for'].forEach((attr) => {
        let value = el.getAttribute(attr)

        if (value !== null) {
          el.setAttribute(attr, value.replace(regExp, newIndex))
        }
      })
    })

    testTarget.appendChild(templFragment)
    testTarget.lastChild.scrollIntoView({ block: 'start', behavior: 'smooth' })
  }

  templateTargetForType(type) {
    return document.getElementById(`${type}-template`)
  }

  testTargetForType(type) {
    return this.testTargets.find((element) => {
      return element.id === type
    })
  }
}
