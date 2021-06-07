import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['countryInput', 'stateContainer']

  connect() {
    this.stateContainerTarget.dispatchEvent(new Event("change"));
  }

  toggle(ev) {
   let states = this.stateContainerTarget.getElementsByClassName("states");
   Array.from(states).forEach(function(e) { e.classList.add("hidden"); });

   let country = ev.target.value.toLowerCase();
   let active_states = this.stateContainerTarget.getElementsByClassName("state_" + country);
   Array.from(active_states).forEach(function(e) { e.classList.remove("hidden"); });
  }
}
