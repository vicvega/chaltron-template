// Using UMD pattern from
// https://github.com/umdjs/umd#regular-module
// `returnExports.js` version
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define('Chaltron', function(){ return factory(root);});
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    module.exports = factory(root);
  } else {
    // Browser globals (root is window)
    root.Chaltron = factory(root);
  }
}(this, function(global) {
  'use strict';
  // Use previously defined object if exists in current scope
  var Chaltron = global && global.Chaltron || {};

  // Check if value is different than undefined and null;
  var isSet = function(value) {
    return typeof(value) !== 'undefined' && value !== null;
  };

  var DEFAULT_OPTIONS = {
    defaultLocale: 'en',
    locale: 'en',
    locales: {
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
    }
  };
  var key;
  for (key in DEFAULT_OPTIONS) if (!isSet(Chaltron[key])) {
    Chaltron[key] = DEFAULT_OPTIONS[key];
  }

  // Return current locale. If no locale has been set, then
  // the current locale will be the default locale.
  Chaltron.currentLocale = function() {
    return this.locale || this.defaultLocale;
  };

  Chaltron.missingTranslation = function(scope, locale) {
    return 'missing translation ' + scope + ' for ' + locale;
  };

  Chaltron.translate = function(scope, locale) {
    locale = locale || Chaltron.currentLocale();
    if (!isSet(Chaltron.locales[locale]) || !isSet(Chaltron.locales[locale][scope])) {
      return Chaltron.missingTranslation(scope, locale);
    }
    return Chaltron.locales[locale][scope];
  };

  // Just return a value to define the module export.
  return Chaltron;
}));
