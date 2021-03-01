$(document).on('turbolinks:load', () => {
  // flash messages
  const flash = $('.flash-container div.alert');
  if (flash.length > 0) {
    flash.click(function f() {
      $(this).fadeOut();
    });
    setTimeout(() => {
      flash.fadeOut();
    }, 5000);
  }
});
