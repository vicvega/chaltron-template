document.addEventListener('turbolinks:load', function() {
  if (document.querySelector('table#ldap_create')) {
    const toggleButton = function f() {
      const button = document.getElementById('ldap_create_button');
      if (document.querySelectorAll('tbody input:checked').length === 0) {
        button.setAttribute('disabled', 'disabled');
      } else {
        button.removeAttribute('disabled');
      }
    };

    // checkboxes
    const checkboxes = document.querySelectorAll("tbody input[type='checkbox']");
    checkboxes.forEach(f => f.addEventListener('click', () => {
      toggleButton();
    }));
    // check all
    document.getElementById('entry-check-all').addEventListener('click', (e) => {
      checkboxes.forEach(c => c.checked = e.target.checked);
      toggleButton();
    });

    document.querySelector('form#ldap_create').addEventListener('submit', (event) => {
      const selected = document.querySelectorAll('tbody input:checked');
      const selectedEntry = Array.prototype.map.call(selected ,function (el) {
        return el.getAttribute('data-entry');
      });
      if (selectedEntry.lenght === 0) {
        // should never be here!!
        event.preventDefault();
      } else {
        selectedEntry.forEach(e => {
          const input = document.createElement('input');
          input.setAttribute('name', 'uids[]');
          input.setAttribute('type', 'hidden');
          input.setAttribute('multiple', 'multiple');
          input.setAttribute('value', e);
          document.querySelector('form#ldap_create').appendChild(input);
        });
      }
    });
  }
});