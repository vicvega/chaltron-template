import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';
import './channels';

import './chaltron';
import '@fortawesome/fontawesome-free/js/all';
import * as bootstrap from 'bootstrap';

window.bootstrap = bootstrap;

Rails.start();
Turbolinks.start();
ActiveStorage.start();

document.addEventListener('turbolinks:load', () => {
  const list = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  list.map((tooltip) => new bootstrap.Tooltip(tooltip));
});
