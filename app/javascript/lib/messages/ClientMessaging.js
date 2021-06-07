import { isObject } from 'lodash'
import { DeveloperError } from '../errors/DeveloperError'

export class ClientMessaging {
  constructor(container, messagesContainer) {
    this.container = container
    this.messagesContainer = messagesContainer
  }

  defaultTag(tag) {
    this.defaultTag = tag
    return this
  }

  clear() {
    this.setContainerClassName(false)
    this.messagesContainer.innerHTML = ''
  }

  message(text) {
    this.clear()
    if (typeof this.defaultTag === 'string') {
      const node = document.createElement(this.defaultTag)
      node.innerText = text
      this.messagesContainer.append(node)
    } else {
      this.messagesContainer.innerText = text
    }
  }

  setContainerClassName(klass) {
    if (this.classes && isObject(this.classes)) {
      Object.keys(this.classes).forEach((cs) => {
        this.container.classList.remove(this.classes[cs])
      })
      if (klass) {
        const foundClass = this.classes[klass]
        if (!foundClass) {
          throw new DeveloperError(`Could not find css class: ${klass} in classes object`)
        } else {
          this.container.classList.add(foundClass)
        }
      }
    }
  }
}
