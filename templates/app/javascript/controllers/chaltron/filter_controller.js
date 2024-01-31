import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Connects to data-controller="chaltron--form"
export default class extends Controller {
  static values = { frame: String }

  submit () {
    const form = this.element
    const formData = new window.FormData(form)

    const params = new URLSearchParams(formData)
    const url = `${form.action}?${params.toString()}`

    Turbo.visit(url, { frame: this.frameValue })
  }
}
