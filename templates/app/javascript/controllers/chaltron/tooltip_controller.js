import { Controller } from '@hotwired/stimulus'
import 'bootstrap'

export default class extends Controller {
  connect () {
    this.tooltip = new bootstrap.Tooltip(this.element)
  }

  disconnect () {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
  }
}
