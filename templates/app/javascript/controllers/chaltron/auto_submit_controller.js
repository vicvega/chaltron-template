import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="chaltron--auto-submit"
export default class extends Controller {
  connect () {
    if (this.element.nodeName !== 'FORM') {
      console.error('chaltron--auto-submit stimulus controller must be referenced by a FORM tag')
    } else {
      Array.from(this.element.elements).forEach((input) => {
        this.#appendAction(input, 'chaltron--auto-submit#submit')
      })
    }
  }

  submit () {
    this.element.requestSubmit()
  }

  #appendAction (element, action) {
    let newAction = action
    if (element.hasAttribute('data-action')) {
      newAction += ` ${element.dataset.action}`
    }
    element.setAttribute('data-action', newAction)
  }
}
