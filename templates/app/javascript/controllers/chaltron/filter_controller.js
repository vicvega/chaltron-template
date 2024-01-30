import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chaltron--form"
export default class extends Controller {
  static values = { frame: String };

  submit(_e) {
    const form = this.element;
    const formData = new FormData(form);

    const params = new URLSearchParams(formData);
    const url = `${form.action}?${params.toString()}`;

    Turbo.visit(url, { frame: this.frameValue });
  }
}
