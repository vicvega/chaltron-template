document.addEventListener('turbo:load', () => {
  const flash = document.querySelectorAll('.flash-container div.alert');
  if (flash.length > 0) {
    flash.forEach((f) => f.addEventListener('click', () => f.remove()));
    setTimeout(() => flash.forEach((f) => f.remove()), 5000);
  }
});
