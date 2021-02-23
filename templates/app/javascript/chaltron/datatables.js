import { Chaltron } from './chaltron';

$(document).on('turbolinks:load', function() {

  const defaultOptions = {
    destroy: true,
    autoWidth: false,
    responsive: true,
    stateSave: true,
    language: Chaltron.translate('datatables')
  };

  // generic datatable
  let container = $('table.datatable');
  if (container.length > 0) {
    const table = container.DataTable(defaultOptions);
    document.addEventListener('turbolinks:before-cache', function() {
      table.destroy();
    });
  }

  // users
  container = $('table#users');
  if (container.length > 0) {
    const user_table = container.DataTable(defaultOptions);
    document.addEventListener('turbolinks:before-cache', function() {
      user_table.destroy();
    });
  }

  // logs
  container = $('table#logs');
  if (container.length > 0) {
    const log_table = container.DataTable($.extend({}, defaultOptions, {
      processing: true,
      serverSide: true,
      ajax: container.data('source'),
      // default sorting: date (2nd column) desc
      order: [[1,'desc']],
      columns: [
        { data: 'severity', searchable: false },
        { data: 'date',     searchable: false },
        { data: 'message' },
        { data: 'category', searchable: false },
      ],
      columnDefs: [
        { orderSequence: ['desc', 'asc'], targets: [ 1 ] },
        { className: 'text-center', 'targets': [ 0 ] }
      ]
    }));
    document.addEventListener('turbolinks:before-cache', function() {
      log_table.destroy();
    });
  }

  // ldap_create
  container = $('table#ldap_create');
  if (container.length > 0) {
    const ldap_create_table = container.DataTable($.extend({}, defaultOptions, {
      stateSave: false,
      paging: false,
      // default sorting: uid (2nd column) asc
      order: [[1,'asc']],
      columnDefs: [
        { orderable: false, className: 'select-checkbox', targets: 0 }
      ]
    }));
    document.addEventListener('turbolinks:before-cache', function() {
      ldap_create_table.destroy();
    });
  }

});