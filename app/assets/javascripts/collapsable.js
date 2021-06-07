[].forEach.call(document.querySelectorAll('[data-collapse-target]'), function (el) {
  var targetSelector = el.getAttribute('data-collapse-target');
  el.addEventListener('change', function (ev) {
    var triggerEl = ev.target;
    if (!triggerEl.classList.contains('collapse-trigger')) return;
    [].forEach.call(el.querySelectorAll(targetSelector), function (target) {
      if (triggerEl.checked) {
        target.classList.remove('hidden');
      } else {
        target.classList.add('hidden');
      }
    });
  });
});
