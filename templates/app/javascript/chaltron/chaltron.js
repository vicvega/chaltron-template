class Chaltron {
  constructor(){
    this._defaultLocale = 'en';
    this._locales = {
      'en': {
        'datatables': {
          'sEmptyTable':     'No data available in table',
          'sInfo':           'Showing _START_ to _END_ of _TOTAL_ entries',
          'sInfoEmpty':      'Showing 0 to 0 of 0 entries',
          'sInfoFiltered':   '(filtered from _MAX_ total entries)',
          'sInfoPostFix':    '',
          'sInfoThousands':  ',',
          'sLengthMenu':     'Show _MENU_ entries',
          'sLoadingRecords': 'Loading...',
          'sProcessing':     'Processing...',
          'sSearch':         'Search:',
          'sZeroRecords':    'No matching records found',
          'oPaginate': {
            'sFirst':    'First',
            'sLast':     'Last',
            'sNext':     'Next',
            'sPrevious': 'Previous'
          },
          'oAria': {
            'sSortAscending':  ': activate to sort column ascending',
            'sSortDescending': ': activate to sort column descending'
          }
        }
      }
    };
  }

  get locale() { return $('body').data('locale') || this._defaultLocale; }
  get locales() { return this._locales; }
  set locales(l) { this._locales = l; }

  missingTranslation(scope, locale) {
    return 'missing translation ' + scope + ' for ' + locale;
  }

  translate(scope, locale) {
    locale = locale || this.locale;
    if (!this._isSet(this.locales[locale]) || !this._isSet(this.locales[locale][scope])) {
      return this.missingTranslation(scope, locale);
    }
    return this.locales[locale][scope];
  }

  // Check if value is different than undefined and null;
  _isSet(value) {
    return typeof(value) !== 'undefined' && value !== null;
  }

}
export let chaltron = new Chaltron();
