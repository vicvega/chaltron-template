document.addEventListener('turbolinks:load', function() {

  // flash messages
  const flash = document.querySelectorAll('.flash-container div.alert');
  if (flash.length > 0) {
    flash.forEach(f => f.addEventListener('click', () => f.style.opacity = '0'));
    setTimeout(() => flash.forEach(f => f.style.opacity = '0'), 5000);
  }
});