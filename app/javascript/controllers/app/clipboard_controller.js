// app/javascripts/controllers/clipboard_controller.js
/*global toastr*/
import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = [ ]

  copy(event){
    // could use data-target, but here I think this is cleaner
    let target = event.target.dataset.value

    let copyText = document.getElementById(target)
    copyText.select()
    var success = document.execCommand('copy')


    // Inform the user of success/failure
    if (success) {
      toastr.success('Copied to clipboard!')
    }
    else{
      toastr.failure('Copy failed')
    }
  }
}
