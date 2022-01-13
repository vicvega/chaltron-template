import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { time: { type: Number, default: 5000 } };

  connect() {
    setTimeout(() => this.element.remove(), this.timeValue);
  }

  remove() {
    this.element.remove();
  }
}
