import chaltron from './chaltron';

$(document).on('turbolinks:load', () => {
  const defaultOptions = {
    destroy: true,
    autoWidth: false,
    responsive: true,
    stateSave: true,
    language: chaltron.translate('datatables'),
  };

  // generic datatable
  let container = $('table.datatable');
  if (container.length > 0) {
    const table = container.DataTable(defaultOptions);
    document.addEventListener('turbolinks:before-cache', () => {
      table.destroy();
    });
  }

  // users
  container = $('table#users');
  if (container.length > 0) {
    const userTable = container.DataTable(defaultOptions);
    document.addEventListener('turbolinks:before-cache', () => {
      userTable.destroy();
    });
  }

  // logs
  container = $('table#logs');
  if (container.length > 0) {
    const logTable = container.DataTable($.extend({}, defaultOptions, {
      processing: true,
      serverSide: true,
      ajax: container.data('source'),
      // default sorting: date (2nd column) desc
      order: [[1, 'desc']],
      columns: [
        { data: 'severity', searchable: false },
        { data: 'date', searchable: false },
        { data: 'message' },
        { data: 'category', searchable: false },
      ],
      columnDefs: [
        { orderSequence: ['desc', 'asc'], targets: [1] },
        { className: 'text-center', targets: [0] },
      ],
    }));
    document.addEventListener('turbolinks:before-cache', () => {
      logTable.destroy();
    });
  }

  // ldap_create
  container = $('table#ldap_create');
  if (container.length > 0) {
    const ldapCreateTable = container.DataTable($.extend({}, defaultOptions, {
      stateSave: false,
      paging: false,
      // default sorting: uid (2nd column) asc
      order: [[1, 'asc']],
      columnDefs: [
        { orderable: false, className: 'select-checkbox', targets: 0 },
      ],
    }));
    document.addEventListener('turbolinks:before-cache', () => {
      ldapCreateTable.destroy();
    });
  }
});
