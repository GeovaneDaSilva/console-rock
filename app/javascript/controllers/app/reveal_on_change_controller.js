import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'revealer', 'revealee' ]

  connect() {
    if (this.element.value == "Route All Detections to A Single Customer") {
      this.oneCustomer("reveal")
    }
    else if (this.element.value == "Route Detections to Customers Using AV Site IDs"){
      this.avMap("reveal")
    }

    this.element.addEventListener('change', () => {
      if (event.target.value == "Route All Detections to A Single Customer"){
        this.oneCustomer("reveal")
        this.avMap("hide")
      }
      else {
        this.oneCustomer("hide")
        this.avMap("reveal")
      }
    })
  }

  oneCustomer(task) {
    var revealees = document.getElementsByClassName("oneCustomer")
    var i;
    for (i = 0; i < revealees.length; i++){
      if (task == "hide") {
        revealees[i].classList.add("hidden")
      }
      else if (task == "reveal") {
        revealees[i].classList.remove("hidden")
      }
    }
  }

  avMap(task) {
    var revealees = document.getElementsByClassName("avMap")
    var i;
    for (i = 0; i < revealees.length; i++){
      if (task == "hide") {
        revealees[i].classList.add("hidden")
      }
      else if (task == "reveal") {
        revealees[i].classList.remove("hidden")
      }
    }
  }
}
