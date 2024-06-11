import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  connect () {
    this.tooltip = new bootstrap.Tooltip(this.element)
    let newAction = 'turbo:morph@window->chaltron--tooltip#reconnect'
    if (this.element.hasAttribute('data-action')) {
      newAction += ` ${this.element.dataset.action}`
    }
    this.element.setAttribute('data-action', newAction)
  }

  reconnect () {
    this.disconnect()
    this.connect()
  }

  disconnect () {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
  }
}
