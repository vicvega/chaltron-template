import { Controller } from '@hotwired/stimulus';
import * as bootstrap from 'bootstrap';

export default class extends Controller {
  connect() {
    const list = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    list.map((tooltip) => new bootstrap.Tooltip(tooltip));
  }
}
