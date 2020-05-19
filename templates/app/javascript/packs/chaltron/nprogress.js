import NProgress from 'nprogress/nprogress.js';

document.addEventListener('turbolinks:request-start', function() {
  NProgress.start();
});
document.addEventListener('turbolinks:request-end', function() {
  NProgress.set(0.7);
});
document.addEventListener('turbolinks:load', function() {
  NProgress.done();
});
document.addEventListener('turbolinks:request-end turbolinks:before-cache', function() {
  NProgress.remove();
});

NProgress.configure({
  showSpinner: false,
});
