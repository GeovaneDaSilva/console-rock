// src/controllers/pin_menu_controller.js
import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'middletag', 'navtag', 'button' ]

  connect() {
    this.addObserver()
    if(localStorage.getItem('navShouldBeOpen') == true) {
      // ensure menu is displayed
      this.element.classList.remove('min')

      this.middletagTarget.style.marginLeft = ''
      this.navtagTarget.style.visibility = 'visible'
      this.buttonTarget.classList.remove('active')
    }
  }

  addObserver(){
    // create an observer instance
    let observer = new MutationObserver( (mutations) => {
      mutations.forEach( () => {
        // set session variable (will be deleted on browser close)
        localStorage.setItem('navShouldBeOpen', (this.element.classList.contains('min') ? 0 : 1))
      })
    })

    // configuration of the observer:
    let config = {
      attributes: true,
      childList: false,
      characterData: false
    }

    // pass in the target node, as well as the observer options
    observer.observe(this.element, config)
  }
}
