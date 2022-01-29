import { Controller } from '@hotwired/stimulus';
import * as bootstrap from 'bootstrap';

export default class extends Controller {
  connect() {
    new bootstrap.Tooltip(this.element);
  }
}
