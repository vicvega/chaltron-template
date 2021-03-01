class Chaltronz {
  constructor() {
    this.defaultLocale = 'en';
    this.locales = {
      en: {
        datatables: {
          sEmptyTable: 'No data available in table',
          sInfo: 'Showing _START_ to _END_ of _TOTAL_ entries',
          sInfoEmpty: 'Showing 0 to 0 of 0 entries',
          sInfoFiltered: '(filtered from _MAX_ total entries)',
          sInfoPostFix: '',
          sInfoThousands: ',',
          sLengthMenu: 'Show _MENU_ entries',
          sLoadingRecords: 'Loading...',
          sProcessing: 'Processing...',
          sSearch: 'Search:',
          sZeroRecords: 'No matching records found',
          oPaginate: {
            sFirst: 'First',
            sLast: 'Last',
            sNext: 'Next',
            sPrevious: 'Previous',
          },
          oAria: {
            sSortAscending: ': activate to sort column ascending',
            sSortDescending: ': activate to sort column descending',
          },
        },
      },
    };
  }

  get locale() { return $('body').data('locale') || this.defaultLocale; }

  translate(scope, loc) {
    const locale = loc || this.locale;
    if (!this.locales[locale] || !this.locales[locale][scope]) {
      return `missing translation ${scope} for ${locale}`;
    }
    return this.locales[locale][scope];
  }
}

const Chaltron = new Chaltronz();
export default Chaltron;
