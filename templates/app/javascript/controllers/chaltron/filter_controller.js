import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="chaltron--filter"
export default class extends Controller {
  connect () {
    if (this.element.nodeName !== 'FORM') {
      console.error('chaltron--filter stimulus controller must be referenced by a FORM tag')
    } else {
      Array.from(this.element.elements).forEach((input) => {
        input.setAttribute('data-action', 'chaltron--filter#submit')
      })
    }
  }

  submit () {
    this.element.requestSubmit()
  }
}
