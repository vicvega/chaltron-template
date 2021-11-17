document.addEventListener('turbo:load', () => {
  const disappear = function f(e) {
    const element = e;
    element.style.opacity = '0';
  };
  // flash messages
  const flash = document.querySelectorAll('.flash-container div.alert');
  if (flash.length > 0) {
    flash.forEach((f) => f.addEventListener('click', () => disappear(f)));
    setTimeout(() => flash.forEach((f) => disappear(f)), 5000);
  }
});
