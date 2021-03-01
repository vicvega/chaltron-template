$(document).on('turbolinks:load', () => {
  const container = $('table#ldap_create');
  if (container.length > 0) {
    const toggleButton = function f() {
      const any = $('input.entry:checkbox')
        .filter(function c() { return this.checked; })
        .length > 0;
      if (any) {
        $('#ldap_create_button').prop('disabled', false);
      } else {
        $('#ldap_create_button').prop('disabled', true);
      }
    };
    // checkboxes
    $('input.entry:checkbox:disabled').prop('indeterminate', true);
    $('input.entry:checkbox').off().on('click', () => {
      toggleButton();
    });
    $('#entry-check-all').off().on('click', function f() {
      $('input.entry:checkbox:enabled').prop('checked', this.checked);
      toggleButton();
    });

    $('form#ldap_create').on('submit', (event) => {
      const selectedEntry = $('input.entry:checkbox:checked')
        .map(function f() { return $(this).attr('data-entry'); })
        .get();
      if (selectedEntry.lenght === 0) {
        // should never be here!!
        event.preventDefault();
      } else {
        $.each(selectedEntry, (index, entry) => {
          $('<input/>', {
            name: 'uids[]',
            type: 'hidden',
            multiple: 'multiple',
            value: entry,
          }).appendTo('form#ldap_create');
        });
      }
    });
  }
});
