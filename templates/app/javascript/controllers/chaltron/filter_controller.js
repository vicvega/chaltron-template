import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="chaltron--filter"
export default class extends Controller {
  connect () {
    if (this.element.nodeName !== 'FORM') {
      console.error('chaltron--filter stimulus controller must be referenced by a FORM tag')
    } else {
      this.#appendAction(this.element, 'turbo:morph@window->chaltron--filter#reconnect')
      Array.from(this.element.elements).forEach((input) => {
        this.#appendAction(input, 'chaltron--filter#submit')
      })
    }
  }

  reconnect () {
    this.connect()
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
