import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['tabs']

  connect() {
    this.hashChangeListener = () => this.navigate()
    window.addEventListener('hashchange', this.hashChangeListener, false)

    this.navigate()
  }

  disconnect() {
    window.removeEventListener('hashchange', this.hashChangeListener)
  }

  navigate() {
    const tabIds = []

    this.tabsTargets.forEach((tabEl, i) => {
      const tabId = '#' + tabEl.id
      tabIds.push(tabId)

      if (location.hash == tabId) {
        tabEl.removeAttribute('hidden')
      } else if (location.hash == '' && i == 0) {
        // No hash specified, show the first tab
        tabEl.removeAttribute('hidden')
      } else {
        tabEl.setAttribute('hidden', true)
      }
    });

    [].forEach.call(document.querySelectorAll('a[href^="#"]'), (anchor) => {
      const anchorUrl = new URL(anchor.href)

      if (tabIds.indexOf(anchorUrl.hash) > -1) {
        if (anchorUrl.hash == location.hash) {
          anchor.parentElement.classList.add('active')
        } else {
          anchor.parentElement.classList.remove('active')
        }
      }
    })
  }
}
