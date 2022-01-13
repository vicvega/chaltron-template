import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button', 'checkAll', 'box'];

  toggleButton() {
    if (this.boxTargets.some((x) => x.checked)) {
      this.buttonTarget.removeAttribute('disabled');
    } else {
      this.buttonTarget.setAttribute('disabled', true);
    }
  }

  toggleCheckBoxes() {
    this.boxTargets.forEach((box) => {
      box.checked = this.checkAllTarget.checked;
    });
    this.toggleButton();
  }

  submit(event) {
    const selectedEntry = this.boxTargets.filter((el) => el.checked)
      .map((el) => el.dataset.entry);

    if (selectedEntry.lenght === 0) {
      // should never be here!!
      event.preventDefault();
    } else {
      selectedEntry.forEach((e) => {
        const input = document.createElement('input');
        input.setAttribute('name', 'uids[]');
        input.setAttribute('type', 'hidden');
        input.setAttribute('multiple', 'multiple');
        input.setAttribute('value', e);
        document.querySelector('form#ldap_create').appendChild(input);
      });
    }
  }
}
