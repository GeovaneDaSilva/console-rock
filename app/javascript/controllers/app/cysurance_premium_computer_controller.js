import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['coverage', 'premium']

  connect() {
    if(!this.premiumTarget.value)
      this.premiumTarget.value = this.premium();
  }

  toggle(ev) {
    let value = parseInt(this.coverageTargetValue());
    if(value > 25000) {
      let answer = confirm("Coverage Limit beyond 25,000 is only available if you have more than 300 employees, do you wish to confirm the coverage limit value " + value + "?");
      if(answer)
        this.premiumTarget.value = this.premium();
      else {
	this.coverageTarget.selectedIndex = 0;
	this.coverageTarget.dispatchEvent(new Event("change"));
      }

    } else {
      this.premiumTarget.value = this.premium();
    }
  }

  coverageTargetValue() {
    return this.coverageTarget.value.substring(1);
  }

  premium() {
    switch(parseInt(this.coverageTargetValue())) {
      case 5000:
        return "$10";
    	break;
      case 10000:
        return "$12";
        break;
      case 15000:
        return "$16";
        break;
      case 20000:
        return "$18";
        break;
      case 25000:
        return "$20";
        break;
      case 50000:
	return "$22";
        break;
      case 100000:
	return "$24";
        break;
    }
  }
}
