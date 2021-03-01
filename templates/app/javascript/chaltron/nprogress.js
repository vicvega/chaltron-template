import NProgress from 'nprogress/nprogress';

$(document)
  .on('page:fetch turbolinks:request-start', () => {
    NProgress.start();
  })
  .on('page:receive turbolinks:request-end', () => {
    NProgress.set(0.7);
  })
  .on('page:change turbolinks:load', () => {
    NProgress.done();
  })
  .on('page:restore turbolinks:request-end turbolinks:before-cache', () => {
    NProgress.remove();
  });

NProgress.configure({
  showSpinner: false,
});
