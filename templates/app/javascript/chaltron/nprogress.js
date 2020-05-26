import NProgress from 'nprogress/nprogress.js';

$(document)
  .on('page:fetch turbolinks:request-start', function() {
    NProgress.start();
  })
  .on('page:receive turbolinks:request-end', function() {
    NProgress.set(0.7);
  })
  .on('page:change turbolinks:load', function() {
    NProgress.done();
  })
  .on('page:restore turbolinks:request-end turbolinks:before-cache', function() {
    NProgress.remove();
  });

NProgress.configure({
  showSpinner: false,
});
