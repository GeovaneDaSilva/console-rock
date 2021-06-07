import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['content']

  connect() {
    jQuery(this.element).on('show.bs.modal', (ev) => {
      this.show(ev.relatedTarget.getAttribute('data-content-target'))
    }).on('hide.bs.modal', () => {
      this.contentTarget.innerHTML = ''
      this.current = null
    })

    this.keyboardListener = document.addEventListener('keydown', (ev) => this.keypress(ev))
  }

  disconnect() {
    if (this.keyboardListener) {
      document.removeEventListener('keydown', this.keypress)
    }
  }

  keypress(ev) {
    if (this.current) {
      switch(ev.keyCode) {
        case 37: this.prev(); break
        case 39: this.next(); break
      }
    }
  }

  clickNext(ev) {
    ev.preventDefault();
    ev.stopPropagation()
    this.next()
  }

  clickPrev(ev) {
    ev.preventDefault();
    ev.stopPropagation()
    this.prev()
  }

  next() {
    if (this.current.nextSibling) {
      this.show(this.current.nextSibling.id)
    } else {
      this.show(this.current.parentElement.firstChild.id)
    }
  }

  prev() {
    if (this.current.previousSibling) {
      this.show(this.current.previousSibling.id)
    } else {
      this.show(this.current.parentElement.lastChild.id)
    }
  }

  show(id) {
    this.current = document.getElementById(id)

    this.contentTarget.innerHTML = this.current.innerHTML
  }
}
