import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';
import './channels';

import '@fortawesome/fontawesome-free/js/all';
import * as bootstrap from 'bootstrap';
window.bootstrap = bootstrap;

import './chaltron';

Rails.start();
Turbolinks.start();
ActiveStorage.start();

document.addEventListener('turbolinks:load', function () {
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })
});