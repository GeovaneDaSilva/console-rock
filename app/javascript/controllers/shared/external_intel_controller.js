import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    if ([null, undefined, ''].indexOf(this.data.get('value')) > -1 ) {
      return
    }

    const new_html = this.makeHtml();
    this.element.insertAdjacentHTML('afterend', new_html)
    this.element.remove()
  }

  makeHtml() {
    switch (this.data.get('type')) {
      case 'ip': return this.ipHtml();
      case 'hash': return this.hashHtml();
    }
  }

  ipHtml() {
    return `<a href="https://metadefender.opswat.com/results#!/ip/${btoa(this.data.get('value'))}/overview" target="_blank" rel="nofollow"> ${this.element.innerText} <img class='fa fa-external-link' src='/opswat_icon-48x48.png' style='width:1.2em'/></a>`
  }

  hashHtml() {
    return `<a href="https://metadefender.opswat.com/results#!/file/${this.data.get('value')}/hash/overview" target="_blank" rel="nofollow"> ${this.element.innerText} <img class='fa fa-external-link' src='/opswat_icon-48x48.png' style='width:1.2em'/></a>` +
    `<a href="https://www.virustotal.com/gui/file/${this.data.get('value')}" target="_blank" rel="nofollow"><img class='fa fa-external-link' src='/vt_logo.svg' style='width:1.2em'/></a>`
  }
}
