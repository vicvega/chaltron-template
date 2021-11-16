document.addEventListener("turbo:load", function() {
  // flash messages
  const flash = document.querySelectorAll('.flash-container div.alert');
  if (flash.length > 0) {
    flash.forEach(f => f.addEventListener('click', () => f.style.display = 'none'));
    setTimeout(() => flash.forEach(f => f.style.display = 'none'), 5000);
  }
});